---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.HealthTextMixin = {}

local significantFiguresCaches = {}
local significantFiguresCallbacks = {}

local function GetDecimalPlaces(details)
  local decimalPlaces = math.floor(tonumber(details.decimalPlaces) or 0)
  return math.min(4, math.max(0, decimalPlaces))
end

local function GetSignificantFigures(details)
  local significantFigures = math.floor(tonumber(details.significantFigures) or 0)
  if significantFigures < 2 then
    return 0
  end
  return math.min(5, significantFigures)
end

local function GetSignificantFiguresFormatter(significantFigures)
  if addonTable.Constants.IsRetail then
    if not significantFiguresCaches[significantFigures] then
      local breakpoints = {
        {breakpoint = 100, fractionDivisor = 10^(significantFigures - 3), significandDivisor = 1/10^(significantFigures - 3), abbreviation = "", abbreviationIsGlobal = false},
        {breakpoint = 10, fractionDivisor = 10^(significantFigures - 2), significandDivisor = 1/10^(significantFigures - 2), abbreviation = "", abbreviationIsGlobal = false},
        {breakpoint = 1/1000000000000000, fractionDivisor = 10^(significantFigures - 1), significandDivisor = 1/10^(significantFigures - 1), abbreviation = "", abbreviationIsGlobal = false},
      }
      significantFiguresCaches[significantFigures] = {config = CreateAbbreviateConfig(breakpoints)}
    end
    return significantFiguresCaches[significantFigures]
  end

  if not significantFiguresCallbacks[significantFigures] then
    local step1 = 10^(significantFigures - 3)
    local step2 = 10^(significantFigures - 2)
    local step3 = 10^(significantFigures - 1)
    significantFiguresCallbacks[significantFigures] = function(number)
      if number >= 100 then
        return math.floor(number * step1) / step1
      elseif number >= 10 then
        return math.floor(number * step2) / step2
      end
      return math.floor(number * step3) / step3
    end
  end

  return significantFiguresCallbacks[significantFigures]
end

local function GetRoundedPercentage(value)
  if C_StringUtil and C_StringUtil.RoundToNearestString then
    return C_StringUtil.RoundToNearestString(value)
  end
  return tostring(Round(value))
end

function addonTable.Display.FormatHealthPercentage(value, details)
  if details.useDecimalPlaces then
    return string.format("%." .. GetDecimalPlaces(details) .. "f%%", value)
  end

  local significantFigures = GetSignificantFigures(details)
  if significantFigures > 0 then
    local formatter = GetSignificantFiguresFormatter(significantFigures)
    if addonTable.Constants.IsRetail then
      return AbbreviateNumbers(value, formatter) .. "%"
    end
    return tostring(formatter(value)) .. "%"
  end

  return GetRoundedPercentage(value) .. "%"
end

function addonTable.Display.HealthTextMixin:PostInit()
end

function addonTable.Display.HealthTextMixin:GetFormattedPercentage(value)
  return addonTable.Display.FormatHealthPercentage(value, self.details)
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
  self.GetFormattedPercentage = nil
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
      values.percentage = self:GetFormattedPercentage(value)
    else
      local value = UnitHealth(self.unit, true)/UnitHealthMax(self.unit)*100
      values.percentage = self:GetFormattedPercentage(value)
    end
    if #types == 2 then
      self.text:SetFormattedText("%s (%s)", values[types[1]], values[types[2]])
    elseif #types == 1 then
      self.text:SetFormattedText("%s", values[types[1]])
    end
  end
end
