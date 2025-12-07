---@class addonTablePlatynator
local addonTable = select(2, ...)
addonTable.Config = {}

local settings = {
  STYLE = {key = "style", default = "_hare"},
  CURRENT_SKIN = {key = "current_skin", default = "blizzard", refresh = {addonTable.Constants.RefreshReason.Skin}},

  GLOBAL_SCALE = {key = "global_scale", default = 1, refresh = {addonTable.Constants.RefreshReason.Scale}},

  LEGACY_DESIGN = {key = "design_all", default = {}},

  DESIGNS = {key = "designs", default = {}, refresh = {addonTable.Constants.RefreshReason.Design}},
  DESIGNS_ASSIGNED = {key = "designs_assigned", default = {["friend"] = "_name-only", ["enemy"] = "_hare"}},

  TARGET_BEHAVIOUR = {key = "target_behaviour", default = "enlarge", refresh = {addonTable.Constants.RefreshReason.TargetBehaviour}},
  NOT_TARGET_BEHAVIOUR = {key = "not_target_behaviour", default = "none", refresh = {addonTable.Constants.RefreshReason.TargetBehaviour}},

  STACKING_NAMEPLATES = {key = "stacking_nameplates", default = true, refresh = {addonTable.Constants.RefreshReason.StackingBehaviour}},
  CLOSER_TO_SCREEN_EDGES = {key = "closer_to_screen_edges", default = true, refresh = {addonTable.Constants.RefreshReason.StackingBehaviour}},
  CLICK_REGION_SCALE_X = {key = "click_region_scale_x", default = 1},
  CLICK_REGION_SCALE_Y = {key = "click_region_scale_y", default = 1},

  STACK_REGION_SCALE_X = {key = "stack_region_scale_x", default = 1.2, refresh = {addonTable.Constants.RefreshReason.StackingBehaviour}},
  STACK_REGION_SCALE_Y = {key = "stack_region_scale_y", default = 1.1, refresh = {addonTable.Constants.RefreshReason.StackingBehaviour}},

  SHOW_NAMEPLATES = {key = "show_nameplates", default = {npc = true, player = true, enemy = true}, refresh = {addonTable.Constants.RefreshReason.ShowBehaviour}},
  STACK_APPLIES_TO = {key = "stack_applies_to", default = {normal = true, minion = false, minor = false}},
  SHOW_FRIENDLY_IN_INSTANCES = {key = "show_friendly_in_instances", default = true, refresh = {addonTable.Constants.RefreshReason.ShowBehaviour}},
}

addonTable.Config.RefreshType = {}

addonTable.Config.Options = {}
addonTable.Config.Defaults = {}

for key, details in pairs(settings) do
  if details.refresh then
    local refreshType = {}
    for _, r in ipairs(details.refresh) do
      refreshType[r] = true
    end
    addonTable.Config.RefreshType[details.key] = refreshType
  end
  addonTable.Config.Options[key] = details.key
  addonTable.Config.Defaults[details.key] = details.default
end

function addonTable.Config.IsValidOption(name)
  for _, option in pairs(addonTable.Config.Options) do
    if option == name then
      return true
    end
  end
  return false
end

local function RawSet(name, value)
  local tree = {strsplit(".", name)}
  if addonTable.Config.CurrentProfile == nil then
    error("PLATYNATOR_CONFIG not initialized")
  elseif not addonTable.Config.IsValidOption(tree[1]) then
    error("Invalid option '" .. name .. "'")
  elseif #tree == 1 then
    local oldValue = addonTable.Config.CurrentProfile[name]
    addonTable.Config.CurrentProfile[name] = value
    if value ~= oldValue then
      return true
    end
  else
    local root = addonTable.Config.CurrentProfile
    for i = 1, #tree - 1 do
      root = root[tree[i]]
      if type(root) ~= "table" then
        error("Invalid option '" .. name .. "', broke at [" .. i .. "]")
      end
    end
    local tail = tree[#tree]
    if root[tail] == nil then
      error("Invalid option '" .. name .. "', broke at [tail]")
    end
    local oldValue = root[tail]
    root[tail] = value
    if value ~= oldValue then
      return true
    end
  end
  return false
end

function addonTable.Config.Set(name, value)
  if RawSet(name, value) then
    addonTable.CallbackRegistry:TriggerEvent("SettingChanged", name)
    if addonTable.Config.RefreshType[name] then
      addonTable.CallbackRegistry:TriggerEvent("RefreshStateChange", addonTable.Config.RefreshType[name])
    end
  end
end

-- Set multiple settings at once and after all are set fire the setting changed
-- events
function addonTable.Config.MultiSet(nameValueMap)
  local changed = {}
  for name, value in pairs(nameValueMap) do
    if RawSet(name, value) then
      table.insert(changed, name)
    end
  end

  local refreshState = {}
  for _, name in ipairs(changed) do
    addonTable.CallbackRegistry:TriggerEvent("SettingChanged", name)
    if addonTable.Config.RefreshType[name] then
      refreshState = Mixin(refreshState, addonTable.Config.RefreshType[name])
    end
  end
  if next(refreshState) ~= nil then
    addonTable.CallbackRegistry:TriggerEvent("RefreshStateChange", refreshState)
  end
end

local addedInstalledNestedToList = {}
local installedNested = {}

function addonTable.Config.Install(name, defaultValue)
  if PLATYNATOR_CONFIG == nil then
    error("PLATYNATOR_CONFIG not initialized")
  elseif name:find("%.") == nil then
    if addonTable.Config.CurrentProfile[name] == nil then
      addonTable.Config.CurrentProfile[name] = defaultValue
    end
  else
    if not addedInstalledNestedToList[name] then
      addedInstalledNestedToList[name] = true
      table.insert(installedNested, name)
    end
    local tree = {strsplit(".", name)}
    local root = addonTable.Config.CurrentProfile
    for i = 1, #tree - 1 do
      if not root[tree[i]] then
        root[tree[i]] = {}
      end
      root = root[tree[i]]
    end
    if root[tree[#tree]] == nil then
      root[tree[#tree]] = defaultValue
    end
  end
end

function addonTable.Config.ResetOne(name)
  local newValue = addonTable.Config.Defaults[name]
  if newValue == nil then
    error("Can't reset that", name)
  else
    if type(newValue) == "table" then
      newValue = CopyTable(newValue)
    end
    addonTable.Config.Set(name, newValue)
  end
end

function addonTable.Config.Reset()
  PLATYNATOR_CONFIG = {
    Profiles = {
      DEFAULT = {},
    },
    CharacterSpecific = {},
    Version = 1,
  }
  addonTable.Config.InitializeData()
end

local function ImportDefaultsToProfile()
  for option, value in pairs(addonTable.Config.Defaults) do
    if addonTable.Config.CurrentProfile[option] == nil then
      if type(value) == "table" then
        addonTable.Config.CurrentProfile[option] = CopyTable(value)
      else
        addonTable.Config.CurrentProfile[option] = value
      end
    end
  end
end

function addonTable.Config.InitializeData()
  if PLATYNATOR_CONFIG == nil then
    addonTable.Config.Reset()
    return
  end

  if PLATYNATOR_CONFIG.Profiles == nil then
    PLATYNATOR_CONFIG = {
      Profiles = {
        DEFAULT = PLATYNATOR_CONFIG,
      },
      CharacterSpecific = {},
      Version = 1,
    }
  end

  if PLATYNATOR_CONFIG.Profiles.DEFAULT == nil then
    PLATYNATOR_CONFIG.Profiles.DEFAULT = {}
  end
  if PLATYNATOR_CONFIG.Profiles[PLATYNATOR_CURRENT_PROFILE] == nil then
    PLATYNATOR_CURRENT_PROFILE = "DEFAULT"
  end

  addonTable.Config.CurrentProfile = PLATYNATOR_CONFIG.Profiles[PLATYNATOR_CURRENT_PROFILE]
  ImportDefaultsToProfile()
end

function addonTable.Config.GetProfileNames()
  return GetKeysArray(PLATYNATOR_CONFIG.Profiles)
end

function addonTable.Config.MakeProfile(newProfileName, clone)
  assert(tIndexOf(addonTable.Config.GetProfileNames(), newProfileName) == nil, "Existing Profile")
  if clone then
    PLATYNATOR_CONFIG.Profiles[newProfileName] = CopyTable(addonTable.Config.CurrentProfile)
  else
    PLATYNATOR_CONFIG.Profiles[newProfileName] = {}
  end
  addonTable.Config.ChangeProfile(newProfileName)
end

function addonTable.Config.DeleteProfile(profileName)
  assert(profileName ~= "DEFAULT" and profileName ~= PLATYNATOR_CURRENT_PROFILE)

  PLATYNATOR_CONFIG.Profiles[profileName] = nil
end

function addonTable.Config.DumpCurrentProfile()
  return CopyTable(PLATYNATOR_CONFIG.Profiles[PLATYNATOR_CURRENT_PROFILE])
end

function addonTable.Config.ChangeProfile(newProfileName)
  assert(tIndexOf(addonTable.Config.GetProfileNames(), newProfileName) ~= nil, "Invalid Profile")

  local changedOptions = {}
  local refreshState = {}
  local newProfile = PLATYNATOR_CONFIG.Profiles[newProfileName]

  for name, value in pairs(addonTable.Config.CurrentProfile) do
    if value ~= newProfile[name] then
      table.insert(changedOptions, name)
      Mixin(refreshState, addonTable.Config.RefreshType[name] or {})
    end
  end

  tAppendAll(changedOptions, installedNested)

  addonTable.Config.CurrentProfile = newProfile
  PLATYNATOR_CURRENT_PROFILE = newProfileName

  ImportDefaultsToProfile()

  addonTable.Core.MigrateSettings()

  for _, name in ipairs(changedOptions) do
    addonTable.CallbackRegistry:TriggerEvent("SettingChanged", name)
  end
  addonTable.CallbackRegistry:TriggerEvent("RefreshStateChange", refreshState)
end

-- characterName is optional, only use if need a character specific setting for
-- a character other than the current one.
function addonTable.Config.Get(name)
  -- This is ONLY if a config is asked for before variables are loaded
  if addonTable.Config.CurrentProfile == nil then
    return addonTable.Config.Defaults[name]
  elseif name:find("%.") == nil then
    return addonTable.Config.CurrentProfile[name]
  else
    local tree = {strsplit(".", name)}
    local root = addonTable.Config.CurrentProfile
    for i = 1, #tree do
      root = root[tree[i]]
      if root == nil then
        break
      end
    end
    return root
  end
end
