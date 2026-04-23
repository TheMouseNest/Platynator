---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.CallbackRegistry = CreateFromMixins(CallbackRegistryMixin)
addonTable.CallbackRegistry:OnLoad()
addonTable.CallbackRegistry:GenerateCallbackEvents(addonTable.Constants.Events)

local hidden = CreateFrame("Frame")
hidden:Hide()
addonTable.hiddenFrame = hidden

local offscreen = CreateFrame("Frame")
offscreen:SetPoint("TOPLEFT", UIParent, "TOPRIGHT")
addonTable.offscreenFrame = hidden

local function SetStyle(isInit)
  local mapping = addonTable.Config.Get(addonTable.Config.Options.DESIGNS_ASSIGNED)

  local styleName = addonTable.Config.Get(addonTable.Config.Options.STYLE)
  if not isInit then
    local found = false
    for _, value in pairs(mapping) do
      if value == styleName then
        found = true
      end
    end
    if not found then
      mapping["enemy"] = styleName
    end
  end
  if styleName:match("^_") then
    local designs = addonTable.Config.Get(addonTable.Config.Options.DESIGNS)
    designs[addonTable.Constants.CustomName] = CopyTable(addonTable.Core.GetDesignByName(styleName))
  end
  addonTable.CallbackRegistry:TriggerEvent("RefreshStateChange", {[addonTable.Constants.RefreshReason.Design] = true})
end

local function UpdateRect(design)
  local function GetRect(asset, scale, anchor)
    local width = asset.width * scale
    local height = asset.height * scale
    local left, bottom
    if anchor[1] == "BOTTOMLEFT" then
      left = anchor[2] or 0
      bottom = anchor[3] or 0
    elseif anchor[1] == "BOTTOM" then
      left = anchor[2] and anchor[2] - width/2 or -width/2
      bottom = anchor[3] or 0
    elseif anchor[1] == "BOTTOMRIGHT" then
      left = anchor[2] and anchor[2] - width or -width
      bottom = anchor[3] or 0
    elseif anchor[1] == "TOPLEFT" then
      left = anchor[2] or 0
      bottom = anchor[3] and anchor[3] - height or -height
    elseif anchor[1] == "TOP" then
      left = anchor[2] and anchor[2] - width/2 or -width/2
      bottom = anchor[3] and anchor[3] - height or -height
    elseif anchor[1] == "TOPRIGHT" then
      left = anchor[2] and anchor[2] - width or -width
      bottom = anchor[3] and anchor[3] - height or -height
    elseif anchor[1] == "LEFT" then
      left = anchor[2] or 0
      bottom = anchor[3] and anchor[3] - height/2 or -height/2
    elseif anchor[1] == "RIGHT" then
      left = anchor[2] and anchor[2] - width or -width
      bottom = anchor[3] and anchor[3] - height/2 or -height/2
    else
      left = -width / 2
      bottom = -height / 2
    end
    return {left = left, bottom = bottom, width = width, height = height}
  end

  local left, right, top, bottom = 0, 0, 0, 0

  local function CacheSize(rect)
    left = math.min(left, rect.left)
    bottom = math.min(bottom, rect.bottom)
    top = math.max(rect.bottom + rect.height, top)
    right = math.max(rect.left + rect.width, right)
  end

  for index, barDetails in ipairs(design.bars) do
    if barDetails.kind == "health" then
      local width, height = barDetails.border.width * addonTable.Assets.BarBordersSize.width, barDetails.border.height * addonTable.Assets.BarBordersSize.height
      local rect = GetRect({width = width, height = height}, barDetails.scale, barDetails.anchor)
      CacheSize(rect)
    end
  end

  addonTable.Rect = {left = left * design.scale, bottom = bottom * design.scale, width = (right ~= left and right - left or 125) * design.scale, height = (top ~= bottom and top - bottom or 10) * design.scale}

  for _, textDetails in ipairs(design.texts) do
    if textDetails.kind == "creatureName" then
      local rect = GetRect({width = textDetails.maxWidth * addonTable.Assets.BarBordersSize.width, height = 10 * textDetails.scale}, 1, textDetails.anchor)
      CacheSize(rect)
    end
  end

  addonTable.StackRect = {left = left * design.scale, bottom = bottom * design.scale, width = (right ~= left and right - left or 125) * design.scale, height = (top ~= bottom and top - bottom or 10) * design.scale}
end

function addonTable.Core.GetDesignByName(name)
  if addonTable.Design.Defaults[name] then
    if not addonTable.Design.ParsedDefaults[name] then
      local design = C_EncodingUtil.DeserializeJSON(addonTable.Design.Defaults[name])
      design.kind = nil
      design.addon = nil
      addonTable.Core.UpgradeDesign(design)
      addonTable.Design.ParsedDefaults[name] = design
    end
    return addonTable.Design.ParsedDefaults[name]
  else
    return addonTable.Config.Get(addonTable.Config.Options.DESIGNS)[name]
  end
end

function addonTable.Core.GetDesignScale(isSimplified)
  if isSimplified then
    return addonTable.Config.Get(addonTable.Config.Options.SIMPLIFIED_SCALE)
  else
    return 1
  end
end

function addonTable.Core.Initialize()
  addonTable.Config.InitializeData()
  addonTable.SlashCmd.Initialize()

  addonTable.Assets.ApplyScale()

  addonTable.Core.MigrateSettings()

  SetStyle(true)
  addonTable.CallbackRegistry:RegisterCallback("SettingChanged", function(_, name)
    if name == addonTable.Config.Options.STYLE then
      SetStyle()
    end
  end)
  UpdateRect(addonTable.Core.GetDesignByName(addonTable.Display.DesignForContextMixin:GetDefaultEnemyNPCDesign()))
  addonTable.CallbackRegistry:RegisterCallback("RefreshStateChange", function(_, state)
    if state[addonTable.Constants.RefreshReason.Design] then
      UpdateRect(addonTable.Core.GetDesignByName(addonTable.Display.DesignForContextMixin:GetDefaultEnemyNPCDesign()))
    end
  end)

  addonTable.CustomiseDialog.Initialize()

  addonTable.Display.Initialize()
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(_, eventName, data)
  if eventName == "ADDON_LOADED" and data == "Platynator" then
    addonTable.Core.Initialize()
  end
end)
