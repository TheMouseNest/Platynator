---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.FactionMarkerMixin = {}

function addonTable.Display.FactionMarkerMixin:PostInit()
  local markerDetails = addonTable.Assets.Markers[self.details.asset]
  self.hordeTexture = markerDetails.horde
  self.allianceTexture = markerDetails.alliance
end

function addonTable.Display.FactionMarkerMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    if UnitIsPlayer(unit) or (UnitTreatAsPlayerForDisplay and UnitTreatAsPlayerForDisplay(unit)) then
      self:RegisterEvent("UNIT_FACTION")
      self:UpdateState()
    else
      self:Hide()
    end
  else
    self:StripInternal()
  end
end

function addonTable.Display.FactionMarkerMixin:OnEvent()
  self:UpdateState()
end

function addonTable.Display.FactionMarkerMixin:UpdateState()
  local faction = UnitFactionGroup(self.unit)
  if faction == "Alliance" then
    self:Show()
    self.marker:SetTexture(self.allianceTexture)
  elseif faction == "Horde" then
    self:Show()
    self.marker:SetTexture(self.hordeTexture)
  else
    self:Hide()
  end
end

function addonTable.Display.FactionMarkerMixin:StripInternal()
  self:UnregisterAllEvents()
end

function addonTable.Display.FactionMarkerMixin:Strip()
  self:StripInternal()
  self.hordeTexture = nil
  self.allianceTexture = nil
  self.PostInit = nil
end
