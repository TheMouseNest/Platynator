---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.LevelTextMixin = {}

function addonTable.Display.LevelTextMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self:RegisterUnitEvent("UNIT_LEVEL", self.unit)
    self:UpdateLevel()

    addonTable.Display.RegisterForColorEvents(self, self.details.autoColors)
    self:SetColor(addonTable.Display.GetColor(self.details.autoColors, self.colorState, self.unit))
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
  if level == -1 then
    self.text:SetText("??")
  else
    self.text:SetText(level)
  end
end

function addonTable.Display.LevelTextMixin:OnEvent(eventName, ...)
  self:ColorEventHandler(eventName)
end
