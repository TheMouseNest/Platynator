---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.MouseoverHighlightMixin = {}

function addonTable.Display.MouseoverHighlightMixin:SetUnit(unit)
  self.unit = unit
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
  self:SetShown(UnitIsUnit("mouseover", self.unit) and (self.details.includeTarget or not UnitIsUnit("target", self.unit)))
end
