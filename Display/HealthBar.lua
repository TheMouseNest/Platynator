---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.HealthBarMixin = {}

function addonTable.Display.HealthBarMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self:RegisterUnitEvent("UNIT_HEALTH", self.unit)
    self:RegisterUnitEvent("UNIT_MAXHEALTH", self.unit)
    self:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", self.unit)
    self.statusBar:SetMinMaxValues(0, UnitHealthMax(self.unit))
    self.statusBarAbsorb:SetMinMaxValues(self.statusBar:GetMinMaxValues())
    self.statusBarAbsorb:SetValue(UnitGetTotalAbsorbs(self.unit))
    self:UpdateHealth()

    self:SetColor(addonTable.Display.GetColor(self.details.autoColors, self.unit))
    addonTable.Display.RegisterForColorEvents(self, self.details.autoColors)
  else
    self:Strip()
  end
end

function addonTable.Display.HealthBarMixin:Strip()
  self:UnregisterAllEvents()
  addonTable.Display.UnregisterForColorEvents(self)
end

function addonTable.Display.HealthBarMixin:SetColor(c)
  self.statusBar:GetStatusBarTexture():SetVertexColor(c.r, c.g, c.b)
  if self.details.background.applyColor then
    self.background:SetVertexColor(c.r, c.g, c.b)
  end
  self.marker:SetVertexColor(c.r, c.g, c.b)
end

function addonTable.Display.HealthBarMixin:UpdateHealth()
  if UnitIsDeadOrGhost(self.unit) then
    self.statusBar:SetValue(0)
  else
    self.statusBar:SetValue(UnitHealth(self.unit, true))
  end
end

function addonTable.Display.HealthBarMixin:OnEvent(eventName)
  if eventName == "UNIT_HEALTH" then
    self:UpdateHealth()
  elseif eventName == "UNIT_MAXHEALTH" then
    self.statusBar:SetMinMaxValues(0, UnitHealthMax(self.unit))
    self.statusBarAbsorb:SetMinMaxValues(self.statusBar:GetMinMaxValues())
  elseif eventName == "UNIT_ABSORB_AMOUNT_CHANGED" then
    self.statusBarAbsorb:SetValue(UnitGetTotalAbsorbs(self.unit))
  end

  self:ColorEventHandler(eventName)
end
