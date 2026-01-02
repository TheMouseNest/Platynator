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

local interruptMap = {
  ["DEATHKNIGHT"] = {47528, 47476},
  ["WARRIOR"] = {6552},
  ["WARLOCK"] = {19647},
  ["SHAMAN"] = {57994},
  ["ROGUE"] = {1766},
  ["PRIEST"] = {15487},
  ["PALADIN"] = {96231, 31935},
  ["MONK"] = {116705},
  ["MAGE"] = {2139},
  ["HUNTER"] = {187707, 147362},
  ["EVOKER"] = {351338},
  ["DRUID"] = {38675, 106839},
  ["DEMONHUNTER"] = {183752},
}

local interruptSpells = interruptMap[UnitClassBase("player")] or {}

local function GetInterruptSpell()
  for _, s in ipairs(interruptSpells) do
    if C_SpellBook.IsSpellKnown(s) then
      return s
    end
  end
end

local ConvertColor = addonTable.Display.Utilities.ConvertColor
local transparency = CreateColor(0, 0, 0, 0)

local t = UIParent:CreateTexture()
t:SetTexture("Interface/AddOns/Platynator/Assets/Special/white.png")
local function WorkaroundBooleanEvaluator(state, color1, color2)
  t:SetVertexColorFromBoolean(state, color1, color2)
  return CreateColor(t:GetVertexColor())
end

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

local kindToEvent = {
  tapped = {"UNIT_HEALTH"},
  target = {"PLAYER_TARGET_CHANGED"},
  focus = {"PLAYER_FOCUS_CHANGED"},
  threat = {"UNIT_THREAT_LIST_UPDATE"},
  quest = {"QUEST_LOG_UPDATE"},
  interruptReady = {
    "UNIT_SPELLCAST_START",
    "UNIT_SPELLCAST_STOP",
    "UNIT_SPELLCAST_DELAYED",
    "UNIT_SPELLCAST_FAILED",
    "UNIT_SPELLCAST_INTERRUPTIBLE",
    "UNIT_SPELLCAST_NOT_INTERRUPTIBLE",
    "UNIT_SPELLCAST_CHANNEL_START",
    "UNIT_SPELLCAST_CHANNEL_STOP",
    "SPELL_UPDATE_COOLDOWN",
  },
  cast = {
    "UNIT_SPELLCAST_START",
    "UNIT_SPELLCAST_STOP",
    "UNIT_SPELLCAST_DELAYED",
    "UNIT_SPELLCAST_CHANNEL_START",
    "UNIT_SPELLCAST_CHANNEL_STOP",
    "UNIT_SPELLCAST_CHANNEL_UPDATE",
    "UNIT_SPELLCAST_INTERRUPTIBLE",
    "UNIT_SPELLCAST_NOT_INTERRUPTIBLE",
  },
  importantCast = {
    "UNIT_SPELLCAST_START",
    "UNIT_SPELLCAST_STOP",
    "UNIT_SPELLCAST_DELAYED",
    "UNIT_SPELLCAST_CHANNEL_START",
    "UNIT_SPELLCAST_CHANNEL_STOP",
  },
}

function addonTable.Display.UnregisterForColorEvents(frame)
  frame.ColorEventHandler = nil
end

function addonTable.Display.RegisterForColorEvents(frame, settings)
  local events = {}
  for _, s in ipairs(settings) do
    local es = kindToEvent[s.kind]
    if es then
      for _, e in ipairs(es) do
        events[e] = true
        frame:RegisterEvent(e)
      end
    end
  end

  function frame:ColorEventHandler(eventName)
    if events[eventName] then
      self:SetColor(addonTable.Display.GetColor(settings, self.unit))
    end
  end
end

function addonTable.Display.GetColor(settings, unit)
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
    elseif s.kind == "focus" then
      if UnitIsUnit("focus", unit) then
        table.insert(colorQueue, {s.colors.focus})
        break
      end
    elseif s.kind == "threat" then
      local threat = UnitThreatSituation("player", unit)
      local hostile = UnitCanAttack("player", unit) and UnitIsEnemy(unit, "player")
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
      if inRelevantInstance or not s.instancesOnly then
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
      if C_QuestLog.UnitIsRelatedToActiveQuest and C_QuestLog.UnitIsRelatedToActiveQuest(unit) then
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
      if UnitIsPlayer(unit) then
        table.insert(colorQueue, {color = SS_COLORS[UnitClassBase(unit)]})
        break
      end
    elseif s.kind == "reaction" then
      if IsNeutral(unit) then
        table.insert(colorQueue, {color = s.colors.neutral})
      elseif IsUnfriendly(unit) then
        table.insert(colorQueue, {color = s.colors.unfriendly})
      elseif UnitIsFriend("player", unit) then
        table.insert(colorQueue, {color = s.colors.friendly})
      else
        table.insert(colorQueue, {color = s.colors.hostile})
      end
      break
    elseif s.kind == "difficulty" then
      table.insert(colorQueue, {color = s.colors[addonTable.Display.Utilities.GetUnitDifficulty(unit)]})
      break
    elseif s.kind == "interruptReady" then
      local spellID = GetInterruptSpell()
      if spellID then
        local _, _, _, _, _, _, _, notInterruptible, _ = UnitCastingInfo(unit)
        if notInterruptible == nil then
          _, _, _, _, _, _, notInterruptible, _ = UnitChannelInfo(unit)
        end
        if notInterruptible ~= nil then
          if C_Spell.GetSpellCooldownDuration and C_CurveUtil.EvaluateColorFromBoolean then
            local duration = C_Spell.GetSpellCooldownDuration(spellID)
            local c1 = C_CurveUtil.EvaluateColorFromBoolean(duration:IsZero(), ConvertColor(s.colors.ready), ConvertColor(s.colors.notReady))
            table.insert(colorQueue, {state = notInterruptible, invert = true, color = c1})
          elseif C_Spell.GetSpellCooldownDuration then
            local duration = C_Spell.GetSpellCooldownDuration(spellID)
            local c1 = WorkaroundBooleanEvaluator(duration:IsZero(), ConvertColor(s.colors.ready), ConvertColor(s.colors.notReady))
            table.insert(colorQueue, {state = notInterruptible, invert = true, color = c1})
          else
            local cooldownInfo = C_Spell.GetSpellCooldown(spellID)
            if notInterruptible == false then
              if cooldownInfo.startTime ~= 0 then
                table.insert(colorQueue, {color = s.colors.notReady})
              else
                table.insert(colorQueue, {color = s.colors.ready})
              end
              break
            end
          end
        end
      end
    elseif s.kind == "importantCast" then
      local _, _, _, _, _, _, _, _, spellID = UnitCastingInfo(unit)
      local isChannel = false
      if spellID == nil then
        _, _, _, _, _, _, _, spellID = UnitChannelInfo(unit)
        isChannel = true
      end
      if spellID ~= nil then
        local state = C_Spell.IsSpellImportant(spellID)
        if isChannel then
          table.insert(colorQueue, {state = state, color = ConvertColor(s.colors.channel)})
        else
          table.insert(colorQueue, {state = state, color = ConvertColor(s.colors.cast)})
        end
      end
    elseif s.kind == "cast" then
      local _, _, _, _, _, _, _, notInterruptible, _ = UnitCastingInfo(unit)
      local isChannel = false
      if notInterruptible == nil then
        _, _, _, _, _, _, notInterruptible, _ = UnitChannelInfo(unit)
        isChannel = true
      end
      if notInterruptible ~= nil then
        local c1 = ConvertColor(s.colors.uninterruptable)
        local c2 = isChannel and ConvertColor(s.colors.channel) or ConvertColor(s.colors.cast)
        table.insert(colorQueue, {state = notInterruptible, color = c1})
        table.insert(colorQueue, {color = c2})
      else
        table.insert(colorQueue, {color = ConvertColor(s.colors.interrupted)})
      end
      break
    elseif s.kind == "fixed" then
      table.insert(colorQueue, {color = ConvertColor(s.colors.fixed)})
      break
    end
  end

  if #colorQueue == 0 then
    return nil
  end

  local color = transparency
  for index = #colorQueue, 1, -1 do
    local details = colorQueue[index]
    if details.state == nil then
      color = details.color
    elseif details.invert then
      if C_CurveUtil then
        if C_CurveUtil.EvaluateColorFromBoolean then
          color = C_CurveUtil.EvaluateColorFromBoolean(details.state, ConvertColor(color), ConvertColor(details.color))
        else
          color = WorkaroundBooleanEvaluator(details.state, ConvertColor(color), ConvertColor(details.color))
        end
      else
        color = details.state and color or details.color
      end
    else
      if C_CurveUtil then
        if C_CurveUtil.EvaluateColorFromBoolean then
          color = C_CurveUtil.EvaluateColorFromBoolean(details.state, details.color, color)
        else
          color = WorkaroundBooleanEvaluator(details.state, details.color, color)
        end
      else
        color = details.state and details.color or color
      end
    end
  end

  return color
end
