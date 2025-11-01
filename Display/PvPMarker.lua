---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.PvPMarkerMixin = {}

function addonTable.Display.PvPMarkerMixin:SetUnit(unit)
  self.unit = unit
  if self.unit and addonTable.Constants.IsRetail then
    self:RegisterUnitEvent("UNIT_CLASSIFICATION_CHANGED", self.unit)

    self.showClassification = C_PvP.IsPVPMap()

    self:Update()
  else
    self:Strip()
  end
end

function addonTable.Display.PvPMarkerMixin:Strip()
  self:UnregisterAllEvents()
end

function addonTable.Display.PvPMarkerMixin:OnEvent(eventName, ...)
  self:Update()
end

local PVP_CLASSIFICATION_ATLAS_ELEMENTS
if Enum.PvPUnitClassification then
  PVP_CLASSIFICATION_ATLAS_ELEMENTS = {
    [Enum.PvPUnitClassification.FlagCarrierHorde] = "nameplates-icon-flag-horde",
    [Enum.PvPUnitClassification.FlagCarrierAlliance] = "nameplates-icon-flag-alliance",
    [Enum.PvPUnitClassification.FlagCarrierNeutral] = "nameplates-icon-flag-neutral",
    [Enum.PvPUnitClassification.CartRunnerHorde] = "nameplates-icon-cart-horde",
    [Enum.PvPUnitClassification.CartRunnerAlliance] = "nameplates-icon-cart-alliance",
    [Enum.PvPUnitClassification.AssassinHorde] = "nameplates-icon-bounty-horde",
    [Enum.PvPUnitClassification.AssassinAlliance] = "nameplates-icon-bounty-alliance",
    [Enum.PvPUnitClassification.OrbCarrierBlue] = "nameplates-icon-orb-blue",
    [Enum.PvPUnitClassification.OrbCarrierGreen] = "nameplates-icon-orb-green",
    [Enum.PvPUnitClassification.OrbCarrierOrange] = "nameplates-icon-orb-orange",
    [Enum.PvPUnitClassification.OrbCarrierPurple] = "nameplates-icon-orb-purple",
  }
end

function addonTable.Display.PvPMarkerMixin:Update()
  if not self.showClassification then
    self.marker:Hide()
    return
  end

  local pvpClassification = UnitPvpClassification(self.unit)
  local atlas = PVP_CLASSIFICATION_ATLAS_ELEMENTS[pvpClassification]

  if atlas then
    self.marker:Show()
    self.marker:SetAtlas(atlas)
  else
    self.marker:Hide()
  end
end
