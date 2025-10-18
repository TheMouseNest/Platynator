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
  self:UnregisterAllEvents()
end

function addonTable.Display.LevelTextMixin:UpdateLevel()
  local level = UnitLevel(self.unit)
  if level == -1 then
    self.text:SetText("??")
  else
    self.text:SetText(level)
  end
end

function addonTable.Display.LevelTextMixin:OnEvent(eventName, ...)
  self:UpdateLevel()
end
