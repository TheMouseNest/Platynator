---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.FocusHighlightMixin = {}

function addonTable.Display.FocusHighlightMixin:SetUnit(unit)
  self.unit = unit
end

function addonTable.Display.FocusHighlightMixin:Strip()
  self.ApplyFocus = nil
end

function addonTable.Display.FocusHighlightMixin:ApplyFocus()
  self:SetShown(UnitIsUnit("focus", self.unit))
end
