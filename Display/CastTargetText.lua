---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.CastTargetTextMixin = {}

function addonTable.Display.CastTargetTextMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self:RegisterUnitEvent("UNIT_SPELLCAST_START", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", self.unit)
    self:UpdateTarget()
    self:UpdateText()
  else
    self:Strip()
  end
end

function addonTable.Display.CastTargetTextMixin:Strip()
  self.target = nil
  self.targetClass = nil
  self:UnregisterAllEvents()
end

function addonTable.Display.CastTargetTextMixin:UpdateTarget()
  if UnitSpellTargetName then
    self.target = UnitSpellTargetName(self.unit)
    self.targetClass = UnitSpellTargetClass(self.unit)
  else
    local _, spellInfo = UnitCastingInfo(self.unit)
    local _, channelInfo = UnitChannelInfo(self.unit)
    if spellInfo or channelInfo then
      self.target = UnitName(self.unit .. "target")
      self.targetClass = UnitClassBase(self.unit .. "target")
    end
  end
end

function addonTable.Display.CastTargetTextMixin:UpdateText()
  if type(self.target) ~= "nil" then
    self.text:SetText(self.target)
    if type(self.targetClass) ~= "nil" then
      local c = RAID_CLASS_COLORS[self.targetClass]
      self.text:SetTextColor(c.r, c.g, c.b)
    end
  else
    self.text:SetText("")
  end
end

function addonTable.Display.CastTargetTextMixin:OnEvent(eventName, ...)
  self:UpdateTarget()
  self:UpdateText()
end
