---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.RareMarkerMixin = {}

function addonTable.Display.RareMarkerMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    local classification = UnitClassification(self.unit)
    if classification == "rare" then
      self.marker:Show()
    else
      self.marker:Hide()
    end
    
    local flip = self.details.flip or {}
    addonTable.Display.UpdateTextureFlip(self.marker, flip.horizontal)
  else
    self:Strip()
  end
end

function addonTable.Display.RareMarkerMixin:Strip()
end
