---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.CastTargetMixin = {}

function addonTable.Display.CastTargetMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self:RegisterUnitEvent("UNIT_TARGET", self.unit)
    self:RegisterUnitEvent("UNIT_THREAT_LIST_UPDATE", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_START", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", self.unit)
    self:UpdateText()
  else
    self:Strip()
  end
end

function addonTable.Display.CastTargetMixin:Strip()
  self:UnregisterAllEvents()
  self.text:SetText("")
end

function addonTable.Display.CastTargetMixin:UpdateText()
  if UnitIsPlayer(self.unit) or not UnitCastingInfo(self.unit) then
    self.text:SetText("")
    return
  end
  
  local target = UnitName(self.unit .. "target")
  local targetUnit = self.unit .. "target"
  
  if target then
    self.text:SetText(target)
    local color = self:GetTargetColor(targetUnit)
    self.text:SetTextColor(color.r, color.g, color.b)
  else
    self.text:SetText("")
  end
end

function addonTable.Display.CastTargetMixin:OnEvent(eventName, ...)
  if eventName == "UNIT_SPELLCAST_START" or 
     eventName == "UNIT_SPELLCAST_STOP" or 
     eventName == "UNIT_SPELLCAST_FAILED" or 
     eventName == "UNIT_SPELLCAST_INTERRUPTED" then
    self:UpdateText()
  else
    self:UpdateText()
  end
end

function addonTable.Display.CastTargetMixin:GetTargetColor(targetUnit)
    if not targetUnit or not UnitExists(targetUnit) then
        return {r = 1, g = 1, b = 1}
    end
    
    local color
    
    if UnitIsPlayer(targetUnit) then
        local class = UnitClassBase(targetUnit)
        color = class and RAID_CLASS_COLORS[class]
        
        if not color then
            color = {r = 1, g = 1, b = 1}
        end
    else
        local reaction = UnitReaction(targetUnit, "player")
        if reaction and FACTION_BAR_COLORS[reaction] then
            color = FACTION_BAR_COLORS[reaction]
        else
            color = {r = 1, g = 0.5, b = 0}
        end
    end
    
    return color
end