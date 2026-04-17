---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.MythicPlusForcesTextMixin = {}

function addonTable.Display.MythicPlusForcesTextMixin:PostInit()
  self.formatMultiple = self.details.formatMultiple
  if self.details.showPercentSymbol then
    self.percentTail = "%"
  else
    self.percentTail = ""
  end
end

if C_ScenarioInfo.GetUnitCriteriaProgressValues then
  function addonTable.Display.MythicPlusForcesTextMixin:SetUnit(unit)
    self.unit = unit
    if C_PartyInfo.IsChallengeModeActive() and self.unit and not (UnitIsPlayer(unit) or UnitTreatAsPlayerForDisplay and UnitTreatAsPlayerForDisplay(unit)) and UnitCanAttack("player", unit) then
      self:Show()
      self:UpdateText()
    else
      self:Hide()
    end
  end
else
  function addonTable.Display.MythicPlusForcesTextMixin:SetUnit(unit)
    self.unit = unit
    self:Hide()
  end
end

function addonTable.Display.MythicPlusForcesTextMixin:UpdateText()
  local a, _, p = C_ScenarioInfo.GetUnitCriteriaProgressValues(self.unit)
  if not a then
    self:Hide()
    return
  end
  local values = {
    percentage = p .. self.percentTail,
    absolute = a,
  }
  local types = self.details.displayTypes
  if #types == 2 then
    self.text:SetFormattedText(self.formatMultiple, values[types[1]], values[types[2]])
  elseif #types == 1 then
    self.text:SetFormattedText("%s", values[types[1]])
  end
end

function addonTable.Display.MythicPlusForcesTextMixin:Strip()
  self.PostInit = nil
end
