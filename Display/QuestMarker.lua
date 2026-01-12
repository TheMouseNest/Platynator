---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.QuestMarkerMixin = CreateFromMixins(addonTable.Display.CombatVisibilityMixin)

function addonTable.Display.QuestMarkerMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self:RegisterEvent("QUEST_LOG_UPDATE")
    self:RegisterCombatEvents()
    self:UpdateMarker()
  else
    self:Strip()
  end
end

function addonTable.Display.QuestMarkerMixin:Strip()
  self:UnregisterAllEvents()
end

function addonTable.Display.QuestMarkerMixin:UpdateMarker()
  self.marker:SetShown(C_QuestLog.UnitIsRelatedToActiveQuest and C_QuestLog.UnitIsRelatedToActiveQuest(self.unit))
  if self:ShouldHideForCombat() then
    self.marker:Hide()
  end
end

function addonTable.Display.QuestMarkerMixin:OnEvent(eventName, ...)
  if eventName == "PLAYER_REGEN_ENABLED" or eventName == "PLAYER_REGEN_DISABLED" then
    self:UpdateMarker()
  else
    self:UpdateMarker()
  end
end
