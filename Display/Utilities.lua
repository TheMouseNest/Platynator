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

do
  local function IsInCombatWith(unit)
    return UnitAffectingCombat(unit) and
      (
        UnitIsFriend("player", unit) and (UnitInParty(unit) == true or UnitInRaid(unit)== true ) or
        UnitThreatSituation("player", unit) ~= nil or
        UnitInParty(unit .. "target") == true or UnitInRaid(unit .. "target") == true
      )
  end

  local watching = {}
  C_Timer.NewTicker(0.08, function()
    local units = GetKeysArray(watching)
    for _, unit in ipairs(units) do
      local newState = IsInCombatWith(unit)
      if newState ~= watching[unit] then
        watching[unit] = newState
        addonTable.CallbackRegistry:TriggerEvent("CombatStatusChange", unit)
      end
    end
  end)
  local frame = CreateFrame("Frame")
  frame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
  frame:SetScript("OnEvent", function(_, _, unit)
    watching[unit] = nil
  end)

  function addonTable.Display.Utilities.IsInCombatWith(unit)
    if watching[unit] ~= nil then
      return watching[unit]
    else
      watching[unit] = IsInCombatWith(unit)
      return watching[unit]
    end
  end
end

function addonTable.Display.Utilities.ConvertColor(color)
  return CreateColor(color.r, color.g, color.b, color.a)
end

local rejectedInstanceTypes = {
  ["none"] = true,
  ["neighbourhood"] = true,
  ["interior"] = true,
}

function addonTable.Display.Utilities.IsInRelevantInstance(state)
  local _, baseType = IsInInstance()
  if rejectedInstanceTypes[baseType] then
    return false
  end
  state = state or {dungeon = true}
  local _, instanceType, _, label = GetInstanceInfo()
  if state.dungeon and (instanceType == "party") then
    return true
  end
  if state.raid and (instanceType == "raid") then
    return true
  end
  if state.pvp and (instanceType == "arena" or instanceType == "pvp") then
    return true
  end
  if state.delve and label == DELVES_LABEL then
    return true
  end
  return false
end

local interruptMap
if addonTable.Constants.IsClassic then
  interruptMap = {
    ["DEATHKNIGHT"] = {47528},
    ["WARRIOR"] = {6552},
    ["WARLOCK"] = {19647, 89766},
    ["SHAMAN"] = {57994},
    ["ROGUE"] = {1766},
    ["PRIEST"] = {15487},
    ["PALADIN"] = {31935, 96231},
    ["MONK"] = {116705},
    ["MAGE"] = {2139},
    ["HUNTER"] = {187707, 147362},
    ["DRUID"] = {38675, 78675, 106839},
  }
else
  interruptMap = {
    ["DEATHKNIGHT"] = {47528},
    ["WARRIOR"] = {6552},
    ["WARLOCK"] = {89766, 119910},
    ["SHAMAN"] = {57994},
    ["ROGUE"] = {1766},
    ["PRIEST"] = {15487},
    ["PALADIN"] = {96231, 31935},
    ["MONK"] = {116705},
    ["MAGE"] = {2139},
    ["HUNTER"] = {147362, 187707},
    ["EVOKER"] = {351338},
    ["DRUID"] = {38675, 78675, 106839},
    ["DEMONHUNTER"] = {183752},
  }
end

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

if addonTable.Constants.IsRetail then
  executeMap[2948] = 0.3 -- Mage: Scorch (critical strike)
end

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

local currentInterrupt = {}
local currentExecute = 0
local isSootheAvailable = false
do
  local class = UnitClassBase("player")
  local interruptSpells = interruptMap[class] or {}

  local frame = CreateFrame("Frame")
  frame:RegisterEvent("PLAYER_LOGIN")
  frame:RegisterEvent("SPELLS_CHANGED")
  frame:SetScript("OnEvent", function()
    currentInterrupt = {}
    for _, s in ipairs(interruptSpells) do
      if C_SpellBook.IsSpellKnownOrInSpellBook(s) or C_SpellBook.IsSpellKnownOrInSpellBook(s, Enum.SpellBookSpellBank.Pet) then
        table.insert(currentInterrupt, s)
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

function addonTable.Display.Utilities.GetInterruptSpells()
  return currentInterrupt
end

function addonTable.Display.Utilities.GetInterruptSpellPriority()
  return currentInterrupt[1]
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
    if addonTable.Display.Utilities.IsInRelevantInstance({dungeon = true, raid = true, pvp = true}) or C_Secrets.ShouldUnitIdentityBeSecret(unit) then
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

function addonTable.Display.Utilities.TintAutoColors(autoColors, mod)
  if mod.r ~= 1 or mod.g ~= 1 or mod.b ~= 1 then
    local modColors = CopyTable(autoColors)
    for _, s in ipairs(modColors) do
      for l, c in pairs(s.colors) do
        s.colors[l] = {r = mod.r * c.r, g = mod.g * c.g, b = mod.b * c.b, a = mod.a}
      end
      if s.kind == "classColors" then
        for class, c in pairs(RAID_CLASS_COLORS) do
          s.colors[class] = {r = mod.r * c.r, g = mod.g * c.g, b = mod.b * c.b, a = mod.a}
        end
      end
    end

    return modColors
  end
end

do
  local roleType = {
    Damage = 1,
    Healer = 2,
    Tank = 3,
  }

  local roleMap = {
    ["DAMAGER"] = roleType.Damage,
    ["TANK"] = roleType.Tank,
    ["HEALER"] = roleType.Healer,
  }

  local role = roleType.Damage
  local isTank = false
  local _, playerClass = UnitClass("player")

  local function GetPlayerRole()
    if addonTable.Constants.IsEra or addonTable.Constants.IsBC or addonTable.Constants.IsWrath then
      -- we're in classic
      local form = GetShapeshiftForm()
      if (playerClass == "WARRIOR" and form == 2) or (playerClass == "DRUID" and form == 1) then
        return roleType.Tank
      elseif playerClass == "PALADIN" and C_UnitAuras.GetUnitAuraBySpellID("player", 25780) ~= nil then
        return roleType.Tank
      end
    else
      local specIndex = C_SpecializationInfo.GetSpecialization()
      local _, _, _, _, role = C_SpecializationInfo.GetSpecializationInfo(specIndex)

      return roleMap[role]
    end
    return roleType.Damage
  end

  do
    local specializationMonitor = CreateFrame("Frame")

    if addonTable.Constants.IsEra or addonTable.Constants.IsBC or addonTable.Constants.IsWrath then
      if playerClass == "WARRIOR" or playerClass == "DRUID" then
        specializationMonitor:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
      elseif playerClass == "PALADIN" then
        specializationMonitor:RegisterUnitEvent("UNIT_AURA", "player")
      end
    elseif C_EventUtils.IsEventValid("PLAYER_SPECIALIZATION_CHANGED") then
      specializationMonitor:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    end
    specializationMonitor:RegisterEvent("PLAYER_ENTERING_WORLD")

    specializationMonitor:SetScript("OnEvent", function()
      local newRole = GetPlayerRole()
      if newRole ~= role then
        role = newRole
        isTank = role == roleType.Tank
        addonTable.CallbackRegistry:TriggerEvent("RoleChange")
      end
    end)
  end

  function addonTable.Display.Utilities.IsTankRole()
    return isTank
  end
end

do
  local inRelevantInstance = false

  -- Checking for party members below the player's level which indicates the mobs will be shifted down one
  -- Except when the dungeon is already at its minimum level, in which case the level won't shift.
  local instanceTracker = CreateFrame("Frame")
  instanceTracker:RegisterEvent("PLAYER_ENTERING_WORLD")
  instanceTracker:RegisterEvent("PLAYER_LEVEL_UP")
  instanceTracker:RegisterEvent("ZONE_CHANGED_NEW_AREA")
  instanceTracker:RegisterEvent("INSTANCE_GROUP_SIZE_CHANGED")
  instanceTracker:SetScript("OnEvent", function(_, event)
    inRelevantInstance = addonTable.Display.Utilities.IsInRelevantInstance({dungeon = true, raid = true, delve = true, pvp = true})
    local _, _, _, _, _, _, _, _, _, lfgDungeonID = GetInstanceInfo()
    if PLATYNATOR_LAST_INSTANCE == nil
      or (inRelevantInstance or inRelevantInstance) ~= PLATYNATOR_LAST_INSTANCE.inInstance
      or PLATYNATOR_LAST_INSTANCE.lastLFGInstanceID ~= lfgDungeonID
      or not inRelevantInstance then
      PLATYNATOR_LAST_INSTANCE = {
        lastLFGInstanceID = lfgDungeonID,
        inInstance = inRelevantInstance,
        instanceLieutenantLevel = nil,
      }
      if lfgDungeonID and addonTable.Display.Utilities.IsInRelevantInstance({dungeon = true}) then
        PLATYNATOR_LAST_INSTANCE.level = GetMaxLevelForExpansionLevel(GetMaximumExpansionLevel())
      else
        PLATYNATOR_LAST_INSTANCE.level = UnitEffectiveLevel("player")
      end
    end
  end)

  function addonTable.Display.Utilities.GetEliteType(unit, casterOverride)
    local classification = UnitClassification(unit)
    if classification == "elite" then
      local level = UnitEffectiveLevel(unit)
      local dungeonLevel = PLATYNATOR_LAST_INSTANCE.level
      local isRetail = addonTable.Constants.IsRetail
      local lieutentantLevel = PLATYNATOR_LAST_INSTANCE.instanceLieutenantLevel
      if isRetail and (level == dungeonLevel + 1 or UnitIsLieutenant(unit)) then
        PLATYNATOR_LAST_INSTANCE.instanceLieutenantLevel = level
        return "miniboss"
      elseif isRetail and (level == dungeonLevel + 2 or lieutentantLevel and level == lieutentantLevel + 1) or level == -1 then
        return "boss"
      else
        local class = UnitClassBase(unit)
        if class == "PALADIN" or class == "MAGE" or class == "PRIEST" then
          return "caster"
        else
          return "melee"
        end
      end
    elseif classification == "normal" or classification == "trivial" or classification == "minus" then
      if casterOverride then
        local class = UnitClassBase(unit)
        if class == "PALADIN" or class == "MAGE" or class == "PRIEST" then
          return "caster"
        end
      end
      return "trivial"
    end
  end

  function addonTable.Display.Utilities.GetDelveType(unit)
    local classification = UnitClassification(unit)
    if classification == "elite" then
      local level = UnitEffectiveLevel(unit)
      local dungeonLevel = PLATYNATOR_LAST_INSTANCE.level
      local isRetail = addonTable.Constants.IsRetail
      local lieutentantLevel = PLATYNATOR_LAST_INSTANCE.instanceLieutenantLevel
      if isRetail and UnitIsLieutenant(unit) then
        PLATYNATOR_LAST_INSTANCE.instanceLieutenantLevel = level
        return "elite"
      elseif isRetail and (level == dungeonLevel + 2 or lieutentantLevel and level == lieutentantLevel + 1) or level == -1 then
        return "boss"
      else
        return "elite"
      end
    elseif classification == "rareelite" then
      return "rare"
    elseif classification == "normal" then
      local class = UnitClassBase(unit)
      if class == "PALADIN" or class == "MAGE" or class == "PRIEST" then
        return "caster"
      else
        return "melee"
      end
    elseif classification == "trivial" or classification == "minus" then
      return "trivial"
    end
  end
end

do
  local groupTracker = CreateFrame("Frame")
  groupTracker:RegisterEvent("PLAYER_ENTERING_WORLD")
  groupTracker:RegisterEvent("INSTANCE_GROUP_SIZE_CHANGED")
  groupTracker:RegisterEvent("GROUP_ROSTER_UPDATE")
  groupTracker:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
  groupTracker:RegisterEvent("UNIT_PET")

  local knownTanksAndPetsMap = {}
  local knownTanksAndPetsList = {}

  groupTracker:SetScript("OnEvent", function(_, event, unit)
    local inRaid = IsInRaid()
    if event == "PLAYER_SPECIALIZATION_CHANGED" then
      if inRaid and unit:match("^raid") or not inRaid and unit:match("^party") then
        local role = UnitGroupRolesAssigned(unit)
        knownTanksAndPetsMap[unit] = role == "TANK" or nil
      end
    elseif event == "UNIT_PET" then
      local petUnit
      if inRaid and unit:match("^raid") then
        petUnit = "raidpet" .. unit:gsub("raid", "")
      elseif not inRaid and unit:match("^party") then
        petUnit = "partypet" .. unit:gsub("party", "")
      elseif not inRaid and unit == "player" then
        petUnit = "pet"
      end
      if petUnit then
        knownTanksAndPetsMap[petUnit] = UnitExists(petUnit) or nil
      end
    elseif inRaid then
      knownTanksAndPetsMap = {}
      for i = 1, 40 do
        local playerUnit = "raid" .. i
        if not UnitIsUnit(playerUnit, "player") then
          local role = UnitGroupRolesAssigned(playerUnit)
          knownTanksAndPetsMap[playerUnit] = role == "TANK" or nil
          local petUnit = "raidpet" .. i
          knownTanksAndPetsMap[petUnit] = UnitExists(petUnit) or nil
        end
      end
    else
      knownTanksAndPetsMap = {}
      for i = 1, 4 do
        local playerUnit = "party" .. i
        local role = UnitGroupRolesAssigned(playerUnit)
        knownTanksAndPetsMap[playerUnit] = role == "TANK" or nil
        local petUnit = "partypet" .. i
        knownTanksAndPetsMap[petUnit] = UnitExists(petUnit) or nil
      end
      knownTanksAndPetsMap["pet"] = UnitExists("pet") or nil
    end

    knownTanksAndPetsList = GetKeysArray(knownTanksAndPetsMap)
  end)

  function addonTable.Display.Utilities.GetOtherTanks()
    return knownTanksAndPetsList
  end
end
