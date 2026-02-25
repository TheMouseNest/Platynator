---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.ClassMarkerMixin = {}

local classMap = {
  ["DEATHKNIGHT"] = "DeathKnight",
  ["DEMONHUNTER"] = "DemonHunter",
  ["DRUID"] = "Druid",
  ["EVOKER"] = "Evoker",
  ["HUNTER"] = "Hunter",
  ["PALADIN"] = "Paladin",
  ["PRIEST"] = "Priest",
  ["ROGUE"] = "Rogue",
  ["MAGE"] = "Mage",
  ["SHAMAN"] = "Shaman",
  ["WARRIOR"] = "Warrior",
  ["MONK"] = "Monk",
  ["WARLOCK"] = "Warlock",
}

function addonTable.Display.ClassMarkerMixin:PostInit()
  self.path = addonTable.Assets.Markers[self.details.asset].file
end

function addonTable.Display.ClassMarkerMixin:SetUnit(unit)
  self.unit = unit
  if self.unit and (UnitIsPlayer(self.unit) or UnitTreatAsPlayerForDisplay and UnitTreatAsPlayerForDisplay(self.unit)) then
    self.marker:Show()
    local _, class = UnitClass(self.unit)
    self.marker:SetTexture(self.path:format(classMap[class]))
  else
    self.marker:Hide()
  end
end

function addonTable.Display.ClassMarkerMixin:Strip()
  self.PostInit = nil
  self.path = nil
end
