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
local executeConverter = UIParent:CreateTexture()

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
local kindToCallback = {
  quest = {"QuestInfoUpdate"},
}

function addonTable.Display.UnregisterForColorEvents(frame)
  if frame.colorState then
    for _, s in ipairs(frame.colorSettings) do
      local ec = kindToCallback[s.kind]
      if ec then
        for _, e in ipairs(ec) do
          addonTable.CallbackRegistry:UnregisterCallback(e, frame.colorState)
        end
      end
    end
    if frame.colorState.timer then
      frame.colorState.timer:Cancel()
    end
  end

  frame.ColorEventHandler = nil
  frame.colorState = nil
  frame.colorSettings = nil
end

function addonTable.Display.RegisterForColorEvents(frame, settings, defaultColor)
  local events = { FORCED = true }
  frame.colorState = {
    frequentUpdater = {},
    isPlayer = UnitIsPlayer(frame.unit) or UnitTreatAsPlayerForDisplay and UnitTreatAsPlayerForDisplay(frame.unit)
  }
  frame.colorSettings = settings
  frame.colorState.defaultColor = defaultColor or transparency
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
    local ec = kindToCallback[s.kind]
    if ec then
      for _, e in ipairs(ec) do
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
        calculator(self.colorState, self.unit)
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
  state.textureOverride = nil
  local colorQueue = {}
  for _, s in ipairs(settings) do
    if s.kind == "tapped" then
      if IsTapped(unit) then
        table.insert(colorQueue, {color = s.colors.tapped, foreground = s.foreground and s.foreground.tapped})
        break
      end
    elseif s.kind == "target" then
      if UnitIsUnit("target", unit) then
        table.insert(colorQueue, {color = s.colors.target, foreground = s.foreground and s.foreground.target})
        break
      end
    elseif s.kind == "softTarget" then
      if not UnitIsUnit("target", unit) and (UnitIsUnit("softenemy", unit) or UnitIsUnit("softfriend", unit)) then
        table.insert(colorQueue, {color = s.colors.softTarget, foreground = s.foreground and s.foreground.softTarget})
        break
      end
    elseif s.kind == "focus" then
      if UnitIsUnit("focus", unit) then
        table.insert(colorQueue, {color = s.colors.focus, foreground = s.foreground and s.foreground.focus})
        break
      end
    elseif s.kind == "threat" then
      local threat = state.threat
      local hostile = state.hostile
      if not state.isPlayer and (inRelevantInstance or not s.instancesOnly) and (threat or (hostile and not s.combatOnly) or IsInCombatWith(unit)) then
        if (isTank and (threat == 0 or threat == nil) and not DoesOtherTankHaveAggro(unit)) or (not isTank and threat == 3) then
          table.insert(colorQueue, {color = s.colors.warning, foreground = s.foreground and s.foreground.warning})
          break
        elseif threat == 1 or threat == 2 then
          table.insert(colorQueue, {color = s.colors.transition, foreground = s.foreground and s.foreground.transition})
          break
        elseif s.useSafeColor and ((isTank and threat == 3) or (not isTank and (threat == 0 or threat == nil))) then
          table.insert(colorQueue, {color = s.colors.safe, foreground = s.foreground and s.foreground.safe})
          break
        elseif isTank and (threat == 0 or threat == nil) and DoesOtherTankHaveAggro(unit) then
          table.insert(colorQueue, {color = s.colors.offtank, foreground = s.foreground and s.foreground.offtank})
          break
        end
      end
    elseif s.kind == "rarity" then
      local classification = UnitClassification(unit)

      if classification == "rare" then
        table.insert(colorQueue, {color = s.colors.rare, foreground = s.foreground and s.foreground.rare})
      elseif classification == "rareelite" then
        table.insert(colorQueue, {color = s.colors.rareElite, foreground = s.foreground and s.foreground.rareElite})
      end
    elseif s.kind == "eliteType" then
      if (inRelevantInstance or not s.instancesOnly) and not addonTable.Display.Utilities.IsNeutralUnit(unit) then
        local classification = UnitClassification(unit)
        if classification == "elite" then
          local level = UnitEffectiveLevel(unit)
          local playerLevel = PLATYNATOR_LAST_INSTANCE.level
          if level == playerLevel or addonTable.Constants.IsClassic then
            local class = UnitClassBase(unit)
            if class == "PALADIN" then
              table.insert(colorQueue, {color = s.colors.caster, foreground = s.foreground and s.foreground.caster})
            else
              table.insert(colorQueue, {color = s.colors.melee, foreground = s.foreground and s.foreground.melee})
            end
            break
          elseif level >= playerLevel + 2 or level == -1 then
            table.insert(colorQueue, {color = s.colors.boss, foreground = s.foreground and s.foreground.boss})
            break
          elseif level == playerLevel + 1 then
            table.insert(colorQueue, {color = s.colors.miniboss, foreground = s.foreground and s.foreground.miniboss})
            break
          end
        elseif classification == "normal" or classification == "trivial" then
          table.insert(colorQueue, {color = s.colors.trivial, foreground = s.foreground and s.foreground.trivial})
          break
        end
      end
    elseif s.kind == "quest" then
      if #addonTable.Display.Utilities.GetQuestInfo(unit) > 0 then
        if IsNeutral(unit) then
          table.insert(colorQueue, {color = s.colors.neutral, foreground = s.foreground and s.foreground.neutral})
          break
        elseif UnitIsFriend("player", unit) then
          table.insert(colorQueue, {color = s.colors.friendly, foreground = s.foreground and s.foreground.friendly})
          break
        else
          table.insert(colorQueue, {color = s.colors.hostile, foreground = s.foreground and s.foreground.hostile})
          break
        end
      end
    elseif s.kind == "guild" then
      if UnitIsPlayer(unit) then
        local playerGuild, _, _, playerRealm = GetGuildInfo("player")
        local unitGuild, _, _, unitRealm = GetGuildInfo(unit)
        if playerGuild ~= nil and playerGuild == unitGuild and playerRealm == unitRealm then
          table.insert(colorQueue, {color = s.colors.guild, foreground = s.foreground and s.foreground.guild})
          break
        end
      end
    elseif s.kind == "classColors" then
      if state.isPlayer then
        local _, class = UnitClass(unit)
        table.insert(colorQueue, {color = RAID_CLASS_COLORS[class]})
        break
      end
    elseif s.kind == "reaction" then
      if IsNeutral(unit) then
        table.insert(colorQueue, {color = s.colors.neutral, foreground = s.foreground and s.foreground.neutral})
      elseif IsUnfriendly(unit) then
        table.insert(colorQueue, {color = s.colors.unfriendly, foreground = s.foreground and s.foreground.unfriendly})
      elseif UnitIsFriend("player", unit) and not UnitCanAttack("player", unit) then
        table.insert(colorQueue, {color = s.colors.friendly, foreground = s.foreground and s.foreground.friendly})
      else
        table.insert(colorQueue, {color = s.colors.hostile, foreground = s.foreground and s.foreground.hostile})
      end
      break
    elseif s.kind == "difficulty" then
      local difficultyKey = addonTable.Display.Utilities.GetUnitDifficulty(unit)
      table.insert(colorQueue, {color = s.colors[difficultyKey], foreground = s.foreground and s.foreground[difficultyKey]})
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
        local spellID = GetInterruptSpell()
        if spellID then
          state.frequentUpdater.interruptReady = true
          if C_Spell.GetSpellCooldownDuration then
            local duration = C_Spell.GetSpellCooldownDuration(spellID)
            table.insert(colorQueue, {color = s.colors.ready, foreground = s.foreground and s.foreground.ready, state = {{value = duration:IsZero()}, {value = notInterruptible, invert = true}}})
          else
            local cooldownInfo = C_Spell.GetSpellCooldown(spellID)
            if notInterruptible == false and cooldownInfo.startTime == 0 then
              table.insert(colorQueue, {color = s.colors.ready, foreground = s.foreground and s.foreground.ready})
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
          table.insert(colorQueue, {color = s.colors.targeted, foreground = s.foreground and s.foreground.targeted, state = {{value = UnitIsSpellTarget(unit, "player")}}})
        elseif UnitIsUnit(unit .. "target", "player") then
          table.insert(colorQueue, {color = s.colors.targeted, foreground = s.foreground and s.foreground.targeted})
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
        table.insert(colorQueue, {color = s.colors.uninterruptable, foreground = s.foreground and s.foreground.uninterruptable, state = {{value = uninterruptable}}})
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
            table.insert(colorQueue, {color = s.colors.channel, foreground = s.foreground and s.foreground.channel, state = {{value = isImportant}}})
          else
            table.insert(colorQueue, {color = s.colors.cast, foreground = s.foreground and s.foreground.cast, state = {{value = isImportant}}})
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
        table.insert(colorQueue, {color = isChannel and s.colors.channel or s.colors.cast, foreground = s.foreground and s.foreground[isChannel and "channel" or "cast"]})
      else
        table.insert(colorQueue, {color = s.colors.interrupted, foreground = s.foreground and s.foreground.interrupted})
      end
      break
    elseif s.kind == "fixed" then
      table.insert(colorQueue, {color = s.colors.fixed, foreground = s.foreground and s.foreground.fixed})
      break
    elseif s.kind == "execute" then
      local executeRange = addonTable.Display.Utilities.GetExecuteRange()
      if executeRange > 0 then
        if UnitHealthPercent then
          local alpha = UnitHealthPercent(unit, true, executeCurve)
          executeConverter:SetDesaturation(alpha)
          table.insert(colorQueue, {color = s.colors.execute, foreground = s.foreground and s.foreground.execute, state = {{value = executeConverter:IsDesaturated()}}})
        else
          local percent = UnitHealth(unit) / UnitHealthMax(unit)
          if percent <= addonTable.Display.Utilities.GetExecuteRange() then
            table.insert(colorQueue, {color = s.colors.execute, foreground = s.foreground and s.foreground.execute})
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
    local foreground = nil
    for index = #colorQueue, 1, -1 do
      local details = colorQueue[index]
      local c = details.color
      if details.state == nil then
        r, g, b, a = c.r, c.g, c.b, c.a or 1
        foreground = details.foreground
      else
        local r0, g0, b0, a0 = c.r, c.g, c.b, c.a
        local foreground0 = details.foreground
        for _, s in ipairs(details.state) do
          if s.invert then
            r0, g0, b0, a0 = SplitEvaluate(s.value, r, g, b, a, r0, g0, b0, a0)
            foreground0 = s.value and foreground or foreground0
          else
            r0, g0, b0, a0 = SplitEvaluate(s.value, r0, g0, b0, a0, r, g, b, a)
            foreground0 = s.value and foreground0 or foreground
          end
        end
        r, g, b, a = r0, g0, b0, a0
        foreground = foreground0
      end
    end
    state.textureOverride = foreground
    return r, g, b, a
  else
    local color = defaultColor
    local foreground = nil
    for index = #colorQueue, 1, -1 do
      local details = colorQueue[index]
      if details.state == nil then
        color = details.color
        foreground = details.foreground
      else
        local color0 = details.color
        local foreground0 = details.foreground
        for _, s in ipairs(details.state) do
          if s.invert then
            color0 = s.value and color or color0
            foreground0 = s.value and foreground or foreground0
          else
            color0 = s.value and color0 or color
            foreground0 = s.value and foreground0 or foreground
          end
        end
        color = color0
        foreground = foreground0
      end
    end
    state.textureOverride = foreground
    return color.r, color.g, color.b, color.a or 1
  end
end
