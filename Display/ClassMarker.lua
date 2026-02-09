---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.ClassMarkerMixin = {}

local borderPool = CreateTexturePool(UIParent, "BACKGROUND", 0, nil, function(_, tex)
  tex:SetColorTexture(0, 0, 0)
end)

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
  self.border = borderPool:Acquire()
  self.border:SetParent(self)
  self.border:ClearAllPoints()

  self.PostApplyAnchor = function()
    PixelUtil.SetPoint(self.border, "TOPLEFT", self, "TOPLEFT", -1, 1)
    PixelUtil.SetPoint(self.border, "BOTTOMRIGHT", self, "BOTTOMRIGHT", 1, -1)
  end
end

function addonTable.Display.ClassMarkerMixin:SetUnit(unit)
  self.unit = unit
  if self.unit and (UnitIsPlayer(self.unit) or UnitTreatAsPlayerForDisplay and UnitTreatAsPlayerForDisplay(self.unit)) then
    self.marker:Show()
    self.border:Show()
    local _, class = UnitClass(self.unit)
    local atlas = "classicon-" .. class:lower()
    self.marker:SetAtlas(atlas)
  else
    self.marker:Hide()
    self.border:Hide()
  end
end

function addonTable.Display.ClassMarkerMixin:Strip()
  self.PostInit = nil
  self.PostApplyAnchor = nil
  if self.border then
    self.border:Hide()
    borderPool:Release(self.border)
    self.border = nil
  end
end
