---@class addonTablePlatynator
local addonTable = select(2, ...)

local IsTapped = addonTable.Display.Utilities.IsTappedUnit
local IsNeutral = addonTable.Display.Utilities.IsNeutralUnit
local IsUnfriendly = addonTable.Display.Utilities.IsUnfriendlyUnit
local IsInCombatWith = addonTable.Display.Utilities.IsInCombatWith

local GetInterruptSpells = addonTable.Display.Utilities.GetInterruptSpells

local transparency = {r = 1, g = 1, b = 1, a = 0}

local IsTankRole = addonTable.Display.Utilities.IsTankRole
local GetEliteType = addonTable.Display.Utilities.GetEliteType
local GetDelveType = addonTable.Display.Utilities.GetDelveType

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
end)

local kindToEvent = {
  reaction = {"UNIT_FACTION"},
  tapped = {"UNIT_HEALTH"},
  target = {"PLAYER_TARGET_CHANGED"},
  notTarget = {"PLAYER_TARGET_CHANGED"},
  softTarget = {"PLAYER_TARGET_CHANGED", "PLAYER_SOFT_ENEMY_CHANGED", "PLAYER_SOFT_FRIEND_CHANGED"},
  focus = {"PLAYER_FOCUS_CHANGED"},
  execute = {"UNIT_HEALTH"},
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
  threat = {"CombatStatusChange", "RoleChange"},
  inCombat = {"CombatStatusChange"},
}
local kindToCache = {
  interruptReady = {"cast"},
  interruptNotReady = {"cast"},
  uninterruptableCast = {"cast"},
  castTargetsYou = {"cast"},
  importantCast = {"cast"},
  cast = {"cast"},
  threat = {"threat"},
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
    hostile = UnitCanAttack("player", frame.unit) and UnitIsEnemy(frame.unit, "player"),
    callbacks = {},
    caches = {},
  }
  frame.colorState.defaultColor = defaultColor or transparency
  for _, s in ipairs(settings) do
    local es = kindToEvent[s.kind]
    if es then
      for _, e in ipairs(es) do
        events[e] = true
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
    local cc = kindToCache[s.kind]
    if cc then
      for _, c in ipairs(cc) do
        if not frame.colorState.caches[c] then
          frame.colorState.caches[c] = true
          addonTable.Display.Cache:RegisterCallback(frame.unit, c, function()
            frame:ColorEventHandler("FORCED")
          end)
        end
      end
    end
  end

  function frame:ColorEventHandler(eventName)
    if events[eventName] then
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

  -- Set the color at least once
  frame:ColorEventHandler("FORCED")
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
    elseif s.kind == "notTarget" then
      if not UnitIsUnit("target", unit) then
        table.insert(colorQueue, {color = s.colors.notTarget})
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
      local threatDetails = addonTable.Display.Cache:Get(unit, "threat")
      local threat = threatDetails.situation
      local doesOtherTankHaveAggro = threatDetails.otherTankAggro
      local hostile = state.hostile
      local isTank = IsTankRole()
      if not state.isPlayer and (inRelevantThreatInstance or not s.instancesOnly) and (threat or (hostile and not s.combatOnly) or IsInCombatWith(unit)) and (not s.tanksOnly or isTank) then
        if (isTank and (threat == 0 or threat == nil) and (not s.useOffTankColor or not doesOtherTankHaveAggro)) or (not isTank and threat == 3) then
          table.insert(colorQueue, {color = s.colors.warning})
          break
        elseif threat == 1 or threat == 2 then
          table.insert(colorQueue, {color = s.colors.transition})
          break
        elseif s.useSafeColor and ((isTank and threat == 3) or (not isTank and (threat == 0 or threat == nil))) then
          table.insert(colorQueue, {color = s.colors.safe})
          break
        elseif s.useOffTankColor and isTank and (threat == 0 or threat == nil) and doesOtherTankHaveAggro then
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
        local t = GetEliteType(unit, s.applyCasterAlways)
        if t and s.enabled[t] then
          table.insert(colorQueue, {color = s.colors[t]})
          break
        end
      end
    elseif s.kind == "delveType" then
      if (inRelevantDelveInstance and s.delves or not inRelevantThreatInstance and s.outsideInstances) and not addonTable.Display.Utilities.IsNeutralUnit(unit) then
        local t = GetDelveType(unit)
        if t and s.enabled[t] then
          table.insert(colorQueue, {color = s.colors[t]})
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
      local cacheInfo = addonTable.Display.Cache:Get(unit, "cast")
      local castInfo = cacheInfo.cast
      local channelInfo = cacheInfo.channel
      local notInterruptible = castInfo[8]
      if notInterruptible == nil then
        notInterruptible = channelInfo[7]
      end
      state.frequentUpdater.interruptReady = nil
      if castInfo[1] or channelInfo[1] then
        if notInterruptible == nil then
          notInterruptible = false
        end
        local interruptSpells = GetInterruptSpells()
        state.frequentUpdater.interruptReady = true
        if C_Spell.GetSpellCooldownDuration then
          for _, spellID in ipairs(interruptSpells) do
            local duration = C_Spell.GetSpellCooldownDuration(spellID)
            table.insert(colorQueue, {state = {{value = duration:IsZero()}, {value = notInterruptible, invert = true}}, color = s.colors.ready})
          end
        elseif notInterruptible ~= true then
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
      local cacheInfo = addonTable.Display.Cache:Get(unit, "cast")
      local castInfo = cacheInfo.cast
      local channelInfo = cacheInfo.channel
      local notInterruptible = castInfo[8]
      if notInterruptible == nil then
        notInterruptible = channelInfo[7]
      end
      state.frequentUpdater.interruptNotReady = nil
      if castInfo[1] or channelInfo[1] then
        if notInterruptible == nil then
          notInterruptible = false
        end
        local spells = GetInterruptSpells()
        if #spells > 0 then
          state.frequentUpdater.interruptNotReady = true
          if C_Spell.GetSpellCooldownDuration then
            local conditions = {{value = notInterruptible, invert = true}}
            for _, spellID in ipairs(spells) do
              local duration = C_Spell.GetSpellCooldownDuration(spellID)
              table.insert(conditions, {value = duration:IsZero(), invert = true})
            end
            table.insert(colorQueue, {state = conditions, color = s.colors.notReady})
          elseif notInterruptible ~= true then
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
      local cacheInfo = addonTable.Display.Cache:Get(unit, "cast")
      local castInfo = cacheInfo.cast
      local channelInfo = cacheInfo.channel
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
      local cacheInfo = addonTable.Display.Cache:Get(unit, "cast")
      local castInfo = cacheInfo.cast
      local channelInfo = cacheInfo.channel
      local uninterruptable = castInfo[8]
      if uninterruptable == nil then
        uninterruptable = channelInfo[7]
      end
      if uninterruptable ~= nil then
        table.insert(colorQueue, {state = {{value = uninterruptable}}, color = s.colors.uninterruptable})
      end
    elseif s.kind == "importantCast" then
      if C_Spell.IsSpellImportant then
        local cacheInfo = addonTable.Display.Cache:Get(unit, "cast")
        local castInfo = cacheInfo.cast
        local channelInfo = cacheInfo.channel
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
      local cacheInfo = addonTable.Display.Cache:Get(unit, "cast")
      local castInfo = cacheInfo.cast
      local channelInfo = cacheInfo.channel
      local text = castInfo[1]
      local isChannel, isEmpowered = false, false
      if text == nil then
        text = channelInfo[1]
        isChannel = true
        isEmpowered = channelInfo[9]
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
            break
          end
        end
      end
    elseif s.kind == "inCombat" then
      if IsInCombatWith(unit) then
        table.insert(colorQueue, {color = s.colors.inCombat})
        break
      end
    elseif s.kind == "energy" then
      local kind = UnitPowerType(unit)
      local mapped = addonTable.Constants.PowerMap[kind]
      if s.colors[mapped] then
        table.insert(colorQueue, {color = s.colors[mapped]})
        break
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
