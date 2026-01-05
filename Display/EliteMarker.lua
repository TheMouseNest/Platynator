---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.EliteMarkerMixin = CreateFromMixins(addonTable.Display.CombatVisibilityMixin)

function addonTable.Display.EliteMarkerMixin:PostInit()
  local markerDetails = addonTable.Assets.Markers[self.details.asset]
  local special = addonTable.Assets.SpecialEliteMarkers[self.details.asset]
  if markerDetails.mode == addonTable.Assets.Mode.Special and special then
    self.eliteTexture = addonTable.Assets.Markers[special.elite].file
    self.rareEliteTexture = addonTable.Assets.Markers[special.rareElite].file
  else
    self.eliteTexture = markerDetails.file
    self.rareEliteTexture = markerDetails.file
  end
end

function addonTable.Display.EliteMarkerMixin:Update()
  local classification = UnitClassification(self.unit)
  if classification == "elite" or classification == "worldboss" then
    self.marker:Show()
    self.marker:SetTexture(self.eliteTexture)
  elseif classification == "rareelite" then
    self.marker:Show()
    self.marker:SetTexture(self.rareEliteTexture)
  else
    self.marker:Hide()
    return
  end
  
  if self:ShouldHideForCombat() then
    self.marker:Hide()
  end
end

function addonTable.Display.EliteMarkerMixin:SetUnit(unit)
  self.unit = unit
  self:UnregisterAllEvents()
  if self.unit then
    self:RegisterCombatEvents()
    self:Update()
  else
    self:Strip()
  end
end

function addonTable.Display.EliteMarkerMixin:OnEvent(event)
  if event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" then
    self:Update()
  end
end

function addonTable.Display.EliteMarkerMixin:Strip()
  self:UnregisterAllEvents()
end
