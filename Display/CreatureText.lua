---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.CreatureTextMixin = {}

function addonTable.Display.CreatureTextMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self:RegisterUnitEvent("UNIT_NAME_UPDATE", self.unit)
    -- ApplyTarget is assumed to run and update the name text
    if self.details.applyClassColors then
      local c
      if UnitIsPlayer(self.unit) then
        c = RAID_CLASS_COLORS[UnitClassBase(self.unit)]
      elseif addonTable.Display.Utilities.IsNeutralUnit(self.unit) then
        c = self.details.colors.npc.neutral
      elseif addonTable.Display.Utilities.IsUnfriendlyUnit(self.unit) then
        c = self.details.colors.npc.unfriendly
      elseif UnitIsFriend("player", self.unit) then
        c = self.details.colors.npc.friendly
      elseif UnitIsTapDenied(self.unit) then
        c = self.details.colors.npc.tapped
      else
        c = self.details.colors.npc.hostile
      end
      self.text:SetTextColor(c.r, c.g, c.b)
    end

    self.rawText = UnitName(self.unit)
    self.targetRequired = false
  else
    self:Strip()
  end
end

function addonTable.Display.CreatureTextMixin:UpdateText()
  if UnitShouldDisplayName(self.unit) and (not self.targetRequired or UnitIsUnit("target", self.unit)) then
    self.text:SetText(self.rawText)
  else
    self.targetRequired = true
    self.text:SetText("")
  end
end

function addonTable.Display.CreatureTextMixin:Strip()
  local c = self.details.color
  self.text:SetTextColor(c.r, c.g, c.b)
  self:UnregisterAllEvents()
end

function addonTable.Display.CreatureTextMixin:OnEvent(eventName, ...)
  self.rawText = UnitName(self.unit)
  self:UpdateText()
end

function addonTable.Display.CreatureTextMixin:ApplyTarget()
  self:UpdateText()
end
