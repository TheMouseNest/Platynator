---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.NameplateMixin = {}
function addonTable.Display.NameplateMixin:OnLoad()
  self:SetFlattensRenderLayers(true)

  self:SetIgnoreParentScale(true)

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

  if not addonTable.Constants.IsMidnight then
    self.AurasManager = addonTable.Utilities.InitFrameWithMixin(self, addonTable.Display.AurasForNameplateMixin)
    self.AurasPool = CreateFramePool("Frame", self, "PlatynatorNameplateBuffButtonTemplate", nil, false, function(frame)
      frame.Cooldown:SetCountdownFont("PlatynatorNameplateCooldownFont")
      frame.Cooldown:SetCountdownAbbrevThreshold(20)
    end)

    local function GetCallback(frame)
      return function(data)
        local keys = GetKeysArray(data)
        table.sort(keys)
        if frame.items then
          for _, item in ipairs(frame.items) do
            self.AurasPool:Release(item)
          end
          frame.items = nil
        end

        if not frame:GetParent():IsShown() then
          return
        end

        local currentX = 0
        local currentY = 0
        local xOffset = 0
        local yOffset = 0
        local details = frame:GetParent().details
        if details.direction == "LEFT" then
          xOffset = -22
        elseif details.direction == "RIGHT" then
          xOffset = 22
        else -- CENTER
          xOffset = 22
          currentX = #keys * 22 / 2
        end
        local anchor = details.anchor[1]
        if type(anchor) ~= "string" then
          anchor = "CENTER"
        end

        frame.items = {}
        for _, auraInstanceID in ipairs(keys) do
          local aura = data[auraInstanceID]
          local buff = self.AurasPool:Acquire()
          table.insert(frame.items, buff)
          buff:SetParent(frame)
          buff.auraInstanceID = auraInstanceID
          buff.isBuff = aura.isHelpful;
          buff.spellID = aura.spellId;

          buff.Icon:SetTexture(aura.icon);
          if (aura.applications > 1) then
            buff.CountFrame.Count:SetText(aura.applications);
            buff.CountFrame.Count:Show();
          else
            buff.CountFrame.Count:Hide();
          end
          buff.Cooldown:SetHideCountdownNumbers(not details.showCountdown)
          CooldownFrame_Set(buff.Cooldown, aura.expirationTime - aura.duration, aura.duration, aura.duration > 0, true);

          buff:Show();

          buff:SetPoint(anchor, currentX, currentY)
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
  end

  self:SetScript("OnEvent", self.OnEvent)

  self:SetSize(10, 10)
  self:SetPoint("CENTER")

  self.casting = false
end

function addonTable.Display.NameplateMixin:InitializeWidgets(design)
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
    self.DebuffDisplay:SetFrameLevel(800 + 1)
    self.DebuffDisplay.details = designInfo.debuffs
    if self.DebuffDisplay.Wrapped then
      self.DebuffDisplay.Wrapped:ClearAllPoints()
      self.DebuffDisplay.Wrapped:SetPoint(designInfo.debuffs.anchor[1] or "CENTER")
      self.DebuffDisplay.Wrapped:SetScale(designInfo.debuffs.scale)
    end
    self.DebuffDisplay:SetSize(defaultSize * designInfo.debuffs.scale, defaultSize * designInfo.debuffs.scale)
    addonTable.Display.ApplyAnchor(self.DebuffDisplay, designInfo.debuffs.anchor)
  end
  if designInfo.buffs then
    self.BuffDisplay.enabled = true
    self.BuffDisplay:ClearAllPoints()
    self.BuffDisplay:SetFrameLevel(800 + 2)
    self.BuffDisplay.details = designInfo.buffs
    if self.BuffDisplay.Wrapped then
      self.BuffDisplay.Wrapped:ClearAllPoints()
      self.BuffDisplay.Wrapped:SetScale(designInfo.buffs.scale)
      self.BuffDisplay.Wrapped:SetPoint(designInfo.buffs.anchor[1] or "CENTER")
    end
    self.BuffDisplay:SetSize(defaultSize * designInfo.buffs.scale, defaultSize * designInfo.buffs.scale)
    addonTable.Display.ApplyAnchor(self.BuffDisplay, designInfo.buffs.anchor)
  end
  if designInfo.crowdControl then
    self.CrowdControlDisplay.enabled = true
    self.CrowdControlDisplay:ClearAllPoints()
    self.CrowdControlDisplay:SetFrameLevel(800 + 3)
    self.CrowdControlDisplay.details = designInfo.crowdControl
    if self.CrowdControlDisplay.Wrapped then
      self.CrowdControlDisplay.Wrapped:ClearAllPoints()
      self.CrowdControlDisplay.Wrapped:SetScale(designInfo.crowdControl.scale)
      self.CrowdControlDisplay.Wrapped:SetPoint(designInfo.crowdControl.anchor[1] or "CENTER")
    end
    self.CrowdControlDisplay:SetSize(defaultSize * designInfo.crowdControl.scale, defaultSize * designInfo.crowdControl.scale)
    addonTable.Display.ApplyAnchor(self.CrowdControlDisplay, designInfo.crowdControl.anchor)
  end
end

function addonTable.Display.NameplateMixin:Install(nameplate)
  self:SetParent(nameplate)
  self:Show()
  self:SetPoint("CENTER")
end

function addonTable.Display.NameplateMixin:SetUnit(unit)
  self.SoftTargetIcon:Hide()
  self.interactUnit = nil
  if unit and (not UnitNameplateShowsWidgetsOnly or not UnitNameplateShowsWidgetsOnly(unit)) and (not UnitIsUnit(unit, "softinteract") or UnitIsUnit(unit, "target")) then
    self.unit = unit
    self:Show()
    if addonTable.Constants.IsMidnight then
      C_NamePlateManager.SetNamePlateSimplified(self.unit, false)
    end

    for _, w in ipairs(self.widgets) do
      w:Show()
      w:SetUnit(self.unit)
      if w.ApplyTarget then
        w:ApplyTarget()
      end
    end

    self.BuffDisplay:SetShown(self.BuffDisplay.enabled)
    self.DebuffDisplay:SetShown(self.DebuffDisplay.enabled)
    self.CrowdControlDisplay:SetShown(self.CrowdControlDisplay.enabled)

    if self.AurasManager then
      self.AurasManager:SetUnit(self.unit)
    end

    if UnitCanAttack("player", self.unit) then
      self:RegisterUnitEvent("UNIT_SPELLCAST_START", self.unit)
      self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", self.unit)
      self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", self.unit)
      self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", self.unit)
    end
  else
    self.unit = nil
    for _, w in ipairs(self.widgets) do
      w:SetUnit(nil)
      w:Hide()
    end

    self.BuffDisplay:Hide()
    self.DebuffDisplay:Hide()
    self.CrowdControlDisplay:Hide()

    if self.AurasManager then
      self.AurasManager:SetUnit()
    end

    self:UnregisterAllEvents()
    self.casting = false
  end

  self.interactUnit = unit

  self:UpdateVisual()
end

function addonTable.Display.NameplateMixin:UpdateCastingState()
  local _, t1 = UnitCastingInfo(self.unit)
  local _, t2 = UnitChannelInfo(self.unit)
  self.casting = type(t1) ~= "nil" or type(t2) ~= "nil"
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

function addonTable.Display.NameplateMixin:UpdateVisual()
  self:SetScale(addonTable.Config.Get(addonTable.Config.Options.GLOBAL_SCALE) * UIParent:GetEffectiveScale())

  if not self.unit then
    return
  end

  local scale = 1
  local alpha = 1
  if UnitIsUnit("target", self.unit) then
    local change = addonTable.Config.Get(addonTable.Config.Options.TARGET_BEHAVIOUR)
    if change == "enlarge" then
      scale = 1.25
    end
  elseif self.casting then
    local change = addonTable.Config.Get(addonTable.Config.Options.TARGET_BEHAVIOUR)
    if change == "enlarge" then
      scale = 1.1
    end
  else
    local change = addonTable.Config.Get(addonTable.Config.Options.NOT_TARGET_BEHAVIOUR)
    if change == "fade" then
      alpha = 0.5
    end
  end
  self:SetScale(scale * addonTable.Config.Get(addonTable.Config.Options.GLOBAL_SCALE) * UIParent:GetEffectiveScale())
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
