---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.AbsorbTextMixin = {}

local significantFiguresCaches = {}

function addonTable.Display.AbsorbTextMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", self.unit)
    self:UpdateText()
  else
    self:UnregisterAllEvents()
  end
end

function addonTable.Display.AbsorbTextMixin:Strip()
  self:UnregisterAllEvents()
  self.text:SetAlpha(1)
end

function addonTable.Display.AbsorbTextMixin:OnEvent()
  self:UpdateText()
end

local AbbreviateNumbersAlt = addonTable.Display.Utilities.AbbreviateNumbersAlt

function addonTable.Display.AbsorbTextMixin:GetAbsorbValues()
  return values
end

function addonTable.Display.AbsorbTextMixin:UpdateText()
  if UnitIsDeadOrGhost(self.unit) then
    self.text:SetText("0")
    self.text:SetAlpha(0)
  else
    local raw = UnitGetTotalAbsorbs(self.unit)
    local absolute = (AbbreviateNumbersAlt or AbbreviateNumbers)(raw)
    self.text:SetText("+" .. absolute)
    if issecretvalue and issecretvalue(raw) then
      self.text:SetAlpha(raw)
    else
      self.text:SetAlpha(raw > 0 and 1 or 0)
    end
  end
end
