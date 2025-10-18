---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.LevelTextMixin = {}

function addonTable.Display.LevelTextMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self:RegisterUnitEvent("UNIT_LEVEL", self.unit)
    self.text:SetText(UnitLevel(self.unit))
  else
    self:Strip()
  end
end

function addonTable.Display.LevelTextMixin:Strip()
  self:UnregisterAllEvents()
end

function addonTable.Display.LevelTextMixin:OnEvent(eventName, ...)
  self.text:SetText(UnitLevel(self.unit))
end
