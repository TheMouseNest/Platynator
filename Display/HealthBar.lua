---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.HealthBarMixin = {}

local ConvertColor = addonTable.Display.Utilities.ConvertColor

function addonTable.Display.HealthBarMixin:PostInit()
  if self.details.background.applyColor then -- Apply tint to colours
    local mod = self.details.background.color
    if mod.r ~= 1 or mod.g ~= 1 or mod.b ~= 1 then
      self.modColors = CopyTable(self.details.autoColors)
      for _, s in ipairs(self.modColors) do
        for l, c in pairs(s.colors) do
          s.colors[l] = {r = mod.r * c.r, g = mod.g * c.g, b = mod.b * c.b, a = mod.a}
        end
      end
    end
  end
  if addonTable.Constants.IsMidnight then
    self.calculator = CreateUnitHealPredictionCalculator()
    if self.calculator.SetMaximumHealthMode then
      self.calculator:SetMaximumHealthMode(Enum.UnitMaximumHealthMode.WithAbsorbs)
      self.calculator:SetDamageAbsorbClampMode(Enum.UnitDamageAbsorbClampMode.MaximumHealth)
    end
  end
end

function addonTable.Display.HealthBarMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self:RegisterUnitEvent("UNIT_HEALTH", self.unit)
    self:RegisterUnitEvent("UNIT_MAXHEALTH", self.unit)
    self:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", self.unit)
    self:UpdateHealth()

    addonTable.Display.RegisterForColorEvents(self, self.details.autoColors)
    self:SetColor(addonTable.Display.GetColor(self.details.autoColors, self.colorState, self.unit))
  else
    self:UnregisterAllEvents()
    addonTable.Display.UnregisterForColorEvents(self)
  end
end

function addonTable.Display.HealthBarMixin:Strip()
  self:UnregisterAllEvents()
  addonTable.Display.UnregisterForColorEvents(self)
  self.modColors = nil
end

function addonTable.Display.HealthBarMixin:SetColor(...)
  self.statusBar:GetStatusBarTexture():SetVertexColor(...)
  if self.details.background.applyColor then
    local mod = self.details.background.color
    if self.modColors then
      self.background:SetVertexColor(addonTable.Display.GetColor(self.modColors, self.colorState, self.unit))
    else
      local r, g, b = ...
      self.background:SetVertexColor(r, g, b, mod.a)
    end
  end
  self.marker:SetVertexColor(...)
end

function addonTable.Display.HealthBarMixin:UpdateHealth()
  if self.calculator then
    if self.calculator.GetMaximumHealth then
      UnitGetDetailedHealPrediction(self.unit, nil, self.calculator)
      self.statusBar:SetMinMaxValues(0, self.calculator:GetMaximumHealth())
      self.statusBarAbsorb:SetMinMaxValues(self.statusBar:GetMinMaxValues())
      local absorbs = self.calculator:GetDamageAbsorbs()
      self.statusBarAbsorb:SetValue(absorbs)
    else
      self.statusBar:SetMinMaxValues(0, UnitHealthMax(self.unit))
      self.statusBarAbsorb:SetMinMaxValues(self.statusBar:GetMinMaxValues())
      self.statusBarAbsorb:SetValue(UnitGetTotalAbsorbs(self.unit))
    end
    self.statusBar:SetValue(UnitHealth(self.unit))
  else
    local absorbs = UnitGetTotalAbsorbs(self.unit)
    self.statusBar:SetMinMaxValues(0, UnitHealthMax(self.unit) + absorbs)
    self.statusBarAbsorb:SetMinMaxValues(self.statusBar:GetMinMaxValues())
    self.statusBar:SetValue(UnitHealth(self.unit, true))
    self.statusBarAbsorb:SetValue(absorbs)
  end
end

function addonTable.Display.HealthBarMixin:OnEvent(eventName)
  if eventName == "UNIT_HEALTH" then
    self:UpdateHealth()
  elseif eventName == "UNIT_MAXHEALTH" then
    self:UpdateHealth()
  elseif eventName == "UNIT_ABSORB_AMOUNT_CHANGED" then
    self:UpdateHealth()
  end

  self:ColorEventHandler(eventName)
end
