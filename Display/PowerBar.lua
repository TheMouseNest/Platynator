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
  --Paladin (ret only)
  [70] = Enum.PowerType.HolyPower,
  --Monk (windwalker)
  [269] = Enum.PowerType.Chi,
  --Mage (arcane only)
  [62] = Enum.PowerType.ArcaneCharges,
}

local specializationToColor = {
  --Rogue (all specs)
  [259] = nil,
  [260] = nil,
  [261] = nil,
  --Druid (feral only)
  [103] = nil,
  --Death Knight (all specs)
  [250] = CreateColorFromRGBHexString("fc3c3f"),
  [251] = CreateColorFromRGBHexString("4282d1"),
  [252] = CreateColorFromRGBHexString("3cc435"),
  --Warlock (all specs)
  [265] = CreateColorFromRGBHexString("b61ff2"),
  [266] = CreateColorFromRGBHexString("b61ff2"),
  [267] = CreateColorFromRGBHexString("b61ff2"),
  --Paladin (ret only)
  [70] = CreateColorFromRGBHexString("f0c900"),
  --Monk (windwalker)
  [269] = nil,
  --Mage (arcane only)
  [62] = nil,
}

local fs = UIParent:CreateFontString(nil, nil, "GameFontNormal")
fs:Hide()

addonTable.Display.PowerBarMixin = {}
function addonTable.Display.PowerBarMixin:OnLoad()
  self.background = self:CreateTexture()
  self.background:SetSize(addonTable.style.power.width * addonTable.style.power.scale, addonTable.style.power.height*addonTable.style.power.scale)
  self.background:SetPoint("CENTER")
  self.background:SetDrawLayer("BACKGROUND")

  self.main = self:CreateTexture()
  self.main:SetSize(addonTable.style.power.width * addonTable.style.power.scale, addonTable.style.power.height*addonTable.style.power.scale)
  self.main:SetPoint("CENTER")

  self:SetSize(addonTable.style.power.width * addonTable.style.power.scale, addonTable.style.power.height*addonTable.style.power.scale)
end

function addonTable.Display.PowerBarMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self:ApplyPower()
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

function addonTable.Display.PowerBarMixin:ApplyPower()
  local powerKind = self:GetPower()
  if powerKind and UnitIsUnit("target", self.unit) and UnitCanAttack("player", self.unit) then
    self:Show()

    local maxPower = UnitPowerMax("player", powerKind)
    fs:SetFormattedText(addonTable.style.power.blank, maxPower)
    self.background:SetTexture(fs:GetText())
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
    fs:SetFormattedText(addonTable.style.power.filled, maxPower, currentPower)
    self.main:SetTexture(fs:GetText())
    local color = self:GetColor() or CreateColor(240/255, 201/255, 0/255)
    self.main:SetVertexColor(color.r, color.g, color.b)
  else
    self:Hide()
  end
end
