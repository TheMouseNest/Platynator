---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.TargetHighlightMixin = {}

function addonTable.Display.TargetHighlightMixin:SetUnit(unit)
  self.unit = unit
  self:Hide()
end

function addonTable.Display.TargetHighlightMixin:Strip()
  self.ApplyTarget = nil
end

function addonTable.Display.TargetHighlightMixin:ApplyTarget()
  self:SetShown(addonTable.Cache:Get(self.unit, "target"))
end
