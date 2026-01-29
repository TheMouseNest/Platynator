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

addonTable.Display.GuildTextMixin = {}

function addonTable.Display.GuildTextMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self.defaultText = ""
    if UnitIsPlayer(self.unit) then
      if self.details.playerGuild then
        local guild = GetGuildInfo(self.unit)
        if guild then
          self.defaultText = guild
        end
      end
    elseif not UnitIsBattlePetCompanion(self.unit) and not addonTable.Display.Utilities.IsInRelevantInstance() then
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
