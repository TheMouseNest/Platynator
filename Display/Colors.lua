---@class addonTablePlatynator
local addonTable = select(2, ...)

local IsTapped = addonTable.Display.Utilities.IsTappedUnit
local IsNeutral = addonTable.Display.Utilities.IsNeutralUnit
local IsUnfriendly = addonTable.Display.Utilities.IsUnfriendlyUnit
local IsInCombatWith = addonTable.Display.Utilities.IsInCombatWith

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
  specializationMonitor:RegisterEvent("PLAYER_LOGIN")

  if addonTable.Constants.IsEra or addonTable.Constants.IsBC or addonTable.Constants.IsWrath then
    if playerClass == "WARRIOR" or playerClass == "DRUID" then
      specializationMonitor:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
    elseif playerClass == "PALADIN" then
      specializationMonitor:RegisterUnitEvent("UNIT_AURA", "player")
    end
  elseif C_EventUtils.IsEventValid("PLAYER_SPECIALIZATION_CHANGED") then
    specializationMonitor:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
  end

  specializationMonitor:SetScript("OnEvent", function()
    isTank = GetPlayerRole() == roleType.Tank
  end)
end

local executeCurve = addonTable.Display.Utilities.GetExecuteCurve()

local GetInterruptSpells = addonTable.Display.Utilities.GetInterruptSpells

local transparency = {r = 1, g = 1, b = 1, a = 0}

local function DoesOtherTankHaveAggro(unit)
  return IsInRaid() and UnitGroupRolesAssigned(unit .. "target") == "TANK"
end

local inRelevantThreatInstance, inRelevantEliteInstance, inRelevantDelveInstance = false, false, false

-- Checking for party members below the player's level which indicates the mobs will be shifted down one
-- Except when the dungeon is already at its minimum level, in which case the level won't shift.
local instanceTracker = CreateFrame("Frame")
instanceTracker:RegisterEvent("PLAYER_ENTERING_WORLD")
instanceTracker:RegisterEvent("PLAYER_LEVEL_UP")
instanceTracker:RegisterEvent("ZONE_CHANGED_NEW_AREA")
instanceTracker:RegisterEvent("INSTANCE_GROUP_SIZE_CHANGED")
instanceTracker:SetScript("OnEvent", function(_, event)
  inRelevantThreatInstance = addonTable.Display.Utilities.IsInRelevantInstance({dungeon = true, raid = true, delve = true, pvp = true})
  inRelevantEliteInstance = addonTable.Display.Utilities.IsInRelevantInstance({dungeon = true, raid = true})
  inRelevantDelveInstance = addonTable.Display.Utilities.IsInRelevantInstance({delve = true})
  local _, _, _, _, _, _, _, _, _, lfgDungeonID = GetInstanceInfo()
  if PLATYNATOR_LAST_INSTANCE == nil
    or (inRelevantThreatInstance or inRelevantEliteInstance) ~= PLATYNATOR_LAST_INSTANCE.inInstance
    or PLATYNATOR_LAST_INSTANCE.lastLFGInstanceID ~= lfgDungeonID
    or not (inRelevantThreatInstance or inRelevantEliteInstance) then
    PLATYNATOR_LAST_INSTANCE = {
      lastLFGInstanceID = lfgDungeonID,
      inInstance = inRelevantThreatInstance or inRelevantEliteInstance,
      instanceLieutenantLevel = nil,
    }
    if lfgDungeonID and addonTable.Display.Utilities.IsInRelevantInstance({dungeon = true}) then
      PLATYNATOR_LAST_INSTANCE.level = GetMaxLevelForExpansionLevel(GetMaximumExpansionLevel())
    else
      PLATYNATOR_LAST_INSTANCE.level = UnitEffectiveLevel("player")
    end
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
    "UNIT_SPELLCAST_EMPOWER_START",
    "UNIT_SPELLCAST_EMPOWER_STOP",
  },
  threat = {
    "UNIT_THREAT_LIST_UPDATE",
  }
}

local stateToCalculator = {
  cast = function(state, unit, event)
    state.cast = true
    -- Special case, the cast info _might_ still exist even though the cast is over
    if event == "UNIT_SPELLCAST_INTERRUPTED" or event == "UNIT_SPELLCAST_CHANNEL_STOP" or event == "UNIT_SPELLCAST_EMPOWER_STOP" then
      state.castInfo = {}
      state.channelInfo = {}
    else
      state.castInfo = {UnitCastingInfo(unit)}
      state.channelInfo = {UnitChannelInfo(unit)}
    end
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
  execute = {"UNIT_HEALTH"},
  interruptReady = {
    "UNIT_SPELLCAST_START",
    "UNIT_SPELLCAST_STOP",
    "UNIT_SPELLCAST_FAILED",
    "UNIT_SPELLCAST_INTERRUPTED",
    "UNIT_SPELLCAST_INTERRUPTIBLE",
    "UNIT_SPELLCAST_NOT_INTERRUPTIBLE",
    "UNIT_SPELLCAST_CHANNEL_START",
    "UNIT_SPELLCAST_CHANNEL_STOP",
    "UNIT_SPELLCAST_EMPOWER_START",
    "UNIT_SPELLCAST_EMPOWER_STOP",
  },
  interruptNotReady = {
    "UNIT_SPELLCAST_START",
    "UNIT_SPELLCAST_STOP",
    "UNIT_SPELLCAST_FAILED",
    "UNIT_SPELLCAST_INTERRUPTED",
    "UNIT_SPELLCAST_INTERRUPTIBLE",
    "UNIT_SPELLCAST_NOT_INTERRUPTIBLE",
    "UNIT_SPELLCAST_CHANNEL_START",
    "UNIT_SPELLCAST_CHANNEL_STOP",
    "UNIT_SPELLCAST_EMPOWER_START",
    "UNIT_SPELLCAST_EMPOWER_STOP",
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
    "UNIT_SPELLCAST_EMPOWER_START",
    "UNIT_SPELLCAST_EMPOWER_STOP",
  },
  castTargetsYou = {
    "UNIT_SPELLCAST_START",
    "UNIT_SPELLCAST_STOP",
    "UNIT_SPELLCAST_FAILED",
    "UNIT_SPELLCAST_INTERRUPTED",
    "UNIT_SPELLCAST_CHANNEL_START",
    "UNIT_SPELLCAST_CHANNEL_STOP",
    "UNIT_SPELLCAST_EMPOWER_START",
    "UNIT_SPELLCAST_EMPOWER_STOP",
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
    "UNIT_SPELLCAST_EMPOWER_START",
    "UNIT_SPELLCAST_EMPOWER_STOP",
  },
  importantCast = {
    "UNIT_SPELLCAST_START",
    "UNIT_SPELLCAST_STOP",
    "UNIT_SPELLCAST_FAILED",
    "UNIT_SPELLCAST_INTERRUPTED",
    "UNIT_SPELLCAST_CHANNEL_START",
    "UNIT_SPELLCAST_CHANNEL_STOP",
    "UNIT_SPELLCAST_EMPOWER_START",
    "UNIT_SPELLCAST_EMPOWER_STOP",
  },
  eliteType = {
    "UNIT_CLASSIFICATION_CHANGED",
  },
  rarity = {
    "UNIT_CLASSIFICATION_CHANGED",
  },
  delveType = {
    "UNIT_CLASSIFICATION_CHANGED",
  },
}
local kindToCallback = {
  quest = {"QuestInfoUpdate"},
  mouseover = {"MouseoverUpdate"},
  threat = {"CombatStatusChange"},
}

function addonTable.Display.UnregisterForColorEvents(frame)
  if frame.colorState then
    for _, e in ipairs(frame.colorState.callbacks) do
      addonTable.CallbackRegistry:UnregisterCallback(e, frame.colorState)
    end
    if frame.colorState.timer then
      frame.colorState.timer:Cancel()
    end
  end

  frame.ColorEventHandler = nil
  frame.colorState = nil
end

function addonTable.Display.RegisterForColorEvents(frame, settings, defaultColor)
  local events = { FORCED = true }
  frame.colorState = {
    frequentUpdater = {},
    isPlayer = UnitIsPlayer(frame.unit) or UnitTreatAsPlayerForDisplay and UnitTreatAsPlayerForDisplay(frame.unit),
    callbacks = {},
  }
  frame.colorState.defaultColor = defaultColor or transparency
  for _, s in ipairs(settings) do
    local es = kindToEvent[s.kind]
    if es then
      for _, e in ipairs(es) do
        events[e] = true
        local stateKind = eventToState[e]
        local state = frame.colorState[stateKind]
        if stateKind and state == nil then
          stateToCalculator[stateKind](frame.colorState, frame.unit, "")
        end
        if C_EventUtils.IsEventValid(e) then
          if e:match("^UNIT") then
            frame:RegisterUnitEvent(e, frame.unit)
          else
            frame:RegisterEvent(e)
          end
        end
      end
    end
    local ec = kindToCallback[s.kind]
    if ec then
      for _, e in ipairs(ec) do
        table.insert(frame.colorState.callbacks, e)
        addonTable.CallbackRegistry:RegisterCallback(e, function()
          frame:SetColor(addonTable.Display.GetColor(settings, frame.colorState, frame.unit))
        end, frame.colorState)
      end
    end
  end

  function frame:ColorEventHandler(eventName)
    if events[eventName] then
      local calculator = eventToCalulator[eventName]
      if calculator then
        calculator(self.colorState, self.unit, eventName)
      end
      self:SetColor(addonTable.Display.GetColor(settings, self.colorState, self.unit))
      if next(self.colorState.frequentUpdater) then
        if not self.colorState.timer then
          self.colorState.timer = C_Timer.NewTicker(0.1, function()
            self:ColorEventHandler("FORCED")
          end)
        end
      elseif self.colorState.timer then
        self.colorState.timer:Cancel()
        self.colorState.timer = nil
      end
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
      if UnitIsUnit("target", unit) then
        table.insert(colorQueue, {color = s.colors.target})
        break
      end
    elseif s.kind == "softTarget" then
      if not UnitIsUnit("target", unit) and (UnitIsUnit("softenemy", unit) or UnitIsUnit("softfriend", unit)) then
        table.insert(colorQueue, {color = s.colors.softTarget})
        break
      end
    elseif s.kind == "focus" then
      if UnitIsUnit("focus", unit) then
        table.insert(colorQueue, {color = s.colors.focus})
        break
      end
    elseif s.kind == "mouseover" then
      if UnitIsUnit("mouseover", unit) and (s.includeTarget or not UnitIsUnit("target", unit)) then
        table.insert(colorQueue, {color = s.colors.mouseover})
        break
      end
    elseif s.kind == "threat" then
      local threat = state.threat
      local hostile = state.hostile
      if not state.isPlayer and (inRelevantThreatInstance or not s.instancesOnly) and (threat or (hostile and not s.combatOnly) or IsInCombatWith(unit)) then
        if (isTank and (threat == 0 or threat == nil) and not DoesOtherTankHaveAggro(unit)) or (not isTank and threat == 3) then
          table.insert(colorQueue, {color = s.colors.warning})
          break
        elseif threat == 1 or threat == 2 then
          table.insert(colorQueue, {color = s.colors.transition})
          break
        elseif s.useSafeColor and ((isTank and threat == 3) or (not isTank and (threat == 0 or threat == nil))) then
          table.insert(colorQueue, {color = s.colors.safe})
          break
        elseif isTank and (threat == 0 or threat == nil) and DoesOtherTankHaveAggro(unit) then
          table.insert(colorQueue, {color = s.colors.offtank})
          break
        end
      end
    elseif s.kind == "rarity" then
      local classification = UnitClassification(unit)

      if classification == "rare" then
        table.insert(colorQueue, {color = s.colors.rare})
      elseif classification == "rareelite" then
        table.insert(colorQueue, {color = s.colors.rareElite})
      end
    elseif s.kind == "eliteType" then
      if (inRelevantEliteInstance or not s.instancesOnly) and not addonTable.Display.Utilities.IsNeutralUnit(unit) then
        local classification = UnitClassification(unit)
        if classification == "elite" then
          local level = UnitEffectiveLevel(unit)
          local dungeonLevel = PLATYNATOR_LAST_INSTANCE.level
          local isRetail = addonTable.Constants.IsRetail
          local lieutentantLevel = PLATYNATOR_LAST_INSTANCE.instanceLieutenantLevel
          if isRetail and (level == dungeonLevel + 1 or UnitIsLieutenant(unit)) then
            PLATYNATOR_LAST_INSTANCE.instanceLieutenantLevel = level
            table.insert(colorQueue, {color = s.colors.miniboss})
            break
          elseif isRetail and (level == dungeonLevel + 2 or lieutentantLevel and level == lieutentantLevel + 1) or level == -1 then
            table.insert(colorQueue, {color = s.colors.boss})
            break
          else
            local class = UnitClassBase(unit)
            if class == "PALADIN" then
              table.insert(colorQueue, {color = s.colors.caster})
            else
              table.insert(colorQueue, {color = s.colors.melee})
            end
            break
          end
        elseif classification == "normal" or classification == "trivial" or classification == "minus" then
          table.insert(colorQueue, {color = s.colors.trivial})
          break
        end
      end
    elseif s.kind == "delveType" then
      if (inRelevantDelveInstance and s.delves or not inRelevantThreatInstance and s.outsideInstances) and not addonTable.Display.Utilities.IsNeutralUnit(unit) then
        local classification = UnitClassification(unit)
        if classification == "elite" then
          local level = UnitEffectiveLevel(unit)
          local dungeonLevel = PLATYNATOR_LAST_INSTANCE.level
          local isRetail = addonTable.Constants.IsRetail
          local lieutentantLevel = PLATYNATOR_LAST_INSTANCE.instanceLieutenantLevel
          if isRetail and UnitIsLieutenant(unit) then
            PLATYNATOR_LAST_INSTANCE.instanceLieutenantLevel = level
            table.insert(colorQueue, {color = s.colors.elite})
            break
          elseif isRetail and (level == dungeonLevel + 2 or lieutentantLevel and level == lieutentantLevel + 1) or level == -1 then
            table.insert(colorQueue, {color = s.colors.boss})
            break
          else
            table.insert(colorQueue, {color = s.colors.elite})
          end
        elseif classification == "rareelite" then
          table.insert(colorQueue, {color = s.colors.rare})
          break
        elseif classification == "normal" then
          local class = UnitClassBase(unit)
          if class == "PALADIN" then
            table.insert(colorQueue, {color = s.colors.caster})
          else
            table.insert(colorQueue, {color = s.colors.melee})
          end
          break
        elseif classification == "trivial" or classification == "minus" then
          table.insert(colorQueue, {color = s.colors.trivial})
          break
        end
      end
    elseif s.kind == "quest" then
      if #addonTable.Display.Utilities.GetQuestInfo(unit) > 0 then
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
      if state.isPlayer then
        local _, class = UnitClass(unit)
        table.insert(colorQueue, {color = s.colors[class] or RAID_CLASS_COLORS[class]})
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
      state.frequentUpdater.interruptReady = nil
      if notInterruptible ~= nil then
        local interruptSpells, useGCD = GetInterruptSpells()
        state.frequentUpdater.interruptReady = true
        if C_Spell.GetSpellCooldownDuration then
          for _, spellID in ipairs(interruptSpells) do
            local duration = C_Spell.GetSpellCooldownDuration(spellID)
            table.insert(colorQueue, {state = {{value = duration:IsZero()}, {value = notInterruptible, invert = true}}, color = s.colors.ready})
          end
        elseif notInterruptible == false then
          local any = false
          for _, spellID in ipairs(interruptSpells) do
            local cooldownInfo = C_Spell.GetSpellCooldown(spellID)
            if cooldownInfo.startTime == 0 then
              any = true
              table.insert(colorQueue, {color = s.colors.ready})
              break
            end
          end
          if any then
            break
          end
        end
      end
    elseif s.kind == "interruptNotReady" then
      local castInfo = state.castInfo
      local channelInfo = state.channelInfo
      local notInterruptible = castInfo[8]
      if notInterruptible == nil then
        notInterruptible = channelInfo[7]
      end
      state.frequentUpdater.interruptReady = nil
      if notInterruptible ~= nil then
        local spells, useGCD = GetInterruptSpells()
        if #spells > 0 then
          state.frequentUpdater.interruptReady = true
          if C_Spell.GetSpellCooldownDuration then
            local conditions = {{value = notInterruptible, invert = true}}
            for _, spellID in ipairs(spells) do
              local duration = C_Spell.GetSpellCooldownDuration(spellID)
              table.insert(conditions, {value = duration:IsZero(), invert = true})
            end
            table.insert(colorQueue, {state = conditions, color = s.colors.notReady})
          elseif notInterruptible == false then
            local any = false
            for _, spellID in ipairs(spells) do
              local cooldownInfo = C_Spell.GetSpellCooldown(spellID)
              if cooldownInfo.startTime == 0 then
                any = true
                break
              end
            end
            if not any then
              table.insert(colorQueue, {color = s.colors.notReady})
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
      local isChannel, isEmpowered = false, false
      if text == nil then
        text = channelInfo[1]
        isChannel = true
        isEmpowered = channelInfo[10]
      end
      if text ~= nil then
        table.insert(colorQueue, {color = isEmpowered and s.colors.empowered or isChannel and s.colors.channel or s.colors.cast})
      else
        table.insert(colorQueue, {color = s.colors.interrupted})
      end
      break
    elseif s.kind == "fixed" then
      table.insert(colorQueue, {color = s.colors.fixed})
      break
    elseif s.kind == "execute" then
      local executeRange = addonTable.Display.Utilities.GetExecuteRange()
      if executeRange > 0 then
        if UnitHealthPercent then
          -- Unable to do the execute colour currently, waiting on a solution from Blizzard
          --local alpha = UnitHealthPercent(unit, true, executeCurve)
          --table.insert(colorQueue, {state = {{value = Convert10ToBoolean(alpha)}}, color = s.colors.execute})
        else
          local percent = UnitHealth(unit) / UnitHealthMax(unit)
          if percent <= addonTable.Display.Utilities.GetExecuteRange() then
            table.insert(colorQueue, {color = s.colors.execute})
          end
        end
      end
    end
  end

  if #colorQueue == 0 then
    return nil
  end

  local defaultColor = state.defaultColor
  if C_CurveUtil then
    local r, g, b, a = defaultColor.r, defaultColor.g, defaultColor.b, defaultColor.a or 1
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
    local color = defaultColor
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
