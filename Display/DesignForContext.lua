---@class addonTablePlatynator
local addonTable = select(2, ...)

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

local function IsMinor(unit)
  return UnitClassification(unit) == "minus"
end

local function IsNPC(unit)
  return not IsPlayer(unit) and not IsMinion(unit)
end

local IsNeutral = addonTable.Display.Utilities.IsNeutralUnit

local function IsHostile(unit)
  return not UnitIsFriend("player", unit) and not IsNeutral(unit)
end

local function IsFriendly(unit)
  return UnitIsFriend("player", unit)
end

local function IsInstanceType(t)
  local _, instanceType = GetInstanceInfo()
  return instanceType == t
end

local function IsDifficulty(d)
  local _, _, difficultyID = GetInstanceInfo()
  return difficultyID == d
end

local IsInCombat = addonTable.Display.Utilities.IsInCombatWith

local assignmentsPossibilities = {
  ["can-attack"] = { frequent = true, check = function(unit) return UnitCanAttack("player", unit) end },
  ["cannot-attack"] = { frequent = true, check = function(unit) return not UnitCanAttack("player", unit) end },

  ["in-combat"] = { frequent = true, check = function(unit) return IsInCombat(unit) end },
  ["out-combat"] = { frequent = true, check = function(unit) return not IsInCombat(unit) end },

  ["friendly"] = { faction = true, check = IsFriendly},
  ["hostile"] = { faction = true, check = IsHostile},
  ["neutral"] = { faction = true, check = IsNeutral },

  ["player"] = { check = IsPlayer },
  ["npc"] = { check = IsNPC },
  ["minion"] = { check = IsMinion },
  ["minor"] = { check = IsMinor },

  ["class-rare"] = { classification = true, check = function(unit) local c = UnitClassification(unit); return c == "rare" or c == "rareelite" end },
  ["class-elite"] = { classification = true, check = function(unit) local c = UnitClassification(unit); return c == "elite" or c == "rareelite" end },
  ["class-worldboss"] = { classification = true, check = function(unit) return UnitClassification(unit) == "worldboss" end },
  ["class-minor"] = { classification = true, check = function(unit) return UnitClassification(unit) == "minor" end },
  ["class-trivial"] = { classification = true, check = function(unit) return UnitClassification(unit) == "trivial" end },

  ["loc-world"] = { check = function() return not IsInInstance() end },
  ["loc-dungeon"] = { check = function() return IsInstanceType("party") end },
  ["loc-raid"] = { check = function() return IsInstanceType("raid") end },
  ["loc-pvp"] = { check = function() return addonTable.Display.Utilities.IsInRelevantInstance({pvp = true}) end },
  ["loc-delve"] = { check = function() return addonTable.Display.Utilities.IsInRelevantInstance({delve = true}) end },

  ["elite-boss"] = { classification = true, check = function(unit) return addonTable.Display.Utilities.GetEliteType(unit) == "boss" end },
  ["elite-miniboss"] = { classification = true, check = function(unit) return addonTable.Display.Utilities.GetEliteType(unit) == "miniboss" end },
  ["elite-caster"] = { classification = true, check = function(unit) return addonTable.Display.Utilities.GetEliteType(unit) == "caster" end },
  ["elite-melee"] = { classification = true, check = function(unit) return addonTable.Display.Utilities.GetEliteType(unit) == "melee" end },
  ["elite-trivial"] = { classification = true, check = function(unit) return addonTable.Display.Utilities.GetEliteType(unit) == "trivial" end },

  ["delve-boss"] = { classification = true, check = function(unit) return addonTable.Display.Utilities.GetDelveType(unit) == "boss" end },
  ["delve-elite"] = { classification = true, check = function(unit) return addonTable.Display.Utilities.GetDelveType(unit) == "elite" end },
  ["delve-rare"] = { classification = true, check = function(unit) return addonTable.Display.Utilities.GetDelveType(unit) == "rare" end },
  ["delve-caster"] = { classification = true, check = function(unit) return addonTable.Display.Utilities.GetDelveType(unit) == "caster" end },
  ["delve-melee"] = { classification = true, check = function(unit) return addonTable.Display.Utilities.GetDelveType(unit) == "melee" end },
  ["delve-trivial"] = { classification = true, check = function(unit) return addonTable.Display.Utilities.GetDelveType(unit) == "trivial" end },
}

addonTable.Display.DesignForContextMixin = {}
function addonTable.Display.DesignForContextMixin:OnLoad()
  addonTable.CallbackRegistry:RegisterCallback("DesignsAssigned", function(_, settingName)
    if settingName == addonTable.Config.Options.DESIGNS_ASSIGNED then
      self:RefreshDesignAssignments()
      addonTable.CallbackRegistry:TriggerCallback("RefreshStateChange", {[addonTable.Constants.RefreshReason.DesignSelection] = true})
    end
  end)
end

function addonTable.Display.DesignForContextMixin:RefreshDesignAssignments()
end

function addonTable.Display.DesignForContextMixin:GetAssignedDesign(unit)
  local assignments = addonTable.Config.Get(addonTable.Config.Options.DESIGNS_ASSIGNED)

  for index, settings in ipairs(assignments) do
    local hit = true
    for _, criteria in ipairs(settings.criteria) do
      if not assignmentsPossibilities[criteria].check(unit) then
        hit = false
        break
      end
    end

    if hit then
      return settings.style, settings.simplified or false, index
    end
  end

  return "_deer", false, 0
end
