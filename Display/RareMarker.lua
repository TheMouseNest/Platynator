---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.RareMarkerMixin = CreateFromMixins(addonTable.Display.CombatVisibilityMixin)

function addonTable.Display.RareMarkerMixin:SetUnit(unit)
  self.unit = unit
  self:UnregisterAllEvents()
  if self.unit then
    self:RegisterCombatEvents()
    self:Update()
  else
    self:Strip()
  end
end

function addonTable.Display.RareMarkerMixin:OnEvent(eventName)
  if eventName == "PLAYER_REGEN_ENABLED" or eventName == "PLAYER_REGEN_DISABLED" then
    self:Update()
  end
end

function addonTable.Display.RareMarkerMixin:Update()
  local classification = UnitClassification(self.unit)
  if classification == "rare" then
    self.marker:Show()
    if self:ShouldHideForCombat() then
      self.marker:Hide()
    end
  else
    self.marker:Hide()
  end
end

function addonTable.Display.RareMarkerMixin:Strip()
end
