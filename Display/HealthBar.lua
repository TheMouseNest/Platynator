---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.HealthBarMixin = {}

function addonTable.Display.HealthBarMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self:RegisterUnitEvent("UNIT_HEALTH", self.unit)
    self:RegisterUnitEvent("UNIT_MAXHEALTH", self.unit)
    self:RegisterUnitEvent("UNIT_THREAT_LIST_UPDATE", self.unit)
    self.statusBar:SetMinMaxValues(0, UnitHealthMax(self.unit))
    self.statusBar:SetValue(UnitHealth(self.unit))
    self:UpdateColor()
    self:UpdateHealth()
  else
    self:Strip()
  end
end

function addonTable.Display.HealthBarMixin:Strip()
  self:UnregisterAllEvents()
end

function addonTable.Display.HealthBarMixin:SetHealthColor(c)
  self.statusBar:GetStatusBarTexture():SetVertexColor(c.r, c.g, c.b)
  if self.details.background.applyColor then
    self.background:SetVertexColor(c.r, c.g, c.b)
  end
  self.marker:SetVertexColor(c.r, c.g, c.b)
end

function addonTable.Display.HealthBarMixin:IsNeutral()
  if UnitSelectionType then
    return UnitSelectionType(self.unit) == 2
  else
    local r, g, b = UnitSelectionColor(self.unit)
    return r == 1 and g == 1 and b == 0
  end
end

function addonTable.Display.HealthBarMixin:UpdateColor()
  if UnitIsPlayer(self.unit) then
    local c = RAID_CLASS_COLORS[UnitClassBase(self.unit)]
    self:SetHealthColor(c)
  elseif self:IsNeutral() and not UnitAffectingCombat(self.unit) then
    local c = self.details.colors.npc.neutral
    self:SetHealthColor(c)
  elseif UnitIsFriend("player", self.unit) then
    local c = self.details.colors.npc.friendly
    self:SetHealthColor(c)
  elseif not UnitCanAttack("player", self.unit) and UnitIsEnemy("player", self.unit) then
    local c = self.details.colors.npc.hostile
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
  if not C_SpecializationInfo.GetSpecialization then
    return roleType.Damage
  end
  local specIndex = C_SpecializationInfo.GetSpecialization()
  local _, _, _, _, role = C_SpecializationInfo.GetSpecializationInfo(specIndex)

  return roleMap[role]
end

function addonTable.Display.HealthBarMixin:ApplyThreat()
  local status = UnitThreatSituation("player", self.unit)
  local role = self:GetRole()
  if (role == roleType.Tank and (status == 0 or status == nil)) or (role ~= roleType.Tank and status == 3) then
    self:SetHealthColor(self.details.colors.threat.warning)
  elseif status == 1 or status == 2 then
    self:SetHealthColor(self.details.colors.threat.transition)
  elseif (role == roleType.Tank and status == 3) or (role ~= roleType.Tank and (status == 0 or status == nil)) then
    self:SetHealthColor(self.details.colors.threat.safe)
  end
end

function addonTable.Display.HealthBarMixin:UpdateHealth()
  if UnitIsDeadOrGhost(self.unit) then
    self.statusBar:SetValue(0)
  else
    self.statusBar:SetValue(UnitHealth(self.unit))
  end
end

function addonTable.Display.HealthBarMixin:OnEvent(eventName)
  if eventName == "UNIT_HEALTH" then
    self:UpdateHealth()
  elseif eventName == "UNIT_MAXHEALTH" then
    self.statusBar:SetMinMaxValues(0, UnitHealthMax(self.unit))
  elseif eventName == "UNIT_THREAT_LIST_UPDATE" then
    self:UpdateColor()
  end
end
