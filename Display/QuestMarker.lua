---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.QuestMarkerMixin = {}

function addonTable.Display.QuestMarkerMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    addonTable.CallbackRegistry:RegisterCallback("QuestInfoUpdate", self.UpdateMarker, self)
    self:UpdateMarker()
  else
    self:Strip()
  end
end

function addonTable.Display.QuestMarkerMixin:Strip()
  addonTable.CallbackRegistry:UnregisterCallback("QuestInfoUpdate", self)
end

function addonTable.Display.QuestMarkerMixin:UpdateMarker()
  self.marker:SetShown(#addonTable.Display.Utilities.GetQuestInfo(self.unit) > 0)
end

function addonTable.Display.QuestMarkerMixin:OnEvent(eventName, ...)
  self:UpdateMarker()
end
