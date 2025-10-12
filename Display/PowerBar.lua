---@class addonTablePlatynator
local addonTable = select(2, ...)

local specializationToPower = {
  --Rogue (all specs)
  [259] = Enum.PowerType.ComboPoints,
  [260] = Enum.PowerType.ComboPoints,
  [261] = Enum.PowerType.ComboPoints,
  --Druid (feral only)
  [103] = Enum.PowerType.ComboPoints,
  --Death Knight (all specs)
  [250] = Enum.PowerType.Runes,
  [251] = Enum.PowerType.Runes,
  [252] = Enum.PowerType.Runes,
  --Warlock (all specs)
  [265] = Enum.PowerType.SoulShards,
  [266] = Enum.PowerType.SoulShards,
  [267] = Enum.PowerType.SoulShards,
  --Paladin (all specs)
  [65] = Enum.PowerType.HolyPower,
  [66] = Enum.PowerType.HolyPower,
  [70] = Enum.PowerType.HolyPower,
  --Monk (windwalker)
  [269] = Enum.PowerType.Chi,
  --Mage (arcane only)
  [62] = Enum.PowerType.ArcaneCharges,
  --Evokers
  [1465] = Enum.PowerType.Essence, -- No spec
  [1467] = Enum.PowerType.Essence,
  [1468] = Enum.PowerType.Essence,
  [1473] = Enum.PowerType.Essence,
}

local specializationToColor = {
  --Rogue (all specs)
  [259] = CreateColorFromRGBHexString("f71322"),
  [260] = CreateColorFromRGBHexString("f71322"),
  [261] = CreateColorFromRGBHexString("f71322"),
  --Druid (feral only)
  [103] = CreateColorFromRGBHexString("e82020"),
  --Death Knight (all specs)
  [250] = CreateColorFromRGBHexString("fc3c3f"),
  [251] = CreateColorFromRGBHexString("4282d1"),
  [252] = CreateColorFromRGBHexString("3cc435"),
  --Warlock (all specs)
  [265] = CreateColorFromRGBHexString("b61ff2"),
  [266] = CreateColorFromRGBHexString("b61ff2"),
  [267] = CreateColorFromRGBHexString("b61ff2"),
  --Paladin (all specs)
  [65] = CreateColorFromRGBHexString("f0c900"),
  [66] = CreateColorFromRGBHexString("f0c900"),
  [70] = CreateColorFromRGBHexString("f0c900"),
  --Monk (windwalker)
  [269] = CreateColorFromRGBHexString("31f78a"),
  --Mage (arcane only)
  [62] = CreateColorFromRGBHexString("46d8fc"),
  --Evokers
  [1465] = CreateColorFromRGBHexString("37e5fc"), -- No spec
  [1467] = CreateColorFromRGBHexString("37e5fc"),
  [1468] = CreateColorFromRGBHexString("37e5fc"),
  [1473] = CreateColorFromRGBHexString("37e5fc"),
}

addonTable.Display.PowerBarMixin = {}
function addonTable.Display.PowerBarMixin:PostInit()
  self.powerKind = self:GetPower()
  self.powerColor = self:GetColor() or CreateColor(240/255, 201/255, 0/255)
end

function addonTable.Display.PowerBarMixin:Strip()
end

function addonTable.Display.PowerBarMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self:ApplyTarget()
  end
end

function addonTable.Display.PowerBarMixin:GetPower()
  local specIndex = C_SpecializationInfo.GetSpecialization()
  local specID = C_SpecializationInfo.GetSpecializationInfo(specIndex)

  return specializationToPower[specID]
end

function addonTable.Display.PowerBarMixin:GetColor()
  local specIndex = C_SpecializationInfo.GetSpecialization()
  local specID = C_SpecializationInfo.GetSpecializationInfo(specIndex)

  return specializationToColor[specID]
end

function addonTable.Display.PowerBarMixin:ApplyTarget()
  local powerKind = self.powerKind
  if powerKind and UnitIsUnit("target", self.unit) and UnitCanAttack("player", self.unit) then
    self:Show()

    local maxPower = UnitPowerMax("player", powerKind)
    self.background:SetValue(maxPower)
    local currentPower = 0
    if powerKind == Enum.PowerType.Runes then
      for index = 1, addonTable.Constants.DeathKnightMaxRunes do
        local _, _, ready = GetRuneCooldown(index)
        if ready then
          currentPower = currentPower + 1
        end
      end
    else
      currentPower = UnitPower("player", powerKind)
    end
    self.main:SetValue(currentPower)
    local color = self.powerColor
    self.main:GetStatusBarTexture():SetVertexColor(color.r, color.g, color.b)
  else
    self:Hide()
  end
end
