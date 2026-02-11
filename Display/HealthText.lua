---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.HealthTextMixin = {}

local significantFiguresCaches = {}

function addonTable.Display.HealthTextMixin:PostInit()
  if self.details.significantFigures > 0 then
    if addonTable.Constants.IsRetail then
      if not significantFiguresCaches[self.details.significantFigures] then
        local breakpoints = {
          {breakpoint = 100, fractionDivisor = 10^(self.details.significantFigures - 3), significandDivisor = 1/10^(self.details.significantFigures - 3), abbreviation = "", abbreviationIsGlobal = false},
          {breakpoint = 10, fractionDivisor = 10^(self.details.significantFigures - 2), significandDivisor = 1/10^(self.details.significantFigures - 2), abbreviation = "", abbreviationIsGlobal = false},
          {breakpoint = 1/1000000000000000, fractionDivisor = 10^(self.details.significantFigures - 1), significandDivisor = 1/10^(self.details.significantFigures - 1), abbreviation = "", abbreviationIsGlobal = false},
        }
        significantFiguresCaches[self.details.significantFigures] = {config = CreateAbbreviateConfig(breakpoints)}
      end
      self.abbreviateData = significantFiguresCaches[self.details.significantFigures]
    else
      local step1 = 10^(self.details.significantFigures - 3)
      local step2 = 10^(self.details.significantFigures - 2)
      local step3 = 10^(self.details.significantFigures - 1)

      self.abbreviateCallback = function(number)
        if number >= 100 then
          return math.floor(number * step1) / step1
        elseif number >= 10 then
          return math.floor(number * step2) / step2
        else
          return math.floor(number * step3) / step3
        end
      end
    end
  end
end

function addonTable.Display.HealthTextMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self:RegisterUnitEvent("UNIT_HEALTH", self.unit)
    self:UpdateText()
  else
    self:UnregisterAllEvents()
  end
end

function addonTable.Display.HealthTextMixin:Strip()
  self:UnregisterAllEvents()
  self.abbreviateData = nil
  self.abbreviateCallback = nil
  self.PostInit = nil
end

function addonTable.Display.HealthTextMixin:OnEvent()
  self:UpdateText()
end

local AbbreviateNumbersAlt = addonTable.Display.Utilities.AbbreviateNumbersAlt

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
      local value = UnitHealthPercent(self.unit, true, CurveConstants.ScaleTo100)
      if self.abbreviateData then
        values.percentage = AbbreviateNumbers(value, self.abbreviateData) .. "%"
      else
        values.percentage = string.format("%d%%", value)
      end
    else
      local value = UnitHealth(self.unit, true)/UnitHealthMax(self.unit)*100
      if self.abbreviateCallback then
        values.percentage = self.abbreviateCallback(value) .. "%"
      else
        values.percentage = string.format("%d%%", value)
      end
    end
    if #types == 2 then
      self.text:SetFormattedText("%s (%s)", values[types[1]], values[types[2]])
    elseif #types == 1 then
      self.text:SetFormattedText("%s", values[types[1]])
    end
  end
end
