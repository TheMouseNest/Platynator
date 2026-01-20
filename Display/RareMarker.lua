---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.RareMarkerMixin = {}

function addonTable.Display.RareMarkerMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    local classification = UnitClassification(self.unit)
    if classification == "rare" or (self.details.includeElites and classification == "rareelite") then
      self.marker:Show()
    else
      self.marker:Hide()
    end
  else
    self:Strip()
  end
end

function addonTable.Display.RareMarkerMixin:Strip()
end
