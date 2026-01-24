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

local GetInterruptSpell = addonTable.Display.Utilities.GetInterruptSpell

local transparency = {r = 1, g = 1, b = 1, a = 0}

local function DoesOtherTankHaveAggro(unit)
  return IsInRaid() and UnitGroupRolesAssigned(unit .. "target") == "TANK"
end

local inRelevantInstance = false

local instanceTracker = CreateFrame("Frame")
instanceTracker:RegisterEvent("PLAYER_ENTERING_WORLD")
instanceTracker:SetScript("OnEvent", function()
  inRelevantInstance = addonTable.Display.Utilities.IsInRelevantInstance()
  if PLATYNATOR_LAST_INSTANCE == nil or inRelevantInstance ~= PLATYNATOR_LAST_INSTANCE.inInstance or PLATYNATOR_LAST_INSTANCE.lastLFGInstanceID ~= select(10, GetInstanceInfo()) then
    PLATYNATOR_LAST_INSTANCE = {
      level = UnitEffectiveLevel("player"),
      lastLFGInstanceID = select(10, GetInstanceInfo()),
      inInstance = inRelevantInstance,
    }
  end
end)

local stateToEvent = {
  cast = {
    "UNIT_SPELLCAST_START",
    "UNIT_SPELLCAST_STOP",
    "UNIT_SPELLCAST_FAILED",
    "UNIT_SPELLCAST_INTERRUPTED",
    "UNIT_SPELLCAST_INTERRUPTIBLE",
    "UNIT_SPELLCAST_NOT_INTERRUPTIBLE",
    "UNIT_SPELLCAST_CHANNEL_START",
    "UNIT_SPELLCAST_CHANNEL_STOP",
  },
  quest = {
    "QUEST_LOG_UPDATE",
  },
  threat = {
    "UNIT_THREAT_LIST_UPDATE",
  }
}

local stateToCalculator = {
  cast = function(state, unit)
    state.cast = true
    state.castInfo = {UnitCastingInfo(unit)}
    state.channelInfo = {UnitChannelInfo(unit)}
  end,
  quest = function(state, unit)
    state.quest = C_QuestLog.UnitIsRelatedToActiveQuest and C_QuestLog.UnitIsRelatedToActiveQuest(unit)
  end,
  threat = function(state, unit)
    state.threat = UnitThreatSituation("player", unit)
    state.hostile = UnitCanAttack("player", unit) and UnitIsEnemy(unit, "player")
  end
}

local eventToState = {}
local eventToCalulator = {}
for key, events in pairs(stateToEvent) do
  for _, e in ipairs(events) do
    eventToState[e] = key
    eventToCalulator[e] = stateToCalculator[key]
  end
end

local kindToEvent = {
  reaction = {"UNIT_FACTION"},
  tapped = {"UNIT_HEALTH"},
  target = {"PLAYER_TARGET_CHANGED"},
  softTarget = {"PLAYER_TARGET_CHANGED", "PLAYER_SOFT_ENEMY_CHANGED", "PLAYER_SOFT_FRIEND_CHANGED"},
  focus = {"PLAYER_FOCUS_CHANGED"},
  threat = {"UNIT_THREAT_LIST_UPDATE"},
  quest = {"QUEST_LOG_UPDATE"},
  interruptReady = {
    "UNIT_SPELLCAST_START",
    "UNIT_SPELLCAST_STOP",
    "UNIT_SPELLCAST_FAILED",
    "UNIT_SPELLCAST_INTERRUPTED",
    "UNIT_SPELLCAST_INTERRUPTIBLE",
    "UNIT_SPELLCAST_NOT_INTERRUPTIBLE",
    "UNIT_SPELLCAST_CHANNEL_START",
    "UNIT_SPELLCAST_CHANNEL_STOP",
    "ACTIONBAR_UPDATE_USABLE",
    "SPELL_UPDATE_USABLE",
  },
  uninterruptableCast = {
    "UNIT_SPELLCAST_START",
    "UNIT_SPELLCAST_STOP",
    "UNIT_SPELLCAST_FAILED",
    "UNIT_SPELLCAST_INTERRUPTED",
    "UNIT_SPELLCAST_CHANNEL_START",
    "UNIT_SPELLCAST_CHANNEL_STOP",
    "UNIT_SPELLCAST_INTERRUPTIBLE",
    "UNIT_SPELLCAST_NOT_INTERRUPTIBLE",
  },
  castTargetsYou = {
    "UNIT_SPELLCAST_START",
    "UNIT_SPELLCAST_STOP",
    "UNIT_SPELLCAST_FAILED",
    "UNIT_SPELLCAST_INTERRUPTED",
    "UNIT_SPELLCAST_CHANNEL_START",
    "UNIT_SPELLCAST_CHANNEL_STOP",
  },
  cast = {
    "UNIT_SPELLCAST_START",
    "UNIT_SPELLCAST_STOP",
    "UNIT_SPELLCAST_FAILED",
    "UNIT_SPELLCAST_INTERRUPTED",
    "UNIT_SPELLCAST_CHANNEL_START",
    "UNIT_SPELLCAST_CHANNEL_STOP",
    "UNIT_SPELLCAST_INTERRUPTIBLE",
    "UNIT_SPELLCAST_NOT_INTERRUPTIBLE",
  },
  importantCast = {
    "UNIT_SPELLCAST_START",
    "UNIT_SPELLCAST_STOP",
    "UNIT_SPELLCAST_FAILED",
    "UNIT_SPELLCAST_INTERRUPTED",
    "UNIT_SPELLCAST_CHANNEL_START",
    "UNIT_SPELLCAST_CHANNEL_STOP",
  },
}

function addonTable.Display.UnregisterForColorEvents(frame)
  frame.ColorEventHandler = nil
  frame.colorState = nil
end

function addonTable.Display.RegisterForColorEvents(frame, settings)
  local events = {}
  frame.colorState = {}
  for _, s in ipairs(settings) do
    local es = kindToEvent[s.kind]
    if es then
      for _, e in ipairs(es) do
        events[e] = true
        local stateKind = eventToState[e]
        local state = frame.colorState[stateKind]
        if stateKind and state == nil then
          stateToCalculator[stateKind](frame.colorState, frame.unit)
        end
        if e:match("^UNIT") then
          frame:RegisterUnitEvent(e, frame.unit)
        else
          frame:RegisterEvent(e)
        end
      end
    end
  end

  function frame:ColorEventHandler(eventName)
    if events[eventName] then
      local calculator = eventToCalulator[eventName]
      if calculator then
        calculator(frame.colorState, self.unit)
      end
      self:SetColor(addonTable.Display.GetColor(settings, frame.colorState, self.unit))
    end
  end
end

local function SplitEvaluate(state, r1, g1, b1, a1, r2, g2, b2, a2)
  return C_CurveUtil.EvaluateColorValueFromBoolean(state, r1, r2),
    C_CurveUtil.EvaluateColorValueFromBoolean(state, g1, g2),
    C_CurveUtil.EvaluateColorValueFromBoolean(state, b1, b2),
    C_CurveUtil.EvaluateColorValueFromBoolean(state, a1 or 1, a2 or 1)
end

function addonTable.Display.GetColor(settings, state, unit)
  local colorQueue = {}
  for _, s in ipairs(settings) do
    if s.kind == "tapped" then
      if IsTapped(unit) then
        table.insert(colorQueue, {color = s.colors.tapped})
        break
      end
    elseif s.kind == "target" then
      if UnitIsUnit("target", unit) and not IsTargetLoose() then
        table.insert(colorQueue, {color = s.colors.target})
        break
      end
    elseif s.kind == "softTarget" then
      if IsTargetLoose() and (UnitIsUnit("softenemy", unit) or UnitIsUnit("softfriend", unit)) then
        table.insert(colorQueue, {color = s.colors.softTarget})
        break
      end
    elseif s.kind == "focus" then
      if UnitIsUnit("focus", unit) then
        table.insert(colorQueue, {color = s.colors.focus})
        break
      end
    elseif s.kind == "threat" then
      local threat = state.threat
      local hostile = state.hostile
      if (inRelevantInstance or not s.instancesOnly) and (threat or (hostile and not s.combatOnly) or (inRelevantInstance and UnitAffectingCombat(unit))) then
        local role = GetPlayerRole()
        if (role == roleType.Tank and (threat == 0 or threat == nil) and not DoesOtherTankHaveAggro(unit)) or (role ~= roleType.Tank and threat == 3) then
          table.insert(colorQueue, {color = s.colors.warning})
          break
        elseif threat == 1 or threat == 2 then
          table.insert(colorQueue, {color = s.colors.transition})
          break
        elseif s.useSafeColor and ((role == roleType.Tank and threat == 3) or (role ~= roleType.Tank and (threat == 0 or threat == nil))) then
          table.insert(colorQueue, {color = s.colors.safe})
          break
        elseif role == roleType.Tank and (threat == 0 or threat == nil) and DoesOtherTankHaveAggro(unit) then
          table.insert(colorQueue, {color = s.colors.offtank})
          break
        end
      end
    elseif s.kind == "eliteType" then
      if (inRelevantInstance or not s.instancesOnly) and not addonTable.Display.Utilities.IsNeutralUnit(unit) then
        local classification = UnitClassification(unit)
        if classification == "elite" then
          local level = UnitEffectiveLevel(unit)
          local playerLevel = PLATYNATOR_LAST_INSTANCE.level
          if level >= playerLevel + 2 then
            table.insert(colorQueue, {color = s.colors.boss})
            break
          elseif level == playerLevel + 1 then
            table.insert(colorQueue, {color = s.colors.miniboss})
            break
          elseif level == playerLevel then
            local class = UnitClassBase(unit)
            if class == "PALADIN" then
              table.insert(colorQueue, {color = s.colors.caster})
            else
              table.insert(colorQueue, {color = s.colors.melee})
            end
            break
          end
        elseif classification == "normal" or classification == "trivial" then
          table.insert(colorQueue, {color = s.colors.trivial})
          break
        end
      end
    elseif s.kind == "quest" then
      if state.quest then
        if IsNeutral(unit) then
          table.insert(colorQueue, {color = s.colors.neutral})
          break
        elseif UnitIsFriend("player", unit) then
          table.insert(colorQueue, {color = s.colors.friendly})
          break
        else
          table.insert(colorQueue, {color = s.colors.hostile})
          break
        end
      end
    elseif s.kind == "guild" then
      if UnitIsPlayer(unit) then
        local playerGuild, _, _, playerRealm = GetGuildInfo("player")
        local unitGuild, _, _, unitRealm = GetGuildInfo(unit)
        if playerGuild ~= nil and playerGuild == unitGuild and playerRealm == unitRealm then
          table.insert(colorQueue, {color = s.colors.guild})
          break
        end
      end
    elseif s.kind == "classColors" then
      if UnitIsPlayer(unit) or UnitTreatAsPlayerForDisplay and UnitTreatAsPlayerForDisplay(unit) then
        local _, class = UnitClass(unit)
        table.insert(colorQueue, {color = RAID_CLASS_COLORS[class]})
        break
      end
    elseif s.kind == "reaction" then
      if IsNeutral(unit) then
        table.insert(colorQueue, {color = s.colors.neutral})
      elseif IsUnfriendly(unit) then
        table.insert(colorQueue, {color = s.colors.unfriendly})
      elseif UnitIsFriend("player", unit) and not UnitCanAttack("player", unit) then
        table.insert(colorQueue, {color = s.colors.friendly})
      else
        table.insert(colorQueue, {color = s.colors.hostile})
      end
      break
    elseif s.kind == "difficulty" then
      table.insert(colorQueue, {color = s.colors[addonTable.Display.Utilities.GetUnitDifficulty(unit)]})
      break
    elseif s.kind == "interruptReady" then
      local castInfo = state.castInfo
      local channelInfo = state.channelInfo
      local notInterruptible = castInfo[8]
      if notInterruptible == nil then
        notInterruptible = channelInfo[7]
      end
      if notInterruptible ~= nil then
        local spellID = GetInterruptSpell()
        if spellID then
          if C_Spell.GetSpellCooldownDuration then
            local duration = C_Spell.GetSpellCooldownDuration(spellID)
            table.insert(colorQueue, {state = {{value = duration:IsZero()}, {value = notInterruptible, invert = true}}, color = s.colors.ready})
          else
            local cooldownInfo = C_Spell.GetSpellCooldown(spellID)
            if notInterruptible == false and cooldownInfo.startTime == 0 then
              table.insert(colorQueue, {color = s.colors.ready})
              break
            end
          end
        end
      end
    elseif s.kind == "castTargetsYou" then
      local castInfo = state.castInfo
      local channelInfo = state.channelInfo
      local name = castInfo[1]
      if name == nil then
        name = channelInfo[1]
      end
      if name ~= nil then
        if UnitIsSpellTarget then
          table.insert(colorQueue, {state = {{value = UnitIsSpellTarget(unit, "player")}}, color = s.colors.targeted})
        elseif UnitIsUnit(unit .. "target", "player") then
          table.insert(colorQueue, {color = s.colors.targeted})
          break
        end
      end
    elseif s.kind == "uninterruptableCast" then
      local castInfo = state.castInfo
      local channelInfo = state.channelInfo
      local uninterruptable = castInfo[8]
      if uninterruptable == nil then
        uninterruptable = channelInfo[7]
      end
      if uninterruptable ~= nil then
        table.insert(colorQueue, {state = {{value = uninterruptable}}, color = s.colors.uninterruptable})
      end
    elseif s.kind == "importantCast" then
      if C_Spell.IsSpellImportant then
        local castInfo = state.castInfo
        local channelInfo = state.channelInfo
        local spellID = castInfo[9]
        local isChannel = false
        if spellID == nil then
          spellID = channelInfo[8]
          isChannel = true
        end
        if spellID ~= nil then
          local isImportant = C_Spell.IsSpellImportant(spellID)
          if isChannel then
            table.insert(colorQueue, {state = {{value = isImportant}}, color = s.colors.channel})
          else
            table.insert(colorQueue, {state = {{value = isImportant}}, color = s.colors.cast})
          end
        end
      end
    elseif s.kind == "cast" then
      local castInfo = state.castInfo
      local channelInfo = state.channelInfo
      local text = castInfo[1]
      local isChannel = false
      if text == nil then
        text = channelInfo[1]
        isChannel = true
      end
      if text ~= nil then
        table.insert(colorQueue, {color = isChannel and s.colors.channel or s.colors.cast})
      else
        table.insert(colorQueue, {color = s.colors.interrupted})
      end
      break
    elseif s.kind == "fixed" then
      table.insert(colorQueue, {color = s.colors.fixed})
      break
    end
  end

  if #colorQueue == 0 then
    return nil
  end

  if C_CurveUtil then
    local r, g, b, a = 0, 0, 0, 0
    for index = #colorQueue, 1, -1 do
      local details = colorQueue[index]
      local c = details.color
      if details.state == nil then
        r, g, b, a = c.r, c.g, c.b, c.a or 1
      else
        local r0, g0, b0, a0 = c.r, c.g, c.b, c.a
        for _, s in ipairs(details.state) do
          if s.invert then
            r0, g0, b0, a0 = SplitEvaluate(s.value, r, g, b, a, r0, g0, b0, a0)
          else
            r0, g0, b0, a0 = SplitEvaluate(s.value, r0, g0, b0, a0, r, g, b, a)
          end
        end
        r, g, b, a = r0, g0, b0, a0
      end
    end
    return r, g, b, a
  else
    local color = transparency
    for index = #colorQueue, 1, -1 do
      local details = colorQueue[index]
      if details.state == nil then
        color = details.color
      else
        local color0 = details.color
        for _, s in ipairs(details.state) do
          if s.invert then
            color0 = s.value and color or color0
          else
            color0 = s.value and color0 or color
          end
        end
        color = color0
      end
    end

    return color.r, color.g, color.b, color.a or 1
  end
end
