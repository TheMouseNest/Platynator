---@class addonTablePlatynator
local addonTable = select(2, ...)

local legacy = {}

addonTable.Display.AurasManagerMixin = {}

function addonTable.Display.AurasManagerMixin:OnLoad()
  self.OnDebuffsUpdate = function() end
  self.OnCrowdControlUpdate = function() end
  self.OnBuffsUpdate = function() end

  self:SetScript("OnEvent", self.OnEvent)
  self.processingAuras = false

  self:Reset()
end

function addonTable.Display.AurasManagerMixin:PostInit(buffs, debuffs, crowdControl)
  self.processingAuras = (buffs or debuffs or crowdControl) and (
    not addonTable.Constants.IsRetail or not (debuffs and debuffs.filters.important or buffs and buffs.filters.important)
  )

  self:Reset()

  self.buffFilter = "HELPFUL"
  self.buffsDetails = buffs
  if buffs then
    if addonTable.Constants.IsRetail then
      if buffs.filters.important then
        self.buffFilter = self.buffFilter .. "|INCLUDE_NAME_PLATE_ONLY"
      end
      if buffs.sorting.kind == "blizzard" then
        self.buffSort = Enum.UnitAuraSortRule.Default
      else
        self.buffSort = Enum.UnitAuraSortRule.ExpirationOnly
      end
      self.buffOrder = buffs.sorting.reversed and Enum.UnitAuraSortDirection.Reverse or Enum.UnitAuraSortDirection.Normal
      self.buffUseImportant = buffs.filters.important
    else
      if buffs.sorting.kind == "blizzard" and not buffs.sorting.reversed then
        self.buffSortFunc = function(a, b)
          return a < b
        end
      elseif buffs.sorting.kind == "blizzard" then
        self.buffSortFunc = function(a, b)
          return a > b
        end
      elseif not buffs.sorting.reversed then
        self.buffSortFunc = function(a, b)
          local aAura = self.auraData[a]
          local bAura = self.auraData[b]
          if aAura.expirationTime ~= bAura.expirationTime then
            return aAura.expirationTime < bAura.expirationTime
          else
            return a < b
          end
        end
      else
        self.buffSortFunc = function(a, b)
          local aAura = self.auraData[a]
          local bAura = self.auraData[b]
          if aAura.expirationTime ~= bAura.expirationTime then
            return aAura.expirationTime > bAura.expirationTime
          else
            return a > b
          end
        end
      end
    end
  end

  self.debuffFilter = "HARMFUL"
  self.debuffsDetails = debuffs
  if debuffs then
    if debuffs.filters.fromYou then
      self.debuffFilter = self.debuffFilter .. "|PLAYER"
    end
    if addonTable.Constants.IsRetail then
      if debuffs.sorting.kind == "blizzard" then
        self.debuffSort = Enum.UnitAuraSortRule.Default
      else
        self.debuffSort = Enum.UnitAuraSortRule.ExpirationOnly
      end
      self.debuffOrder = debuffs.sorting.reversed and Enum.UnitAuraSortDirection.Reverse or Enum.UnitAuraSortDirection.Normal
      self.debuffUseImportant = debuffs.filters.important
    else
      if debuffs.sorting.kind == "blizzard" and not debuffs.sorting.reversed then
        self.debuffSortFunc = function(a, b)
          local aAura = self.auraData[a]
          local bAura = self.auraData[b]
          if aAura.unit == "player" and bAura.unit ~= "player" then
            return true
          elseif aAura.unit ~= "player" and bAura.unit == "player" then
            return false
          elseif aAura.canApplyAura and not bAura.canApplyAura then
            return true
          elseif not aAura.canApplyAura and bAura.canApplyAura then
            return false
          else
            return a < b
          end
        end
      elseif debuffs.sorting.kind == "blizzard" then -- Blizzard Reversed
        self.debuffSortFunc = function(a, b)
          local aAura = self.auraData[a]
          local bAura = self.auraData[b]
          if aAura.unit == "player" and bAura.unit ~= "player" then
            return false
          elseif aAura.unit ~= "player" and bAura.unit == "player" then
            return true
          elseif aAura.canApplyAura and not bAura.canApplyAura then
            return false
          elseif not aAura.canApplyAura and bAura.canApplyAura then
            return true
          else
            return a > b
          end
        end
      elseif not debuffs.sorting.reversed then -- Duration
        self.debuffSortFunc = function(a, b)
          local aAura = self.auraData[a]
          local bAura = self.auraData[b]
          if aAura.unit == "player" and bAura.unit ~= "player" then
            return true
          elseif aAura.unit ~= "player" and bAura.unit == "player" then
            return false
          elseif aAura.canApplyAura and not bAura.canApplyAura then
            return true
          elseif not aAura.canApplyAura and bAura.canApplyAura then
            return false
          elseif aAura.expirationTime ~= bAura.expirationTime then
            return aAura.expirationTime < bAura.expirationTime
          else
            return a < b
          end
        end
      else -- Duration Reversed
        self.debuffSortFunc = function(a, b)
          local aAura = self.auraData[a]
          local bAura = self.auraData[b]
          if aAura.unit == "player" and bAura.unit ~= "player" then
            return false
          elseif aAura.unit ~= "player" and bAura.unit == "player" then
            return true
          elseif aAura.canApplyAura and not bAura.canApplyAura then
            return false
          elseif not aAura.canApplyAura and bAura.canApplyAura then
            return true
          elseif aAura.expirationTime ~= bAura.expirationTime then
            return aAura.expirationTime > bAura.expirationTime
          else
            return a > b
          end
        end
      end
    end
  end

  self.crowdControlFilter = "HARMFUL"
  self.crowdControlDetails = crowdControl

  if crowdControl then
    if addonTable.Constants.IsRetail then
      self.crowdControlFilter = self.crowdControlFilter .. "|CROWD_CONTROL"
      if crowdControl.sorting.kind == "blizzard" then
        self.crowdControlSort = Enum.UnitAuraSortRule.Default
      else
        self.crowdControlSort = Enum.UnitAuraSortRule.ExpirationOnly
      end
      self.crowdControlOrder = crowdControl.sorting.reversed and Enum.UnitAuraSortDirection.Reverse or Enum.UnitAuraSortDirection.Normal
    else
      if crowdControl.sorting.kind == "blizzard" and not crowdControl.sorting.reversed then
        self.crowdControlSortFunc = function(a, b)
          return a < b
        end
      elseif crowdControl.sorting.kind == "blizzard" then
        self.crowdControlSortFunc = function(a, b)
          return a > b
        end
      elseif not crowdControl.sorting.reversed then
        self.crowdControlSortFunc = function(a, b)
          local aAura = self.auraData[a]
          local bAura = self.auraData[b]
          if aAura.expirationTime ~= bAura.expirationTime then
            return aAura.expirationTime < bAura.expirationTime
          else
            return a < b
          end
        end
      else
        self.crowdControlSortFunc = function(a, b)
          local aAura = self.auraData[a]
          local bAura = self.auraData[b]
          if aAura.expirationTime ~= bAura.expirationTime then
            return aAura.expirationTime > bAura.expirationTime
          else
            return a > b
          end
        end
      end
    end
  end
end

function addonTable.Display.AurasManagerMixin:Reset()
  self.debuffs = {}
  self.crowdControl = {}
  self.buffs = {}
  self.lossOfControlApplied = nil

  self.auraData = {}
end

function addonTable.Display.AurasManagerMixin:DoesDebuffFilterIn(auraInstanceID)
  if not self.debuffsDetails.filters.important then
    return not C_UnitAuras.IsAuraFilteredOutByInstanceID(self.unit, auraInstanceID, self.debuffFilter)
  else
    return self.knownImportant[auraInstanceID] and not C_UnitAuras.IsAuraFilteredOutByInstanceID(self.unit, auraInstanceID, self.debuffFilter)
  end
end

function addonTable.Display.AurasManagerMixin:DoesBuffFilterIn(auraInstanceID, dispelName)
  if not self.buffsDetails.filters.important then
    if self.buffsDetails.filters.dispelable then
      return dispelName ~= nil and not C_UnitAuras.IsAuraFilteredOutByInstanceID(self.unit, auraInstanceID, self.buffFilter)
    else
      return not C_UnitAuras.IsAuraFilteredOutByInstanceID(self.unit, auraInstanceID, self.buffFilter)
    end
  elseif self.isFriendly then
    return not C_UnitAuras.IsAuraFilteredOutByInstanceID(self.unit, auraInstanceID, self.buffFilter .. "|RAID_IN_COMBAT|PLAYER")
  elseif self.buffsDetails.filters.dispelable then
    return self.knownImportant[auraInstanceID] and dispelName ~= nil and not C_UnitAuras.IsAuraFilteredOutByInstanceID(self.unit, auraInstanceID, self.buffFilter)
  elseif self.isPlayer then
    return self.knownImportant[auraInstanceID] and not (
      C_UnitAuras.IsAuraFilteredOutByInstanceID(self.unit, auraInstanceID, self.buffFilter .. "|RAID_IN_COMBAT") and
      C_UnitAuras.IsAuraFilteredOutByInstanceID(self.unit, auraInstanceID, self.buffFilter .. "|BIG_DEFENSIVE")) and
      C_UnitAuras.IsAuraFilteredOutByInstanceID(self.unit, auraInstanceID, self.buffFilter .. "|EXTERNAL_DEFENSIVE")
  else
    return self.knownImportant[auraInstanceID] and not C_UnitAuras.IsAuraFilteredOutByInstanceID(self.unit, auraInstanceID, self.buffFilter)
  end
end

function addonTable.Display.AurasManagerMixin:SetUnit(unit)
  self.unit = unit
  if unit then
    self.isPlayer = UnitIsPlayer(self.unit)
    self.isFriendly = UnitIsFriend("player", self.unit)

    if UnitCanAttack("player", self.unit) or addonTable.Constants.IsRetail then
      self:FullRefresh()
    else
      self:Reset()
      self.OnBuffsUpdate(self.buffs, self.buffFilter)
      self.OnDebuffsUpdate(self.debuffs, self.debuffFilter)
      self.OnCrowdControlUpdate(self.crowdControl, self.crowdControlFilter)
    end
    if self.processingAuras then
      self:RegisterUnitEvent("UNIT_AURA", self.unit)
    end
  else
    self:UnregisterAllEvents()
  end
end

function addonTable.Display.AurasManagerMixin:GetByInstanceID(auraInstanceID)
  return self.auraData[auraInstanceID]
end

local function FilterCommon(a1, a2)
  local include = {}
  for _, id in ipairs(a1) do
    include[id] = true
  end
  local res = {}
  for _, id in ipairs(a2) do
    if include[id] then
      include[id] = nil
      table.insert(res, id)
    end
  end

  return res
end

function addonTable.Display.AurasManagerMixin:FullRefresh()
  self:Reset()

  self.buffs = {}
  self.debuffs = {}
  self.crowdControl = {}

  local changes = {
    buffs = self.buffsDetails ~= nil,
    debuffs = self.debuffsDetails ~= nil,
    crowdControl = self.crowdControlDetails ~= nil,
  }

  local all = {}
  if C_UnitAuras.GetUnitAuras then
    if self.buffsDetails then
      tAppendAll(all, C_UnitAuras.GetUnitAuras(self.unit, "HELPFUL"))
    end
    if self.debuffsDetails or self.crowdControlDetails then
      tAppendAll(all, C_UnitAuras.GetUnitAuras(self.unit, "HARMFUL"))
    end
  else
    local index = 1
    while true do
      local aura = C_UnitAuras.GetAuraDataByIndex(self.unit, index, "HELPFUL")
      if not aura then
        break
      end
      table.insert(all, aura)
      index = index + 1
    end
    index = 1
    while true do
      local aura = C_UnitAuras.GetAuraDataByIndex(self.unit, index, "HARMFUL")
      if not aura then
        break
      end
      table.insert(all, aura)
      index = index + 1
    end
  end
  self:AddAuras(all)

  self:SortAurasAndReport(changes)
end

function addonTable.Display.AurasManagerMixin:OnEvent(event, _, refreshData)
  if not UnitCanAttack("player", self.unit) and not addonTable.Constants.IsRetail then
    if next(self.buffs) or next(self.debuffs) or next(self.crowdControl) then
      self.buffs = {}
      self.debuffs = {}
      self.crowdControl = {}
      self.OnBuffsUpdate(self.buffs, self.buffFilter)
      self.OnDebuffsUpdate(self.debuffs, self.debuffFilter)
      self.OnCrowdControlUpdate(self.crowdControl, self.crowdControlFilter)
    end
    return
  end

  if refreshData.isFullUpdate then
    self:FullRefresh()
    return
  end

  local changes = {}

  if refreshData.addedAuras then
    changes = self:AddAuras(refreshData.addedAuras)
  end

  if refreshData.updatedAuraInstanceIDs then
    for _, auraInstanceID in ipairs(refreshData.updatedAuraInstanceIDs) do
      local stored = self.auraData[auraInstanceID]
      if stored then
        local aura = C_UnitAuras.GetAuraDataByAuraInstanceID(self.unit, auraInstanceID)
        if aura then
          aura.kind = stored.kind
          if C_UnitAuras.GetAuraDuration then
            aura.applicationsString = C_UnitAuras.GetAuraApplicationDisplayCount(self.unit, auraInstanceID, 2, 1000)
            aura.durationSecret = C_UnitAuras.GetAuraDuration(self.unit, auraInstanceID)
          else
            aura.applicationsString = aura.applications > 1 and tostring(aura.applications) or ""
          end
          self.auraData[auraInstanceID] = aura
          changes[stored.kind] = true
        end
      end
    end
  end

  if refreshData.removedAuraInstanceIDs then
    for _, auraInstanceID in ipairs(refreshData.removedAuraInstanceIDs) do
      local stored = self.auraData[auraInstanceID]
      if stored then
        self.auraData[auraInstanceID] = nil

        local list = self[stored.kind]
        local index = tIndexOf(list, auraInstanceID)
        if index then
          changes[stored.kind] = true
          table.remove(list, index)
        end
      end
    end
  end

  self:SortAurasAndReport(changes)
end

if addonTable.Constants.IsRetail then
  function addonTable.Display.AurasManagerMixin:AddAuras(addedAuras)
    local changes = {}
    if self.debuffsDetails and self.debuffsDetails.filters.important or self.buffsDetails and self.buffsDetails.filters.important then
      self.knownImportant = self.GetImportantAuras()
    else
      self.knownImportant = {}
    end
    for _, aura in ipairs(addedAuras) do
      if self.auraData[aura.auraInstanceID] == nil then
        local keep = false
        if self.buffsDetails and self:DoesBuffFilterIn(aura.auraInstanceID, aura.dispelName) then
          keep = true
          table.insert(self.buffs, aura.auraInstanceID)
          aura.kind = "buffs"
        elseif self.crowdControlDetails and not C_UnitAuras.IsAuraFilteredOutByInstanceID(self.unit, aura.auraInstanceID, self.crowdControlFilter) then
          keep = true
          table.insert(self.crowdControl, aura.auraInstanceID)
          aura.kind = "crowdControl"
        elseif self.debuffsDetails and self:DoesDebuffFilterIn(aura.auraInstanceID) then
          keep = true
          table.insert(self.debuffs, aura.auraInstanceID)
          aura.kind = "debuffs"
        end
        if keep then
          aura.applicationsString = C_UnitAuras.GetAuraApplicationDisplayCount(self.unit, aura.auraInstanceID, 2, 1000)
          aura.durationSecret = C_UnitAuras.GetAuraDuration(self.unit, aura.auraInstanceID)
          self.auraData[aura.auraInstanceID] = aura
          changes[aura.kind] = true
        end
      end
    end
    return changes
  end
else
  function addonTable.Display.AurasManagerMixin:AddAuras(addedAuras)
    local changes = {}
    for _, aura in ipairs(addedAuras) do
      local keep = false
      if not self.isPlayer and self.buffsDetails and aura.isHelpful and
        not legacy.blacklistedBuffs[aura.spellId] and ((not self.buffsDetails.dispelable and not self.buffsDetails.important) or aura.dispelName ~= nil) then
        keep = true
        table.insert(self.buffs, aura.auraInstanceID)
        aura.kind = "buffs"
      elseif legacy.crowdControlSpells[aura.spellId] then
        if self.crowdControlDetails then  -- Prevents CC placing in the debuffs if CC is disabled
          keep = true
          table.insert(self.crowdControl, aura.auraInstanceID)
          aura.kind = "crowdControl"
        end
      elseif self.debuffsDetails and aura.isHarmful and (not self.debuffsDetails.filters.important or aura.nameplateShowPersonal or legacy.whitelistedDebuffs[aura.spellId] or addonTable.Constants.IsClassic) and aura.sourceUnit == "player" then
        keep = true
        table.insert(self.debuffs, aura.auraInstanceID)
        aura.kind = "debuffs"
      end
      if keep then
        aura.applicationsString = aura.applications > 1 and tostring(aura.applications) or ""
        self.auraData[aura.auraInstanceID] = aura
        changes[aura.kind] = true
      end
    end
    return changes
  end
end

function addonTable.Display.AurasManagerMixin:SortAurasAndReport(changes)
  if changes.debuffs then
    if self.debuffSortFunc then
      table.sort(self.debuffs, self.debuffSortFunc)
    else
      self.debuffs = FilterCommon(self.debuffs, C_UnitAuras.GetUnitAuraInstanceIDs(self.unit, self.debuffFilter, nil, self.debuffSort, self.debuffOrder))
    end
    self.OnDebuffsUpdate(self.debuffs, self.debuffFilter)
  end
  if changes.crowdControl then
    if self.crowdControlSortFunc then
      table.sort(self.crowdControl, self.crowdControlSortFunc)
    else
      self.crowdControl = C_UnitAuras.GetUnitAuraInstanceIDs(self.unit, self.crowdControlFilter, nil, self.crowdControlSort, self.crowdControlOrder)
    end
    self.OnCrowdControlUpdate(self.crowdControl, self.crowdControlFilter)
  end
  if changes.buffs then
    if self.buffSortFunc then
      table.sort(self.buffs, self.buffSortFunc)
    else
      self.buffs = FilterCommon(self.buffs, C_UnitAuras.GetUnitAuraInstanceIDs(self.unit, self.buffFilter, nil, self.buffSort, self.buffOrder))
    end
    self.OnBuffsUpdate(self.buffs, self.buffFilter)
  end
end

function addonTable.Display.AurasManagerMixin:SetBuffsCallback(callback)
  self.OnBuffsUpdate = callback
end

function addonTable.Display.AurasManagerMixin:SetDebuffsCallback(callback)
  self.OnDebuffsUpdate = callback
end

function addonTable.Display.AurasManagerMixin:SetCrowdControlCallback(callback)
  self.OnCrowdControlUpdate = callback
end

function addonTable.Display.AurasManagerMixin:SetGetImportantAuras(callback)
  self.GetImportantAuras = callback
end

legacy.crowdControlSpells = {
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
[8643] = true,
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
[236077] = true,
}

legacy.blacklistedBuffs = {
[209859] = true,
[206150] = true,
}

legacy.whitelistedDebuffs = {
  [257284] = true, -- Hunter's Mark (Retail)
  [121253] = true, -- Keg Smash (Monk)
  [123725] = true, -- Breath of Fire (Monk)
  [325153] = true, -- Exploding Keg (Monk)
  [445584] = true, -- Marked for Execution (Warrior)
}
