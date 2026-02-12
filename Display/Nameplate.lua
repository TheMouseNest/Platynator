---@class addonTablePlatynator
local addonTable = select(2, ...)

local LSM = LibStub("LibSharedMedia-3.0")

local pandemicCurve
local pandemicPercentage = 0.3
local dispelCurve
if C_CurveUtil then
  pandemicCurve = C_CurveUtil.CreateCurve()
  pandemicCurve:SetType(Enum.LuaCurveType.Step)
  pandemicCurve:AddPoint(0, 1)
  pandemicCurve:AddPoint(pandemicPercentage, 0)

  dispelCurve = C_CurveUtil.CreateColorCurve()
  dispelCurve:SetType(Enum.LuaCurveType.Step)
  dispelCurve:AddPoint(0, CreateColor(0, 0, 0, 0))
  dispelCurve:AddPoint(9, CreateColor(0, 0, 0, 1))
  dispelCurve:AddPoint(10, CreateColor(0, 0, 0, 0))
end

addonTable.Display.NameplateMixin = {}
function addonTable.Display.NameplateMixin:OnLoad()
  self:SetFlattensRenderLayers(true)
  self:SetCollapsesLayout(true)

  self.widgets = {}

  self.SoftTargetIcon = self:CreateTexture(nil, "OVERLAY")
  self.SoftTargetIcon:SetSize(34, 34)
  self.SoftTargetIcon:SetPoint("BOTTOM", self, "TOP", 0, 24)
  self.SoftTargetIcon:Hide()

  self.BuffDisplay = CreateFrame("Frame", nil, self)
  self.BuffDisplay:SetSize(10, 10)
  self.DebuffDisplay = CreateFrame("Frame", nil, self)
  self.DebuffDisplay:SetSize(10, 10)
  self.CrowdControlDisplay = CreateFrame("Frame", nil, self)
  self.CrowdControlDisplay:SetSize(10, 10)

  self.AurasManager = addonTable.Utilities.InitFrameWithMixin(self, addonTable.Display.AurasManagerMixin)
  local borderAsset = LSM:Fetch("nineslice", "Platy: 1px")
  local dispelAsset = LSM:Fetch("nineslice", "Platy: 4px")
  self.AurasPool = CreateFramePool("Frame", self, "PlatynatorNameplateBuffButtonTemplate", nil, false, function(frame)
    frame.Border = frame:CreateTexture(nil, "OVERLAY")
    frame.Border:SetAllPoints(true)
    frame.Border:SetScale(borderAsset.scaleModifier)
    frame.Border:SetTexture(borderAsset.file)
    frame.Border:SetTextureSliceMargins(borderAsset.margins.left, borderAsset.margins.top, borderAsset.margins.right, borderAsset.margins.bottom)
    frame.Border:SetVertexColor(0, 0, 0)
    frame.Cooldown:SetCountdownAbbrevThreshold(20)
    frame.Cooldown.Text = frame.Cooldown:GetRegions()
    frame.Pandemic = CreateFrame("Frame", nil, frame)
    frame.Pandemic:SetAllPoints()
    frame.Pandemic.Animation = frame.Pandemic:CreateAnimationGroup()
    frame.Pandemic:SetFrameLevel(frame.Cooldown:GetFrameLevel() + 5)
    do
      frame.Pandemic.Top = frame.Pandemic:CreateTexture()
      frame.Pandemic.Top:SetPoint("TOPLEFT")
      frame.Pandemic.Top:SetPoint("TOPRIGHT")
      frame.Pandemic.Top:SetTexture("Interface/AddOns/Platynator/Assets/Special/pandemic.png")
      frame.Pandemic.Bottom = frame.Pandemic:CreateTexture()
      frame.Pandemic.Bottom:SetPoint("BOTTOMLEFT")
      frame.Pandemic.Bottom:SetPoint("BOTTOMRIGHT")
      frame.Pandemic.Bottom:SetTexture("Interface/AddOns/Platynator/Assets/Special/pandemic.png")
      frame.Pandemic.Bottom:SetRotation(math.pi)
      frame.Pandemic.Left = frame.Pandemic:CreateTexture()
      frame.Pandemic.Left:SetPoint("TOPLEFT")
      frame.Pandemic.Left:SetPoint("BOTTOMLEFT")
      frame.Pandemic.Left:SetTexture("Interface/AddOns/Platynator/Assets/Special/pandemic-90.png")
      frame.Pandemic.Right = frame.Pandemic:CreateTexture()
      frame.Pandemic.Right:SetPoint("TOPRIGHT")
      frame.Pandemic.Right:SetPoint("BOTTOMRIGHT")
      frame.Pandemic.Right:SetTexture("Interface/AddOns/Platynator/Assets/Special/pandemic-90.png")
      frame.Pandemic.Right:SetRotation(math.pi)
      local fb = frame.Pandemic.Animation:CreateAnimation("Flipbook")
      fb:SetFlipBookColumns(1)
      fb:SetFlipBookRows(11)
      fb:SetDuration(0.5)
      fb:SetTarget(frame.Pandemic.Top)
      local fb = frame.Pandemic.Animation:CreateAnimation("Flipbook")
      fb:SetFlipBookColumns(1)
      fb:SetFlipBookRows(11)
      fb:SetDuration(0.5)
      fb:SetTarget(frame.Pandemic.Bottom)
      local fb = frame.Pandemic.Animation:CreateAnimation("Flipbook")
      fb:SetFlipBookColumns(11)
      fb:SetFlipBookRows(1)
      fb:SetDuration(0.5)
      fb:SetTarget(frame.Pandemic.Left)
      local fb = frame.Pandemic.Animation:CreateAnimation("Flipbook")
      fb:SetFlipBookColumns(11)
      fb:SetFlipBookRows(1)
      fb:SetDuration(0.5)
      fb:SetTarget(frame.Pandemic.Right)
      frame.Pandemic.Animation:SetLooping("REPEAT")
      frame.Pandemic.Animation:Play()
    end
    frame.Dispel = CreateFrame("Frame", nil, frame)
    frame.Dispel:SetAllPoints()
    do
      local dispelTexture = frame.Dispel:CreateTexture()
      dispelTexture:SetAllPoints()
      dispelTexture:SetScale(dispelAsset.scaleModifier)
      dispelTexture:SetTexture(dispelAsset.file)
      dispelTexture:SetTextureSliceMargins(dispelAsset.margins.left, dispelAsset.margins.top, dispelAsset.margins.right, dispelAsset.margins.bottom)
      dispelTexture:SetVertexColor(1, 0, 0)
    end
    frame:SetScript("OnEnter", function()
      GameTooltip_SetDefaultAnchor(GameTooltip, frame)
      if GameTooltip.SetUnitAuraByAuraInstanceID then
        GameTooltip:SetUnitAuraByAuraInstanceID(self.unit, frame.auraInstanceID)
      elseif frame.auraIndex then
        if frame.auraIndex ~= -1 then
          GameTooltip:SetUnitAura(self.unit, frame.auraIndex, frame.auraFilter)
          GameTooltip:Show()
        end
      else
        local index = 1
        while true do
          local aura = C_UnitAuras.GetAuraDataByIndex(self.unit, index, frame.auraFilter)
          if not aura then
            break
          end
          if aura.auraInstanceID == frame.auraInstanceID then
            frame.auraIndex = index
            break
          end
          index = index + 1
        end

        if frame.auraIndex then
          GameTooltip:SetUnitAura(self.unit, frame.auraIndex, frame.auraFilter)
          GameTooltip:Show()
        else
          frame.auraIndex = -1
        end
      end
    end)
    frame:SetScript("OnLeave", function()
      GameTooltip:Hide()
    end)
  end)

  local function GetCallback(frame)
    return function(data, auraFilter)
      if frame.items then
        for _, item in ipairs(frame.items) do
          self.AurasPool:Release(item)
        end
        frame.items = nil
      end

      if not frame:GetParent():IsShown() then
        return
      end

      local pandemicDim = PixelUtil.ConvertPixelsToUIForRegion(1, frame)

      local step = PixelUtil.ConvertPixelsToUIForRegion(22, frame)
      local currentX = 0
      local currentY = 0
      local xOffset = 0
      local yOffset = 0
      local details = frame:GetParent().details
      if details.direction == "LEFT" then
        xOffset = -step
      elseif details.direction == "RIGHT" then
        xOffset = step
      else -- CENTER
        xOffset = step
        currentX = #keys * step / 2
      end
      local anchor = details.anchor[1]
      if type(anchor) ~= "string" then
        anchor = "CENTER"
      end

      local sootheAvailable = addonTable.Display.Utilities.GetSootheAvailable()

      frame.items = {}
      local texBase = 0.95 * (1 - details.height) / 2
      for _, auraInstanceID in ipairs(data) do
        local aura = self.AurasManager:GetByInstanceID(auraInstanceID)
        local auraFrame = self.AurasPool:Acquire()
        table.insert(frame.items, auraFrame)
        auraFrame:SetParent(frame)

        auraFrame.auraInstanceID = auraInstanceID
        auraFrame.auraIndex = nil
        auraFrame.auraFilter = auraFilter
        auraFrame.durationSecret = aura.durationSecret
        if not C_Secrets then
          auraFrame.duration = aura.duration
          auraFrame.expirationTime = aura.expirationTime
        end

        auraFrame.Pandemic:SetShown(details.showPandemic)
        if details.showPandemic then
          auraFrame.Pandemic.Top:SetHeight(pandemicDim)
          auraFrame.Pandemic.Bottom:SetHeight(pandemicDim)
          auraFrame.Pandemic.Left:SetWidth(pandemicDim)
          auraFrame.Pandemic.Right:SetWidth(pandemicDim)
        end

        auraFrame.Dispel:SetShown(sootheAvailable and details.showDispel.enrage)

        auraFrame.Icon:SetTexture(aura.icon);
        auraFrame.CountFrame.Count:SetText(aura.applicationsString)
        auraFrame.CountFrame.Count:SetFontObject(addonTable.CurrentFont)
        auraFrame.CountFrame.Count:SetTextScale(11/12 * details.textScale)
        auraFrame.CountFrame.Count:Show();

        auraFrame.Cooldown:SetHideCountdownNumbers(not details.showCountdown)

        if details.showCountdown then
          auraFrame.Cooldown.Text:SetFontObject(addonTable.CurrentFont)
          auraFrame.Cooldown.Text:SetTextScale(14/12 * details.textScale)
        end

        PixelUtil.SetSize(auraFrame, 20, 20 * details.height)
        PixelUtil.SetSize(auraFrame.Border, 20, 20 * details.height)
        PixelUtil.SetSize(auraFrame.Icon, 20, 20 * details.height)
        auraFrame.Icon:SetTexCoord(0.05, 0.95, 0.05 + texBase, 0.95 - texBase)

        if aura.durationSecret then
          auraFrame.Cooldown:SetCooldownFromDurationObject(aura.durationSecret)
          if details.showPandemic then
            auraFrame.Pandemic:SetAlpha(C_CurveUtil.EvaluateColorValueFromBoolean(auraFrame.durationSecret:IsZero(), 0, auraFrame.durationSecret:EvaluateRemainingPercent(pandemicCurve)))
          end
          if sootheAvailable and details.showDispel.enrage then
            auraFrame.Dispel:SetAlpha(C_UnitAuras.GetAuraDispelTypeColor(self.unit, aura.auraInstanceID, dispelCurve).a)
          end
        elseif auraFrame.expirationTime then
          CooldownFrame_Set(auraFrame.Cooldown, aura.expirationTime - aura.duration, aura.duration, aura.duration > 0, true);
          if details.showPandemic then
            auraFrame.Pandemic:SetAlpha(aura.duration > 0 and aura.expirationTime - GetTime() <= aura.duration * pandemicPercentage and 1 or 0)
          end
          if details.showDispel.enrage then
            auraFrame.Dispel:SetAlpha(aura.dispelName == "" and 1 or 0)
          end
        else
          auraFrame.Cooldown:Clear()
          auraFrame.Pandemic:SetAlpha(0)
          auraFrame.Dispel:SetAlpha(0)
        end

        auraFrame:Show();

        PixelUtil.SetPoint(auraFrame, anchor, frame, anchor, currentX, currentY)
        currentX = currentX + xOffset
      end
    end
  end

  self.BuffDisplay.Wrapped = CreateFrame("Frame", nil, self.BuffDisplay)
  self.BuffDisplay.Wrapped:SetSize(10, 10)
  self.DebuffDisplay.Wrapped = CreateFrame("Frame", nil, self.DebuffDisplay)
  self.DebuffDisplay.Wrapped:SetSize(10, 10)
  self.CrowdControlDisplay.Wrapped = CreateFrame("Frame", nil, self.CrowdControlDisplay)
  self.CrowdControlDisplay.Wrapped:SetSize(10, 10)

  self.DebuffDisplay:Hide()
  self.BuffDisplay:Hide()
  self.CrowdControlDisplay:Hide()

  self.AurasManager:SetDebuffsCallback(GetCallback(self.DebuffDisplay.Wrapped))
  self.AurasManager:SetBuffsCallback(GetCallback(self.BuffDisplay.Wrapped))
  self.AurasManager:SetCrowdControlCallback(GetCallback(self.CrowdControlDisplay.Wrapped))

  self:SetScript("OnEvent", self.OnEvent)

  self:SetSize(10, 10)

  self.casting = false

  self.sizeChangeCount = -1
end

function addonTable.Display.NameplateMixin:OnSizeChanged()
  -- Optimisation to avoid recalculating anchors/sizes while nameplate scales up/down
  self.sizeChangeCount = 0
  self:SetScript("OnUpdate", function()
    self.sizeChangeCount = self.sizeChangeCount + 1
    if self.sizeChangeCount >= 2 then
      self:ApplyPixelPerfectSizing()
      self:SetScript("OnUpdate", nil)
    end
  end)
end

-- Avoid pixel-perfecting the alignment if the scale hasn't changed, or its
-- shrinking cause the nameplate is disappearing
function addonTable.Display.NameplateMixin:ShouldNotSize()
  -- Detect sizing down, which we should ignore
  if not self.unit or not self:IsVisible() then
    return true
  end
  local scale = self:GetEffectiveScale()
  return scale == self.lastScale or scale < self.offsetScale
end

function addonTable.Display.NameplateMixin:ApplyPixelPerfectSizing()
  if self:ShouldNotSize() then
    return
  end
  for _, w in ipairs(self.widgets) do
    w:ApplyAnchor()
    w:ApplySize()
  end
  self.lastScale = self:GetEffectiveScale()
end

function addonTable.Display.NameplateMixin:InitializeWidgets(design, scale)
  self.offsetScale = (scale or 1) * UIParent:GetEffectiveScale() * addonTable.Config.Get(addonTable.Config.Options.GLOBAL_SCALE)
  self.scale = design.scale

  self.lastScale = self:GetEffectiveScale()

  self.unit = nil
  self:UpdateVisual()

  if self.widgets then
    addonTable.Display.ReleaseWidgets(self.widgets)
    self.widgets = nil
  end
  self.widgets = addonTable.Display.GetWidgets(design, self)

  local auras = design.auras
  local designInfo = {}
  for _, a in ipairs(auras) do
    designInfo[a.kind] = a
  end
  self.DebuffDisplay.enabled = false
  self.BuffDisplay.enabled = false
  self.CrowdControlDisplay.enabled = false
  local defaultSize = 20
  if designInfo.debuffs then
    self.DebuffDisplay.enabled = true
    self.DebuffDisplay:ClearAllPoints()
    self.DebuffDisplay:SetFrameStrata("MEDIUM")
    self.DebuffDisplay:SetFrameLevel(800 + 1)
    self.DebuffDisplay.details = designInfo.debuffs
    if self.DebuffDisplay.Wrapped then
      self.DebuffDisplay.Wrapped:ClearAllPoints()
      self.DebuffDisplay.Wrapped:SetPoint(designInfo.debuffs.anchor[1] or "CENTER")
      self.DebuffDisplay.Wrapped:SetScale(designInfo.debuffs.scale)
    end
    PixelUtil.SetSize(self.DebuffDisplay, defaultSize * designInfo.debuffs.scale, defaultSize * designInfo.debuffs.scale)
    addonTable.Display.ApplyAnchor(self.DebuffDisplay, designInfo.debuffs.anchor)
  end
  if designInfo.buffs then
    self.BuffDisplay.enabled = true
    self.BuffDisplay:ClearAllPoints()
    self.BuffDisplay:SetFrameStrata("MEDIUM")
    self.BuffDisplay:SetFrameLevel(800 + 2)
    self.BuffDisplay.details = designInfo.buffs
    if self.BuffDisplay.Wrapped then
      self.BuffDisplay.Wrapped:ClearAllPoints()
      self.BuffDisplay.Wrapped:SetScale(designInfo.buffs.scale)
      self.BuffDisplay.Wrapped:SetPoint(designInfo.buffs.anchor[1] or "CENTER")
    end
    PixelUtil.SetSize(self.BuffDisplay, defaultSize * designInfo.buffs.scale, defaultSize * designInfo.buffs.scale)
    addonTable.Display.ApplyAnchor(self.BuffDisplay, designInfo.buffs.anchor)
  end
  if designInfo.crowdControl then
    self.CrowdControlDisplay.enabled = true
    self.CrowdControlDisplay:ClearAllPoints()
    self.CrowdControlDisplay:SetFrameStrata("MEDIUM")
    self.CrowdControlDisplay:SetFrameLevel(800 + 3)
    self.CrowdControlDisplay.details = designInfo.crowdControl
    if self.CrowdControlDisplay.Wrapped then
      self.CrowdControlDisplay.Wrapped:ClearAllPoints()
      self.CrowdControlDisplay.Wrapped:SetScale(designInfo.crowdControl.scale)
      self.CrowdControlDisplay.Wrapped:SetPoint(designInfo.crowdControl.anchor[1] or "CENTER")
    end
    PixelUtil.SetSize(self.CrowdControlDisplay, defaultSize * designInfo.crowdControl.scale, defaultSize * designInfo.crowdControl.scale)
    addonTable.Display.ApplyAnchor(self.CrowdControlDisplay, designInfo.crowdControl.anchor)
  end

  self.AurasManager:PostInit(designInfo.buffs, designInfo.debuffs, designInfo.crowdControl)

  if self:GetScript("OnSizeChanged") == nil then
    self:SetScript("OnSizeChanged", self.OnSizeChanged)
  end
  self:SetScript("OnUpdate", nil)
end

function addonTable.Display.NameplateMixin:Install(nameplate)
  self:Show()
  self:SetFrameStrata("BACKGROUND")
  self:SetPoint("CENTER", nameplate)
  self:SetSize(10, 10)

  -- We force a sizing immediately to avoid 0 size widgets breaking the textures from the Blizz animations
  self:ApplyPixelPerfectSizing()
  self:SetScript("OnUpdate", nil)
end

function addonTable.Display.NameplateMixin:SetUnit(unit)
  self.SoftTargetIcon:Hide()

  self.interactUnit = unit
  if unit and (not UnitNameplateShowsWidgetsOnly or not UnitNameplateShowsWidgetsOnly(unit)) and not UnitIsGameObject(unit) then
    self.unit = unit
    self:Show()

    for _, w in ipairs(self.widgets) do
      w:Show()
      w:SetUnit(self.unit)
      if w.ApplyTarget then
        w:ApplyTarget()
      end
      if w.ApplyMouseover then
        w:ApplyMouseover()
      end
      if w.ApplyFocus then
        w:ApplyFocus()
      end
      if addonTable.API.TextOverrides.isActive and w.ApplyTextOverride then
        w:ApplyTextOverride()
      end
    end

    self.BuffDisplay:SetShown(self.BuffDisplay.enabled)
    self.DebuffDisplay:SetShown(self.DebuffDisplay.enabled)
    self.CrowdControlDisplay:SetShown(self.CrowdControlDisplay.enabled)

    self.AurasManager:SetUnit(self.unit)

    if UnitCanAttack("player", self.unit) then
      self:RegisterUnitEvent("UNIT_SPELLCAST_START", self.unit)
      self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", self.unit)
      self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", self.unit)
      self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", self.unit)
    end

    addonTable.CallbackRegistry:RegisterCallback("TextOverrideUpdated", function(_, unit)
      if unit ~= self.unit then
        return
      end
      for _, w in ipairs(self.widgets) do
        if w.ApplyTextOverride then
          w:ApplyTextOverride()
        end
      end
    end, self)
  else
    self.unit = nil
    for _, w in ipairs(self.widgets) do
      w:SetUnit(nil)
      w:Hide()
    end

    self.BuffDisplay:Hide()
    self.DebuffDisplay:Hide()
    self.CrowdControlDisplay:Hide()

    self.AurasManager:SetUnit()

    self:UnregisterAllEvents()
    self.casting = false

    addonTable.CallbackRegistry:UnregisterCallback("TextOverrideUpdated", self)
  end

  self:UpdateVisual()
end

function addonTable.Display.NameplateMixin:UpdateCastingState()
  local _, cast = UnitCastingInfo(self.unit)
  local _, channel = UnitChannelInfo(self.unit)
  self.casting = cast ~= nil or channel ~= nil
end

function addonTable.Display.NameplateMixin:UpdateForTarget()
  if self.unit then
    for _, w in ipairs(self.widgets) do
      if w.ApplyTarget then
        w:ApplyTarget()
      end
    end
  end

  self:UpdateVisual()
end

function addonTable.Display.NameplateMixin:UpdateForMouseover()
  if self.unit then
    for _, w in ipairs(self.widgets) do
      if w.ApplyMouseover then
        w:ApplyMouseover()
      end
    end
  end

  self:UpdateVisual()
end

function addonTable.Display.NameplateMixin:UpdateForFocus()
  if self.unit then
    for _, w in ipairs(self.widgets) do
      if w.ApplyFocus then
        w:ApplyFocus()
      end
    end
  end

  self:UpdateVisual()
end

function addonTable.Display.NameplateMixin:UpdateVisual()
  local scaleMod = addonTable.Constants.IsRetail and 1 or UIParent:GetEffectiveScale()
  if not self.unit then
    self:SetAlpha(1)
    self:SetScale(self.scale * addonTable.Config.Get(addonTable.Config.Options.GLOBAL_SCALE) * scaleMod)
    return
  end

  local scale = 1
  local alpha = 1
  local isTarget = UnitIsUnit("target", self.unit) or UnitIsUnit("softenemy", self.unit) or UnitIsUnit("softfriend", self.unit)
  if isTarget then
    -- Nothing to do as its parented to the nameplate, as that will handle scaling for us
  elseif self.casting then
    scale = scale * addonTable.Config.Get(addonTable.Config.Options.CAST_SCALE)
    alpha = alpha * addonTable.Config.Get(addonTable.Config.Options.CAST_ALPHA)
  else
    alpha = alpha * addonTable.Config.Get(addonTable.Config.Options.NOT_TARGET_ALPHA)
  end
  self:SetScale(self.scale * scale * addonTable.Config.Get(addonTable.Config.Options.GLOBAL_SCALE) * scaleMod)
  self:SetAlpha(alpha)
end

function addonTable.Display.NameplateMixin:UpdateSoftInteract()
  -- From Blizzard code, modified
  local doEnemyIcon = GetCVarBool("SoftTargetIconEnemy")
  local doFriendIcon = GetCVarBool("SoftTargetIconFriend")
  local doInteractIcon = GetCVarBool("SoftTargetIconInteract")
  local hasCursorTexture = false
  if ((doEnemyIcon and UnitIsUnit(self.interactUnit, "softenemy")) or
    (doFriendIcon and UnitIsUnit(self.interactUnit, "softfriend")) or
    (doInteractIcon and UnitIsUnit(self.interactUnit, "softinteract"))
    ) then
    hasCursorTexture = SetUnitCursorTexture(self.SoftTargetIcon, self.interactUnit)
  end
  self.SoftTargetIcon:SetShown(hasCursorTexture)
end

function addonTable.Display.NameplateMixin:OnEvent(eventName)
  self:UpdateCastingState()
  self:UpdateVisual()
end

function addonTable.Display.NameplateMixin:UpdateAurasForPandemic()
  local time = GetTime()
  if self.DebuffDisplay.details and self.DebuffDisplay.details.showPandemic and self.DebuffDisplay.Wrapped.items then
    for _, item in ipairs(self.DebuffDisplay.Wrapped.items) do
      if item.durationSecret then
        item.Pandemic:SetAlpha(C_CurveUtil.EvaluateColorValueFromBoolean(item.durationSecret:IsZero(), 0, item.durationSecret:EvaluateRemainingPercent(pandemicCurve)))
      elseif item.expirationTime then
        item.Pandemic:SetAlpha(item.duration > 0 and item.expirationTime - time <= item.duration * pandemicPercentage and 1 or 0)
      end
    end
  end
end
