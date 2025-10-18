---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.UnitTargetTextMixin = {}

function addonTable.Display.UnitTargetTextMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self:RegisterUnitEvent("UNIT_TARGET", self.unit)
    self:UpdateText()
  else
    self:Strip()
  end
end

function addonTable.Display.UnitTargetTextMixin:Strip()
  self:UnregisterAllEvents()
end

function addonTable.Display.UnitTargetTextMixin:UpdateText()
  local target = UnitName(self.unit .. "target")
  if type(target) ~= nil then
    self.text:SetText(target)
  else
    self.text:SetText("")
  end
end

function addonTable.Display.UnitTargetTextMixin:OnEvent(eventName, ...)
  self:UpdateText()
end
