---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.CastTimeLeftTextMixin = {}

function addonTable.Display.CastTimeLeftTextMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self.interrupted = nil
    self:RegisterUnitEvent("UNIT_SPELLCAST_START", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", self.unit)

    self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", self.unit)

    self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", self.unit)

    self:ApplyCasting()
  else
    self:Strip()
  end
end

function addonTable.Display.CastTimeLeftTextMixin:Strip()
  if self.timer then
    self.timer:Cancel()
    self.timer = nil
  end
  self:SetScript("OnUpdate", nil)
  self.duration = nil
  self.endTime = nil
  self:UnregisterAllEvents()
end

function addonTable.Display.CastTimeLeftTextMixin:OnEvent(eventName, ...)
  self:ApplyCasting()
end

function addonTable.Display.CastTimeLeftTextMixin:ApplyCasting()
  local name, _, _, _, endTime = UnitCastingInfo(self.unit)
  local isChanneled = false
  if type(name) == "nil" then
    name, _, _, _, endTime = UnitChannelInfo(self.unit)
    isChanneled = true
  end

  if type(name) ~= "nil" then
    self:Show()
    if UnitChannelDuration then
      if isChanneled then
        self.duration = UnitChannelDuration(self.unit)
      else
        self.duration = UnitCastingDuration(self.unit)
      end
      self.text:SetText(string.format("%.1f", self.duration:GetRemainingDuration()))
      self:SetScript("OnUpdate", function()
        self.text:SetText(string.format("%.1f", self.duration:GetRemainingDuration()))
      end)
    else
      self.endTime = endTime / 1000
      self.text:SetText(string.format("%.1f", self.endTime - GetTime()))
      self:SetScript("OnUpdate", function()
        self.text:SetText(string.format("%.1f", self.endTime - GetTime()))
      end)
    end
  else
    self:SetScript("OnUpdate", nil)
    self:Hide()
  end
end
