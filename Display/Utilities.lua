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

function addonTable.Display.Utilities.IsInCombatWith(unit)
  return InCombatLockdown() and
    UnitAffectingCombat(unit) and
    (
      UnitIsFriend("player", unit) or
      UnitThreatSituation("player", unit) ~= nil or
      IsInGroup() and (UnitInParty(unit .. "target") or UnitInRaid(unit .. "target")) and UnitThreatSituation(unit .. "target", unit) ~= nil
    )
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
  ["DEATHKNIGHT"] = {47528},
  ["WARRIOR"] = {6552},
  ["WARLOCK"] = {19647, 89766, 119910, 1276467, 132409},
  ["SHAMAN"] = {57994},
  ["ROGUE"] = {1766},
  ["PRIEST"] = {15487},
  ["PALADIN"] = {31935, 96231},
  ["MONK"] = {116705},
  ["MAGE"] = {2139},
  ["HUNTER"] = {187707, 147362},
  ["EVOKER"] = {351338},
  ["DRUID"] = {38675, 78675, 106839},
  ["DEMONHUNTER"] = {183752},
}

local executeMap = {
  -- Hunter
  [5331] = 0.2,
  -- Warrior (Retail)
  [163201] = 0.2, -- (Arms/Prot)
  [5308] = 0.2, -- (Fury)
  [281001] = 0.35, -- (Massacre, Arms/Prot)
  [206315] = 0.35, -- (Massacre, Fury)
  -- Monk (Retail)
  [322109] = 0.15,
  --Priest (Retail)
  [32379] = 0.2,
  [392507] = 0.35, -- (Deathspeaker)
  -- Death Knight (Retail)
  [343294] = 0.35,
  -- Rogue
  [328085] = 0.35,
  -- Warlock
  [388667] = 0.2, -- Drain soul
  [17877] = 0.2, -- Shadowburn
  [234876] = 0.35, -- Death's Embrace

  --Warrior (Classic ranks)
  [20658] = 0.2,
  [20661] = 0.2,
  [20662] = 0.2,
  -- Hunter (Classic ranks)
  [53351] = 0.2,
  [61005] = 0.2,
  [61006] = 0.2,
  -- Monk (MoP)
  [115080] = 0.1,
  -- Paladin (Classic ranks)
  [24275] = 0.2,
  [24274] = 0.2,
  [24239] = 0.2,
  [27180] = 0.2,
  [48805] = 0.2,
  [48806] = 0.2,
}

local sootheSpells = {
  2908,
  374346,
  19801,
  5938,

  -- Arcane Torrent (Blood Elf Racial)
  28730, 25046, 202719, 129597, 80483, 69179, 155145, 50613, 232633
}

local executeCurve
if C_CurveUtil then
  executeCurve = C_CurveUtil.CreateCurve()
  executeCurve:SetType(Enum.LuaCurveType.Step)
end

local currentInterrupt
local currentExecute = 0
local isSootheAvailable = false
do
  local class = UnitClassBase("player")
  local interruptSpells = interruptMap[class] or {}

  local frame = CreateFrame("Frame")
  frame:RegisterEvent("PLAYER_LOGIN")
  frame:RegisterEvent("SPELLS_CHANGED")
  frame:SetScript("OnEvent", function()
    currentInterrupt = nil
    for _, s in ipairs(interruptSpells) do
      if C_SpellBook.IsSpellKnownOrInSpellBook(s) or C_SpellBook.IsSpellKnownOrInSpellBook(s, Enum.SpellBookSpellBank.Pet) then
        currentInterrupt = s
      end
    end

    currentExecute = 0
    for s, amount in pairs(executeMap) do
      if C_SpellBook.IsSpellKnown(s) then
        currentExecute = math.max(amount, currentExecute)
      end
    end

    if executeCurve and currentExecute > 0 then
      executeCurve:ClearPoints()
      executeCurve:AddPoint(0, 1)
      executeCurve:AddPoint(currentExecute, 0)
    end

    isSootheAvailable = false
    for _, spellID in ipairs(sootheSpells) do
      if C_SpellBook.IsSpellKnown(spellID) then
        isSootheAvailable = true
        break
      end
    end
  end)
end

function addonTable.Display.Utilities.GetInterruptSpell()
  return currentInterrupt
end

function addonTable.Display.Utilities.GetExecuteRange()
  return currentExecute
end

function addonTable.Display.Utilities.GetExecuteCurve()
  return executeCurve
end

function addonTable.Display.Utilities.GetSootheAvailable()
  return isSootheAvailable
end

local ignoredLocales = {
  "zhTW",
  "zhCN",
  "koKR",
  "ruRU",
}
if addonTable.Constants.IsMists and tIndexOf(ignoredLocales, GetLocale()) == nil then
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

if addonTable.Constants.IsRetail then
  local questData = {}
  do
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
    frame:RegisterEvent("QUEST_LOG_UPDATE")
    frame:SetScript("OnEvent", function(_, event, unit)
      if event == "NAME_PLATE_UNIT_REMOVED" then
        questData[unit] = nil
      elseif event == "QUEST_LOG_UPDATE" then
        questData = {}
        addonTable.CallbackRegistry:TriggerEvent("QuestInfoUpdate")
      end
    end)
  end

  local questLineTypes = {
    [Enum.TooltipDataLineType.QuestObjective] = true,
    [Enum.TooltipDataLineType.QuestTitle] = true,
    [Enum.TooltipDataLineType.QuestPlayer] = true,
  }
  local playerName = UnitName("player")

  function addonTable.Display.Utilities.GetQuestInfo(unit)
    if questData[unit] then
      return questData[unit]
    end
    if addonTable.Display.Utilities.IsInRelevantInstance() or C_Secrets.ShouldUnitIdentityBeSecret(unit) then
      questData[unit] = {}
      return questData[unit]
    end

    local info = C_TooltipInfo.GetUnit(unit)
    if info then
      local lines = tFilter(info.lines, function(l)
        return questLineTypes[l.type]
      end, true)
      local data = {}
      local ignoreUntilTitle = false
      for _, l in ipairs(lines) do
        if not ignoreUntilTitle and l.type == Enum.TooltipDataLineType.QuestObjective then
          local count1, count2 = l.leftText:match("(%d+)%/(%d+)")
          if count1 ~= count2 then
            table.insert(data, count1 .. "/" .. count2)
          end
          local percent = l.leftText:match("(%d+)%%")
          if percent and percent ~= "100" then
            table.insert(data, percent .. "%")
          end
        elseif l.type == Enum.TooltipDataLineType.QuestTitle then
          ignoreUntilTitle = false
        elseif l.type == Enum.TooltipDataLineType.QuestPlayer then
          if l.leftText == playerName then
            ignoreUntilTitle = false
          else
            ignoreUntilTitle = true
          end
        end
      end
      questData[unit] = data
    else
      questData[unit] = {}
    end

    return questData[unit]
  end
else
  local questData = {}
  local frame = CreateFrame("Frame")
  frame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
  frame:SetScript("OnEvent", function(_, _, unit)
    questData[unit] = nil
  end)

  local QuestieTooltips

  addonTable.Utilities.OnAddonLoaded("Questie", function()
    Questie.API.RegisterOnReady(function()
      QuestieTooltips = QuestieLoader:ImportModule("QuestieTooltips")
      addonTable.CallbackRegistry:TriggerEvent("QuestInfoUpdate")
      Questie.API.RegisterForQuestUpdates(function()
        questData = {}
        addonTable.CallbackRegistry:TriggerEvent("QuestInfoUpdate")
      end)
    end)
  end)

  function addonTable.Display.Utilities.GetQuestInfo(unit)
    if not Questie or not Questie.API.isReady then
      return {}
    end

    local npcID = UnitGUID(unit):match("Creature%-%d+%-%d+%-%d+%-%d+%-(%d+)")
    if not npcID then
      return {}
    end
    local status = pcall(function()
      local data = QuestieTooltips.lookupByKey["m_" .. npcID]
      if data then
        local result = {}
        for _, tooltip in pairs(data) do
          if not tooltip.name then
            local objective = tooltip.objective
            if objective.Collected ~= objective.Needed then
              table.insert(result, objective.Collected .. "/" .. objective.Needed)
            end
          end
        end
        questData[unit] = result
      end
    end)
    if not status then
      questData[unit] = {Questie.API.GetQuestObjectiveIconForUnit(UnitGUID(unit)) ~= nil and "" or nil}
    end
    return questData[unit] or {}
  end

end
