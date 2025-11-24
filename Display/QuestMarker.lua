---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.QuestMarkerMixin = {}

function addonTable.Display.QuestMarkerMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self:RegisterEvent("QUEST_LOG_UPDATE")
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
end

function addonTable.Display.QuestMarkerMixin:OnEvent(eventName, ...)
  self:UpdateMarker()
end
