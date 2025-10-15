---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.HealthTextMixin = {}

function addonTable.Display.HealthTextMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    local unitFrame = C_NamePlate.GetNamePlateForUnit(self.unit).UnitFrame
    if addonTable.Constants.IsMidnight then
      self.healthSource = unitFrame.HealthBarsContainer.healthBar
    end
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
    local values = {percentage = "", absolute = ""}
    local types = self.details.displayTypes 
    if addonTable.Constants.IsMidnight then
      --- XXX: Remove when unit health formatting available, currently hides non-target friends cause the value stops updating
      values.absolute = self.healthSource.RightText:GetText()
      values.percentage = self.healthSource.LeftText:GetText()
      if type(values.absolute) == "nil" or UnitIsFriend("player", self.unit) and not UnitIsUnit("target", self.unit) then
        self.text:SetText("")
        return
      end
    else
      local health = UnitHealth(self.unit)
      values.absolute = AbbreviateNumbers(health)
      values.percentage = math.ceil(health/UnitHealthMax(self.unit)*100) .. "%"
    end
    if #types == 2 then
      self.text:SetFormattedText("%s (%s)", values[types[1]], values[types[2]])
    elseif #types == 1 then
      self.text:SetFormattedText("%s", values[types[1]])
    end
  end
end
