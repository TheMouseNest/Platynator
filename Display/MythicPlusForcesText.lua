---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.MythicPlusForcesTextMixin = {}

if C_ScenarioInfo.GetUnitCriteriaProgressValues then
  function addonTable.Display.MythicPlusForcesTextMixin:SetUnit(unit)
    self.unit = unit
    if C_PartyInfo.IsChallengeModeActive() and self.unit and not (UnitIsPlayer(unit) or UnitTreatAsPlayerForDisplay and UnitTreatAsPlayerForDisplay(unit)) and UnitCanAttack("player", unit) then
      local _, _, percent = C_ScenarioInfo.GetUnitCriteriaProgressValues(unit)
      if percent then
        self:Show()
        self.text:SetText(percent .. "%")
      else
        self:Hide()
      end
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

function addonTable.Display.MythicPlusForcesTextMixin:Strip()
end
