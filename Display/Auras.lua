---@class addonTablePlatynator
local addonTable = select(2, ...)

local crowdControlSpells, blacklistedBuffs

addonTable.Display.AurasForNameplateMixin = {}
function addonTable.Display.AurasForNameplateMixin:OnLoad()
  self.OnDebuffsUpdate = function() end
  self.OnCrowdControlUpdate = function() end
  self.OnBuffsUpdate = function() end

  self:SetScript("OnEvent", self.OnEvent)

  self:Reset()
end

function addonTable.Display.AurasForNameplateMixin:Reset()
  self.debuffs = {}
  self.crowdControl = {}
  self.buffs = {}

  self.acceptedAuras = {}
end

function addonTable.Display.AurasForNameplateMixin:SetUnit(unit)
  self.unit = unit
  if unit then
    self.isPlayer = UnitIsPlayer(self.unit)
    if UnitCanAttack("player", self.unit) then
      self:ScanAllAuras()
    else
      self:Reset()
      self.OnDebuffsUpdate(self.debuffs)
      self.OnCrowdControlUpdate(self.crowdControl)
      self.OnBuffsUpdate(self.buffs)
    end
    self:RegisterUnitEvent("UNIT_AURA", unit)
  else
    self:UnregisterAllEvents()
  end
end

function addonTable.Display.AurasForNameplateMixin:GetAuraKind(info)
  if info.isHelpful and not self.isPlayer and not blacklistedBuffs[info.spellId] then
    return "buffs"
  elseif crowdControlSpells[info.spellId] then
    return "crowdControl"
  elseif info.isHarmful and (info.nameplateShowPersonal or addonTable.Constants.IsClassic) and info.sourceUnit == "player" then
    return "debuffs"
  end
end

function addonTable.Display.AurasForNameplateMixin:ScanAllAuras()
  self:Reset()

  local index = 1
  while true do
    local info = C_UnitAuras.GetAuraDataByIndex(self.unit, index, "HARMFUL")
    if not info then
      break
    end
    local kind = self:GetAuraKind(info)
    if kind then
      self[kind][info.auraInstanceID] = info
    end
    index = index + 1
  end

  index = 1
  while true do
    local info = C_UnitAuras.GetAuraDataByIndex(self.unit, index, "HELPFUL")
    if not info then
      break
    end
    local kind = self:GetAuraKind(info)
    if kind then
      self[kind][info.auraInstanceID] = info
    end
    index = index + 1
  end

  self.OnDebuffsUpdate(self.debuffs)
  self.OnCrowdControlUpdate(self.crowdControl)
  self.OnBuffsUpdate(self.buffs)
end

function addonTable.Display.AurasForNameplateMixin:OnEvent(eventName, unit, data)
  if not UnitCanAttack("player", self.unit) and next(self.buffs) == nil and next(self.debuffs) == nil and next(self.crowdControl) == nil then
    return
  end

  if data.isFullUpdate then
    self:ScanAllAuras()
    return
  end

  local changes = {}

  if data.addedAuras then
    for _, auraData in ipairs(data.addedAuras) do
      local kind = self:GetAuraKind(auraData)
      if kind then
        self[kind][auraData.auraInstanceID] = auraData
        changes[kind] = true
      end
    end
  end

  if data.updatedAuraInstanceIDs then
    for _, auraInstanceID in ipairs(data.updatedAuraInstanceIDs) do
      if self.buffs[auraInstanceID] then
        self.buffs[auraInstanceID] = C_UnitAuras.GetAuraDataByAuraInstanceID(self.unit, auraInstanceID)
        changes["buffs"] = true
      elseif self.debuffs[auraInstanceID] then
        self.debuffs[auraInstanceID] = C_UnitAuras.GetAuraDataByAuraInstanceID(self.unit, auraInstanceID)
        changes["debuffs"] = true
      elseif self.crowdControl[auraInstanceID] then
        self.crowdControl[auraInstanceID] = C_UnitAuras.GetAuraDataByAuraInstanceID(self.unit, auraInstanceID)
        changes["crowdControl"] = true
      end
    end
  end

  if data.removedAuraInstanceIDs then
    for _, auraInstanceID in ipairs(data.removedAuraInstanceIDs) do
      if self.buffs[auraInstanceID] then
        self.buffs[auraInstanceID] = nil
        changes["buffs"] = true
      elseif self.debuffs[auraInstanceID] then
        self.debuffs[auraInstanceID] = nil
        changes["debuffs"] = true
      elseif self.crowdControl[auraInstanceID] then
        self.crowdControl[auraInstanceID] = nil
        changes["crowdControl"] = true
      end
    end
  end

  if changes.debuffs then
    self.OnDebuffsUpdate(self.debuffs)
  end
  if changes.crowdControl then
    self.OnCrowdControlUpdate(self.crowdControl)
  end
  if changes.buffs then
    self.OnBuffsUpdate(self.buffs)
  end
end

function addonTable.Display.AurasForNameplateMixin:SetBuffsCallback(callback)
  self.OnBuffsUpdate = callback
end

function addonTable.Display.AurasForNameplateMixin:SetDebuffsCallback(callback)
  self.OnDebuffsUpdate = callback
end

function addonTable.Display.AurasForNameplateMixin:SetCrowdControlCallback(callback)
  self.OnCrowdControlUpdate = callback
end

 crowdControlSpells = {
[377048] = true,
[221562] = true,
[31935] = true,
[89766] = true,
[710] = true,
[117526] = true,
[2094] = true,
[105421] = true,
[207167] = true,
[451517] = true,
[179057] = true,
[1833] = true,
[324382] = true,
[33786] = true,
[31661] = true,
[64695] = true,
[77505] = true,
[460614] = true,
[339] = true,
[393456] = true,
[118699] = true,
[211881] = true,
[33395] = true,
[122] = true,
[3355] = true,
[1330] = true,
[91800] = true,
[1776] = true,
[473291] = true,
[853] = true,
[287712] = true,
[51514] = true,
[2637] = true,
[200200] = true,
[5484] = true,
[157997] = true,
[454787] = true,
[217832] = true,
[99] = true,
[22703] = true,
[5246] = true,
[316595] = true,
[316593] = true,
[24394] = true,
[408] = true,
[355689] = true,
[119381] = true,
[305485] = true,
[203123] = true,
[102359] = true,
[383121] = true,
[200166] = true,
[5211] = true,
[453] = true,
[91797] = true,
[6789] = true,
[115078] = true,
[118] = true,
[64044] = true,
[8122] = true,
[107079] = true,
[20066] = true,
[82691] = true,
[6770] = true,
[213691] = true,
[6358] = true,
[9484] = true,
[30283] = true,
[91807] = true,
[385954] = true,
[132168] = true,
[207685] = true,
[204490] = true,
[15487] = true,
[360806] = true,
[81261] = true,
[198909] = true,
[118905] = true,
[132169] = true,
[197214] = true,
[372245] = true,
[374776] = true,
[10326] = true,
[114404] = true,
[20549] = true,
[370970] = true,
[357229] = true,
[353706] = true,
[347775] = true,
[355640] = true,
[355888] = true,
[1244446] = true,
[428150] = true,
[356133] = true,
[1240214] = true,
[1221133] = true,
[422969] = true,
[451112] = true,
[326450] = true,
[117405] = true,
}

blacklistedBuffs = {
[209859] = true,
[206150] = true,
}
