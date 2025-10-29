---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.CreatureTextMixin = {}

function addonTable.Display.CreatureTextMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self:RegisterUnitEvent("UNIT_NAME_UPDATE", self.unit)
    self.text:SetText(UnitName(self.unit))
    if self.details.applyClassColors and UnitIsPlayer(self.unit) then
      local c = RAID_CLASS_COLORS[UnitClassBase(self.unit)]
      self.text:SetTextColor(c.r, c.g, c.b)
    end
  else
    self:Strip()
  end
end

function addonTable.Display.CreatureTextMixin:Strip()
  local c = self.details.color
  self.text:SetTextColor(c.r, c.g, c.b)
  self:UnregisterAllEvents()
end

function addonTable.Display.CreatureTextMixin:OnEvent(eventName, ...)
  self.text:SetText(UnitName(self.unit))
end
