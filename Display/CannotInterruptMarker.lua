---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.CannotInterruptMarkerMixin = {}

function addonTable.Display.CannotInterruptMarkerMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self:RegisterUnitEvent("UNIT_SPELLCAST_START", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", self.unit)

    self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", self.unit)

    self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", self.unit)


    self:ApplyCasting()
  else
    self:Strip()
  end
end

function addonTable.Display.CannotInterruptMarkerMixin:Strip()
  self:UnregisterAllEvents()
  self.marker:SetAlpha(1)
end

function addonTable.Display.CannotInterruptMarkerMixin:OnEvent(eventName, ...)
  self:ApplyCasting()
end

function addonTable.Display.CannotInterruptMarkerMixin:ApplyCasting()
  local name, _, _, _, _, _, _, notInterruptible, _ = UnitCastingInfo(self.unit)

  if type(name) == "nil" then
    name, _, _, _, _, _, notInterruptible, _ = UnitChannelInfo(self.unit)
  end

  if type(name) ~= "nil" then
    if self.marker.SetAlphaFromBoolean then
      self.marker:Show()
      self.marker:SetAlphaFromBoolean(notInterruptible)
    else
      self.marker:SetShown(notInterruptible)
    end
  else
    self.marker:Hide()
  end
end
