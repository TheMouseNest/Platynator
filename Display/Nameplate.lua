---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.NameplateMixin = {}
function addonTable.Display.NameplateMixin:OnLoad()
  self:SetFlattensRenderLayers(true)

  local style = addonTable.Config.Get(addonTable.Config.Options.DESIGN)

  self:SetIgnoreParentScale(true)

  self.SoftTargetIcon = self:CreateTexture(nil, "OVERLAY")
  self.SoftTargetIcon:SetSize(24, 24)
  self.SoftTargetIcon:SetPoint("BOTTOM", self, "TOP", 0, -8)
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
        local currentX = 0
        local currentY = 0
        local xOffset = 0
        local yOffset = 0
        if frame.details.anchor[1]:match("RIGHT") then
          xOffset = -22
        elseif frame.details.anchor[1]:match("LEFT") then
          xOffset = 22
        else -- CENTER
          xOffset = 22
          currentX = #keys * 22 / 2
        end

        frame.items = {}
        for _, auraInstanceID in ipairs(keys) do
          local aura = data[auraInstanceID]
          local buff = self.AurasPool:Acquire()
          buff:SetScale(frame.details.scale)
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
          buff.Cooldown:SetHideCountdownNumbers(not frame.details.showCountdown)
          CooldownFrame_Set(buff.Cooldown, aura.expirationTime - aura.duration, aura.duration, aura.duration > 0, true);

          buff:Show();

          buff:SetPoint(frame.details.anchor[1], currentX, currentY)
          currentX = currentX + xOffset
        end
      end
    end

    self.AurasManager:SetDebuffsCallback(GetCallback(self.DebuffDisplay))
    self.AurasManager:SetBuffsCallback(GetCallback(self.BuffDisplay))
    self.AurasManager:SetCrowdControlCallback(GetCallback(self.CrowdControlDisplay))
  end

  self:InitializeWidgets()

  self:SetScript("OnEvent", self.OnEvent)

  self:SetSize(10, 10)
  self:SetPoint("CENTER")
end

function addonTable.Display.NameplateMixin:InitializeWidgets()
  if self.widgets then
    addonTable.Display.ReleaseWidgets(self.widgets)
    self.widgets = nil
  end
  local style = addonTable.Config.Get(addonTable.Config.Options.DESIGN)
  self.widgets = addonTable.Display.GetWidgets(style, self)

  local auras = addonTable.Config.Get(addonTable.Config.Options.DESIGN).auras
  local designInfo = {}
  for _, a in ipairs(auras) do
    designInfo[a.kind] = a
  end
  local globalScale = 1
  if designInfo.debuffs then
    self.DebuffDisplay:ClearAllPoints()
    self.DebuffDisplay.details = designInfo.debuffs
    addonTable.Display.ApplyAnchor(self.DebuffDisplay, designInfo.debuffs.anchor)
  else
    self.DebuffDisplay:Hide()
  end
  if designInfo.buffs then
    self.BuffDisplay:ClearAllPoints()
    self.BuffDisplay.details = designInfo.buffs
    addonTable.Display.ApplyAnchor(self.BuffDisplay, designInfo.buffs.anchor)
  else
    self.BuffDisplay:Hide()
  end
  if designInfo.crowdControl then
    self.CrowdControlDisplay:ClearAllPoints()
    self.CrowdControlDisplay.details = designInfo.crowdControl
    addonTable.Display.ApplyAnchor(self.CrowdControlDisplay, designInfo.crowdControl.anchor)
  else
    self.CrowdControlDisplay:Hide()
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

    if self.AurasManager then
      self.AurasManager:SetUnit(self.unit)
    end
  else
    self.unit = nil
    for _, w in ipairs(self.widgets) do
      w:SetUnit(nil)
      w:Hide()
    end

    self:UnregisterAllEvents()
  end

  if unit and UnitIsInteractable(unit) then
    self.interactUnit = unit
    self:UpdateSoftInteract()
    self:RegisterEvent("PLAYER_SOFT_INTERACT_CHANGED")
  else
    self:UnregisterEvent("PLAYER_SOFT_INTERACT_CHANGED")
  end

  self:UpdateScale()
end

function addonTable.Display.NameplateMixin:UpdateForTarget()
  if self.interactUnit and not self.unit and UnitExists(self.interactUnit) and UnitIsUnit("target", self.interactUnit) then
    self:SetUnit(self.interactUnit)
    return
  end

  if self.unit then
    for _, w in ipairs(self.widgets) do
      if w.ApplyTarget then
        w:ApplyTarget()
      end
    end
  end

  self:UpdateScale()
end

function addonTable.Display.NameplateMixin:UpdateScale()
  self:SetScale(addonTable.Config.Get(addonTable.Config.Options.GLOBAL_SCALE) * UIParent:GetEffectiveScale())

  if not self.unit then
    return
  end

  if UnitIsUnit("target", self.unit) then
    local change = addonTable.Config.Get(addonTable.Config.Options.TARGET_BEHAVIOUR)
    if change == "enlarge" then
      self:SetScale(1.25 * addonTable.Config.Get(addonTable.Config.Options.GLOBAL_SCALE) * UIParent:GetEffectiveScale())
    end
  else
    self:SetScale(addonTable.Config.Get(addonTable.Config.Options.GLOBAL_SCALE) * UIParent:GetEffectiveScale())
  end
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
  if eventName == "PLAYER_SOFT_INTERACT_CHANGED" then
    self:UpdateSoftInteract()
  end
end
