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

  local difficulty
  if addonTable.Constants.IsRetail then
    local rawDifficulty = C_PlayerInfo.GetContentDifficultyCreatureForPlayer(self.unit)
    if rawDifficulty == Enum.RelativeContentDifficulty.Trivial then
      difficulty =  "trivial"
    elseif rawDifficulty == Enum.RelativeContentDifficulty.Easy then
      difficulty = "standard"
    elseif rawDifficulty == Enum.RelativeContentDifficulty.Fair then
      difficulty = "difficult"
    elseif rawDifficulty == Enum.RelativeContentDifficulty.Difficult then
      difficulty = "verydifficult"
    elseif rawDifficulty == Enum.RelativeContentDifficulty.Impossible then
      difficulty = "impossible"
    else
      difficulty = "difficult"
    end
  else
    local levelDiff = UnitLevel(self.unit) - UnitEffectiveLevel("player");
    if  levelDiff >= 5 then
      difficulty = "impossible"
    elseif  levelDiff >= 3 then
      difficulty = "verydifficult"
    elseif  levelDiff >= -4 then
      difficulty = "difficult"
    elseif  -levelDiff <= GetQuestGreenRange() then
      difficulty = "standard"
    else
      difficulty =  "trivial"
    end
  end

  local color = self.details.colors.difficulty[difficulty]
  self.text:SetTextColor(color.r, color.g, color.b)
end

function addonTable.Display.LevelTextMixin:OnEvent(eventName, ...)
  self:UpdateLevel()
end
