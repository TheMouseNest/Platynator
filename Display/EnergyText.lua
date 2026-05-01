---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.EnergyTextMixin = {}

function addonTable.Display.EnergyTextMixin:PostInit()
  if self.details.showPercentSymbol then
    self.tail = "%"
  else
    self.tail = ""
  end
end

function addonTable.Display.EnergyTextMixin:SetUnit(unit)
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
    else
      self:Hide()
    end
  else
    self:Strip()
  end
end

function addonTable.Display.EnergyTextMixin:StripInternal()
  self:UnregisterAllEvents()

  self.powerKind = nil
end

function addonTable.Display.EnergyTextMixin:Strip()
  self.tail = nil
  self.PostInit = nil
end

function addonTable.Display.EnergyTextMixin:UpdateValue()
  self.text:SetText(string.format("%d", UnitPowerPercent(self.unit, self.powerKind, nil, CurveConstants.ScaleTo100)) .. self.tail)
end

function addonTable.Display.EnergyTextMixin:OnEvent()
  self:UpdateValue()
end
