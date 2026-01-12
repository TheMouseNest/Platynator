---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.SoftTargetHighlightMixin = {}

function addonTable.Display.SoftTargetHighlightMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self:RegisterEvent("PLAYER_SOFT_ENEMY_CHANGED")
    self:RegisterEvent("PLAYER_SOFT_FRIEND_CHANGED")
    self:ApplySoftTarget()
  else
    self:UnregisterAllEvents()
  end
end

function addonTable.Display.SoftTargetHighlightMixin:Strip()
  self.ApplySoftTarget = nil
end

function addonTable.Display.SoftTargetHighlightMixin:OnEvent()
  self:ApplySoftTarget()
end

function addonTable.Display.SoftTargetHighlightMixin:ApplySoftTarget()
  self:SetShown(IsTargetLoose() and UnitIsUnit("target", self.unit) and (UnitIsUnit("softenemy", self.unit) or UnitIsUnit("softfriend", self.unit)))
end
