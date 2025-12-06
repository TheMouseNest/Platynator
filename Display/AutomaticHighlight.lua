---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.AutomaticHighlightMixin = {}

function addonTable.Display.AutomaticHighlightMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self:SetColor(addonTable.Display.GetColor(self.details.autoColors, self.unit))
    addonTable.Display.RegisterForColorEvents(self, self.details.autoColors)
  else
    self:Strip()
  end
end

function addonTable.Display.AutomaticHighlightMixin:Strip()
  self.highlight:SetVertexColor(1, 1, 1, 1)
  self:UnregisterAllEvents()
  addonTable.Display.UnregisterForColorEvents(self)
end

function addonTable.Display.AutomaticHighlightMixin:SetColor(c)
  self:SetShown(c ~= nil)
  if c then
    self.highlight:SetVertexColor(c.r, c.g, c.b, c.a)
  end
end

function addonTable.Display.AutomaticHighlightMixin:OnEvent(eventName)
  self:ColorEventHandler(eventName)
end
