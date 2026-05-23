---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.PortraitMarkerMixin = {}

function addonTable.Display.PortraitMarkerMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self:RegisterUnitEvent("UNIT_PORTRAIT_UPDATE", unit)
    self:UpdateMarker()
  else
    self:Strip()
  end
end

function addonTable.Display.PortraitMarkerMixin:Strip()
  self:UnregisterAllEvents()
  self.marker:SetTexCoord(0, 1, 0, 1)
end

function addonTable.Display.PortraitMarkerMixin:OnEvent()
  self:UpdateMarker()
end

function addonTable.Display.PortraitMarkerMixin:UpdateMarker()
  SetPortraitTexture(self.marker, self.unit, false)
end
