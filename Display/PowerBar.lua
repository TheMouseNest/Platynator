---@class addonTablePlatynator
local addonTable = select(2, ...)

local specializationToDivisor = {
  [265] = addonTable.Constants.IsMists and 100 or nil,
  [267] = addonTable.Constants.IsMists and 10 or nil,
}
local specializationToPower = {
  --Rogue (all specs)
  [259] = Enum.PowerType.ComboPoints,
  [260] = Enum.PowerType.ComboPoints,
  [261] = Enum.PowerType.ComboPoints,
  [1453] = Enum.PowerType.ComboPoints,
  --Druid (feral only)
  [103] = Enum.PowerType.ComboPoints,
  [1447] = Enum.PowerType.ComboPoints,
  --Death Knight (all specs)
  [250] = Enum.PowerType.Runes,
  [251] = Enum.PowerType.Runes,
  [252] = Enum.PowerType.Runes,
  --Warlock (all specs)
  [265] = Enum.PowerType.SoulShards,
  [266] = addonTable.Constants.IsRetail and Enum.PowerType.SoulShards or nil,
  [267] = addonTable.Constants.IsMists and Enum.PowerType.BurningEmbers or Enum.PowerType.SoulShards,
  [1454] = Enum.PowerType.SoulShards,
  --Paladin (all specs)
  [65] = Enum.PowerType.HolyPower,
  [66] = Enum.PowerType.HolyPower,
  [70] = Enum.PowerType.HolyPower,
  [1451] = Enum.PowerType.HolyPower,
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

-- Used in classic era, so excludes classes without an appropriate resource
local classToSpec = {
  ["ROGUE"] = 259,
  ["DRUID"] = 103,
}

local specializationToColor = {
  --Rogue (all specs)
  [259] = CreateColorFromRGBHexString("f71322"),
  [260] = CreateColorFromRGBHexString("f71322"),
  [261] = CreateColorFromRGBHexString("f71322"),
  [1453] = CreateColorFromRGBHexString("f71322"),
  --Druid (feral only)
  [103] = CreateColorFromRGBHexString("e82020"),
  [1447] = CreateColorFromRGBHexString("e82020"),
  --Death Knight (all specs)
  [250] = CreateColorFromRGBHexString("fc3c3f"),
  [251] = CreateColorFromRGBHexString("4282d1"),
  [252] = CreateColorFromRGBHexString("3cc435"),
  --Warlock (all specs)
  [265] = CreateColorFromRGBHexString("b61ff2"),
  [266] = CreateColorFromRGBHexString("b61ff2"),
  [267] = CreateColorFromRGBHexString("b61ff2"),
  [1454] = CreateColorFromRGBHexString("b61ff2"),
  --Paladin (all specs)
  [65] = CreateColorFromRGBHexString("f0c900"),
  [66] = CreateColorFromRGBHexString("f0c900"),
  [70] = CreateColorFromRGBHexString("f0c900"),
  [1451] = CreateColorFromRGBHexString("f0c900"),
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

local chargeColor = CreateColorFromRGBHexString("00aaff")

local powerKind, powerColor, powerDivisor, specID

local specializationMonitor = CreateFrame("Frame")
specializationMonitor:RegisterEvent("PLAYER_LOGIN")
if C_EventUtils.IsEventValid("PLAYER_SPECIALIZATION_CHANGED") then
  specializationMonitor:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
end
specializationMonitor:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
specializationMonitor:SetScript("OnEvent", function()
  specID = nil
  if UnitClassBase("player") == "DRUID" then
    if GetShapeshiftFormID() == 1 then
      specID = classToSpec["DRUID"]
    end
  elseif addonTable.Constants.IsRetail or addonTable.Constants.IsMists then
    local specIndex = C_SpecializationInfo.GetSpecialization()
    specID = C_SpecializationInfo.GetSpecializationInfo(specIndex)
  else
    specID = classToSpec[UnitClassBase("player")]
  end

  powerKind = specializationToPower[specID]
  powerColor = specializationToColor[specID]
  powerDivisor = specializationToDivisor[specID]
end)

addonTable.Display.PowerBarMixin = {}

function addonTable.Display.PowerBarMixin:PostInit()
  function self:PostApplySize()
    self.lastMaxPower = 0
    self.lastSpecID = nil
    PixelUtil.SetSize(self, (self.asset.width - self.asset.inset) * self.lastMaxPower, self.asset.height)
    if self.unit then
      self:ApplyTarget()
    end
  end
  if not self.powerTextures then
    self.powerTextures = {}
  end

  self.asset = addonTable.Assets.PowerBars[self.details.asset]
  self.lastMaxPower = 0
  self.lastSpecID = nil
  for _, t in ipairs(self.powerTextures) do
    t:SetTexture(self.asset.file)
  end
end

function addonTable.Display.PowerBarMixin:Strip()
  self.asset = nil
end

function addonTable.Display.PowerBarMixin:SetUnit(unit)
  self.unit = unit
end

function addonTable.Display.PowerBarMixin:ApplyTarget()
  if powerKind and UnitIsUnit("target", self.unit) and UnitCanAttack("player", self.unit) then
    local maxPower
    local currentPower = 0
    if powerKind == Enum.PowerType.Runes then
      maxPower = addonTable.Constants.DeathKnightMaxRunes
      for index = 1, addonTable.Constants.DeathKnightMaxRunes do
        local _, _, ready = GetRuneCooldown(index)
        if ready then
          currentPower = currentPower + 1
        end
      end
    elseif addonTable.Constants.IsClassic and powerKind == Enum.PowerType.ComboPoints then
      maxPower = UnitPowerMax("player", powerKind)
      currentPower = GetComboPoints("player", "target")
    else
      maxPower = UnitPowerMax("player", powerKind)
      currentPower = UnitPower("player", powerKind)
      if powerDivisor then
        currentPower = currentPower / powerDivisor
        maxPower = maxPower / powerDivisor
      end
    end
    if maxPower == 0 then
      self:Hide()
      return
    end

    self:Show()
    self:SetValue(currentPower, maxPower, powerColor)
  else
    self:Hide()
  end
end

function addonTable.Display.PowerBarMixin:SetValue(currentPower, maxPower, color)
  if self.lastMaxPower ~= maxPower or self.lastSpecID ~= specID then
    local width = PixelUtil.ConvertPixelsToUIForRegion(self.asset.width * self.details.scale, self)
    local height = PixelUtil.ConvertPixelsToUIForRegion(self.asset.height * self.details.scale, self)
    while #self.powerTextures < maxPower do
      local t = self:CreateTexture(nil, "ARTWORK")
      t:SetTexture(self.asset.file)

      table.insert(self.powerTextures, t)
    end

    if #self.powerTextures > maxPower then
      for i = maxPower + 1, #self.powerTextures do
        self.powerTextures[i]:Hide()
      end
    end

    local offset = PixelUtil.ConvertPixelsToUIForRegion((-(self.asset.width - self.asset.inset) * maxPower/2 - self.asset.inset / 2) * self.details.scale, self)
    local step = PixelUtil.ConvertPixelsToUIForRegion((self.asset.width - self.asset.inset) * self.details.scale, self)
    for i = 1, maxPower do
      local t = self.powerTextures[i]
      t:SetVertexColor(color.r, color.g, color.b)
      t:ClearAllPoints()
      t:SetPoint("LEFT", self, "CENTER", offset, 0)
      t:SetSize(width, height)
      t:Show()
      offset = offset + step
    end

    self.lastMaxPower = maxPower
    self.lastSpecID = specID

    PixelUtil.SetSize(self, (self.asset.width - self.asset.inset) * self.details.scale * maxPower, (self.asset.height - self.asset.inset) * self.details.scale)
  end

  if maxPower > 0 then
    local chargedPoints = GetUnitChargedPowerPoints and GetUnitChargedPowerPoints("player") or nil
    for i = 1, maxPower do
      local c = (chargedPoints and tContains(chargedPoints, i)) and chargeColor or color
      self.powerTextures[i]:SetVertexColor(c.r, c.g, c.b)
    end

    if self.powerTextures[1].SetSpriteSheetCell then
      for i = 1, maxPower do
        self.powerTextures[i]:SetSpriteSheetCell(i <= currentPower and 1 or 2, 1, 2)
      end
    else
      for i = 1, maxPower do
        if i <= currentPower then
          self.powerTextures[i]:SetTexCoord(0, 0.5, 0, 1)
        else
          self.powerTextures[i]:SetTexCoord(0.5, 1, 0, 1)
        end
      end
    end
  end
end
