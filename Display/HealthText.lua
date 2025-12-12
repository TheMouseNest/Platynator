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

local AbbreviateNumbersAlt
if addonTable.Constants.IsClassic then
  local NUMBER_ABBREVIATION_DATA_ALT = {
    { breakpoint = 10000000,	abbreviation = SECOND_NUMBER_CAP_NO_SPACE,	significandDivisor = 1000000,	fractionDivisor = 1 },
    { breakpoint = 1000000,		abbreviation = SECOND_NUMBER_CAP_NO_SPACE,	significandDivisor = 100000,		fractionDivisor = 10 },
    { breakpoint = 10000,		abbreviation = FIRST_NUMBER_CAP_NO_SPACE,	significandDivisor = 1000,		fractionDivisor = 1 },
    { breakpoint = 1000,		abbreviation = FIRST_NUMBER_CAP_NO_SPACE,	significandDivisor = 100,		fractionDivisor = 10 },
  }

  AbbreviateNumbersAlt = function(value)
    for i, data in ipairs(NUMBER_ABBREVIATION_DATA_ALT) do
      if value >= data.breakpoint then
        local finalValue = math.floor(value / data.significandDivisor) / data.fractionDivisor;
        return finalValue .. data.abbreviation;
      end
    end
    return tostring(value);
  end
end

function addonTable.Display.HealthTextMixin:UpdateText()
  if UnitIsDeadOrGhost(self.unit) then
    self.text:SetText("0")
  else
    local values = {
      percentage = "",
      absolute = (AbbreviateNumbersAlt or AbbreviateNumbers)(UnitHealth(self.unit)),
    }
    local types = self.details.displayTypes 
    if UnitHealthPercent then -- Midnight APIs
      values.percentage = string.format("%d%%", UnitHealthPercent(self.unit, true, CurveConstants.ScaleTo100))
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
