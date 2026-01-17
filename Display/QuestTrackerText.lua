---@class addonTablePlatynator
local addonTable = select(2, ...)

local tooltip
if not C_TooltipInfo then
  tooltip = CreateFrame("GameTooltip", "PlatynatorQuestTrackerTooltip", nil, "GameTooltipTemplate")
end

local unitTypeLevelPattern
if UNIT_TYPE_LEVEL_TEMPLATE then
  -- Convert e.g. "%s Level %s" into a whole-line pattern so we can skip "Beast Level 70".
  unitTypeLevelPattern = "^" .. UNIT_TYPE_LEVEL_TEMPLATE:gsub("%%.", ".+") .. "$"
end

local unitLevelPattern
if UNIT_LEVEL_TEMPLATE then
  -- Convert e.g. "Level %s" into a whole-line pattern so we can skip "Level 70".
  unitLevelPattern = "^" .. UNIT_LEVEL_TEMPLATE:gsub("%%.", ".+") .. "$"
end

local function IsSecret(value)
  return issecretvalue and issecretvalue(value)
end

-- Remove UI color codes so comparisons work on plain text (e.g. "|cffff0000Level 70|r" -> "Level 70").
local function StripColorCodes(text)
  if not text then
    return nil
  end
  text = text:gsub("|c%x%x%x%x%x%x%x%x", "")
  text = text:gsub("|r", "")
  return text
end

-- Normalize for comparisons: strip color codes + trim whitespace.
local function NormalizeText(text)
  text = StripColorCodes(text)
  if not text then
    return nil
  end
  return text:match("^%s*(.-)%s*$")
end

-- Remove leading dash used by Blizzard list formatting.
local function CleanProgressText(text)
  text = NormalizeText(text)
  if not text then
    return nil
  end
  return text:gsub("^%-+%s*", "")
end

-- Detect quest progress lines like "3/7" or "70%".
local function IsQuestProgressText(text)
  text = NormalizeText(text)
  if not text or text == "" then
    return false
  end
  if unitTypeLevelPattern and text:match(unitTypeLevelPattern) then
    return false
  end
  if unitLevelPattern and text:match(unitLevelPattern) then
    return false
  end
  if text:match("%d+/%d+") then
    return true
  end
  if text:match("%d+%%") then
    return true
  end
  return false
end

local questLineType = Enum and Enum.TooltipDataLineType and Enum.TooltipDataLineType.QuestObjective

-- Extract text from tooltip line, ignoring hidden/secret values.
local function GetLineText(line)
  if not line or line.isHidden then
    return nil
  end
  if line.leftText and not IsSecret(line.leftText) then
    return line.leftText
  end
  if line.rightText and not IsSecret(line.rightText) then
    return line.rightText
  end
  return nil
end

-- Build name lookup for player (and optionally party/raid) headers.
local function GetNameMap(includeGroup)
  local names = {}

  local function AddName(name, realm)
    if not name or name == "" then
      return
    end
    names[name] = true
    if realm and realm ~= "" then
      names[name .. "-" .. realm] = true
    end
  end
  
  local function AddUnit(unit)
    if not UnitName then
      return
    end
    local name, realm = UnitName(unit)
    AddName(name, realm)
    if UnitFullName then
      local fullName, fullRealm = UnitFullName(unit)
      AddName(fullName, fullRealm)
    end
  end

  AddUnit("player")
  if includeGroup then
    if IsInRaid and IsInRaid() and GetNumGroupMembers then
      for i = 1, GetNumGroupMembers() do
        AddUnit("raid" .. i)
      end
    elseif IsInGroup and IsInGroup() then
      local count = GetNumSubgroupMembers and GetNumSubgroupMembers() or 0
      for i = 1, count do
        AddUnit("party" .. i)
      end
    end
  end

  return names
end

-- Parse tooltip data (C_TooltipInfo) into quest progress text.
local function GetQuestTextFromTooltipData(tooltipData, firstOnly, partySupport)
  if not tooltipData or not tooltipData.lines then
    return nil
  end

  local groupNames = GetNameMap(true)
  local playerNames = GetNameMap(false)
  local isInGroup = IsInGroup and IsInGroup() or false
  local isInRaid = IsInRaid and IsInRaid() or false
  local inGroup = isInGroup or isInRaid
  -- Party support only applies in party, not in raid.
  local partySupportEnabled = partySupport and isInGroup and not isInRaid
  local currentIsPlayer = not inGroup
  local currentName
  local sawPlayerHeader = false
  local seenPlayers = {}

  local function IsGroupMemberLine(text)
    local plain = NormalizeText(text)
    if not plain or plain == "" then
      return false
    end
    return groupNames[plain] == true
  end

  local function IsPlayerLine(text)
    local plain = NormalizeText(text)
    if not plain or plain == "" then
      return false
    end
    return playerNames[plain] == true
  end

  -- Detect when tooltip enters a new player's section.
  local function SetCurrentPlayer(text)
    local plain = NormalizeText(text)
    if not plain or plain == "" then
      return
    end
    sawPlayerHeader = true
    currentName = plain
    currentIsPlayer = IsPlayerLine(plain)
  end

  -- Add a quest line based on mode (self-only vs party support).
  local function AddQuestLine(results, text)
    if partySupportEnabled then
      if not sawPlayerHeader or not currentName then
        return nil
      end
      local displayName = currentIsPlayer and (addonTable.Locales.ME or "Me") or currentName
      local seenKey = currentIsPlayer and "__me" or currentName
      if firstOnly and seenPlayers[seenKey] then
        return nil
      end
      if firstOnly then
        seenPlayers[seenKey] = true
      end
      local cleanText = CleanProgressText(text)
      if cleanText and cleanText ~= "" then
        table.insert(results, displayName .. ": " .. cleanText)
      end
      return nil
    end

    if not sawPlayerHeader or currentIsPlayer then
      if firstOnly then
        return text
      end
      table.insert(results, text)
    end
    return nil
  end

  if questLineType then
    local results = {}
    for _, line in ipairs(tooltipData.lines) do
      local headerText = GetLineText(line)
      if IsGroupMemberLine(headerText) then
        SetCurrentPlayer(headerText)
      end
      if line.type == questLineType then
        local text = GetLineText(line)
        if text and text ~= "" then
          local firstResult = AddQuestLine(results, text)
          if firstResult then
            return firstResult
          end
        end
      end
    end
    if #results > 0 then
      return table.concat(results, "\n")
    end
  end

  local results = {}
  for _, line in ipairs(tooltipData.lines) do
    local text = GetLineText(line)
    if IsGroupMemberLine(text) then
      SetCurrentPlayer(text)
    elseif IsQuestProgressText(text) then
      local firstResult = AddQuestLine(results, text)
      if firstResult then
        return firstResult
      end
    end
  end

  if #results > 0 then
    return table.concat(results, "\n")
  end

  return nil
end

-- Parse tooltip via GameTooltip fallback (classic/legacy).
local function GetQuestTextFromTooltip(unit, firstOnly, partySupport)
  if not tooltip then
    return nil
  end

  tooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
  tooltip:SetUnit(unit)

  local groupNames = GetNameMap(true)
  local playerNames = GetNameMap(false)
  local isInGroup = IsInGroup and IsInGroup() or false
  local isInRaid = IsInRaid and IsInRaid() or false
  local inGroup = isInGroup or isInRaid
  -- Party support only applies in party, not in raid.
  local partySupportEnabled = partySupport and isInGroup and not isInRaid
  local currentIsPlayer = not inGroup
  local currentName
  local sawPlayerHeader = false
  local seenPlayers = {}

  local function IsGroupMemberLine(text)
    local plain = NormalizeText(text)
    if not plain or plain == "" then
      return false
    end
    return groupNames[plain] == true
  end

  local function IsPlayerLine(text)
    local plain = NormalizeText(text)
    if not plain or plain == "" then
      return false
    end
    return playerNames[plain] == true
  end

  local function SetCurrentPlayer(text)
    local plain = NormalizeText(text)
    if not plain or plain == "" then
      return
    end
    sawPlayerHeader = true
    currentName = plain
    currentIsPlayer = IsPlayerLine(plain)
  end

  local function AddQuestLine(results, text)
    if partySupportEnabled then
      if not sawPlayerHeader or not currentName then
        return nil
      end
      local displayName = currentIsPlayer and (addonTable.Locales.ME or "Me") or currentName
      local seenKey = currentIsPlayer and "__me" or currentName
      if firstOnly and seenPlayers[seenKey] then
        return nil
      end
      if firstOnly then
        seenPlayers[seenKey] = true
      end
      local cleanText = CleanProgressText(text)
      if cleanText and cleanText ~= "" then
        table.insert(results, displayName .. ": " .. cleanText)
      end
      return nil
    end

    if not sawPlayerHeader or currentIsPlayer then
      if firstOnly then
        return text
      end
      table.insert(results, text)
    end
    return nil
  end

  local results = {}
  for i = 1, tooltip:NumLines() do
    local line = _G[tooltip:GetName() .. "TextLeft" .. i]
    local text = line and line:GetText()
    if IsGroupMemberLine(text) then
      SetCurrentPlayer(text)
    elseif IsQuestProgressText(text) then
      local firstResult = AddQuestLine(results, text)
      if firstResult then
        return firstResult
      end
    end
  end

  if #results > 0 then
    return table.concat(results, "\n")
  end

  return nil
end

-- Dispatch between C_TooltipInfo and GameTooltip paths.
local function GetQuestText(unit, firstOnly, partySupport)
  if C_TooltipInfo then
    return GetQuestTextFromTooltipData(C_TooltipInfo.GetUnit(unit), firstOnly, partySupport)
  end
  return GetQuestTextFromTooltip(unit, firstOnly, partySupport)
end

addonTable.Display.QuestTrackerTextMixin = {}

-- Mixin: register updates and refresh on quest log changes.
function addonTable.Display.QuestTrackerTextMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self:RegisterEvent("QUEST_LOG_UPDATE")
    self:UpdateText()
  else
    self:Strip()
  end
end

function addonTable.Display.QuestTrackerTextMixin:Strip()
  self:UnregisterAllEvents()
end

-- Mixin: apply the current formatted quest text.
function addonTable.Display.QuestTrackerTextMixin:UpdateText()
  if not self.unit then
    return
  end

  local text = GetQuestText(self.unit, self.details.firstOnly ~= false, self.details.partySupport == true)
  self.text:SetText(text or "")
end

function addonTable.Display.QuestTrackerTextMixin:OnEvent()
  self:UpdateText()
end
