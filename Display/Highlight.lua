---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.HighlightMixin = {}

function addonTable.Display.HighlightMixin:SetUnit(unit)
  self.unit = unit
end

function addonTable.Display.HighlightMixin:Strip()
end

function addonTable.Display.HighlightMixin:ApplyTarget()
  self.highlight:SetChecked(UnitIsUnit("target", self.unit))
end
