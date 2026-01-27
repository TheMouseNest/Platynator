---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.TargetHighlightMixin = {}

function addonTable.Display.TargetHighlightMixin:SetUnit(unit)
  self.unit = unit
end

function addonTable.Display.TargetHighlightMixin:Strip()
  self.ApplyTarget = nil
end

function addonTable.Display.TargetHighlightMixin:ApplyTarget()
  self:SetShown(UnitIsUnit("target", self.unit))
end
