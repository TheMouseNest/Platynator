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

local fs = UIParent:CreateFontString(nil, nil, "GameFontNormal")
fs:Hide()

addonTable.Display.PowerBarMixin = {}
function addonTable.Display.PowerBarMixin:OnLoad()
  self.powerKind = classToPower[UnitClassBase("player")]

  local powerBg = self:CreateTexture()
  self.bg = powerBg
  powerBg:SetSize(addonTable.style.power.width * addonTable.style.power.scale, addonTable.style.power.height*addonTable.style.power.scale)
  powerBg:SetPoint("CENTER")
  powerBg:SetDrawLayer("BACKGROUND")

  local power = self:CreateTexture()
  self.main = power
  power:SetSize(addonTable.style.power.width * addonTable.style.power.scale, addonTable.style.power.height*addonTable.style.power.scale)
  power:SetPoint("CENTER")

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

    fs:SetFormattedText(addonTable.style.power.blank, UnitPowerMax("player", self.powerKind))
    self.bg:SetTexture(fs:GetText())
    fs:SetFormattedText(addonTable.style.power.filled, UnitPowerMax("player", self.powerKind), UnitPower("player", self.powerKind))
    self.main:SetTexture(fs:GetText())
    self.main:SetVertexColor(240/255, 201/255, 0/255)
  else
    self:Hide()
  end
end
