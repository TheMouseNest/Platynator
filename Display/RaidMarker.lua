---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.RaidMarkerMixin = {}

function addonTable.Display.RaidMarkerMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self:RegisterEvent("RAID_TARGET_UPDATE")
    self:UpdateMarker()
  else
    self:Strip()
  end
end

function addonTable.Display.RaidMarkerMixin:Strip()
  self:UnregisterAllEvents()
  self.marker:SetTexCoord(0, 1, 0, 1)
end

function addonTable.Display.RaidMarkerMixin:OnEvent()
  self:UpdateMarker()
end

function addonTable.Display.RaidMarkerMixin:UpdateMarker()
  local index = GetRaidTargetIndex(self.unit)
  if type(index) ~= "nil" then
    self.marker:Show()
    SetRaidTargetIconTexture(self.marker, index)
  else
    self.marker:Hide()
  end
end
