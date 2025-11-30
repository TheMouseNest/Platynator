---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.LevelTextMixin = {}

function addonTable.Display.LevelTextMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self:RegisterUnitEvent("UNIT_LEVEL", self.unit)
    self:UpdateLevel()
  else
    self:Strip()
  end
end

function addonTable.Display.LevelTextMixin:Strip()
  self.text:SetTextColor(self.details.color.r, self.details.color.g, self.details.color.b)
  self:UnregisterAllEvents()
end

function addonTable.Display.LevelTextMixin:UpdateLevel()
  local level = UnitLevel(self.unit)
  if level == -1 then
    self.text:SetText("??")
  else
    self.text:SetText(level)
  end

  if not self.details.applyDifficultyColors then
    return
  end

  local difficulty = addonTable.Display.Utilities.GetUnitDifficulty(self.unit)

  local color = self.details.colors.difficulty[difficulty]
  self.text:SetTextColor(color.r, color.g, color.b)
end

function addonTable.Display.LevelTextMixin:OnEvent(eventName, ...)
  self:UpdateLevel()
end
