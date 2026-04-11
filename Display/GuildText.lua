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

-- [ADDED] Guild Name Filter
-- Evaluates whether a guild name satisfies the user-configured filter condition.
-- Called before displaying the guild name on a nameplate; if the filter is active
-- and the guild does not match, the text is suppressed (defaultText stays "").
--
-- @param guild   string  The guild name retrieved via GetGuildInfo()
-- @param filter  table|nil  details.guildNameFilter:
--                  { enabled = bool, operator = string, value = string }
--                  operator values: "equalTo" | "beginsWith" | "endsWith"
--                                   "contains" | "notEqualTo"
-- @return bool   true = show the guild name, false = suppress it
local function MatchesGuildFilter(guild, filter)
  -- If no filter is configured, or the checkbox is unchecked, always show.
  if not filter or not filter.enabled then return true end

  local text = filter.value or ""
  -- An empty filter value is treated as "no restriction" — always show.
  if text == "" then return true end

  -- If we somehow have no guild string at this point, suppress to be safe.
  if not guild or guild == "" then return false end

  local op = filter.operator or "equalTo"

  if     op == "equalTo"    then return guild == text
  elseif op == "beginsWith" then return guild:sub(1, #text) == text
  elseif op == "endsWith"   then return #text == 0 or guild:sub(-#text) == text
  elseif op == "contains"   then return guild:find(text, 1, true) ~= nil
  elseif op == "notEqualTo" then return guild ~= text
  end

  -- Unknown operator — default to showing.
  return true
end

addonTable.Display.GuildTextMixin = {}

function addonTable.Display.GuildTextMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self.defaultText = ""
    if UnitIsPlayer(self.unit) then
      if self.details.playerGuild then
        local guild = GetGuildInfo(self.unit)
        -- [ADDED] Only set the guild name as the display text if it passes the
        -- user's guild name filter (details.guildNameFilter). When no filter is
        -- set (or the checkbox is unchecked), MatchesGuildFilter returns true and
        -- behaviour is identical to the original code.
        if guild and MatchesGuildFilter(guild, self.details.guildNameFilter) then
          self.defaultText = guild
        end
      end
    elseif not UnitIsBattlePetCompanion(self.unit) and not addonTable.Display.Utilities.IsInRelevantInstance({dungeon = true, raid = true, delve = true, pvp = true}) then
      if self.details.npcRole then
        local text
        if C_TooltipInfo then
          local tooltipData = C_TooltipInfo.GetUnit(self.unit)
          local line = tooltipData.lines[isColorBlindMode and 3 or 2]
          if not issecretvalue and line or (issecretvalue and not issecretvalue(line) and line and not issecretvalue(line.leftText)) then
            text = line.leftText
          end
        else
          tooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
          tooltip:SetUnit(self.unit)
          local line = _G[tooltip:GetName() .. "TextLeft" .. (isColorBlindMode and 3 or 2)]
          if line then
            text = line:GetText()
          end
        end
        if text and not text:match(invalidPattern1) and not text:match(invalidPattern2) then
          self.defaultText = text
        end
      end
    end
    self.text:SetText(self.defaultText)
    if self.details.showWhenWowDoes then
      self:SetShown(UnitIsUnit(self.unit, "target") or UnitShouldDisplayName(self.unit))
      self:RegisterUnitEvent("UNIT_HEALTH", self.unit)
    end
  else
    self.defaultText = nil
    self:UnregisterAllEvents()
  end
end

function addonTable.Display.GuildTextMixin:Strip()
  self.ApplyTarget = nil
  self.ApplyTextOverride = nil

  self.defaultText = nil
  self:UnregisterAllEvents()
end

function addonTable.Display.GuildTextMixin:OnEvent()
  self:ApplyTarget()
end

function addonTable.Display.GuildTextMixin:ApplyTarget()
  if self.details.showWhenWowDoes then
    self:SetShown(UnitIsUnit(self.unit, "target") or UnitShouldDisplayName(self.unit))
  end
end

function addonTable.Display.GuildTextMixin:ApplyTextOverride()
  local override = addonTable.API.TextOverrides.guild[self.unit]
  self.text:SetText(override or self.defaultText)
end
