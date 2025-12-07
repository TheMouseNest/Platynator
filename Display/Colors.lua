---@class addonTablePlatynator
local addonTable = select(2, ...)

local IsTapped = addonTable.Display.Utilities.IsTappedUnit
local IsNeutral = addonTable.Display.Utilities.IsNeutralUnit
local IsUnfriendly = addonTable.Display.Utilities.IsUnfriendlyUnit

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

local function GetPlayerRole()
  if not C_SpecializationInfo.GetSpecialization then
    return roleType.Damage
  end
  local specIndex = C_SpecializationInfo.GetSpecialization()
  local _, _, _, _, role = C_SpecializationInfo.GetSpecializationInfo(specIndex)

  return roleMap[role]
end

local function DoesOtherTankHaveAggro(unit)
  return IsInRaid() and UnitGroupRolesAssigned(unit .. "target") == "TANK"
end

local inRelevantInstance = false

local instanceTracker = CreateFrame("Frame")
instanceTracker:RegisterEvent("PLAYER_ENTERING_WORLD")
instanceTracker:SetScript("OnEvent", function()
  local _, instanceType = GetInstanceInfo()
  inRelevantInstance = instanceType == "raid" or instanceType == "party" or instanceType == "arenas"
  if PLATYNATOR_LAST_INSTANCE == nil or inRelevantInstance ~= PLATYNATOR_LAST_INSTANCE.inInstance or PLATYNATOR_LAST_INSTANCE.lastLFGInstanceID ~= select(10, GetInstanceInfo()) then
    PLATYNATOR_LAST_INSTANCE = {
      level = UnitEffectiveLevel("player"),
      lastLFGInstanceID = select(10, GetInstanceInfo()),
      inInstance = inRelevantInstance,
    }
  end
end)

local kindToEvent = {
  tapped = "UNIT_HEALTH",
  target = "PLAYER_TARGET_CHANGED",
  focus = "PLAYER_FOCUS_CHANGED",
  threat = "UNIT_THREAT_LIST_UPDATE",
  quest = "QUEST_LOG_UPDATE",
}

function addonTable.Display.UnregisterForColorEvents(frame)
  frame.ColorEventHandler = nil
end

function addonTable.Display.RegisterForColorEvents(frame, settings)
  local events = {}
  for _, s in ipairs(settings) do
    local e = kindToEvent[s.kind]
    if e then
      events[e] = true
      frame:RegisterEvent(e)
    end
  end

  function frame:ColorEventHandler(eventName)
    if events[eventName] then
      self:SetColor(addonTable.Display.GetColor(settings, self.unit))
    end
  end
end

function addonTable.Display.GetColor(settings, unit)
  for _, s in ipairs(settings) do
    if s.kind == "tapped" then
      if IsTapped(unit) then
        return s.colors.tapped
      end
    elseif s.kind == "target" then
      if UnitIsUnit("target", unit) then
        return s.colors.target
      end
    elseif s.kind == "focus" then
      if UnitIsUnit("focus", unit) then
        return s.colors.focus
      end
    elseif s.kind == "threat" then
      local threat = UnitThreatSituation("player", unit)
      local hostile = UnitCanAttack("player", unit) and UnitIsEnemy(unit, "player")
      if (inRelevantInstance or not s.instancesOnly) and (threat or (hostile and not s.combatOnly)) then
        local role = GetPlayerRole()
        if (role == roleType.Tank and (threat == 0 or threat == nil) and not DoesOtherTankHaveAggro(unit)) or (role ~= roleType.Tank and threat == 3) then
          return s.colors.warning
        elseif threat == 1 or threat == 2 then
          return s.colors.transition
        elseif (role == roleType.Tank and threat == 3) or (role ~= roleType.Tank and (threat == 0 or threat == nil)) then
          return s.colors.safe
        elseif role == roleType.Tank and (threat == 0 or threat == nil) and DoesOtherTankHaveAggro(unit) then
          return s.colors.offtank
        end
      end
    elseif s.kind == "eliteType" then
      if inRelevantInstance or not s.instancesOnly then
        local classification = UnitClassification(unit)
        if classification == "elite" then
          local level = UnitEffectiveLevel(unit)
          local playerLevel = PLATYNATOR_LAST_INSTANCE.level
          if level >= playerLevel + 2 then
            return s.colors.boss
          elseif level == playerLevel + 1 then
            return s.colors.miniboss
          elseif level == playerLevel then
            local class = UnitClassBase(unit)
            if class == "PALADIN" then
              return s.colors.caster
            else
              return s.colors.melee
            end
          end
        elseif classification == "normal" or classification == "trivial" then
          return s.colors.trivial
        end
      end
    elseif s.kind == "quest" then
      if C_QuestLog.UnitIsRelatedToActiveQuest and C_QuestLog.UnitIsRelatedToActiveQuest(unit) then
        return s.colors.quest
      end
    elseif s.kind == "guild" then
      if UnitIsPlayer(unit) then
        local playerGuild, _, _, playerRealm = GetGuildInfo("player")
        local unitGuild, _, _, unitRealm = GetGuildInfo(unit)
        if playerGuild ~= nil and playerGuild == unitGuild and playerRealm == unitRealm then
          return s.colors.guild
        end
      end
    elseif s.kind == "classColors" then
      if UnitIsPlayer(unit) then
        return RAID_CLASS_COLORS[UnitClassBase(unit)]
      end
    elseif s.kind == "reaction" then
      if IsNeutral(unit) then
        return s.colors.neutral
      elseif IsUnfriendly(unit) then
        return s.colors.unfriendly
      elseif UnitIsFriend("player", unit) then
        return s.colors.friendly
      else
        return s.colors.hostile
      end
    elseif s.kind == "difficulty" then
      return s.colors[addonTable.Display.Utilities.GetUnitDifficulty(unit)]
    elseif s.kind == "fixed" then
      return s.colors.fixed
    end
  end
end
