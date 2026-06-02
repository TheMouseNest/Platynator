---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.MouseoverHighlightMixin = {}

function addonTable.Display.MouseoverHighlightMixin:SetUnit(unit)
  self.unit = unit
  self:Hide()
end

function addonTable.Display.MouseoverHighlightMixin:Strip()
  self.ApplyTarget = nil
  self.ApplyMouseover = nil
end

function addonTable.Display.MouseoverHighlightMixin:ApplyTarget()
  if not self.details.includeTarget then
    self:ApplyMouseover()
  end
end

function addonTable.Display.MouseoverHighlightMixin:ApplyMouseover()
  self:SetShown(addonTable.Cache:Get(self.unit, "mouseover") and (self.details.includeTarget or not addonTable.Cache:Get(self.unit, "target")))
end
