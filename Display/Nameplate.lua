---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.NameplateMixin = {}
function addonTable.Display.NameplateMixin:OnLoad()
  self:SetFlattensRenderLayers(true)

  local style = addonTable.Config.Get(addonTable.Config.Options.DESIGN)

  self:InitializeWidgets()

  self.AurasFrame = nil
  self.UnitFrame = nil
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
  if self.UnitFrame and self.UnitFrame.WidgetContainer:GetParent() == nameplate then
    self.UnitFrame.WidgetContainer:SetParent(self.UnitFrame)
  end
  self.UnitFrame = nameplate.UnitFrame
  nameplate.UnitFrame.WidgetContainer:SetParent(nameplate)
end

function addonTable.Display.NameplateMixin:SetUnit(unit)
  self.unit = unit
  if self.unit and not UnitNameplateShowsWidgetsOnly(self.unit) then
    self:Show()
    self:UpdateScale()
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

  self:UpdateScale()
end

function addonTable.Display.NameplateMixin:UpdateScale()
  self:SetScale(addonTable.Config.Get(addonTable.Config.Options.GLOBAL_SCALE))

  if not self.unit then
    return
  end

  if not addonTable.Constants.IsMidnight then
    if UnitIsUnit("target", self.unit) then
      self:SetScale(1.08 * addonTable.Config.Get(addonTable.Config.Options.GLOBAL_SCALE))
    else
      self:SetScale(0.9 * addonTable.Config.Get(addonTable.Config.Options.GLOBAL_SCALE))
    end
  end
end
