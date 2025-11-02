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
    self.rawText = ""
    if UnitIsPlayer(self.unit) then
      local guild = GetGuildInfo(self.unit)
      if guild then
        set = true
        self.rawText = guild
      end
    elseif not UnitIsBattlePetCompanion(self.unit) and not IsInInstance() then
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
          local text = line:GetText()
        end
      end
      if text and not text:match(invalidPattern1) and not text:match(invalidPattern2) then
        self.rawText = text
      end
    end
    self.targetRequired = false
  else
    self:Strip()
  end
end

function addonTable.Display.GuildTextMixin:UpdateText()
end

function addonTable.Display.GuildTextMixin:Strip()
  self.text:SetText("")
  self:UnregisterAllEvents()
end

function addonTable.Display.GuildTextMixin:ApplyTarget()
  if UnitShouldDisplayName(self.unit) and (not self.targetRequired or UnitIsUnit("target", self.unit)) then
    self.text:SetText(self.rawText)
  else
    self.targetRequired = true
    self.text:SetText("")
  end
end
