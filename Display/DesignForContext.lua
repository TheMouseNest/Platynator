---@class addonTablePlatynator
local addonTable = select(2, ...)

local IsNeutral = addonTable.Display.Utilities.IsNeutralUnit
local IsInCombat = addonTable.Display.Utilities.IsInCombatWith
local IsInRelevantInstance = addonTable.Display.Utilities.IsInRelevantInstance
local GetEliteType = addonTable.Display.Utilities.GetEliteType
local GetDelveType = addonTable.Display.Utilities.GetDelveType

local IsPlayer
if UnitTreatAsPlayerForDisplay then
  IsPlayer = function(unit)
    return UnitIsPlayer(unit) or UnitTreatAsPlayerForDisplay(unit)
  end
else
  IsPlayer = function(unit)
    return UnitIsPlayer(unit)
  end
end

local IsMinion
if UnitIsMinion then
  IsMinion = function(unit)
    return UnitIsMinion(unit)
  end
else
  IsMinion = function(unit)
    return UnitIsOtherPlayersPet(unit) or UnitIsUnit(unit, "pet")
  end
end

local function IsNPC(unit)
  return not IsPlayer(unit) and not IsMinion(unit)
end

local function GetAlignment(unit)
  if addonTable.Display.Utilities.IsNeutralUnit then
    return "neutral"
  elseif UnitIsFriend("player", unit) then
    return "friend"
  else
    return "enemy"
  end
end

local assignmentsPossibilities = {
  ["can-attack"] = { frequent = true, updates = "canAttack", check = function(state) return state.canAttack end },
  ["cannot-attack"] = { frequent = true, updates = "canAttack", check = function(state) return not state.canAttack end },

  ["in-combat"] = { frequent = true, updates = "inCombat", check = function(state) return state.inCombat end },
  ["out-combat"] = { frequent = true, updates = "inCombat", check = function(state) return not state.inCombat end },

  ["friend"] = { updates = "alignment", check = function(state) return state.alignment == "friendly" end},
  ["hostile"] = { updates = "alignment", check = function(state) return state.alignment == "friend" end},
  ["neutral"] = { updates = "alignment", check = function(state) return state.alignment == "friend" end},

  ["player"] = { check = function(state) return state.isPlayer end },
  ["npc"] = { check = function(state) return state.isNPC end },
  ["minion"] = { check = function(state) return state.isMinon end },

  ["class-rare"] = { updates = "classification", check = function(state) local c = state.classification; return c == "rare" or c == "rareelite" end },
  ["class-elite"] = { updates = "classification", check = function(state) local c = state.classification; return c == "elite" or c == "rareelite" end },
  ["class-worldboss"] = { updates = "classification", check = function(state) return state.classification == "worldboss" end },
  ["class-normal"] = { updates = "classification", check = function(state) return state.classification == "normal" end },
  ["class-minor"] = { updates = "classification", check = function(state) return state.classification == "minus" end },
  ["class-trivial"] = { updates = "classification", check = function(state) return state.classification == "trivial" end },

  ["loc-world"] = { check = function(state) return state.location == "world" end },
  ["loc-dungeon"] = { check = function(state) return state.location == "dungeon" end },
  ["loc-raid"] = { check = function(state) return state.location == "raid" end },
  ["loc-pvp"] = { check = function(state) return state.location == "pvp" end },
  ["loc-delve"] = { check = function(state) return state.location == "delve" end },

  ["elite-boss"] = { updates = "classification", check = function(state) return state.eliteType == "boss" end },
  ["elite-miniboss"] = { updates = "classification", check = function(state) return state.eliteType == "miniboss" end },
  ["elite-caster"] = { updates = "classification", check = function(state) return state.eliteType == "caster" end },
  ["elite-melee"] = { updates = "classification", check = function(state) return state.eliteType == "melee" end },
  ["elite-trivial"] = { updates = "classification", check = function(state) return state.eliteType == "trivial" end },

  ["delve-boss"] = { updates = "classification", check = function(state) return state.delveType == "boss" end },
  ["delve-elite"] = { updates = "classification", check = function(state) return state.delveType == "elite" end },
  ["delve-rare"] = { updates = "classification", check = function(state) return state.delveType == "rare" end },
  ["delve-caster"] = { updates = "classification", check = function(state) return state.delveType == "caster" end },
  ["delve-melee"] = { updates = "classification", check = function(state) return state.delveType == "melee" end },
  ["delve-trivial"] = { updates = "classification", check = function(state) return state.delveType == "trivial" end },
}

local location
local instanceTracker = CreateFrame("Frame")
instanceTracker:RegisterEvent("PLAYER_ENTERING_WORLD")
instanceTracker:RegisterEvent("ZONE_CHANGED_NEW_AREA")
instanceTracker:RegisterEvent("INSTANCE_GROUP_SIZE_CHANGED")
instanceTracker:SetScript("OnEvent", function()
  if not IsInRelevantInstance({dungeon = true, raid = true, pvp = true, delve = true}) then
    location = "world"
  elseif IsInRelevantInstance({dungeon = true}) then
    location = "dungeon"
  elseif IsInRelevantInstance({raid = true}) then
    location = "raid"
  elseif IsInRelevantInstance({pvp = true}) then
    location = "pvp"
  elseif IsInRelevantInstance({delve = true}) then
    location = "delve"
  end
end)

local function GenerateState(unit)
  return {
    canAttack = UnitCanAttack("player", unit),
    inCombat = IsInCombat(unit),
    alignment = GetAlignment(unit),
    isPlayer = IsPlayer(unit),
    isNPC = IsNPC(unit),
    isMinion = IsMinion(unit),
    classification = UnitClassification(unit),
    location = location,
    eliteType = GetEliteType(unit),
    delveType = GetDelveType(unit),

    updates = {},
  }
end

addonTable.Display.DesignForContextMixin = {}
function addonTable.Display.DesignForContextMixin:OnLoad()
  addonTable.CallbackRegistry:RegisterCallback("CustomiseDesignsAssigned", function(_, settingName)
    if settingName == addonTable.Config.Options.DESIGNS_ASSIGNED then
      self:RefreshDesignAssignments()
      addonTable.CallbackRegistry:TriggerCallback("RefreshStateChange", {[addonTable.Constants.RefreshReason.DesignSelection] = true})
    end
  end)

  self.unitStates = {}

  C_Timer.NewTicker(0.1, function() -- Used for transitioning mobs to attackable
    local UnitCanAttack = UnitCanAttack
    for unit, state in pairs(self.unitStates) do
      local canAttack = UnitCanAttack("player", unit)
      local changes = canAttack ~= state.canAttack
      state.canAttack = canAttack
      if changes then
        addonTable.CallbackRegistry:TriggerCallback("UnitDesignChange", unit)
      end
    end
  end)

  addonTable.CallbackRegistry:RegisterCallback("CombatStatusChange", function(_, unit)
    local state = self.unitStates[unit]
    if state then
      local inCombat = IsInCombat(unit)
      local changes = state.updates.inCombat and inCombat ~= state.inCombat
      state.inCombat = inCombat
      if changes then
        addonTable.CallbackRegistry:TriggerCallback("UnitDesignChange", unit)
      end
    end
  end)

  self:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
  self:RegisterEvent("UNIT_CLASSIFICATION_CHANGED")
  self:SetScript("OnEvent", self.OnEvent)
end

function addonTable.Display.DesignForContextMixin:OnEvent(event, unit)
  if event == "UNIT_CLASSIFICATION_CHANGED" then
    if self.unitStates[unit] then
      local changes = self.unitStates[unit].updates.classification
      self.unitStates[unit].classification = UnitClassification(unit)
      if changes then
        addonTable.CallbackRegistry:TriggerCallback("UnitDesignChange", unit)
      end
    end
  elseif event == "UNIT_FACTION" then
    if self.unitStates[unit] then
      local changes = self.unitStates[unit].updates.alignment
      self.unitStates[unit].alignment = GetAlignment(unit)
      if changes then
        addonTable.CallbackRegistry:TriggerCallback("UnitDesignChange", unit)
      end
    end
  elseif event == "NAME_PLATE_UNIT_REMOVED" then
    self.unitStates[unit] = nil
  end
end

function addonTable.Display.DesignForContextMixin:GetAssignedDesign(unit)
  if not self.unitStates[unit] then
    self.unitStates[unit] = GenerateState(unit)
  end
  local state = self.unitStates[unit]
  state.updates = {}

  return self:GetDesignFromState(state)
end

function addonTable.Display.DesignForContextMixin:GetDefaultEnemyNPCDesign()
  return self:GetDesignFromState({
    canAttack = true,
    inCombat = true,
    alignment = "enemy",
    isPlayer = false,
    isNPC = true,
    isMinion = false,
    isMinor = false,
    classification = "normal",
    location = "dungeon",
    eliteType = "trival",
    delveType = "melee",

    updates = {},
  })
end

function addonTable.Display.DesignForContextMixin:GetDefaultFriendlyPlayerDesign()
  return self:GetDesignFromState({
    canAttack = false,
    inCombat = false,
    alignment = "friend",
    isPlayer = true,
    isNPC = false,
    isMinion = false,
    isMinor = false,
    classification = "normal",
    location = "dungeon",
    eliteType = nil,
    delveType = nil,

    updates = {},
  })
end

function addonTable.Display.DesignForContextMixin:GetDesignFromState(state)
  local assignments = addonTable.Config.Get(addonTable.Config.Options.DESIGNS_ASSIGNED)
  for index, settings in ipairs(assignments) do
    local hit = true
    for _, criteria in ipairs(settings.criteria) do
      local details = assignmentsPossibilities[criteria]
      if details.updates then
        state.updates[details.updates] = true
      end
      if not details.check(state) then
        hit = false
        break
      end
    end

    if hit then
      return settings.style, settings.scale, settings.simplified or false, index
    end
  end

  return "_deer", 1, false, 0
end
