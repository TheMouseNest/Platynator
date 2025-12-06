---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.MouseoverHighlightMixin = {}

function addonTable.Display.MouseoverHighlightMixin:SetUnit(unit)
  self.unit = unit
end

function addonTable.Display.MouseoverHighlightMixin:Strip()
  self.ApplyMouseover = nil
end

function addonTable.Display.MouseoverHighlightMixin:ApplyMouseover()
  self:SetShown(UnitIsUnit("mouseover", self.unit))
end
