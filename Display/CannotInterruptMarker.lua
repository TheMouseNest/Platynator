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

    self:ApplyCasting()
  else
    self:Strip()
  end
end

function addonTable.Display.CannotInterruptMarkerMixin:Strip()
  self:UnregisterAllEvents()
end

function addonTable.Display.CannotInterruptMarkerMixin:OnEvent(eventName, ...)
  self:ApplyCasting()
end

function addonTable.Display.CannotInterruptMarkerMixin:IsUninterruptible()
  local nameplate = C_NamePlate.GetNamePlateForUnit(self.unit, issecure())
  if nameplate and nameplate.UnitFrame then
    return nameplate.UnitFrame.castBar.barType == "uninterruptable"
  end
end

function addonTable.Display.CannotInterruptMarkerMixin:ApplyCasting()
  local name = UnitCastingInfo(self.unit)

  if type(name) == "nil" then
    name = UnitChannelInfo(self.unit)
  end

  if type(name) ~= "nil"then
    self.marker:SetShown(self:IsUninterruptible())
    C_Timer.After(0, function()
      self.marker:SetShown(self:IsUninterruptible())
    end)
  else
    self.marker:Hide()
  end
end
