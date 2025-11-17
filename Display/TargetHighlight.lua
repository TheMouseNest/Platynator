---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.TargetHighlightMixin = {}

function addonTable.Display.TargetHighlightMixin:SetUnit(unit)
  self.unit = unit
  self.highlight:SetChecked(false)
end

function addonTable.Display.TargetHighlightMixin:Strip()
  self.ApplyTarget = nil
end

function addonTable.Display.TargetHighlightMixin:ApplyTarget()
  self.highlight:SetChecked(UnitIsUnit("target", self.unit))
end
