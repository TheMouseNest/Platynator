---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.CannotInterruptMarkerMixin = {}

function addonTable.Display.CannotInterruptMarkerMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self:RegisterUnitEvent("UNIT_SPELLCAST_START", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", self.unit)

    self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", self.unit)

    if addonTable.Constants.IsRetail then
      self:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_START", self.unit)
      self:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_STOP", self.unit)
    end

    self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", self.unit)

    self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTIBLE", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", self.unit)

    self:ApplyCasting()
  else
    self:Strip()
  end
end

function addonTable.Display.CannotInterruptMarkerMixin:Strip()
  self:UnregisterAllEvents()
  self.marker:SetAlpha(1)
end

function addonTable.Display.CannotInterruptMarkerMixin:OnEvent(eventName)
  if eventName == "UNIT_SPELLCAST_CHANNEL_STOP" or eventName == "UNIT_SPELLCAST_EMPOWER_STOP" or eventName == "UNIT_SPELLCAST_STOP" then
    self:Hide()
  else
    self:ApplyCasting()
  end
end

function addonTable.Display.CannotInterruptMarkerMixin:ApplyCasting()
  local _, _, _, _, _, _, _, notInterruptible, _ = UnitCastingInfo(self.unit)

  if notInterruptible == nil then
    _, _, _, _, _, _, notInterruptible, _ = UnitChannelInfo(self.unit)
  end

  if notInterruptible ~= nil then
    if self.marker.SetAlphaFromBoolean then
      self:Show()
      self.marker:SetAlphaFromBoolean(notInterruptible)
    else
      self:SetShown(notInterruptible)
    end
  else
    self:Hide()
  end
end
