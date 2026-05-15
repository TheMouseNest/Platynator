---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.LevelTextMixin = {}

function addonTable.Display.LevelTextMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self:RegisterUnitEvent("UNIT_LEVEL", self.unit)
    self:RegisterUnitEvent("UNIT_CLASSIFICATION_CHANGED", self.unit)
    self:UpdateLevel()

    addonTable.Display.RegisterForColorEvents(self, self.details.autoColors)
  else
    self:Strip()
  end
end

function addonTable.Display.LevelTextMixin:Strip()
  self.text:SetTextColor(self.details.color.r, self.details.color.g, self.details.color.b)
  self:UnregisterAllEvents()
  addonTable.Display.UnregisterForColorEvents(self)
end

function addonTable.Display.LevelTextMixin:SetColor(r, g, b)
  if r then
    self.text:SetTextColor(r, g, b)
  else
    self.text:SetTextColor(self.details.color.r, self.details.color.g, self.details.color.b)
  end
end

function addonTable.Display.LevelTextMixin:UpdateLevel()
  local level = UnitLevel(self.unit)
  local text
  if level == -1 then
    text = "??"
  else
    text = tostring(level)
  end
  if self.details.showModifiers then
    local classification = UnitClassification(self.unit)
    if classification == "rare" then
      text = text .. "R"
    elseif classification == "rareelite" then
      text = text .. "R+"
    elseif classification == "elite" then
      text = text .. "+"
    elseif classification == "minus" then
      text = text .. "-"
    elseif classification == "worldboss" then
      text = text .. "B"
    end
  end
  self.text:SetText(text)
end

function addonTable.Display.LevelTextMixin:OnEvent(eventName)
  if eventName == "UNIT_LEVEL" or eventName == "UNIT_CLASSIFICATION_CHANGED" then
    self:UpdateLevel()
  end
  self:ColorEventHandler(eventName)
end
