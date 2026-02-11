---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.QuestTextMixin = {}

local significantFiguresCaches = {}

function addonTable.Display.QuestTextMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    addonTable.CallbackRegistry:RegisterCallback("QuestInfoUpdate", self.UpdateText, self)
    self:UpdateText()
  else
    addonTable.CallbackRegistry:UnregisterCallback("QuestInfoUpdate", self)
  end
end

function addonTable.Display.QuestTextMixin:Strip()
  addonTable.CallbackRegistry:UnregisterCallback("QuestInfoUpdate", self)
end

function addonTable.Display.QuestTextMixin:UpdateText()
  local info = addonTable.Display.Utilities.GetQuestInfo(self.unit)
  local text = ""
  if #info > 0 then
    text = info[1]
  end

  self.text:SetText(text)
end
