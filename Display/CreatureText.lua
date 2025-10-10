---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.CreatureTextMixin = {}

function addonTable.Display.CreatureTextMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self:RegisterUnitEvent("UNIT_NAME_UPDATE", self.unit)
    self.text:SetText(UnitName(self.unit))
  else
    self:Strip()
  end
end

function addonTable.Display.CreatureTextMixin:Strip()
  self:UnregisterAllEvents()
end

function addonTable.Display.CreatureTextMixin:OnEvent(eventName, ...)
  self.text:SetText(UnitName(self.unit))
end
