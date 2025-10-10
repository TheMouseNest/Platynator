---@class addonTablePlatynator
local addonTable = select(2, ...)

local fs = UIParent:CreateFontString(nil, nil, "GameFontNormal")
fs:Hide()

addonTable.Display.HealthBarMixin = {}
function addonTable.Display.HealthBarMixin:OnLoad()
  self:SetScript("OnEvent", self.OnEvent)

  local castStyle = addonTable.style.castBar

  self.healthBar = CreateFrame("StatusBar", nil, self)
  local healthBar = self.healthBar
  healthBar:SetStatusBarTexture(addonTable.style.healthBar.foreground)
  healthBar:SetPoint("CENTER")
  healthBar:SetSize(addonTable.style.healthBar.width*addonTable.style.healthBar.scale, addonTable.style.healthBar.height*addonTable.style.healthBar.scale)
  healthBar:SetClipsChildren(true)
  healthBar:GetStatusBarTexture():SetDrawLayer("ARTWORK")

  if addonTable.style.healthBar.marker and addonTable.style.healthBar.marker.texture then
    local healthMarker = self.healthBar:CreateTexture()
    healthMarker:SetTexture(addonTable.style.healthBar.marker.texture)
    healthMarker:SetPoint("RIGHT", healthBar:GetStatusBarTexture(), "RIGHT", addonTable.style.healthBar.marker.width * addonTable.style.healthBar.scale / 2, 0)
    healthMarker:SetSize(addonTable.style.healthBar.marker.width * addonTable.style.healthBar.scale, healthBar:GetHeight())
    healthMarker:SetDrawLayer("ARTWORK", 2)
    healthBar.marker = healthMarker
  end

  self.border = healthBar:CreateTexture()
  self.border:SetTexture(addonTable.style.healthBar.border)
  self.border:SetSize(addonTable.style.healthBar.width*addonTable.style.healthBar.scale, addonTable.style.healthBar.height*addonTable.style.healthBar.scale)
  self.border:SetPoint("CENTER")
  self.border:SetDrawLayer("OVERLAY")
  self.background = healthBar:CreateTexture()
  self.background:SetTexture(addonTable.style.healthBar.background)
  self.background:SetSize(addonTable.style.healthBar.width*addonTable.style.healthBar.scale, addonTable.style.healthBar.height*addonTable.style.healthBar.scale)
  self.background:SetPoint("CENTER")
  self.background:SetDrawLayer("BACKGROUND")
  self.background:SetAlpha(addonTable.style.healthBar.backgroundAlpha)
  healthBar.bg = bg

  self.targetHighlight = self:CreateTexture()
  self.targetHighlight:SetTexture(addonTable.style.healthBar.targetHighlight.texture)
  self.targetHighlight:SetSize(addonTable.style.healthBar.targetHighlight.width*addonTable.style.healthBar.scale, addonTable.style.healthBar.targetHighlight.height*addonTable.style.healthBar.scale)
  local targetColor = addonTable.style.healthBar.targetHighlight.color
  self.targetHighlight:SetVertexColor(targetColor.r, targetColor.g, targetColor.b)
  self.targetHighlight:Hide()
  self.targetHighlight:SetPoint("CENTER")
  self.targetHighlight:SetDrawLayer("BACKGROUND", -5)

  self.healthTextContainer = CreateFrame("Frame", nil, self)
  self.healthTextContainer:SetAllPoints()
  self.healthText = self.healthTextContainer:CreateFontString(nil, nil, "PlatynatorNameplateFont")
  self.healthText:SetPoint(unpack(addonTable.style.healthText.anchor))
  self.healthText:SetDrawLayer("OVERLAY", 6)
  self.healthText:SetTextScale(addonTable.style.healthText.scale)

  self:SetSize(addonTable.style.healthBar.width*addonTable.style.healthBar.scale, addonTable.style.healthBar.height*addonTable.style.healthBar.scale)
end

function addonTable.Display.HealthBarMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self:RegisterUnitEvent("UNIT_HEALTH", self.unit)
    self:RegisterUnitEvent("UNIT_MAXHEALTH", self.unit)
    self:RegisterUnitEvent("UNIT_THREAT_LIST_UPDATE", self.unit)
    local unitFrame = C_NamePlate.GetNamePlateForUnit(self.unit).UnitFrame
    self.healthSource = unitFrame.HealthBarsContainer.healthBar
    self.healthBar:SetMinMaxValues(0, UnitHealthMax(self.unit))
    self.healthBar:SetValue(UnitHealth(self.unit))
    self:UpdateColor()
    self:UpdateHealth()
    self:ApplyTarget()
  else
    self:UnregisterAllEvents()
  end
end

function addonTable.Display.HealthBarMixin:SetHealthColor(c)
  self.healthBar:GetStatusBarTexture():SetVertexColor(c.r, c.g, c.b)
  if addonTable.style.healthBar.colorBackground then
    self.background:SetVertexColor(c.r, c.g, c.b)
  end
  if self.healthBar.marker then
    self.healthBar.marker:SetVertexColor(c.r, c.g, c.b)
  end
end

function addonTable.Display.HealthBarMixin:UpdateColor()
  if UnitIsPlayer(self.unit) then
    local c = RAID_CLASS_COLORS[UnitClassBase(self.unit)]
    self:SetHealthColor(c)
  elseif UnitIsFriend("player", self.unit) then
    local c = addonTable.style.healthBar.colors.npc.friendly
    self:SetHealthColor(c)
  elseif UnitSelectionType(self.unit) == 2 and not UnitAffectingCombat(self.unit) then
    local c = addonTable.style.healthBar.colors.npc.neutral
    self:SetHealthColor(c)
  elseif (not UnitCanAttack("player", self.unit)--[[or not UnitAffectingCombat(self.unit)]]) and UnitIsEnemy("player", self.unit) then
    local c = addonTable.style.healthBar.colors.npc.hostile
    self:SetHealthColor(c)
  else
    self:ApplyThreat()
  end
end

local roleType = {
  Damage = 1,
  Healer = 2,
  Tank = 3,
}

local roleMap = {
  ["DAMAGER"] = roleType.Damage,
  ["TANK"] = roleType.Tank,
  ["HEALER"] = roleType.Healer,

}
function addonTable.Display.HealthBarMixin:GetRole()
  local specIndex = C_SpecializationInfo.GetSpecialization()
  local _, _, _, _, role = C_SpecializationInfo.GetSpecializationInfo(specIndex)

  return roleMap[role]
end

function addonTable.Display.HealthBarMixin:ApplyThreat()
  local status = UnitThreatSituation("player", self.unit)
  local role = self:GetRole()
  if (role == roleType.Tank and (status == 0 or status == nil)) or (role ~= roleType.Tank and status == 3) then
    self:SetHealthColor(addonTable.style.healthBar.colors.threat.warning)
  elseif status == 1 or status == 2 then
    self:SetHealthColor(addonTable.style.healthBar.colors.threat.transition)
  elseif (role == roleType.Tank and status == 3) or (role ~= roleType.Tank and (status == 0 or status == nil)) then
    self:SetHealthColor(addonTable.style.healthBar.colors.threat.safe)
  end
end

function addonTable.Display.HealthBarMixin:UpdateHealth()
  if UnitIsDeadOrGhost(self.unit) then
    self.healthBar:SetValue(0)
    if #addonTable.style.healthText.types > 0 then
      self.healthText:SetText("0")
    else
      self.healthText:SetText("")
    end
  else
    self.healthBar:SetValue(UnitHealth(self.unit))

    local values = {percentage = "", absolute = ""}
    local types = addonTable.style.healthText.types
    if addonTable.Constants.IsMidnight then
      --- XXX: Remove when unit health formatting available, currently hides non-target friends cause the value stops updating
      values.absolute = self.healthSource.RightText:GetText()
      values.percentage = self.healthSource.LeftText:GetText()
      if type(values.absolute) == "nil" or UnitIsFriend("player", self.unit) and not UnitIsUnit("target", self.unit) then
        self.healthText:SetText("")
        return
      end
    else
      local health = UnitHealth(self.unit)
      values.absolute = FormatLargeNumber(health)
      values.percentage = math.floor(health/UnitHealthMax(self.unit)*100) .. "%"
    end
    if #types == 2 then
      self.healthText:SetFormattedText("%s (%s)", values[types[1]], values[types[2]])
    elseif #types == 1 then
      self.healthText:SetFormattedText("%s", values[types[1]])
    end
  end
end

function addonTable.Display.HealthBarMixin:ApplyTarget()
  self.targetHighlight:SetShown(self.unit and UnitIsUnit(self.unit, "target"))
  C_Timer.After(0, function()
    if self.unit then
      self:UpdateHealth()
    end
  end)
end

function addonTable.Display.HealthBarMixin:OnEvent(eventName)
  if eventName == "UNIT_HEALTH" then
    self:UpdateHealth()
  elseif eventName == "UNIT_MAXHEALTH" then
    self.healthBar:SetMinMaxValues(0, UnitHealthMax(self.unit))
  elseif eventName == "UNIT_THREAT_LIST_UPDATE" then
    self:UpdateColor()
  end
end
