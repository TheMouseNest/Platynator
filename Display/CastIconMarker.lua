---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.CastIconMarkerMixin = {}

function addonTable.Display.CastIconMarkerMixin:SetUnit(unit)
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

function addonTable.Display.CastIconMarkerMixin:Strip()
  self:UnregisterAllEvents()
end

function addonTable.Display.CastIconMarkerMixin:OnEvent(eventName, ...)
  self:ApplyCasting()
end

function addonTable.Display.CastIconMarkerMixin:ApplyCasting()
  local _, _, texture = UnitCastingInfo(self.unit)
  if type(texture) == "nil" then
    _, _, texture = UnitChannelInfo(self.unit)
  end

  if type(texture) ~= "nil" then
    self:Show()
    self.marker:SetTexture(texture)
  else
    self:Hide()
  end
end
