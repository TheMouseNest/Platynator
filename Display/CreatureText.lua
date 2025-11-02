---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.CreatureTextMixin = {}

function addonTable.Display.CreatureTextMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self:RegisterUnitEvent("UNIT_NAME_UPDATE", self.unit)

    -- *** NEW: respect Blizzard's name display settings ***
    if UnitShouldDisplayName and not UnitShouldDisplayName(self.unit) then
      self.text:SetText("") -- blank out name if Blizzard wouldn't show it
      return
    end
    -- *** END NEW ***

    self.text:SetText(UnitName(self.unit))
    if self.details.applyClassColors then
      local c
      if UnitIsPlayer(self.unit) then
        c = RAID_CLASS_COLORS[UnitClassBase(self.unit)]
      elseif addonTable.Display.Utilities.IsNeutralUnit(self.unit) then
        c = self.details.colors.npc.neutral
      elseif UnitIsFriend("player", self.unit) then
        c = self.details.colors.npc.friendly
      elseif UnitIsTapDenied(self.unit) then
        c = self.details.colors.npc.tapped
      else
        c = self.details.colors.npc.hostile
      end
      self.text:SetTextColor(c.r, c.g, c.b)
    end
  else
    self:Strip()
  end
end

function addonTable.Display.CreatureTextMixin:Strip()
  local c = self.details.color
  self.text:SetTextColor(c.r, c.g, c.b)
  self:UnregisterAllEvents()
end

function addonTable.Display.CreatureTextMixin:OnEvent(eventName, ...)
  -- Recheck Blizzard name visibility on name update
  if UnitShouldDisplayName and not UnitShouldDisplayName(self.unit) then
    self.text:SetText("")
  else
    self.text:SetText(UnitName(self.unit))
  end
end
