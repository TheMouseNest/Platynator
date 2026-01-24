---@class addonTablePlatynator
local addonTable = select(2, ...)

-- For clients other than Midnight
local frame = CreateFrame("Frame")
local interrupterEnabled = false
frame:SetScript("OnEvent", function()
  local timestamp, subevent, _, playerGUID, _, _, _, destGUID = CombatLogGetCurrentEventInfo()
  if subevent == "SPELL_INTERRUPT" then
    addonTable.CallbackRegistry:TriggerEvent("LegacyInterrupter", playerGUID, destGUID)
  end
end)

local function EnableInterrupter()
  if interrupterEnabled then
    return
  end
  interrupterEnabled = true
  frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

addonTable.Display.CastInterrupterTextMixin = {}

function addonTable.Display.CastInterrupterTextMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self:RegisterUnitEvent("UNIT_SPELLCAST_START", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", self.unit)
    if not C_Secrets then
      EnableInterrupter()
      addonTable.CallbackRegistry:RegisterCallback("LegacyInterrupter", function(_, playerGUID, destGUID)
        if UnitGUID(self.unit) == destGUID then
          self:UpdateFromGUID(playerGUID)
        end
      end, self)
    end
    self:Hide()
  else
    self:Strip()
  end
end

function addonTable.Display.CastInterrupterTextMixin:Strip()
  if self.timer then
    self.timer:Cancel()
    self.timer = nil
  end
  self.interrupter = nil
  self.interrupterClass = nil
  self:UnregisterAllEvents()
  if not C_Secrets then
    addonTable.CallbackRegistry:UnregisterCallback("LegacyInterrupter", self)
  end
end

function addonTable.Display.CastInterrupterTextMixin:UpdateFromGUID(guid)
  local name, class, _
  if UnitNameFromGUID then
    name = UnitNameFromGUID(guid)
    _, class = GetPlayerInfoByGUID(guid)
  else
    local unit = UnitTokenFromGUID(guid)
    if not unit then
      return
    end
    name = UnitName(unit)
    class = UnitClassBase(unit)
  end
  self.interrupter = name
  self.interrupterClass = class

  self:UpdateText()
  self:Show()

  if self.timer then
    self.timer:Cancel()
  end
  self.timer = C_Timer.NewTimer(0.8, function()
    self:Hide()
    self.timer = nil
  end)
end

function addonTable.Display.CastInterrupterTextMixin:UpdateText()
  if self.interrupter ~= nil then
    self.text:SetText(self.interrupter)
    if self.interrupterClass ~= nil and self.details.applyClassColors then
      if C_ClassColor then
        self.text:SetTextColor(C_ClassColor.GetClassColor(self.interrupterClass):GetRGB())
      else
        self.text:SetTextColor(RAID_CLASS_COLORS[self.interrupterClass]:GetRGB())
      end
    end
  else
    self.text:SetText("")
  end
end

function addonTable.Display.CastInterrupterTextMixin:OnEvent(eventName, ...)
  local _, _, _, guid = ...
  if (eventName == "UNIT_SPELLCAST_INTERRUPTED" or eventName == "UNIT_SPELLCAST_CHANNEL_STOP") and guid then
    self:UpdateFromGUID(guid)
  else
    if self.timer then
      self.timer:Cancel()
      self.timer = nil
      self:Hide()
    end
  end
end
