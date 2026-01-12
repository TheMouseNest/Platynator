---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.RaidMarkerMixin = CreateFromMixins(addonTable.Display.CombatVisibilityMixin)

function addonTable.Display.RaidMarkerMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self:RegisterEvent("RAID_TARGET_UPDATE")
    self:RegisterCombatEvents()
    self:UpdateMarker()
  else
    self:Strip()
  end
end

function addonTable.Display.RaidMarkerMixin:Strip()
  self:UnregisterAllEvents()
  self.marker:SetTexCoord(0, 1, 0, 1)
end

function addonTable.Display.RaidMarkerMixin:OnEvent(eventName)
  if eventName == "PLAYER_REGEN_ENABLED" or eventName == "PLAYER_REGEN_DISABLED" then
    self:UpdateMarker()
  else
    self:UpdateMarker()
  end
end

local fontString = UIParent:CreateFontString(nil, nil, "GameFontNormal")

function addonTable.Display.RaidMarkerMixin:UpdateMarker()
  local index = GetRaidTargetIndex(self.unit)
  if type(index) ~= "nil" then
    self.marker:Show()
    SetRaidTargetIconTexture(self.marker, index)
    if self:ShouldHideForCombat() then
      self.marker:Hide()
    end
  else
    self.marker:Hide()
  end
end
