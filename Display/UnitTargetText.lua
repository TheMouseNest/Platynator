---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.UnitTargetTextMixin = {}

function addonTable.Display.UnitTargetTextMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self:RegisterUnitEvent("UNIT_TARGET", self.unit)
    self:RegisterUnitEvent("UNIT_THREAT_LIST_UPDATE", self.unit)
    self:UpdateText()
  else
    self:Strip()
  end
end

function addonTable.Display.UnitTargetTextMixin:Strip()
  self:UnregisterAllEvents()
end

function addonTable.Display.UnitTargetTextMixin:UpdateText()
  local targetUnit = self.unit .. "target"
  local target = UnitName(targetUnit)
  if type(target) ~= "nil" then
    self.text:SetText(target)
    if self.details.applyClassColors and UnitIsPlayer(targetUnit) then
      local c = RAID_CLASS_COLORS[UnitClassBase(targetUnit)]
      self.text:SetTextColor(c.r, c.g, c.b)
    end
  else
    self.text:SetText("")
  end
end

function addonTable.Display.UnitTargetTextMixin:OnEvent(eventName, ...)
  self:UpdateText()
end
