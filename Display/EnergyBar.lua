---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.EnergyBarMixin = {}

function addonTable.Display.EnergyBarMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    if UnitIsPlayer(unit) or UnitTreatAsPlayerForDisplay and UnitTreatAsPlayerForDisplay(unit) then
      self:Hide()
      return
    end

    local numKind = UnitPowerType(self.unit)

    local isDelveRelevant = addonTable.Display.Utilities.IsInRelevantInstance({delve = true}) and self.details.mobTypes[addonTable.Display.Utilities.GetDelveType(self.unit)]
    local isDungeonOrRaidRelevant = addonTable.Display.Utilities.IsInRelevantInstance({dungeon = true, raid = true}) and self.details.mobTypes[addonTable.Display.Utilities.GetEliteType(self.unit)]

    if self.details.powerTypes[addonTable.Constants.PowerMap[numKind]] and (isDelveRelevant or isDungeonOrRaidRelevant) then
      self.powerKind = numKind

      self:RegisterUnitEvent("UNIT_POWER_UPDATE", self.unit)
      self:RegisterUnitEvent("UNIT_MAXPOWER", self.unit)
      self:UpdateValue()
      self:Show()
      addonTable.Display.RegisterForColorEvents(self, self.details.autoColors)
    else
      self:Hide()
    end
  else
    self:Strip()
  end
end

function addonTable.Display.EnergyBarMixin:SetColor(...)
  self.statusBar:GetStatusBarTexture():SetVertexColor(...)
  if self.details.background.applyColor then
    local mod = self.details.background.color
    if self.modColors then
      self.background:SetVertexColor(addonTable.Display.GetColor(self.modColors, self.colorState, self.unit))
    else
      local r, g, b = ...
      self.background:SetVertexColor(r, g, b, mod.a)
    end
  end
  self.marker:SetVertexColor(...)
end

function addonTable.Display.EnergyBarMixin:Strip()
  self:UnregisterAllEvents()
  addonTable.Display.UnregisterForColorEvents(self)

  self.powerKind = nil
end

function addonTable.Display.EnergyBarMixin:UpdateValue()
  local maxPower = UnitPowerMax(self.unit, self.powerKind)
  local currentPower = UnitPower(self.unit, self.powerKind)

  self.statusBar:SetMinMaxValues(0, maxPower)
  self.statusBar:SetValue(currentPower)
end

function addonTable.Display.EnergyBarMixin:OnEvent()
  self:UpdateValue()
end
