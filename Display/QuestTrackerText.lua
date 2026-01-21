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

local questProgressPatterns
local threatPatterns

local function FormatStringToPattern(formatString)
  if not formatString or formatString == "" then
    return nil
  end

  local pattern = formatString
  pattern = pattern:gsub("%%(%d+)%$", "%%")
  pattern = pattern:gsub("%%%%", "\0PERCENT\0")
  pattern = pattern:gsub("%%%-?%d*%.?%d*[d]", "\0DIGIT\0")
  pattern = pattern:gsub("%%%-?%d*%.?%d*[s]", "\0STRING\0")
  pattern = pattern:gsub("([%(%)%.%+%-%*%?%[%]%^%$%%])", "%%%1")
  pattern = pattern:gsub("\0DIGIT\0", "%d+")
  pattern = pattern:gsub("\0STRING\0", ".+")
  pattern = pattern:gsub("\0PERCENT\0", "%%")
  return "^" .. pattern .. "$"
end

local function BuildQuestProgressPatterns()

  if questProgressPatterns then
    return questProgressPatterns
  end
  questProgressPatterns = {}
  if type(_G) ~= "table" then
    return questProgressPatterns
  end
  for key, value in pairs(_G) do
    if type(key) == "string" and key:match("^QUEST_") and type(value) == "string" then
      if (value:find("/", 1, true) or value:find("%%", 1, true))
        and (value:find("%d", 1, true) or value:find("%s", 1, true)) then
        local pattern = FormatStringToPattern(value)
        if pattern then
          table.insert(questProgressPatterns, pattern)
        end
      end
    end
  end
  return questProgressPatterns
end

local function BuildThreatPatterns()
  if threatPatterns then
    return threatPatterns
  end
  threatPatterns = {}
  if type(_G) ~= "table" then
    return threatPatterns
  end
  for key, value in pairs(_G) do
    if type(key) == "string" and key:match("^THREAT") and type(value) == "string" then
      if value:find("%d", 1, true) or value:find("%s", 1, true) then
        local pattern = FormatStringToPattern(value)
        if pattern then
          table.insert(threatPatterns, pattern)
        end
      end
    end
  end
  return threatPatterns
end

local function MatchesAnyPattern(text, patterns)
  for _, pattern in ipairs(patterns) do
    if text:match(pattern) then
      return true
    end
  end
  return false
end

-- Detect quest progress lines like "3/7" or "70%".
local function IsQuestProgressText(text, allowFallback)
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
  local threatList = BuildThreatPatterns()
  if #threatList > 0 and MatchesAnyPattern(text, threatList) then
    return false
  end
  local questList = BuildQuestProgressPatterns()
  if #questList > 0 then
    if MatchesAnyPattern(text, questList) then
      return true
    end
    if allowFallback then
      -- Questie may format objective text as "1/7 Objective" without Blizzard's format string.
      if text:match("^%d+/%d+") or text:match("^%d+%%") then
        return true
      end
    end
    return false
  end
  if allowFallback and (text:match("^%d+/%d+") or text:match("^%d+%%")) then
    return true
  end
  return false
end

local questieTooltips

-- Questie only hooks the default GameTooltip, so use its API when available.
local function GetQuestieTooltips()
  if questieTooltips then
    return questieTooltips
  end
  if QuestieLoader and QuestieLoader.ImportModule then
    local ok, tooltips = pcall(QuestieLoader.ImportModule, QuestieLoader, "QuestieTooltips")
    if ok and tooltips and tooltips.GetTooltip then
      questieTooltips = tooltips
      return questieTooltips
    end
  end
  return nil
end

local function GetQuestieNpcId(unit)
  if not UnitGUID then
    return nil
  end
  local guid = UnitGUID(unit)
  if not guid or guid == "" then
    return nil
  end
  local unitType, _, _, _, _, npcId = strsplit("-", guid)
  if unitType ~= "Creature" and unitType ~= "Vehicle" then
    return nil
  end
  if not npcId or npcId == "" then
    return nil
  end
  return npcId
end

local GetNameMap
local nameMapCache = {dirty = true}
local classColorCache = {dirty = true}

local function InvalidateNameMaps()
  nameMapCache.dirty = true
  classColorCache.dirty = true
end

do
  local frame = CreateFrame("Frame")
  frame:RegisterEvent("GROUP_ROSTER_UPDATE")
  frame:RegisterEvent("PLAYER_ENTERING_WORLD")
  frame:RegisterEvent("PLAYER_LOGIN")
  frame:RegisterEvent("UNIT_NAME_UPDATE")
  frame:SetScript("OnEvent", function()
    InvalidateNameMaps()
  end)
end

local function NormalizeName(text)
  text = NormalizeText(text)
  if not text then
    return nil
  end
  return text:lower()
end

local function BuildNameMapLower(includeGroup)
  return GetNameMap(includeGroup, true)
end

local function GetQuestieLineName(text, nameMap)
  if not text or not nameMap then
    return nil
  end
  for chunk in text:gmatch("%b()") do
    local plain = NormalizeName(chunk:sub(2, -2))
    if plain and nameMap[plain] then
      return plain
    end
  end
  return nil
end

local function StripQuestieNames(text, nameMap)
  if not text or not nameMap then
    return text
  end
  local stripped = text:gsub("%b()", function(chunk)
    local plain = NormalizeName(chunk:sub(2, -2))
    if plain and nameMap[plain] then
      return ""
    end
    return chunk
  end)
  stripped = stripped:gsub("%s%s+", " "):gsub("%s+$", "")
  return stripped
end

local BuildResultsText

local function GetQuestTextFromQuestie(unit, firstOnly, partySupport, partySupportCollapse)
  local tooltips = GetQuestieTooltips()
  if not tooltips then
    return nil
  end

  local npcId = GetQuestieNpcId(unit)
  if not npcId then
    return nil
  end

  local tooltipLines = tooltips.GetTooltip("m_" .. npcId)
  if type(tooltipLines) ~= "table" then
    return nil
  end

  local collapseEnabled = partySupport and partySupportCollapse == true
  local playerNames
  local groupNames
  if not partySupport or collapseEnabled then
    playerNames = BuildNameMapLower(false)
    groupNames = BuildNameMapLower(true)
  end

  local results = {}
  local playerProgress = collapseEnabled and {} or nil
  local currentQuestIndex = 0
  for _, line in ipairs(tooltipLines) do
    local normalized = NormalizeText(line)
    if normalized and normalized ~= "" and not IsQuestProgressText(line, true) then
      if firstOnly and currentQuestIndex >= 1 and #results > 0 then
        break
      end
      currentQuestIndex = currentQuestIndex + 1
    elseif IsQuestProgressText(line, true) then
      if currentQuestIndex == 0 then
        currentQuestIndex = 1
      end
      if not firstOnly or currentQuestIndex == 1 then
        local output = line
        local cleanText
        local isPlayerLine
        if collapseEnabled then
          local lineName = GetQuestieLineName(line, groupNames)
          if lineName then
            isPlayerLine = playerNames[lineName] == true
          end
          cleanText = CleanProgressText(StripQuestieNames(line, groupNames))
          if cleanText == "" then
            cleanText = nil
          end
        end
        if not partySupport then
          local lineName = GetQuestieLineName(line, groupNames)
          if lineName and not playerNames[lineName] then
            output = nil
          else
            output = StripQuestieNames(line, playerNames)
          end
        end
        if output and output ~= "" then
          if collapseEnabled then
            table.insert(results, {text = output, cleanText = cleanText, isPlayer = isPlayerLine})
            if isPlayerLine and cleanText then
              playerProgress[cleanText] = true
            end
          else
            table.insert(results, output)
          end
        end
      end
    end
  end

  if collapseEnabled then
    for _, entry in ipairs(results) do
      if entry and not entry.isPlayer and entry.cleanText and playerProgress[entry.cleanText] then
        entry.skip = true
      end
    end
  end

  local text = BuildResultsText(results)
  if text then
    return text
  end

  return nil
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
local function BuildNameMap(includeGroup)
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

local function BuildLowerNameMap(nameMap)
  local lowered = {}
  for name in pairs(nameMap) do
    if type(name) == "string" then
      lowered[name:lower()] = true
    end
  end
  return lowered
end

local function BuildClassMap(includeGroup)
  local classes = {}

  local function AddClass(name, realm, classFile)
    if not name or name == "" or not classFile then
      return
    end
    classes[name] = classFile
    if realm and realm ~= "" then
      classes[name .. "-" .. realm] = classFile
    end
  end
  
  local function AddUnit(unit)
    if not UnitName or not UnitClass then
      return
    end
    local name, realm = UnitName(unit)
    local classFile = UnitClassBase and UnitClassBase(unit)
    if not classFile then
      _, classFile = UnitClass(unit)
    end
    AddClass(name, realm, classFile)
    if UnitFullName then
      local fullName, fullRealm = UnitFullName(unit)
      AddClass(fullName, fullRealm, classFile)
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

  return classes
end

local function BuildLowerClassMap(classMap)
  local lowered = {}
  for name, classFile in pairs(classMap) do
    if type(name) == "string" and type(classFile) == "string" then
      lowered[name:lower()] = classFile
    end
  end
  return lowered
end

local function RefreshClassColors()
  classColorCache.group = BuildClassMap(true)
  classColorCache.groupLower = BuildLowerClassMap(classColorCache.group)
  classColorCache.dirty = false
end

local function RefreshNameMaps()
  nameMapCache.player = BuildNameMap(false)
  nameMapCache.group = BuildNameMap(true)
  nameMapCache.playerLower = BuildLowerNameMap(nameMapCache.player)
  nameMapCache.groupLower = BuildLowerNameMap(nameMapCache.group)
  nameMapCache.dirty = false
end

GetNameMap = function(includeGroup, lower)
  if nameMapCache.dirty or not nameMapCache.player or not nameMapCache.group then
    RefreshNameMaps()
  end
  if lower then
    return includeGroup and nameMapCache.groupLower or nameMapCache.playerLower
  end
  return includeGroup and nameMapCache.group or nameMapCache.player
end

local function GetClassColorHexByName(name)
  if not name or name == "" then
    return nil
  end
  if classColorCache.dirty or not classColorCache.groupLower then
    RefreshClassColors()
  end
  local normalized = NormalizeName(name)
  if not normalized then
    return nil
  end
  local classFile = classColorCache.groupLower[normalized]
  if not classFile then
    return nil
  end
  if C_ClassColor and C_ClassColor.GetClassColor then
    local color = C_ClassColor.GetClassColor(classFile)
    if color and color.GenerateHexColor then
      return color:GenerateHexColor()
    end
  end
  if RAID_CLASS_COLORS and RAID_CLASS_COLORS[classFile] then
    local color = RAID_CLASS_COLORS[classFile]
    if color.colorStr then
      return color.colorStr
    end
    return ("ff%02x%02x%02x"):format(color.r * 255, color.g * 255, color.b * 255)
  end
  return nil
end

local function FormatGroupMemberName(name)
  local hex = GetClassColorHexByName(name)
  if hex then
    return "|c" .. hex .. name .. "|r"
  end
  return name
end

local function CreateQuestLineState(firstOnly, partySupport, partySupportCollapse)
  local groupNames = GetNameMap(true)
  local playerNames = GetNameMap(false)
  local isInGroup = IsInGroup and IsInGroup() or false
  local isInRaid = IsInRaid and IsInRaid() or false
  local inGroup = isInGroup or isInRaid
  -- Party support only applies in party, not in raid.
  local partySupportEnabled = partySupport and isInGroup and not isInRaid
  local collapseEnabled = partySupportEnabled and partySupportCollapse == true
  local currentIsPlayer = not inGroup
  local currentName
  local sawPlayerHeader = false
  local seenPlayers = {}
  local results = {}
  local playerProgress = collapseEnabled and {} or nil

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

  local function MarkCollapsed(cleanText)
    if not collapseEnabled or not cleanText then
      return
    end
    for _, entry in ipairs(results) do
      if entry and not entry.skip and not entry.isPlayer and entry.cleanText == cleanText then
        entry.skip = true
      end
    end
  end

  -- Add a quest line based on mode (self-only vs party support).
  local function AddQuestLine(text)
    if partySupportEnabled then
      if not sawPlayerHeader or not currentName then
        return nil
      end
      local seenKey = currentIsPlayer and "__me" or currentName
      if firstOnly and seenPlayers[seenKey] then
        return nil
      end
      if firstOnly then
        seenPlayers[seenKey] = true
      end
      local cleanText = CleanProgressText(text)
      if cleanText and cleanText ~= "" then
        if currentIsPlayer then
          table.insert(results, {text = cleanText, cleanText = cleanText, isPlayer = true})
          if collapseEnabled then
            playerProgress[cleanText] = true
            MarkCollapsed(cleanText)
          end
        else
          if collapseEnabled and playerProgress[cleanText] then
            return nil
          end
          local entryText = cleanText .. " (" .. FormatGroupMemberName(currentName) .. ")"
          table.insert(results, {text = entryText, cleanText = cleanText, isPlayer = false})
        end
      end
      return nil
    end

    if not sawPlayerHeader or currentIsPlayer then
      if firstOnly then
        return text
      end
      table.insert(results, {text = text})
    end
    return nil
  end

  return {
    results = results,
    isGroupMemberLine = IsGroupMemberLine,
    setCurrentPlayer = SetCurrentPlayer,
    addQuestLine = AddQuestLine,
  }
end

BuildResultsText = function(results)
  if not results then
    return nil
  end
  local lines = {}
  for _, entry in ipairs(results) do
    if type(entry) == "string" then
      if entry ~= "" then
        table.insert(lines, entry)
      end
    elseif entry and entry.text and not entry.skip then
      table.insert(lines, entry.text)
    end
  end
  if #lines > 0 then
    return table.concat(lines, "\n")
  end
  return nil
end

-- Parse tooltip data (C_TooltipInfo) into quest progress text.
local function GetQuestTextFromTooltipData(tooltipData, firstOnly, partySupport, partySupportCollapse)
  if not tooltipData or not tooltipData.lines then
    return nil
  end

  if questLineType then
    local state = CreateQuestLineState(firstOnly, partySupport, partySupportCollapse)
    for _, line in ipairs(tooltipData.lines) do
      local headerText = GetLineText(line)
      if state.isGroupMemberLine(headerText) then
        state.setCurrentPlayer(headerText)
      end
      if line.type == questLineType then
        local text = GetLineText(line)
        if text and text ~= "" then
          local firstResult = state.addQuestLine(text)
          if firstResult then
            return firstResult
          end
        end
      end
    end
    local text = BuildResultsText(state.results)
    if text then
      return text
    end
  end

  local state = CreateQuestLineState(firstOnly, partySupport, partySupportCollapse)
  for _, line in ipairs(tooltipData.lines) do
    local text = GetLineText(line)
    if state.isGroupMemberLine(text) then
      state.setCurrentPlayer(text)
    elseif IsQuestProgressText(text) then
      local firstResult = state.addQuestLine(text)
      if firstResult then
        return firstResult
      end
    end
  end

  local text = BuildResultsText(state.results)
  if text then
    return text
  end

  return nil
end

-- Parse tooltip via GameTooltip fallback (classic/legacy).
local function GetQuestTextFromTooltip(unit, firstOnly, partySupport, partySupportCollapse)
  if not tooltip then
    return nil
  end

  tooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
  tooltip:SetUnit(unit)

  local state = CreateQuestLineState(firstOnly, partySupport, partySupportCollapse)
  for i = 1, tooltip:NumLines() do
    local line = _G[tooltip:GetName() .. "TextLeft" .. i]
    local text = line and line:GetText()
    if state.isGroupMemberLine(text) then
      state.setCurrentPlayer(text)
    elseif IsQuestProgressText(text) then
      local firstResult = state.addQuestLine(text)
      if firstResult then
        return firstResult
      end
    end
  end

  local text = BuildResultsText(state.results)
  if text then
    return text
  end

  return nil
end

-- Dispatch between C_TooltipInfo and GameTooltip paths.
local function GetQuestText(unit, firstOnly, partySupport, partySupportCollapse)
  if C_TooltipInfo then
    local text = GetQuestTextFromTooltipData(C_TooltipInfo.GetUnit(unit), firstOnly, partySupport, partySupportCollapse)
    if text and text ~= "" then
      return text
    end
  end
  local questieText = GetQuestTextFromQuestie(unit, firstOnly, partySupport, partySupportCollapse)
  if questieText and questieText ~= "" then
    return questieText
  end
  if not C_TooltipInfo then
    return GetQuestTextFromTooltip(unit, firstOnly, partySupport, partySupportCollapse)
  end
  return nil
end

addonTable.Display.QuestTrackerTextMixin = {}

-- Mixin: register updates and refresh on quest log changes.
function addonTable.Display.QuestTrackerTextMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self:RegisterEvent("QUEST_LOG_UPDATE")
    self:RegisterEvent("UNIT_QUEST_LOG_CHANGED")
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

  local text = GetQuestText(
    self.unit,
    self.details.firstOnly ~= false,
    self.details.partySupport == true,
    self.details.partySupportCollapse == true
  )
  self.text:SetText(text or "")
end

function addonTable.Display.QuestTrackerTextMixin:OnEvent()
  self:UpdateText()
end
