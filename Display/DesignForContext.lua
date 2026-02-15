---@class addonTablePlatynator
local addonTable = select(2, ...)

local function IsPlayer(unit)
  return UnitIsPlayer(unit) or UnitTreatAsPlayerForDisplay and UnitTreatAsPlayerForDisplay(unit)
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

local function IsInCombat(unit)
  return InCombatLockdown() and
    UnitAffectingCombat(unit) and
    (
      UnitIsFriend(unit) or
      UnitThreatSituation("player", unit) ~= nil or
      IsInGroup("player") and (UnitInParty(unit .. "target") or UnitInRaid(unit .. "target")) and UnitThreatSituation(unit .. "target") ~= nil
    )
end

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

  ["rare"] = { check = function(unit) local c = UnitClassification(unit); return c == "rare" or c == "rareelite" end },
  ["elite"] = { check = function(unit) local c = UnitClassification(unit); return c == "elite" or c == "rareelite" end },
  ["worldboss"] = { check = function(unit) return UnitClassification(unit) == "worldboss" end },
  ["trivial"] = { check = function(unit) return UnitClassification(unit) == "trivial" end },

  ["instance"] = { check = addonTable.Display.Utilities.IsInRelevantInstance },
  ["dungeon"] = { check = function() return IsInstanceType("party") end },
  ["raid"] = { check = function() return IsInstanceType("raid") end },
  ["arena"] = { check = function() return IsInstanceType("arena") end },
  ["battleground"] = { check = function() return IsInstanceType("pvp") end },
  ["delve"] = { check = function() return IsDifficulty(208) end },
}

addonTable.Display.DesignForContextMixin = {}
function addonTable.Display.DesignForContextMixin:OnLoad()
  addonTable.CallbackRegistry:RegisterCallback("DesignsAssigned", function(_, settingName)
    if settingName == addonTable.Config.Options.DESIGNS_ASSIGNED then
      self:RefreshDesignAssignments()
    end
  end)
end

function addonTable.Display.DesignForContextMixin:RefreshDesignAssignments()
end
