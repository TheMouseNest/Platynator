---@class addonTablePlatynator
local addonTable = select(2, ...)

local GetOtherTanks = addonTable.Display.Utilities.GetOtherTanks
local IsTank = addonTable.Display.Utilities.IsTankRole

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
      return {cast = {}, channel = {}, interrupted = {guid = interrupterGUID}}, true
    end
    if eventName == "UNIT_SPELLCAST_CHANNEL_STOP" then
      local _, _, interrupterGUID = ...
      return {cast = {}, channel = {}, interrupted = interrupterGUID and {guid = interrupterGUID} or nil}, true
    end
    if eventName == "UNIT_SPELLCAST_EMPOWER_STOP" then
      local _, _, _, interrupterGUID = ...
      return {cast = {}, channel = {}, interrupted = {guid = interrupterGUID}}, true
    end
    if eventName == "UNIT_SPELLCAST_DELAYED" and next(oldState.cast) == nil or eventName == "UNIT_SPELLCAST_CHANNEL_UPDATE" and next(oldState.channel) == nil then
      return {cast = {}, channel = {}, interrupted = nil}, false
    end
    return {cast = {UnitCastingInfo(unit)}, channel = {UnitChannelInfo(unit)}, interrupted = nil}, true
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
  }
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

  for event in pairs(eventToKind) do
    self:RegisterEvent(event)
  end

  addonTable.CallbackRegistry:RegisterCallback("LegacyInterrupter", function(_, playerGUID, destGUID)
    for unit, details in pairs(self.monitoring) do
      if details.cast and UnitGUID(unit) == destGUID then
        local data = {cast = {}, channel = {}, interrupted = {guid = playerGUID}}
        self.state[unit]["cast"] = data
        for _, callback in ipairs(self.registeredCallbacks[unit]["cast"]) do
          callback(data)
        end
      end
    end
  end)
end

function addonTable.Display.CacheMixin:AddUnit(unit)
  self.monitoring[unit] = {}
  self.state[unit] = {}
  self.registeredCallbacks[unit] = {}
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

function addonTable.Display.CacheMixin:OnEvent(eventName, unit, ...)
  if not self.monitoring[unit] then
    return
  end
  local kind = eventToKind[eventName]
  if self.monitoring[unit][kind] then
    local data, update = getter[kind](self.state[unit][kind], unit, eventName, ...)
    self.state[unit][kind] = data
    if update then
      for index, callback in ipairs(self.registeredCallbacks[unit][kind]) do
        callback(data)
      end
    end
  end
end
