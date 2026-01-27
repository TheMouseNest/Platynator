---@class addonTablePlatynator
local addonTable = select(2, ...)

local legacy = {}


addonTable.Display.AurasManagerMixin = {}

function addonTable.Display.AurasManagerMixin:OnLoad()
  self.OnDebuffsUpdate = function() end
  self.OnCrowdControlUpdate = function() end
  self.OnBuffsUpdate = function() end

  self:SetScript("OnEvent", self.OnEvent)
  self.processingAuras = not addonTable.Constants.IsRetail

  self:Reset()
end

function addonTable.Display.AurasManagerMixin:PostInit(buffs, debuffs, crowdControl)
  self.processingAuras = not addonTable.Constants.IsRetail

  self:Reset()

  self.buffFilter = "HELPFUL"
  self.buffsDetails = buffs
  if buffs then
    if C_UnitAuras.GetUnitAuraInstanceIDs then
      if buffs.sorting.kind == "blizzard" then
        self.buffSort = Enum.UnitAuraSortRule.Default
      else
        self.buffSort = Enum.UnitAuraSortRule.ExpirationOnly
      end
      self.buffOrder = buffs.sorting.reversed and Enum.UnitAuraSortDirection.Reverse or Enum.UnitAuraSortDirection.Normal
      self.buffUseImportant = buffs.filters.important
      self.processingAuras = self.processingAuras or buffs.filters.important
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

  if debuffs then
    if C_UnitAuras.GetUnitAuraInstanceIDs then
      if debuffs.sorting.kind == "blizzard" then
        self.debuffSort = Enum.UnitAuraSortRule.Default
      else
        self.debuffSort = Enum.UnitAuraSortRule.ExpirationOnly
      end
      self.debuffOrder = debuffs.sorting.reversed and Enum.UnitAuraSortDirection.Reverse or Enum.UnitAuraSortDirection.Normal
      self.debuffUseImportant = debuffs.filters.important
      self.processingAuras = self.processingAuras or debuffs.filters.important
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
  self.debuffsDetails = debuffs
  self.debuffFilter = "HARMFUL"
  if debuffs and debuffs.filters.fromYou then
    self.debuffFilter = self.debuffFilter .. "|PLAYER"
  end

  self.crowdControlFilter = "HARMFUL"
  self.crowdControlDetails = crowdControl

  if crowdControl then
    if C_UnitAuras.GetUnitAuraInstanceIDs then
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

function addonTable.Display.AurasManagerMixin:SetUnit(unit)
  self.unit = unit
  if unit then
    self.isPlayer = UnitIsPlayer(self.unit)
    if UnitCanAttack("player", self.unit) or addonTable.Constants.IsRetail then
      self:FullRefresh()
    else
      self:Reset()
      self.OnBuffsUpdate(self.buffs, self.buffFilter)
      self.OnDebuffsUpdate(self.debuffs, self.debuffFilter)
      self.OnCrowdControlUpdate(self.crowdControl, self.crowdControlFilter)
    end
    self:RegisterUnitEvent("UNIT_AURA", self.unit)
    if addonTable.Constants.IsRetail and UnitIsPlayer(self.unit) then
      self:RegisterUnitEvent("LOSS_OF_CONTROL_UPDATE", self.unit)
      self:RegisterUnitEvent("LOSS_OF_CONTROL_ADDED", self.unit)
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
      table.insert(res, id)
    end
  end

  return res
end

function addonTable.Display.AurasManagerMixin:FullRefresh()
  self:Reset()

  if C_UnitAuras.GetUnitAuraInstanceIDs then
    local important, crowdControl = self.GetImportantAuras()
    if self.buffsDetails then
      local all = C_UnitAuras.GetUnitAuras(self.unit, self.buffFilter, nil, self.buffSort, self.buffOrder)
      for _, aura in ipairs(all) do
        if (not self.buffsDetails.filters.important or important[aura.auraInstanceID]) and (not self.buffsDetails.dispelable or type(aura.dispelName) ~= "nil") then
          table.insert(self.buffs, aura.auraInstanceID)
          aura.applicationsString = C_UnitAuras.GetAuraApplicationDisplayCount(self.unit, aura.auraInstanceID, 2, 1000)
          aura.durationSecret = C_UnitAuras.GetAuraDuration(self.unit, aura.auraInstanceID)
          aura.kind = "buffs"
          self.auraData[aura.auraInstanceID] = aura
        end
      end
    end
    if self.debuffsDetails then
      local all = C_UnitAuras.GetUnitAuras(self.unit, self.debuffFilter, nil, self.debuffSort, self.debuffOrder)
      for _, aura in ipairs(all) do
        if (not self.debuffsDetails.filters.important or important[aura.auraInstanceID]) and not crowdControl[aura.auraInstanceID] then
          table.insert(self.debuffs, aura.auraInstanceID)
          aura.applicationsString = C_UnitAuras.GetAuraApplicationDisplayCount(self.unit, aura.auraInstanceID, 2, 1000)
          aura.durationSecret = C_UnitAuras.GetAuraDuration(self.unit, aura.auraInstanceID)
          aura.kind = "debuffs"
          self.auraData[aura.auraInstanceID] = aura
        end
      end
    end
    if self.crowdControlDetails then
      local all = C_UnitAuras.GetUnitAuras(self.unit, self.crowdControlFilter, nil, self.crowdControlSort, self.crowdControlOrder)
      for _, aura in ipairs(all) do
        if crowdControl[aura.auraInstanceID] then
          table.insert(self.crowdControl, aura.auraInstanceID)
          aura.applicationsString = C_UnitAuras.GetAuraApplicationDisplayCount(self.unit, aura.auraInstanceID, 2, 1000)
          aura.durationSecret = C_UnitAuras.GetAuraDuration(self.unit, aura.auraInstanceID)
          aura.kind = "crowdControl"
          self.auraData[aura.auraInstanceID] = aura
        end
      end
    end
  else
    if self.buffsDetails and not self.isPlayer then
      local index = 1
      while true do
        local aura = C_UnitAuras.GetAuraDataByIndex(self.unit, index, self.buffFilter)
        if not aura then
          break
        end
        if not legacy.blacklistedBuffs[aura.spellId] and ((not self.buffsDetails.dispelable and not self.buffsDetails.important) or type(aura.dispelName) ~= "nil") then
          table.insert(self.buffs, aura.auraInstanceID)
          aura.applicationsString = aura.applications > 1 and tostring(aura.applications) or ""
          aura.kind = "buffs"
          self.auraData[aura.auraInstanceID] = aura
        end
        index = index + 1
      end
      table.sort(self.buffs, self.buffSortFunc)
    end
    if self.debuffsDetails then
      local index = 1
      while true do
        local aura = C_UnitAuras.GetAuraDataByIndex(self.unit, index, self.debuffFilter)
        if not aura then
          break
        end
        if aura.isHarmful and (not self.debuffsDetails.filters.important or aura.nameplateShowPersonal or legacy.whitelistedDebuffs[aura.spellId] or addonTable.Constants.IsClassic) and not legacy.crowdControlSpells[aura.spellId] then
          table.insert(self.debuffs, aura.auraInstanceID)
          aura.applicationsString = aura.applications > 1 and tostring(aura.applications) or ""
          aura.kind = "debuffs"
          self.auraData[aura.auraInstanceID] = aura
        end
        index = index + 1
      end
      table.sort(self.debuffs, self.debuffSortFunc)
    end
    if self.crowdControlDetails then
      local index = 1
      while true do
        local aura = C_UnitAuras.GetAuraDataByIndex(self.unit, index, self.crowdControlFilter)
        if not aura then
          break
        end
        if legacy.crowdControlSpells[aura.spellId] then
          table.insert(self.crowdControl, aura.auraInstanceID)
          aura.applicationsString = aura.applications > 1 and tostring(aura.applications) or ""
          aura.kind = "crowdControl"
          self.auraData[aura.auraInstanceID] = aura
        end
        index = index + 1
      end
      table.sort(self.crowdControl, self.crowdControlSortFunc)
    end
  end

  if addonTable.Constants.IsRetail then
    self:UpdateLossOfControl()
  end

  self.OnDebuffsUpdate(self.debuffs, self.debuffFilter)
  self.OnCrowdControlUpdate(self.crowdControl, self.crowdControlFilter)
  self.OnBuffsUpdate(self.buffs, self.buffFilter)
end

function addonTable.Display.AurasManagerMixin:UpdateLossOfControl()
  local changes = {}

  if not UnitIsPlayer(self.unit) then
    return changes
  end

  local lossOfControlData = C_LossOfControl.GetActiveLossOfControlDataByUnit(self.unit, LOSS_OF_CONTROL_ACTIVE_INDEX);
  if lossOfControlData and lossOfControlData.auraInstanceID then
    local aura = C_UnitAuras.GetAuraDataByAuraInstanceID(self.unit, lossOfControlData.auraInstanceID)

    if aura then
      aura.applicationsString = C_UnitAuras.GetAuraApplicationDisplayCount(self.unit, aura.auraInstanceID, 2, 1000)
      aura.durationSecret = C_UnitAuras.GetAuraDuration(self.unit, aura.auraInstanceID)
      aura.kind = "crowdControl"
      self.auraData[aura.auraInstanceID] = aura

      self.crowdControl = {lossOfControlData.auraInstanceID}
      local oldIndex = tIndexOf(self.debuffs, lossOfControlData.auraInstanceID)
      if oldIndex then
        table.remove(self.debuffs, oldIndex)
        changes["debuffs"] = true
      end

      self.lossOfControlApplied = lossOfControlData.auraInstanceID
      changes["crowdControl"] = true
    end
  elseif self.lossOfControlApplied then
    self.crowdControl = {}
    self.auraData[self.lossOfControlApplied] = nil
    self.lossOfControlApplied = nil
    changes["crowdControl"] = true
  end

  return changes
end

function addonTable.Display.AurasManagerMixin:OnEvent(event, _, refreshData)
  if event == "LOSS_OF_CONTROL_ADDED" or event == "LOSS_OF_CONTROL_UPDATE" then
    local changes = self:UpdateLossOfControl()
    self.OnDebuffsUpdate(self.debuffs, self.debuffFilter)
    if changes.debuffs then
      self.OnDebuffsUpdate(self.debuffs, self.debuffFilter)
    end
    if changes.crowdControl then
      self.OnCrowdControlUpdate(self.crowdControl, self.crowdControlFilter)
    end
    if changes.buffs then
      self.OnBuffsUpdate(self.buffs, self.buffFilter)
    end

    return
  end

  if not self.processingAuras and event ~= "" then
    return
  end

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
    if self.GetImportantAuras then 
      local important, crowdControl = self.GetImportantAuras()

      if self.lossOfControlApplied then
        crowdControl[self.lossOfControlApplied] = true
      end

      for _, aura in ipairs(refreshData.addedAuras) do
        if self.auraData[aura.auraInstanceID] == nil then
          local keep = false
          if self.buffsDetails and not C_UnitAuras.IsAuraFilteredOutByInstanceID(self.unit, aura.auraInstanceID, self.buffFilter) and 
            (not self.buffsDetails.filters.important or important[aura.auraInstanceID]) and (not self.buffsDetails.dispelable or type(aura.dispelName) ~= "nil") then
            keep = true
            table.insert(self.buffs, aura.auraInstanceID)
            aura.kind = "buffs"
          elseif self.crowdControlDetails and crowdControl[aura.auraInstanceID] then
            if aura.auraInstanceID ~= self.lossOfControlApplied then
              keep = true
              table.insert(self.crowdControl, aura.auraInstanceID)
              aura.kind = "crowdControl"
            end
          elseif self.debuffsDetails and not C_UnitAuras.IsAuraFilteredOutByInstanceID(self.unit, aura.auraInstanceID, self.debuffFilter) and
            (not self.debuffsDetails.filters.important or important[aura.auraInstanceID]) and not crowdControl[aura.auraInstanceID] then
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
    else
      for _, aura in ipairs(refreshData.addedAuras) do
        local keep = false
        if not self.isPlayer and self.buffsDetails and aura.isHelpful and
          not legacy.blacklistedBuffs[aura.spellId] and ((not self.buffsDetails.dispelable and not self.buffsDetails.important) or type(aura.dispelName) ~= "nil") then
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
    end
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
      self.crowdControl = FilterCommon(self.crowdControl, C_UnitAuras.GetUnitAuraInstanceIDs(self.unit, self.crowdControlFilter, nil, self.crowdControlSort, self.crowdControlOrder))
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
