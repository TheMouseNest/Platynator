---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.CastTextMixin = {}

function addonTable.Display.CastTextMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
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
  self:UnregisterAllEvents()
end

function addonTable.Display.CastTextMixin:OnEvent(eventName, ...)
  self:ApplyCasting()
end

function addonTable.Display.CastTextMixin:ApplyCasting()
  local name, text = UnitCastingInfo(self.unit)
  if type(name) == "nil" then
    name, text = UnitChannelInfo(self.unit)
  end

  if type(name) ~= "nil" then
    self:Show()
    self.text:SetText(text)
  else
    self:Hide()
  end
end
