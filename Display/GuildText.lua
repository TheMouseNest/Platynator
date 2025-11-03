---@class addonTablePlatynator
local addonTable = select(2, ...)

local isColorBlindMode = false

local cvarMonitor = CreateFrame("Frame")
cvarMonitor:RegisterEvent("VARIABLES_LOADED")
cvarMonitor:RegisterEvent("CVAR_UPDATE")
cvarMonitor:SetScript("OnEvent", function()
  isColorBlindMode = GetCVarBool("colorblindmode")
end)

local invalidPattern1 = "^" .. UNIT_TYPE_LEVEL_TEMPLATE:gsub("%%.", ".+") .. "$"
local invalidPattern2 = "^" .. UNIT_LEVEL_TEMPLATE:gsub("%%.", ".+") .. "$"

local tooltip
if not C_TooltipInfo then
  tooltip = CreateFrame("GameTooltip", "PlatynatorUnitGuildTooltip", nil, "GameTooltipTemplate")
end

-----------------------------------------------------------------------
-- ShouldRespectBlizzardFilter (same as CreatureText logic)
-----------------------------------------------------------------------
local function ShouldRespectBlizzardFilter(unit)
  if not unit or UnitIsPlayer(unit) then return false end

  local reaction = UnitReaction("player", unit)
  if not reaction then return true end

  -- Hostile (<=3): always show
  if reaction <= 3 then return false end

  -- Neutral (4): only hide peaceful/parrots/citizens/etc
  if reaction == 4 then
    if UnitCanAttack("player", unit) then
      return false -- aggressive neutral
    else
      return true  -- peaceful neutral -> follow Blizzard
    end
  end

  -- Friendly: follow Blizzard
  return true
end

-----------------------------------------------------------------------
-- Guild Text Widget
-----------------------------------------------------------------------
addonTable.Display.GuildTextMixin = {}

function addonTable.Display.GuildTextMixin:SetUnit(unit)
  self.unit = unit
  if not unit then return self:Strip() end

  self.rawText = ""

  if UnitIsPlayer(self.unit) then
    local guild = GetGuildInfo(self.unit)
    if guild then self.rawText = guild end

  elseif not UnitIsBattlePetCompanion(self.unit) and not IsInInstance() then
    local text
    if C_TooltipInfo then
      local tooltipData = C_TooltipInfo.GetUnit(self.unit)
      local line = tooltipData.lines[isColorBlindMode and 3 or 2]
      if line and line.leftText then text = line.leftText end
    else
      tooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
      tooltip:SetUnit(self.unit)
      local line = _G[tooltip:GetName() .. "TextLeft" .. (isColorBlindMode and 3 or 2)]
      if line then text = line:GetText() end
    end

    if text
      and not text:match(invalidPattern1)
      and not text:match(invalidPattern2)
    then
      self.rawText = text
    end
  end

  self.targetRequired = false
end

function addonTable.Display.GuildTextMixin:UpdateText()
  if not self.unit then return end

  local respect = ShouldRespectBlizzardFilter(self.unit)
  local showByBlizzard = UnitShouldDisplayName(self.unit)

  if (not respect or showByBlizzard)
     and (not self.targetRequired or UnitIsUnit("target", self.unit))
  then
    self.text:SetText(self.rawText or "")
  else
    self.targetRequired = true
    self.text:SetText("")
  end
end

function addonTable.Display.GuildTextMixin:Strip()
  self.rawText = nil
  self.targetRequired = nil
  self:UnregisterAllEvents()
end

function addonTable.Display.GuildTextMixin:ApplyTarget()
  self:UpdateText()
end
