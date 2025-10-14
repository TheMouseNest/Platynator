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

  self:SetScript("OnEvent", self.OnEvent)
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
  self:SetSize(10, 10)
  self:SetPoint("CENTER")
  if addonTable.Constants.IsMidnight then
    nameplate.UnitFrame:SetAlpha(0) --- XXX: Remove when unit health formatting available
    nameplate.UnitFrame.HitTestFrame:SetParent(nameplate)
    nameplate.UnitFrame.HitTestFrame:ClearAllPoints()
    nameplate.UnitFrame.HitTestFrame:SetPoint("BOTTOMLEFT", self, "CENTER", addonTable.Rect.left, addonTable.Rect.bottom)
    nameplate.UnitFrame.HitTestFrame:SetSize(addonTable.Rect.width, addonTable.Rect.height)

    if self.AurasFrame and self.AurasFrame:GetParent() == self then
      self.AurasFrame:SetParent(self.UnitFrame)
    end
    nameplate.UnitFrame.AurasFrame:SetParent(self)
    self.AurasFrame = nameplate.UnitFrame.AurasFrame
    nameplate.UnitFrame.AurasFrame:ClearAllPoints()
    nameplate.UnitFrame.AurasFrame:SetPoint("BOTTOM", self, "CENTER", 0, addonTable.Rect.bottom + addonTable.Rect.height)
  else
    self:SetScale(9/10)
    nameplate.UnitFrame:SetParent(addonTable.hiddenFrame)
    nameplate.UnitFrame:UnregisterAllEvents()
    -- NYI
  end
  self.SoftTargetIcon:SetParent(nameplate)
  self.SoftTargetIcon:SetPoint("BOTTOM", nameplate, "TOP", 0, -8)
  self.SoftTargetIcon:Hide()
  if nameplate.UnitFrame.WidgetContainer then
    if self.UnitFrame and self.UnitFrame.WidgetContainer:GetParent() == nameplate then
      self.UnitFrame.WidgetContainer:SetParent(self.UnitFrame)
    end
    nameplate.UnitFrame.WidgetContainer:SetParent(nameplate)
  end
  self.UnitFrame = nameplate.UnitFrame
end

function addonTable.Display.NameplateMixin:SetUnit(unit)
  self.SoftTargetIcon:Hide()
  self:UnregisterEvent("PLAYER_SOFT_INTERACT_CHANGED")
  if unit and (not UnitNameplateShowsWidgetsOnly or not UnitNameplateShowsWidgetsOnly(unit)) and not UnitIsInteractable(unit) then
    self.unit = unit
    self.interactUnit = nil
    self:Show()
    if addonTable.Constants.IsMidnight then
      C_NamePlateManager.SetNamePlateSimplified(self.unit, false)
    end

    for _, w in ipairs(self.widgets) do
      w:SetUnit(self.unit)
    end
  else
    self.unit = nil
    self:Hide()
    self:UnregisterAllEvents()
    for _, w in ipairs(self.widgets) do
      w:SetUnit(nil)
    end

    if unit and UnitIsInteractable(unit) then
      self.interactUnit = unit
      self.SoftTargetIcon:Show()
      SetUnitCursorTexture(self.SoftTargetIcon, unit)
      self:RegisterEvent("PLAYER_SOFT_INTERACT_CHANGED")
    end
  end
  self:UpdateForTarget()
end

function addonTable.Display.NameplateMixin:UpdateForTarget()
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

function addonTable.Display.NameplateMixin:OnEvent(eventName)
  if eventName == "PLAYER_SOFT_INTERACT_CHANGED" then
    SetUnitCursorTexture(self.SoftTargetIcon, self.interactUnit)
  end
end
