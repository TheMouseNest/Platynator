---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.SoftTargetHighlightMixin = {}

function addonTable.Display.SoftTargetHighlightMixin:SetUnit(unit)
  self.unit = unit
end

function addonTable.Display.SoftTargetHighlightMixin:Strip()
  self.ApplyTarget = nil
end

function addonTable.Display.SoftTargetHighlightMixin:ApplyTarget()
  self:SetShown(IsTargetLoose() and (UnitIsUnit("softenemy", self.unit) or UnitIsUnit("softfriend", self.unit)))
end
