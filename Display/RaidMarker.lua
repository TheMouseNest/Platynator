---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.RaidMarkerMixin = {}

function addonTable.Display.RaidMarkerMixin:PostInit()
  self.defaultAsset = addonTable.Assets.Markers[self.details.asset]
end

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
end

local fontString = UIParent:CreateFontString(nil, nil, "GameFontNormal")

function addonTable.Display.RaidMarkerMixin:UpdateMarker()
  local index = GetRaidTargetIndex(self.unit)
  if type(index) ~= "nil" then
    self.marker:Show()
    --XXX: Update this when Midnight supports sprite sheet properly
    fontString:SetFormattedText("Interface\\TargetingFrame\\UI-RaidTargetingIcon_%d.blp", index)
    self.marker:SetTexture(fontString:GetText())
  else
    self.marker:Hide()
  end
end
