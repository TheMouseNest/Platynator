---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.AutomaticHighlightMixin = {}

function addonTable.Display.AutomaticHighlightMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    addonTable.Display.RegisterForColorEvents(self, self.details.autoColors)
    self:SetColor(addonTable.Display.GetColor(self.details.autoColors, self.colorState, self.unit))
  else
    self:Strip()
  end
end

function addonTable.Display.AutomaticHighlightMixin:Strip()
  self.highlight:SetVertexColor(1, 1, 1, 1)
  self:UnregisterAllEvents()
  addonTable.Display.UnregisterForColorEvents(self)
end

function addonTable.Display.AutomaticHighlightMixin:SetColor(...)
  self:SetShown(... ~= nil)
  if ... then
    self.highlight:SetVertexColor(...)
  end
end

function addonTable.Display.AutomaticHighlightMixin:OnEvent(eventName)
  self:ColorEventHandler(eventName)
end
