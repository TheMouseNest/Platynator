---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.CreatureTextMixin = {}

-- Helper to decide when to respect Blizzard's name visibility rules
local function ShouldRespectBlizzardFilter(unit)
  if not unit or UnitIsPlayer(unit) then return false end

  local reaction = UnitReaction("player", unit)
  if not reaction then return true end

  -- Hostile: always show
  if reaction <= 3 then
    return false
  end

  -- Neutral (reaction == 4): obey Blizzard for peaceful units only
  if reaction == 4 then
    if UnitCanAttack("player", unit) then
      return false -- aggressive neutral
    else
      return true  -- peaceful neutral → follow Blizzard
    end
  end

  -- Friendly: always follow Blizzard
  return true
end

function addonTable.Display.CreatureTextMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self:RegisterUnitEvent("UNIT_NAME_UPDATE", self.unit)

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
  if not self.unit then return end

  -- Apply hybrid rule: only hide if Blizzard says so *and* this unit type should obey that rule
  local respectFilter = ShouldRespectBlizzardFilter(self.unit)
  local showByBlizzard = UnitShouldDisplayName(self.unit)

  if (not respectFilter or showByBlizzard)
     and (not self.targetRequired or UnitIsUnit("target", self.unit)) then
    self.text:SetText(self.rawText)
  else
    self.targetRequired = true
    self.text:SetText("")
  end
end

function addonTable.Display.CreatureTextMixin:Strip()
  local c = self.details.color
  self.text:SetTextColor(c.r, c.g, c.b)
  self.rawText = nil
  self.targetRequired = nil
  self:UnregisterAllEvents()
end

function addonTable.Display.CreatureTextMixin:OnEvent(eventName, ...)
  self.rawText = UnitName(self.unit)
  self:UpdateText()
end

function addonTable.Display.CreatureTextMixin:ApplyTarget()
  self:UpdateText()
end
