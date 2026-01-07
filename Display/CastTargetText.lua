---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.CastTargetTextMixin = {}

function addonTable.Display.CastTargetTextMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self:RegisterUnitEvent("UNIT_SPELLCAST_START", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", self.unit)

    self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", self.unit)

    self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", self.unit)

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
  local _, spellInfo = UnitCastingInfo(self.unit)
  local _, channelInfo = UnitChannelInfo(self.unit)
  if spellInfo or channelInfo then
    if UnitSpellTargetName then
      self.target = UnitSpellTargetName(self.unit)
      self.targetClass = UnitSpellTargetClass(self.unit)
    else
      self.target = UnitName(self.unit .. "target")
      self.targetClass = UnitClassBase(self.unit .. "target")
    end
  end
end

function addonTable.Display.CastTargetTextMixin:UpdateText()
  if self.target ~= nil then
    self.text:SetText(self.target)
    if self.targetClass ~= nil and self.details.applyClassColors then
      if C_ClassColor then
        self.text:SetTextColor(C_ClassColor.GetClassColor(self.targetClass):GetRGB())
      else
        self.text:SetTextColor(RAID_CLASS_COLORS[self.targetClass]:GetRGB())
      end
    end
  else
    self.text:SetText("")
  end
end

function addonTable.Display.CastTargetTextMixin:OnEvent(eventName, ...)
  local name = UnitCastingInfo(self.unit)

  if type(name) == "nil" then
    name = UnitChannelInfo(self.unit)
  end

  if type(name) == "nil" then
    self.target = nil
    self.targetClass = nil
  else
    self:UpdateTarget()
  end
  self:UpdateText()
end
