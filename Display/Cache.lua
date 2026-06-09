---@class addonTablePlatynator
local addonTable = select(2, ...)

local GetOtherTanks = addonTable.Display.Utilities.GetOtherTanks
local IsTank = addonTable.Display.Utilities.IsTankRole
local GetRangeChecker = addonTable.Display.Utilities.GetRangeSpell

local function IsInCombatWith(unit)
  return UnitAffectingCombat(unit) and
    (
      UnitIsFriend("player", unit) and (UnitInParty(unit) == true or UnitInRaid(unit)== true) or
      addonTable.Cache:Get(unit, "threat").situation ~= nil or
      UnitInParty(unit .. "target") == true or UnitInRaid(unit .. "target") == true
    )
end

-- For clients other than Midnight
if not C_Secrets then
  local frame = CreateFrame("Frame")
  frame:SetScript("OnEvent", function()
    local _, subevent, _, playerGUID, _, _, _, destGUID = CombatLogGetCurrentEventInfo()
    if subevent == "SPELL_INTERRUPT" then
      addonTable.CallbackRegistry:TriggerEvent("LegacyInterrupter", playerGUID, destGUID)
    end
  end)
  frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

addonTable.Display.CacheMixin = {}

local getter = {
  ["cast"] = function(oldState, unit, eventName, ...)
    if eventName == "UNIT_SPELLCAST_INTERRUPTED" then
      local _, _, interrupterGUID = ...
      return {cast = {}, channel = {}, interrupted = {guid = interrupterGUID, time = GetTime() * 1000}}, true, addonTable.Config.Get(addonTable.Config.Options.CAST_INTERRUPTED_TIMEOUT)
    end
    if eventName == "UNIT_SPELLCAST_CHANNEL_STOP" then
      local _, _, interrupterGUID = ...
      return {cast = {}, channel = {}, interrupted = interrupterGUID and {guid = interrupterGUID, time = GetTime() * 1000} or nil}, true, interrupterGUID and addonTable.Config.Get(addonTable.Config.Options.CAST_INTERRUPTED_TIMEOUT) or nil
    end
    if eventName == "UNIT_SPELLCAST_EMPOWER_STOP" then
      local _, _, _, interrupterGUID = ...
      return {cast = {}, channel = {}, interrupted = interrupterGUID and {guid = interrupterGUID, time = GetTime() * 1000} or nil}, true, interrupterGUID and addonTable.Config.Get(addonTable.Config.Options.CAST_INTERRUPTED_TIMEOUT) or nil
    end
    local new, state = nil, false
    if eventName == "UNIT_SPELLCAST_DELAYED" and next(oldState.cast) == nil or eventName == "UNIT_SPELLCAST_CHANNEL_UPDATE" and next(oldState.channel) == nil then
      new, state = {cast = {}, channel = {}, interrupted = nil}, false
    else
      new, state = {cast = {UnitCastingInfo(unit)}, channel = {UnitChannelInfo(unit)}, interrupted = nil}, true
    end
    -- Using approximated milliseconds to avoid rounding errors breaking the time comparison
    if oldState and oldState.interrupted and math.ceil(GetTime()*1000) - math.floor(oldState.interrupted.time) < addonTable.Config.Get(addonTable.Config.Options.CAST_INTERRUPTED_TIMEOUT) * 1000 and next(new.cast) == nil and next(new.channel) == nil then
      new.interrupted = oldState.interrupted
    end
    if addonTable.Constants.IsSecretsActive then
      if new.cast[1] then
        new.castDuration = UnitCastingDuration(unit)
      end
      if new.channel[9] then
        new.empoweredDuration = UnitEmpoweredChannelDuration(unit, true)
      elseif new.channel[1] then
        new.channelDuration = UnitChannelDuration(unit)
      end
    end
    return new, state
  end,
  ["threat"] = function(oldState, unit)
    local result = {situation = UnitThreatSituation("player", unit), otherTankAggro = false}
    if result.situation ~= 3 and result.situation ~= 2 and IsTank() then
      for _, tankUnit in ipairs(GetOtherTanks()) do
        if UnitThreatSituation(tankUnit, unit) == 3 then
          result.otherTankAggro = true
          break
        end
      end
    end
    return result, not oldState or result.situation ~= oldState.situation or result.otherTankAggro ~= oldState.otherTankAggro
  end,
  ["range"] = function(oldState, unit)
    local result = addonTable.Display.Utilities.GetRangeChecker()(unit)
    return result, result ~= oldState
  end,
  ["combat"] = function(oldState, unit)
    local inCombat = IsInCombatWith(unit)
    return inCombat, inCombat ~= oldState
  end,
  ["canAttack"] = function(oldState, unit)
    local canAttack = UnitCanAttack("player", unit)
    return canAttack, canAttack ~= oldState
  end,
  ["target"] = function(oldState, unit)
    local target = UnitIsUnit("target", unit)
    return target, target ~= oldState
  end,
  ["softTarget"] = function(oldState, unit)
    local target = not UnitIsUnit("target", unit) and (UnitIsUnit("softenemy", unit) or UnitIsUnit("softfriend", unit))
    return target, target ~= oldState
  end,
  ["mouseover"] = function(oldState, unit)
    local mouseover = UnitIsUnit("mouseover", unit)
    return mouseover, mouseover ~= oldState
  end,
  ["focus"] = function(oldState, unit)
    local focus = UnitIsUnit("focus", unit)
    return focus, focus ~= oldState
  end,
}

local eventsFromKind = {
  ["cast"] = {
    "UNIT_SPELLCAST_START",
    "UNIT_SPELLCAST_STOP",
    "UNIT_SPELLCAST_FAILED",
    "UNIT_SPELLCAST_INTERRUPTED",
    "UNIT_SPELLCAST_INTERRUPTIBLE",
    "UNIT_SPELLCAST_NOT_INTERRUPTIBLE",
    "UNIT_SPELLCAST_CHANNEL_START",
    "UNIT_SPELLCAST_CHANNEL_STOP",
    "UNIT_SPELLCAST_DELAYED",
    "UNIT_SPELLCAST_CHANNEL_UPDATE",
  },
  ["threat"] = {
    "UNIT_THREAT_LIST_UPDATE",
  },
}
if addonTable.Constants.IsRetail then
  tAppendAll(eventsFromKind["cast"], {
    "UNIT_SPELLCAST_EMPOWER_START",
    "UNIT_SPELLCAST_EMPOWER_STOP",
    "UNIT_SPELLCAST_EMPOWER_UPDATE",
  })
end
local eventToKind = {}
for kind, events in pairs(eventsFromKind) do
  for _, e in ipairs(events) do
    eventToKind[e] = kind
  end
end

function addonTable.Display.CacheMixin:OnLoad()
  self:SetScript("OnEvent", self.OnEvent)

  self.registeredCallbacks = {}

  self.monitoring = {
    --[[
    ["nameplate1"] = {
      cast = false,
      threat = false,
    },
    ]]
  }
  self.state = {
    --[[
    ["nameplate1"] = {
      cast = {cast = {}, channel = {}, interrupter = nil},
      threat = nil,
    },
    ]]
  }
  self.monitoringOrder = {}
  self.step = 1
  self.totalElapsed = 0

  for event in pairs(eventToKind) do
    self:RegisterEvent(event)
  end
  self:RegisterEvent("PLAYER_TARGET_CHANGED")
  self:RegisterEvent("PLAYER_SOFT_ENEMY_CHANGED")
  self:RegisterEvent("PLAYER_SOFT_FRIEND_CHANGED")

  self:RegisterEvent("PLAYER_FOCUS_CHANGED")
  self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")

  self:SetScript("OnUpdate", self.OnUpdate)

  addonTable.CallbackRegistry:RegisterCallback("LegacyInterrupter", function(_, playerGUID, destGUID)
    for unit, details in pairs(self.monitoring) do
      if details.cast and UnitGUID(unit) == destGUID then
        self:Process("cast", unit, "UNIT_SPELLCAST_INTERRUPTED", nil, nil, playerGUID)
      end
    end
  end)
end

function addonTable.Display.CacheMixin:AddUnit(unit)
  self.monitoring[unit] = {}
  self.state[unit] = {}
  self.registeredCallbacks[unit] = {}
  table.insert(self.monitoringOrder, unit)
  for kind in pairs(getter) do
    self.registeredCallbacks[unit][kind] = {}
  end
end

function addonTable.Display.CacheMixin:RegisterCallback(unit, kind, callback)
  table.insert(self.registeredCallbacks[unit][kind], callback)
end

function addonTable.Display.CacheMixin:RemoveUnit(unit)
  self.monitoring[unit] = nil
  self.state[unit] = nil
  self.registeredCallbacks[unit] = nil
  local index = tIndexOf(self.monitoringOrder, unit)
  if index then
    table.remove(self.monitoringOrder, index)
  end
end

function addonTable.Display.CacheMixin:Get(unit, kind)
  if self.monitoring[unit][kind] then
    return self.state[unit][kind]
  else
    local newState = getter[kind](nil, unit)
    self.state[unit][kind] = newState
    self.monitoring[unit][kind] = true
    return newState
  end
end

function addonTable.Display.CacheMixin:Process(kind, unit, eventName, ...)
  if not self.monitoring[unit] or not self.monitoring[unit][kind] then
    return
  end

  local data, update, timer = getter[kind](self.state[unit][kind], unit, eventName, ...)
  if update then
    self.state[unit][kind] = data
    for index, callback in ipairs(self.registeredCallbacks[unit][kind]) do
      callback(data)
    end
  end
  if timer then
    C_Timer.After(timer, function()
      self:Process(kind, unit)
    end)
  end
end

function addonTable.Display.CacheMixin:UpdateMouseover()
  for unit, details in pairs(self.monitoring) do
    if details.mouseover then
      self:Process("mouseover", unit, "UPDATE_MOUSEOVER_UNIT")
    end
  end

  if UnitExists("mouseover") and not self.MouseoverMonitor then
    self.MouseoverMonitor = C_Timer.NewTicker(0.1, function()
      if not UnitExists("mouseover") then
        self.MouseoverMonitor:Cancel()
        self.MouseoverMonitor = nil
        self:UpdateMouseover()
        if IsMouseButtonDown() then -- Holding down the mouse button will remove the mouseover unit temporarily
          self:RegisterEvent("GLOBAL_MOUSE_UP")
        end
      end
    end)
  end
end

function addonTable.Display.CacheMixin:OnEvent(eventName, unit, ...)
  if eventName == "PLAYER_TARGET_CHANGED" or eventName == "PLAYER_SOFT_FRIEND_CHANGED" or eventName == "PLAYER_SOFT_ENEMY_CHANGED" then
    for unit, details in pairs(self.monitoring) do
      if details.target then
        self:Process("target", unit, eventName, ...)
      end
      if details.softTarget then
        self:Process("softTarget", unit, eventName, ...)
      end
    end
  elseif eventName == "UPDATE_MOUSEOVER_UNIT" or eventName == "GLOBAL_MOUSE_UP" then
    self:UnregisterEvent("GLOBAL_MOUSE_UP")
    self:UpdateMouseover()
  elseif eventName == "PLAYER_FOCUS_CHANGED" then
    for unit, details in pairs(self.monitoring) do
      if details.focus then
        self:Process("focus", unit, eventName, ...)
      end
    end
  else
    local kind = eventToKind[eventName]
    self:Process(kind, unit, eventName, ...)
  end
end

function addonTable.Display.CacheMixin:OnUpdate(elapsed)
  local length = #self.monitoringOrder
  if length == 0 then
    return
  end
  if self.step > length then
    self.step = 1
  end
  self.totalElapsed = self.totalElapsed + elapsed
  if self.totalElapsed < 1 / 4 / length then
    return
  end
  local toProcess = self.totalElapsed * 4 * length
  self.totalElapsed = 0

  for i = self.step, math.min(length, self.step + toProcess - 1) do
    local unit = self.monitoringOrder[self.step]
    local details = self.monitoring[unit]
    local state = self.state[unit]

    if details.range then
      local kind = "range"
      local data, update = getter[kind](state[kind], unit)
      state[kind] = data
      if update then
        for _, callback in ipairs(self.registeredCallbacks[unit][kind]) do
          callback(data)
        end
      end
    end
    if details.combat then
      local kind = "combat"
      local data, update = getter[kind](state[kind], unit)
      state[kind] = data
      if update then
        for _, callback in ipairs(self.registeredCallbacks[unit][kind]) do
          callback(data)
        end
      end
    end
    if details.canAttack then
      local kind = "canAttack"
      local data, update = getter[kind](state[kind], unit)
      state[kind] = data
      if update then
        for _, callback in ipairs(self.registeredCallbacks[unit][kind]) do
          callback(data)
        end
      end
    end
    self.step = self.step + 1
  end
end
