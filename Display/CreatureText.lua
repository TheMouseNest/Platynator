---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.CreatureTextMixin = {}

function addonTable.Display.CreatureTextMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self:RegisterUnitEvent("UNIT_NAME_UPDATE", self.unit)
    self:RegisterUnitEvent("UNIT_HEALTH", self.unit)
    self.text:SetText(UnitName(self.unit))
    self:UpdateColor()
  else
    self:Strip()
  end
end

local IsTapped = addonTable.Display.Utilities.IsTappedUnit
local IsNeutral = addonTable.Display.Utilities.IsNeutralUnit
local IsUnfriendly = addonTable.Display.Utilities.IsUnfriendlyUnit

function addonTable.Display.CreatureTextMixin:UpdateColor()
  if self.details.applyClassColors then
    local c
    if UnitIsPlayer(self.unit) then
      c = RAID_CLASS_COLORS[UnitClassBase(self.unit)]
    elseif IsTapped(self.unit) then
      c = self.details.colors.npc.tapped
    elseif IsNeutral(self.unit) then
      c = self.details.colors.npc.neutral
    elseif IsUnfriendly(self.unit) then
      c = self.details.colors.npc.unfriendly
    elseif UnitIsFriend("player", self.unit) then
      c = self.details.colors.npc.friendly
    else
      c = self.details.colors.npc.hostile
    end
    self.text:SetTextColor(c.r, c.g, c.b)
  end
end

function addonTable.Display.CreatureTextMixin:Strip()
  local c = self.details.color
  self.text:SetTextColor(c.r, c.g, c.b)
  self.rawText = nil
  self.targetRequired = nil
  self:UnregisterAllEvents()
end

function addonTable.Display.CreatureTextMixin:OnEvent(eventName, ...)
  if eventName == "UNIT_HEALTH" then
    self:UpdateColor()
  else
    self.text:SetText(UnitName(self.unit))
  end
end
