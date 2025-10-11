---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.NameplateMixin = {}
function addonTable.Display.NameplateMixin:OnLoad()
  self:SetFlattensRenderLayers(true)

  local style = addonTable.Config.Get(addonTable.Config.Options.DESIGN)

  self:InitializeWidgets()

  self.AurasFrame = nil
  self.OldUnitFrame = nil
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
  self:SetAllPoints()
  if addonTable.Constants.IsMidnight then
    nameplate.UnitFrame:SetAlpha(0) --- XXX: Remove when unit health formatting available
    nameplate.UnitFrame.HitTestFrame:SetParent(nameplate)
    nameplate.UnitFrame.HitTestFrame:ClearAllPoints()
    nameplate.UnitFrame.HitTestFrame:SetPoint("TOPLEFT", self.widgets[1])
    nameplate.UnitFrame.HitTestFrame:SetPoint("BOTTOMRIGHT", self.widgets[2])
    if self.AurasFrame and self.AurasFrame:GetParent() == self then
      self.AurasFrame:SetParent(self.OldUnitFrame)
    end
    nameplate.UnitFrame.AurasFrame:SetParent(self)
    self.AurasFrame = nameplate.UnitFrame.AurasFrame
    nameplate.UnitFrame.AurasFrame:ClearAllPoints()
    nameplate.UnitFrame.AurasFrame:SetPoint("BOTTOMLEFT", self.name, "TOPLEFT")
  else
    self:SetScale(9/10)
    nameplate.UnitFrame:SetParent(addonTable.hiddenFrame)
    nameplate.UnitFrame:UnregisterAllEvents()
    -- NYI
  end
  if self.OldUnitFrame and self.OldUnitFrame.WidgetContainer:GetParent() == nameplate then
    self.OldUnitFrame.WidgetContainer:SetParent(self.OldUnitFrame)
  end
  nameplate.UnitFrame.WidgetContainer:SetParent(nameplate)
end

function addonTable.Display.NameplateMixin:SetUnit(unit)
  self.unit = unit
  if self.unit and not UnitNameplateShowsWidgetsOnly(self.unit) then
    self:Show()
    if addonTable.Constants.IsMidnight then
      C_NamePlateManager.SetNamePlateSimplified(self.unit, false)
    end
  elseif self.unit and UnitNameplateShowsWidgetsOnly(self.unit) then
    self:Hide()
    self:UnregisterAllEvents()
  end

  for _, w in ipairs(self.widgets) do
    w:SetUnit(self.unit)
  end
end

function addonTable.Display.NameplateMixin:UpdateForTarget()
  if self.unit then
    for _, w in ipairs(self.widgets) do
      if w.ApplyTarget then
        w:ApplyTarget()
      end
    end
  end

  if not addonTable.Constants.IsMidnight then
    if UnitIsUnit("target", self.unit) then
      self:SetScale(1.2 * 9/10)
    else
      self:SetScale(1 * 9/10)
    end
  end
end
