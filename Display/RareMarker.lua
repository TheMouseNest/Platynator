---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.RareMarkerMixin = {}

function addonTable.Display.RareMarkerMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self:RegisterEvent("UNIT_CLASSIFICATION_CHANGED")
    self:UpdateState()
  else
    self:Strip()
  end
end

function addonTable.Display.RareMarkerMixin:Strip()
  self:UnregisterAllEvents()
end

function addonTable.Display.RareMarkerMixin:OnEvent()
  self:UpdateState()
end

function addonTable.Display.RareMarkerMixin:UpdateState()
  local classification = UnitClassification(self.unit)
  if classification == "rare" or (self.details.includeElites and classification == "rareelite") then
    self:Show()
  else
    self:Hide()
  end
end
