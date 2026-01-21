---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.Utilities = {}

function addonTable.Display.Utilities.IsNeutralUnit(unit)
  if UnitSelectionType then
    return UnitSelectionType(unit) == 2
  else
    return UnitReaction(unit, "player") == 4
  end
end

function addonTable.Display.Utilities.IsUnfriendlyUnit(unit)
  if UnitSelectionType then
    return UnitSelectionType(unit) == 1
  else
    return UnitReaction(unit, "player") == 3
  end
end

function addonTable.Display.Utilities.IsTappedUnit(unit)
  return not UnitPlayerControlled(unit) and UnitIsTapDenied(unit)
end

function addonTable.Display.Utilities.GetUnitDifficulty(unit)
  if addonTable.Constants.IsRetail then
    local rawDifficulty = C_PlayerInfo.GetContentDifficultyCreatureForPlayer(unit)
    if rawDifficulty == Enum.RelativeContentDifficulty.Trivial then
      return  "trivial"
    elseif rawDifficulty == Enum.RelativeContentDifficulty.Easy then
      return "standard"
    elseif rawDifficulty == Enum.RelativeContentDifficulty.Fair then
      return "difficult"
    elseif rawDifficulty == Enum.RelativeContentDifficulty.Difficult then
      return "verydifficult"
    elseif rawDifficulty == Enum.RelativeContentDifficulty.Impossible then
      return "impossible"
    else
      return "difficult"
    end
  else
    local levelDiff = UnitLevel(unit) - UnitEffectiveLevel("player");
    if levelDiff >= 5 then
      return "impossible"
    elseif levelDiff >= 3 then
      return "verydifficult"
    elseif levelDiff >= -2 then
      return "difficult"
    elseif -levelDiff <= GetQuestGreenRange() then
      return "standard"
    else
      return  "trivial"
    end
  end
end

function addonTable.Display.Utilities.ConvertColor(color)
  return CreateColor(color.r, color.g, color.b, color.a)
end

function addonTable.Display.Utilities.IsInRelevantInstance()
  if not IsInInstance() then
    return false
  end
  local _, instanceType = GetInstanceInfo()
  return instanceType == "raid" or instanceType == "party" or instanceType == "arenas"
end

local interruptMap = {
  ["DEATHKNIGHT"] = {47528, 47476},
  ["WARRIOR"] = {6552},
  ["WARLOCK"] = {19647, 1276467},
  ["SHAMAN"] = {57994},
  ["ROGUE"] = {1766},
  ["PRIEST"] = {15487},
  ["PALADIN"] = {96231, 31935},
  ["MONK"] = {116705},
  ["MAGE"] = {2139},
  ["HUNTER"] = {187707, 147362},
  ["EVOKER"] = {351338},
  ["DRUID"] = {38675, 78675, 106839},
  ["DEMONHUNTER"] = {183752},
}

local interruptSpells = interruptMap[UnitClassBase("player")] or {}

function addonTable.Display.Utilities.GetInterruptSpell()
  for _, s in ipairs(interruptSpells) do
    if C_SpellBook.IsSpellKnown(s) or C_SpellBook.IsSpellKnown(s, Enum.SpellBookSpellBank.Pet) then
      return s
    end
  end
end

if addonTable.Constants.IsClassic then
  local NUMBER_ABBREVIATION_DATA_ALT = {
    { breakpoint = 10000000,	abbreviation = SECOND_NUMBER_CAP_NO_SPACE,	significandDivisor = 1000000,	fractionDivisor = 1 },
    { breakpoint = 1000000,		abbreviation = SECOND_NUMBER_CAP_NO_SPACE,	significandDivisor = 100000,		fractionDivisor = 10 },
    { breakpoint = 10000,		abbreviation = FIRST_NUMBER_CAP_NO_SPACE,	significandDivisor = 1000,		fractionDivisor = 1 },
    { breakpoint = 1000,		abbreviation = FIRST_NUMBER_CAP_NO_SPACE,	significandDivisor = 100,		fractionDivisor = 10 },
  }

  addonTable.Display.Utilities.AbbreviateNumbersAlt = function(value)
    for i, data in ipairs(NUMBER_ABBREVIATION_DATA_ALT) do
      if value >= data.breakpoint then
        local finalValue = math.floor(value / data.significandDivisor) / data.fractionDivisor;
        return finalValue .. data.abbreviation;
      end
    end
    return tostring(value);
  end
end
