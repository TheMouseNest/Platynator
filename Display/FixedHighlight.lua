---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.FixedHighlightMixin = {}

function addonTable.Display.FixedHighlightMixin:SetUnit(unit)
  self.unit = unit
end

function addonTable.Display.FixedHighlightMixin:Strip()
end
