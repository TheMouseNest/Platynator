---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.HealthTextMixin = {}

function addonTable.Display.HealthTextMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self:RegisterUnitEvent("UNIT_HEALTH", self.unit)
    self:UpdateText()
  else
    self:Strip()
  end
end

function addonTable.Display.HealthTextMixin:Strip()
  self:UnregisterAllEvents()
end

function addonTable.Display.HealthTextMixin:OnEvent()
  self:UpdateText()
end

function addonTable.Display.HealthTextMixin:UpdateText()
  if UnitIsDeadOrGhost(self.unit) then
    self.text:SetText("0")
  else
    local values = {
      percentage = "",
      absolute = AbbreviateNumbers(UnitHealth(self.unit)),
    }
    local types = self.details.displayTypes 
    if UnitHealthPercent then -- Midnight APIs
      values.percentage = string.format("%d%%", UnitHealthPercent(self.unit, true, true))
    else
      values.percentage = math.ceil(UnitHealth(self.unit, true)/UnitHealthMax(self.unit)*100) .. "%"
    end
    if #types == 2 then
      self.text:SetFormattedText("%s (%s)", values[types[1]], values[types[2]])
    elseif #types == 1 then
      self.text:SetFormattedText("%s", values[types[1]])
    end
  end
end
