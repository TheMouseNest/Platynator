---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.CastTextMixin = {}

function addonTable.Display.CastTextMixin:SetUnit(unit)
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

function addonTable.Display.CastTextMixin:Strip()
  if self.timer then
    self.timer:Cancel()
    self.timer = nil
  end
  self.interrupted = nil
  self:UnregisterAllEvents()
end

function addonTable.Display.CastTextMixin:OnEvent(eventName, ...)
  if eventName == "UNIT_SPELLCAST_INTERRUPTED" or eventName == "UNIT_SPELLCAST_CHANNEL_STOP" and select(4, ...) ~= nil then
    self.interrupted = true
    self:Show()
    self.text:SetText(addonTable.Locales.INTERRUPTED)
    if self.timer then
      self.timer:Cancel()
    end
    self.timer = C_Timer.NewTimer(0.8, function()
      if self.interrupted then
        self.interrupted = nil
        self.timer = nil
        self:Hide()
      end
    end)
  else
    self:ApplyCasting()
  end
end

function addonTable.Display.CastTextMixin:ApplyCasting()
  local name, text = UnitCastingInfo(self.unit)
  if type(name) == "nil" then
    name, text = UnitChannelInfo(self.unit)
  end

  if type(name) ~= "nil" then
    self.interrupted = nil
    self:Show()
    self.text:SetText(text)
  else
    if not self.interrupted then
      self:Hide()
    end
  end
end
