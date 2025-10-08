---@class addonTablePlatynator
local addonTable = select(2, ...)

local classToPower = {
  ["ROGUE"] = Enum.PowerType.ComboPoints,
  ["DRUID"] = Enum.PowerType.ComboPoints,
  ["DEATHKNIGHT"] = Enum.PowerType.Runes,
  ["WARLOCK"] = Enum.PowerType.SoulShards,
  ["PALADIN"] = Enum.PowerType.HolyPower,
  ["MONK"] = Enum.PowerType.Chi,
  ["MAGE"] = Enum.PowerType.ArcaneCharges,
}

local classToColor = {
  ["DEATHKNIGHT"] = CreateColorFromRGBHexString("4282d1"),
  ["PALADIN"] = CreateColorFromRGBHexString("f0c900"),
}

local fs = UIParent:CreateFontString(nil, nil, "GameFontNormal")
fs:Hide()

addonTable.Display.PowerBarMixin = {}
function addonTable.Display.PowerBarMixin:OnLoad()
  local playerClass = UnitClassBase("player")
  self.powerKind = classToPower[playerClass]

  self.background = self:CreateTexture()
  self.background:SetSize(addonTable.style.power.width * addonTable.style.power.scale, addonTable.style.power.height*addonTable.style.power.scale)
  self.background:SetPoint("CENTER")
  self.background:SetDrawLayer("BACKGROUND")

  self.main = self:CreateTexture()
  self.main:SetSize(addonTable.style.power.width * addonTable.style.power.scale, addonTable.style.power.height*addonTable.style.power.scale)
  self.main:SetPoint("CENTER")
  local color = classToColor[playerClass] or CreateColor(240/255, 201/255, 0/255)
  self.main:SetVertexColor(color.r, color.g, color.b)

  self:SetSize(addonTable.style.power.width * addonTable.style.power.scale, addonTable.style.power.height*addonTable.style.power.scale)
end

function addonTable.Display.PowerBarMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self:ApplyPower()
  end
end

function addonTable.Display.PowerBarMixin:ApplyPower()
  if UnitIsUnit("target", self.unit) and self.powerKind and UnitCanAttack("player", self.unit) then
    self:Show()

    local maxPower = UnitPowerMax("player", self.powerKind)
    fs:SetFormattedText(addonTable.style.power.blank, maxPower)
    self.background:SetTexture(fs:GetText())
    local currentPower = 0
    if self.powerKind == Enum.PowerType.Runes then
      for index = 1, maxPower do
        local _, _, ready = GetRuneCooldown(index)
        if ready then
          currentPower = currentPower + 1
        end
      end
    else
      currentPower = UnitPower("player", self.powerKind)
    end
    fs:SetFormattedText(addonTable.style.power.filled, maxPower, currentPower)
    self.main:SetTexture(fs:GetText())
  else
    self:Hide()
  end
end
