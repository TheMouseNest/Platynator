---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.NameplateMixin = {}
function addonTable.Display.NameplateMixin:OnLoad()
  self:SetFlattensRenderLayers(true)

  local style = addonTable.Config.Get(addonTable.Config.Options.DESIGN)

  self:SetIgnoreParentScale(true)

  self:InitializeWidgets()

  self.AurasFrame = nil
  self.UnitFrame = nil
  self.SoftTargetIcon = self:CreateTexture(nil, "OVERLAY")
  self.SoftTargetIcon:SetSize(24, 24)
  self.SoftTargetIcon:SetPoint("BOTTOM", self, "TOP", 0, -8)
  self.SoftTargetIcon:Hide()

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
end

function addonTable.Display.NameplateMixin:Install(nameplate)
  self:SetParent(nameplate)
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
