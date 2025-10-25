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

function addonTable.Core.UpgradeDesign(design)
  design.appliesToAll = nil

  for _, text in ipairs(design.texts) do
    if not text.color then
      text.color = {r = 1, g = 1, b = 1}
    end
    if not text.align then
      text.align = "CENTER"
    end
    if text.truncate == nil then
      text.truncate = "NONE"
    end
  end
  for _, marker in ipairs(design.markers) do
    if not marker.color then
      marker.color = {r = 1, g = 1, b = 1}
    end
  end
  if not design.auras then
    design.auras = {
      {
        kind = "debuffs",
        anchor = {"BOTTOMLEFT", -63, 25},
        scale = 1,
        showCountdown = true,
        direction = "RIGHT",
      },
      {
        kind = "buffs",
        anchor = {"RIGHT", -68, 0},
        scale = 1,
        showCountdown = true,
        direction = "LEFT",
      },
      {
        kind = "crowdControl",
        anchor = {"LEFT", 68, 0},
        scale = 1,
        showCountdown = true,
        direction = "RIGHT",
      },
    }
  else
    for _, aura in ipairs(design.auras) do
      if not aura.scale then
        aura.scale = 1
      end
      if aura.showCountdown == nil then
        aura.showCountdown = true
      end
      if aura.direction == nil then
        if aura.anchor[1] and aura.anchor[1]:match("RIGHT") then
          aura.direction = "LEFT"
        else
          aura.direction = "RIGHT"
        end
      end
    end
  end

  for _, bar in ipairs(design.bars) do
    if bar.kind == "health" and bar.aggroColoursOnHostiles == nil then
      bar.aggroColoursOnHostiles = true
    end
    if bar.kind == "health" and (bar.colors.threat.offtank == nil or bar.colors.npc.tapped == nil) then
      local newColor = CreateColorFromRGBHexString("0FAAC8")
      bar.colors.threat.offtank = {r = newColor.r, g = newColor.g, b = newColor.b}
      newColor = CreateColorFromRGBHexString("6E6E6E")
      bar.colors.npc.tapped = {r = newColor.r, g = newColor.g, b = newColor.b}
    end
    if bar.kind == "cast" and bar.colors.interrupted == nil then
      local newColor = CreateColorFromRGBHexString("FC36E0")
      bar.colors.interrupted = {r = newColor.r, g = newColor.g, b = newColor.b}
    end
  end

  if design.font.shadow == nil or design.font.flags ~= nil then
    design.font.shadow = true
    design.font.outline = design.font.flags == "OUTLINE"
    design.font.flags = nil
  end
end

function addonTable.Core.MigrateSettings()
  local legacyDesign = addonTable.Config.Get(addonTable.Config.Options.LEGACY_DESIGN)

  if legacyDesign.appliesToAll then
    local mapping = addonTable.Config.Get(addonTable.Config.Options.DESIGNS_ASSIGNED)
    local styleName = addonTable.Config.Get(addonTable.Config.Options.STYLE)
    if styleName == "custom" then
      mapping["friend"] = "_custom"
      mapping["enemy"] = "_custom"
      addonTable.Config.Get(addonTable.Config.Options.DESIGNS)["_custom"] = legacyDesign
    else
      mapping["friend"] = "_" .. styleName
      mapping["enemy"] = "_" .. styleName
    end
    addonTable.Config.Set(addonTable.Config.Options.LEGACY_DESIGN, {})
  end

  for _, design in ipairs(addonTable.Config.Get(addonTable.Config.Options.DESIGNS)) do
    addonTable.Core.UpgradeDesign(design)
  end
end

local function SetStyle()
  local mapping = addonTable.Config.Get(addonTable.Config.Options.DESIGNS_ASSIGNED)

  local styleName = addonTable.Config.Get(addonTable.Config.Options.STYLE)
  if mapping["friend"] == mapping["enemy"] and styleName ~= "_custom" and styleName:match("^_") then
    local designs = addonTable.Config.Get(addonTable.Config.Options.DESIGNS)
    designs["_custom"] = CopyTable(addonTable.Core.GetDesign("enemy"))
    mapping["friend"] = styleName
    mapping["enemy"] = styleName
    addonTable.CallbackRegistry:TriggerEvent("RefreshStateChange", {[addonTable.Constants.RefreshReason.Design] = true})
  elseif styleName ~= "_custom" and styleName:match("^_") then
    local designs = addonTable.Config.Get(addonTable.Config.Options.DESIGNS)
    designs["_custom"] = CopyTable(addonTable.Core.GetDesign("enemy"))
    addonTable.CallbackRegistry:TriggerEvent("RefreshStateChange", {[addonTable.Constants.RefreshReason.Design] = true})
  end
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
      left = anchor[2] and anchor[2] - width / 2 or -width / 2
      bottom = anchor[3] or 0
    elseif anchor[1] == "BOTTOMRIGHT" then
      left = anchor[2] and anchor[2] - width or -width
      bottom = anchor[3] or 0
    elseif anchor[1] == "TOPLEFT" then
      left = anchor[2] or 0
      bottom = anchor[3] and anchor[3] - height
    elseif anchor[1] == "TOP" then
      left = anchor[2] and anchor[2] - width / 2 or -width / 2
      bottom = anchor[3] and anchor[3] - height
    elseif anchor[1] == "TOPRIGHT" then
      left = anchor[2] and anchor[2] - width or -width
      bottom = anchor[3] and anchor[3] - height
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
    local foregroundDetails = addonTable.Assets.BarBackgrounds[barDetails.foreground.asset]
    local borderDetails = addonTable.Assets.BarBorders[barDetails.border.asset]
    local asset = foregroundDetails
    if borderDetails.mode and borderDetails.mode ~= foregroundDetails.mode then
      asset = {width = math.min(borderDetails.width, foregroundDetails.width), height = math.min(borderDetails.height, foregroundDetails.height)}
    end
    local rect = GetRect(asset, barDetails.scale, barDetails.anchor)
    CacheSize(rect)
  end

  for index, textDetails in ipairs(design.texts) do
    local rect = GetRect({width = textDetails.widthLimit or 20, height = 10}, textDetails.scale, textDetails.anchor)
    CacheSize(rect)
  end

  for index, specialDetails in ipairs(design.specialBars) do
    if specialDetails.kind == "power" then
      local rect = GetRect(addonTable.Assets.PowerBars[specialDetails.blank], specialDetails.scale, specialDetails.anchor)
      CacheSize(rect)
    end
  end

  addonTable.Rect = {left = left, bottom = bottom, width = right - left, height = top - bottom}
end

function addonTable.Core.GetDesign(kind)
  local name = addonTable.Config.Get(addonTable.Config.Options.DESIGNS_ASSIGNED)[kind]
  if addonTable.Design.Defaults[name] then
    if not addonTable.Design.ParsedDefaults[name] then
      local design = C_EncodingUtil.DeserializeJSON(addonTable.Design.Defaults[name])
      addonTable.Core.UpgradeDesign(design)
      addonTable.Design.ParsedDefaults[name] = design
    end
    return addonTable.Design.ParsedDefaults[name]
  else
    return addonTable.Config.Get(addonTable.Config.Options.DESIGNS)[name]
  end
end

function addonTable.Core.Initialize()
  addonTable.Config.InitializeData()
  addonTable.SlashCmd.Initialize()

  --if next(addonTable.Config.Get(addonTable.Config.Options.DESIGN)) == nil then
  --  addonTable.Config.Set(addonTable.Config.Options.DESIGN, addonTable.Design.GetDefaultDesignSlight())
  --end

  addonTable.Assets.ApplyScale()

  addonTable.Core.MigrateSettings()

  SetStyle()
  addonTable.CallbackRegistry:RegisterCallback("SettingChanged", function(_, name)
    if name == addonTable.Config.Options.STYLE then
      SetStyle()
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
