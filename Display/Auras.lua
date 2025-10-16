---@class addonTablePlatynator
local addonTable = select(2, ...)

local crowdControlSpells = {
}

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
    if UnitCanAttack("player", self.unit) then
      self:ScanAllAuras()
    end
    self:RegisterUnitEvent("UNIT_AURA", unit)
  else
    self:UnregisterAllEvents()
  end
end

function addonTable.Display.AurasForNameplateMixin:GetAuraKind(info)
  if info.isHelpful then
    return "buffs"
  elseif info.isHarmful and info.isFromPlayerOrPlayerPet and info.nameplateShowPersonal and C_UnitAuras.IsAuraFilteredOutByInstanceID(self.unit, info.auraInstanceID, "PLAYER") then
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
    if info.auraInstanceID then
      local kind = self:GetAuraKind(info)
      if kind then
        self[kind][auraInstanceID] = info
      end
    end
    index = index + 1
  end

  index = 1
  while true do
    local info = C_UnitAuras.GetAuraDataByIndex(self.unit, index, "HELPFUL")
    if not info then
      break
    end
    if info.auraInstanceID then
      local kind = self:GetAuraKind(info)
      if kind then
        self[kind][auraInstanceID] = info
      end
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
        print("kind", kind,auraData.auraInstanceID, auraData.spellId)
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
