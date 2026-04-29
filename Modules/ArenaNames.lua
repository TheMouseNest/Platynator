---@class addonTablePlatynator
local addonTable = select(2, ...)

-- Arena Names module: overrides nameplate names for arena opponents with their arena slot ID and spec.
-- Uses Platynator.API.SetUnitTextOverride so existing API + customise dialog values work uniformly.

local ArenaNames = CreateFrame("Frame")
addonTable.ArenaNames = ArenaNames

local SHORT_SPECS = {
  [250]="Blood",[251]="Frost",[252]="Unholy",
  [577]="Havoc",[581]="Vengeance",[1480]="Devourer",
  [102]="Balance",[103]="Feral",[104]="Guardian",[105]="Restoration",
  [1467]="Devastation",[1468]="Preservation",[1473]="Augmentation",
  [253]="Beast Mastery",[254]="Marksmanship",[255]="Survival",
  [62]="Arcane",[63]="Fire",[64]="Frost",
  [268]="Brewmaster",[269]="Windwalker",[270]="Mistweaver",
  [65]="Holy",[66]="Protection",[70]="Retribution",
  [256]="Discipline",[257]="Holy",[258]="Shadow",
  [259]="Assassination",[260]="Outlaw",[261]="Subtlety",
  [262]="Elemental",[263]="Enhancement",[264]="Restoration",
  [265]="Affliction",[266]="Demonology",[267]="Destruction",
  [71]="Arms",[72]="Fury",[73]="Protection",
}

-- per-arena cache (built from arena1..arena5, also from prep specs before opponents exist)
local arenaCache = {}      -- [arenaID] = {class, race, sex, power, spec, name, guid}
-- mapping from nameplate token -> arenaID
local plateToID = {}
local lastSpecShort = {}

local function safeVal(v)
  if v == nil then return nil end
  if type(issecretvalue) == "function" then
    local ok, secret = pcall(issecretvalue, v)
    if ok and secret then return nil end
  end
  return v
end

local function safeCall(func, ...)
  if type(func) ~= "function" then return nil end
  local ok, a, b, c, d = pcall(func, ...)
  if not ok then return nil end
  return a, b, c, d
end

local function isInArena()
  local _, instanceType = safeCall(IsInInstance)
  return safeVal(instanceType) == "arena"
end

local function isEnabled()
  return addonTable.Config.Get(addonTable.Config.Options.ARENA_NAMES_ENABLED) == true
end

local function shouldOverride()
  return isEnabled() and isInArena()
end

local function getFormat()
  return addonTable.Config.Get(addonTable.Config.Options.ARENA_NAMES_FORMAT) or "id_spec"
end

local function getSpecShort(specID)
  specID = safeVal(specID)
  if not specID or specID <= 0 then return nil end
  if SHORT_SPECS[specID] then return SHORT_SPECS[specID] end
  local _, specName = safeCall(GetSpecializationInfoByID, specID)
  specName = safeVal(specName)
  if specName then return specName:sub(1, 4) end
  return nil
end

local function readUnitProps(unit)
  local _, class = safeCall(UnitClass, unit)
  local _, race = safeCall(UnitRace, unit)
  return {
    class = safeVal(class),
    race = safeVal(race),
    sex = safeVal(safeCall(UnitSex, unit)),
    power = safeVal(safeCall(UnitPowerType, unit)),
  }
end

local function buildArenaCache()
  for arenaID = 1, 3 do
    local unit = "arena" .. arenaID
    local entry = arenaCache[arenaID] or {}
    arenaCache[arenaID] = entry

    -- spec from prep API (works before opponents exist)
    local specID = safeVal(safeCall(GetArenaOpponentSpec, arenaID))
    if specID and specID > 0 then
      entry.spec = specID
      lastSpecShort[arenaID] = getSpecShort(specID) or lastSpecShort[arenaID]
      -- get class from spec if not already known
      if not entry.class then
        local _, _, _, _, _, classFile = safeCall(GetSpecializationInfoByID, specID)
        if safeVal(classFile) then entry.class = classFile end
      end
    end

    -- if arena unit exists, fill in/refresh more identifying props
    if safeVal(safeCall(UnitExists, unit)) then
      local props = readUnitProps(unit)
      for k, v in pairs(props) do
        if v then entry[k] = v end
      end
      local n = safeVal(safeCall(UnitName, unit))
      if n then entry.name = n end
      local g = safeVal(safeCall(UnitGUID, unit))
      if g then entry.guid = g end
    end
  end
end

local function isEnemyPlayerPlate(token)
  if not safeVal(safeCall(UnitIsPlayer, token)) then return false end
  if not safeVal(safeCall(UnitIsEnemy, "player", token)) then return false end
  if safeVal(safeCall(UnitIsPossessed, token)) then return false end
  return true
end

local function propsScore(plateProps, arenaProps)
  -- 4-prop fingerprint: class, race, sex, power
  local matches, total = 0, 0
  for _, key in ipairs({"class", "race", "sex", "power"}) do
    if plateProps[key] ~= nil and arenaProps[key] ~= nil then
      total = total + 1
      if plateProps[key] == arenaProps[key] then
        matches = matches + 1
      else
        return nil  -- any mismatch on a comparable prop disqualifies
      end
    end
  end
  return matches, total
end

local function rebuildPlateMappings()
  if not isInArena() then
    wipe(plateToID)
    return
  end

  buildArenaCache()

  local plates = safeCall(C_NamePlate.GetNamePlates)
  if type(plates) ~= "table" then return end

  -- collect candidate enemy player tokens
  local candidates = {}
  for _, plate in ipairs(plates) do
    local token = plate.namePlateUnitToken
    if not token and type(plate.UnitFrame) == "table" then token = plate.UnitFrame.unit end
    if type(token) == "string" and token:match("^nameplate%d+$") then
      if isEnemyPlayerPlate(token) then
        table.insert(candidates, {token = token, props = readUnitProps(token), name = safeVal(safeCall(UnitName, token)), guid = safeVal(safeCall(UnitGUID, token))})
      end
    end
  end

  local newMap = {}

  -- Pass 1: GUID exact match
  for arenaID = 1, 3 do
    local entry = arenaCache[arenaID]
    if entry and entry.guid then
      for _, c in ipairs(candidates) do
        if c.guid == entry.guid then
          newMap[c.token] = arenaID
          break
        end
      end
    end
  end

  -- Pass 2: unique 4-prop match for unmapped
  local taken = {}
  for token, id in pairs(newMap) do taken[id] = true end

  for _, c in ipairs(candidates) do
    if not newMap[c.token] then
      local matches = {}
      for arenaID = 1, 3 do
        if not taken[arenaID] and arenaCache[arenaID] then
          local m, t = propsScore(c.props, arenaCache[arenaID])
          if m and t > 0 then table.insert(matches, {id = arenaID, m = m, t = t}) end
        end
      end
      -- only commit if there's exactly one viable match
      if #matches == 1 then
        newMap[c.token] = matches[1].id
        taken[matches[1].id] = true
      end
    end
  end

  -- Pass 3: name-based fallback for any leftovers
  for _, c in ipairs(candidates) do
    if not newMap[c.token] and c.name then
      for arenaID = 1, 3 do
        if not taken[arenaID] and arenaCache[arenaID] and arenaCache[arenaID].name == c.name then
          newMap[c.token] = arenaID
          taken[arenaID] = true
          break
        end
      end
    end
  end

  plateToID = newMap
end

local function buildDisplayText(arenaID)
  local format = getFormat()
  local idText = tostring(arenaID)
  local specShort = lastSpecShort[arenaID]
  if not specShort and arenaCache[arenaID] and arenaCache[arenaID].spec then
    specShort = getSpecShort(arenaCache[arenaID].spec)
    if specShort then lastSpecShort[arenaID] = specShort end
  end

  if format == "id_only" then
    return idText
  elseif format == "spec_only" then
    return specShort or idText
  else  -- id_spec
    if specShort then
      return specShort .. " " .. idText
    else
      return idText
    end
  end
end

local function applyOverrides()
  if not Platynator or not Platynator.API or not Platynator.API.SetUnitTextOverride then
    return
  end

  local plates = safeCall(C_NamePlate.GetNamePlates)
  if type(plates) ~= "table" then return end

  local override = shouldOverride()

  for _, plate in ipairs(plates) do
    local token = plate.namePlateUnitToken
    if not token and type(plate.UnitFrame) == "table" then token = plate.UnitFrame.unit end
    if type(token) == "string" and token:match("^nameplate%d+$") then
      local arenaID = override and plateToID[token] or nil
      if arenaID then
        Platynator.API.SetUnitTextOverride(token, buildDisplayText(arenaID), nil)
      else
        Platynator.API.SetUnitTextOverride(token, nil, nil)
      end
    end
  end
end

local refreshScheduled = false
local burstToken = 0

local function refreshNow()
  refreshScheduled = false
  rebuildPlateMappings()
  applyOverrides()
end

local function queueRefresh()
  if refreshScheduled then return end
  refreshScheduled = true
  C_Timer.After(0, refreshNow)
end

local burstDelays = {0, 0.05, 0.15, 0.4, 0.9, 1.5}
local function queueBurstRefresh()
  burstToken = burstToken + 1
  local thisToken = burstToken
  for _, d in ipairs(burstDelays) do
    C_Timer.After(d, function()
      if thisToken ~= burstToken then return end
      refreshNow()
    end)
  end
end

ArenaNames:RegisterEvent("PLAYER_ENTERING_WORLD")
ArenaNames:RegisterEvent("ZONE_CHANGED_NEW_AREA")
ArenaNames:RegisterEvent("ARENA_OPPONENT_UPDATE")
ArenaNames:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
ArenaNames:RegisterEvent("NAME_PLATE_UNIT_ADDED")
ArenaNames:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
ArenaNames:RegisterEvent("PLAYER_TARGET_CHANGED")
ArenaNames:RegisterEvent("PLAYER_FOCUS_CHANGED")
ArenaNames:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
ArenaNames:RegisterEvent("UNIT_NAME_UPDATE")

ArenaNames:SetScript("OnEvent", function(_, event, arg1)
  if event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA"
      or event == "ARENA_OPPONENT_UPDATE" or event == "ARENA_PREP_OPPONENT_SPECIALIZATIONS" then
    if isInArena() then
      queueBurstRefresh()
    else
      wipe(arenaCache)
      wipe(plateToID)
      wipe(lastSpecShort)
      queueRefresh()
    end
  elseif event == "NAME_PLATE_UNIT_REMOVED" and type(arg1) == "string" then
    plateToID[arg1] = nil
    queueRefresh()
  else
    queueRefresh()
  end
end)

-- Refresh whenever the user toggles the option in the dialog
addonTable.CallbackRegistry:RegisterCallback("ArenaNamesSettingChanged", function()
  queueRefresh()
end)
