---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.AnimatedBorderHighlightMixin = {}

function addonTable.Display.AnimatedBorderHighlightMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    addonTable.Display.RegisterForColorEvents(self, self.details.autoColors)
    self:SetColor(addonTable.Display.GetColor(self.details.autoColors, self.colorState, self.unit))
  else
    self:Strip()
  end
end

function addonTable.Display.AnimatedBorderHighlightMixin:Strip()
  self.Top:SetVertexColor(1, 1, 1, 1)
  self.Bottom:SetVertexColor(1, 1, 1, 1)
  self.Left:SetVertexColor(1, 1, 1, 1)
  self.Right:SetVertexColor(1, 1, 1, 1)
  self:UnregisterAllEvents()
  addonTable.Display.UnregisterForColorEvents(self)
end

function addonTable.Display.AnimatedBorderHighlightMixin:SetColor(...)
  self:SetShown(... ~= nil)
  if ... then
    self.Top:SetVertexColor(...)
    self.Bottom:SetVertexColor(...)
    self.Left:SetVertexColor(...)
    self.Right:SetVertexColor(...)
  end
end

function addonTable.Display.AnimatedBorderHighlightMixin:OnEvent(eventName)
  self:ColorEventHandler(eventName)
end
