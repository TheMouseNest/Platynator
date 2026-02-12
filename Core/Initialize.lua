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

local function GetColor(rgb)
  local color = CreateColorFromRGBHexString(rgb)
  return {r = color.r, g = color.g, b = color.b}
end

local truncateMap = {
  ["NONE"] = "NONE",
  ["LEFT"] = "LAST",
  ["RIGHT"] = "FIRST",
}

function addonTable.Core.UpgradeDesign(design)
  design.appliesToAll = nil
  design.addon = nil
  design.kind = nil

  if design.scale == nil then
    design.scale = 1
  end

  for _, text in ipairs(design.texts) do
    if not text.color then
      text.color = {r = 1, g = 1, b = 1}
    end
    if not text.align then
      text.align = "CENTER"
    end
    if type(text.truncate) == "string" then
      text.shorten = truncateMap[text.truncate]
      text.truncate = false
    end
    if text.truncate == nil then
      text.truncate = false
    end
    if text.layer == nil then
      text.layer = 2
    end
    if text.maxWidth == nil then
      text.maxWidth = math.floor((text.widthLimit or 0) / addonTable.Assets.BarBordersSize.width * 100) / 100
      text.widthLimit = nil
    end
  end
  for _, marker in ipairs(design.markers) do
    if not marker.color then
      marker.color = {r = 1, g = 1, b = 1}
    end
    if marker.layer == nil then
      marker.layer = 3
    end
    if marker.kind == "castIcon" and marker.square == nil then
      marker.square = false
    end
    if marker.kind == "elite" and marker.openWorldOnly == nil then
      marker.openWorldOnly = false
    end
    if marker.kind == "rare" and marker.includeElites == nil then
      marker.includeElites = false
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
  end
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
    if not aura.height then
      aura.height = 1
    end
    if not aura.textScale then
      aura.textScale = 1
    end
    if aura.kind == "debuffs" and not aura.filters then
      aura.showPandemic = true
      aura.filters = {
        important = true,
        fromYou = true,
      }
    end
    if aura.kind == "buffs" and not aura.filters then
      aura.filters = {
        dispelable = false,
        important = true,
      }
    end
    if aura.kind == "buffs" and aura.showDispel == nil then
      aura.showDispel = {enrage = true}
    elseif aura.kind ~= "buffs" then
      aura.showDispel = {}
    end
    if aura.kind == "crowdControl" and not aura.filters then
      aura.filters = {
        fromYou = false,
      }
    end
    if not aura.sorting then
      aura.sorting = {
        kind = "duration",
        reversed = false,
      }
    end
    if aura.kind == "debuffs" and aura.showPandemic == nil then
      aura.showPandemic = true
    end
  end

  local function UpdateAutoColors(autoColors)
    local index = 1
    while index <= #autoColors do
      local ac = autoColors[index]
      if ac.kind == "eliteType" and ac.colors.trivial == nil then
        ac.colors.trivial = GetColor("b28e55")
      elseif ac.kind == "threat" and ac.useSafeColor == nil then
        ac.useSafeColor = true
      elseif ac.kind == "quest" and ac.colors.hostile == nil then
        ac.colors.hostile = ac.colors.quest
        ac.colors.neutral = ac.colors.quest
        ac.colors.friendly = ac.colors.quest
        ac.colors.quest = nil
      elseif ac.kind == "classColors" and ac.colors == nil then
        ac.colors = {}
      elseif ac.kind == "cast" and ac.colors.uninterruptable then
        local new = CopyTable(addonTable.CustomiseDialog.ColorsConfig["uninterruptableCast"].default)
        new.colors.uninterruptable = ac.colors.uninterruptable
        table.insert(autoColors, index, new)
        ac.colors.uninterruptable = nil
        index = index - 1
      elseif ac.kind == "interruptReady" and ac.notReady then
        ac.notReady = nil
      end

      index = index + 1
    end
  end

  local function RemoveAutoColorsAlpha(autoColors)
    for _, ac in ipairs(autoColors) do
      for _, color in pairs(ac.colors) do
        color.a = nil
      end
    end
  end

  for _, bar in ipairs(design.bars) do
    if bar.kind == "health" and not bar.absorb then
      local mode = bar.border.height and bar.border.height * 100 or addonTable.Assets.BarBordersLegacy[bar.border.asset].mode
      local isNarrow = mode < 75
      bar.absorb = {asset = isNarrow and "narrow/blizzard-absorb" or "wide/blizzard-absorb", color = {r = 1, g = 1, b = 1}}
    end
    if bar.kind == "health" and not bar.absorb.color then
      bar.absorb.color = GetColor("FFFFFF")
    end
    if bar.kind == "health" and bar.animate == nil then
      bar.animate = false
    end
    if bar.layer == nil then
      bar.layer = 1
    end
    if bar and bar.absorb and bar.absorb.color.a == nil then
      bar.absorb.color.a = 1
    end
    if bar.border.color.a == nil then
      bar.border.color.a = 1
    end
    if bar.border.asset:match("/blizzard%-cast%-bar$") then
      local map = {
        ["200/blizzard-cast-bar"] = "200/blizzard-cast-bar-white",
        ["175/blizzard-cast-bar"] = "175/blizzard-cast-bar-white",
        ["150/blizzard-cast-bar"] = "150/blizzard-cast-bar-white",
        ["125/blizzard-cast-bar"] = "125/blizzard-cast-bar-white",
        ["100/blizzard-cast-bar"] = "100/blizzard-cast-bar-white",
        ["75/blizzard-cast-bar"] = "75/blizzard-cast-bar-white",
        ["special/blizzard-cast-bar"] = "50/blizzard-cast-bar-white",
      }
      if bar.border.color.r == 1 and bar.border.color.g == 1 and bar.border.color.b == 1 and bar.border.color.a == 1 then
        bar.border.color = GetColor("fffb52")
        bar.border.color.a = 0.5
      end
      bar.border.asset = map[bar.border.asset]
    end
    if bar.kind == "health" and not bar.autoColors then
      local classColors = CopyTable(addonTable.CustomiseDialog.ColorsConfig["classColors"].default)
      local tapped = CopyTable(addonTable.CustomiseDialog.ColorsConfig["tapped"].default)
      if bar.colors and bar.colors.tapped then
        tapped.colors.tapped = bar.colors.tapped
      end
      local threat = CopyTable(addonTable.CustomiseDialog.ColorsConfig["threat"].default)
      Mixin(threat.colors, bar.colors and bar.colors.threat or {})
      local reaction = CopyTable(addonTable.CustomiseDialog.ColorsConfig["reaction"].default)
      Mixin(reaction.colors, bar.colors and bar.colors.npc or {})
      reaction.colors.tapped = nil

      threat.combatOnly = not bar.aggroColoursOnHostiles
      bar.aggroColoursOnHostiles = nil

      bar.autoColors = {
        classColors,
        tapped,
        threat,
        reaction
      }
      bar.colors = nil
    end
    if not bar.background.color then
      bar.background.color = GetColor("FFFFFF")
      bar.background.color.a = bar.background.alpha or 1
      bar.background.alpha = nil
    end
    if bar.kind == "cast" and bar.colors and bar.colors.normalChannel == nil then
      bar.colors.normalChannel = GetColor("3ec637")
    end
    if bar.kind == "cast" and bar.colors and bar.colors.normalCast == nil then
      bar.colors.importantCast = GetColor("ff1827")
      bar.colors.importantChannel = GetColor("0a43ff")
      bar.colors.normalCast = bar.colors.normal
      bar.colors.normal = nil
    end
    if bar.kind == "cast" and not bar.autoColors then
      local cast = {
        kind = "cast",
        colors = {
          cast = bar.colors.normalCast,
          channel = bar.colors.normalChannel,
          uninterruptable = bar.colors.uninterruptable,
          interrupted = bar.colors.interrupted,
        },
      }
      local important = {
        kind = "importantCast",
        colors = {
          cast = bar.colors.importantCast,
          channel = bar.colors.importantChannel,
        },
      }
      bar.autoColors = {
        important,
        cast,
      }
      bar.colors = nil
    end
    if addonTable.Assets.BarBordersSlicedLegacy[bar.border.asset] then
      bar.border.asset = addonTable.Assets.BarBordersSlicedLegacy[bar.border.asset]
    elseif not addonTable.Assets.BarBordersSliced[bar.border.asset] and addonTable.Assets.BarBordersLegacy[bar.border.asset] then
      local size = addonTable.Assets.BarBordersLegacy[bar.border.asset].mode
      bar.border.asset = addonTable.Assets.BarBordersLegacy[bar.border.asset].tag
      bar.border.width = 1
      bar.border.height = size ~= 50 and size/100 or 3.8/7.5

      if bar.border.asset == "blizzard-classic-level" then
        bar.border.asset = "blizzard-classic"
        table.insert(design.highlights, {
          kind = "fixed",
          asset = "100/classic-level",
          layer = bar.layer + 1,
          scale = bar.scale,
          color = CopyTable(bar.border.color),
          anchor = {"RIGHT", 84 * bar.scale, 0}
        })
      end

      if addonTable.Assets.BarBordersSlicedLegacy[bar.border.asset] then
        bar.border.asset = addonTable.Assets.BarBordersSlicedLegacy[bar.border.asset]
      end
    end
    if bar.kind == "cast" and bar.interruptMarker == nil then
      bar.interruptMarker = {asset = "none"}
    end
    if bar.kind == "cast" and bar.interruptMarker.color == nil then
      bar.interruptMarker.color = GetColor("FFFFFF")
    end
    if bar.autoColors then
      UpdateAutoColors(bar.autoColors)
      RemoveAutoColorsAlpha(bar.autoColors)
    end
    if addonTable.Assets.BarBackgroundsLegacyMap[bar.background.asset] then
      bar.background.asset = addonTable.Assets.BarBackgroundsLegacyMap[bar.background.asset]
    end
    if addonTable.Assets.BarBackgroundsLegacyMap[bar.foreground.asset] then
      bar.foreground.asset = addonTable.Assets.BarBackgroundsLegacyMap[bar.foreground.asset]
    end
    if bar.kind == "health" and addonTable.Assets.BarBackgroundsLegacyMap[bar.absorb.asset] then
      bar.absorb.asset = addonTable.Assets.BarBackgroundsLegacyMap[bar.absorb.asset]
    end
  end

  for _, text in ipairs(design.texts) do
    if text.kind == "layer" then
      text.kind = "level"
    end
    if text.kind == "target" and text.applyClassColors == nil then
      text.applyClassColors = false
    end
    if (text.kind == "creatureName" or text.kind == "guild") and text.showWhenWowDoes == nil then
      text.showWhenWowDoes = false
    end
    if text.shorten ~= nil then
      text.shorten = nil
      text.truncate = text.truncate or text.shorten and true or false
    end
    if text.kind == "creatureName" and not text.autoColors then
      if text.applyClassColors then
        local classColors = CopyTable(addonTable.CustomiseDialog.ColorsConfig["classColors"].default)
        local tapped = CopyTable(addonTable.CustomiseDialog.ColorsConfig["tapped"].default)
        if text.colors and text.colors.tapped then
          tapped.colors.tapped = text.colors.tapped
        end
        local reaction = CopyTable(addonTable.CustomiseDialog.ColorsConfig["reaction"].default)
        Mixin(reaction.colors, text.colors and text.colors.npc or {})
        reaction.colors.tapped = nil
        text.autoColors = {classColors, tapped, reaction}
      else
        text.autoColors = {}
      end
      text.applyClassColors = nil
      text.colors = nil
    end
    if text.kind == "level" and not text.autoColors then
      if text.applyDifficultyColors then
        local difficulty = CopyTable(addonTable.CustomiseDialog.ColorsConfig["difficulty"].default)
        Mixin(difficulty.colors, text.colors and text.colors.difficulty or {})
        text.autoColors = {
          difficulty,
        }
      else
        text.autoColors = {}
      end
      text.applyDifficultyColors = nil
      text.colors = nil
    end
    if text.kind == "health" and text.significantFigures == nil then
      text.significantFigures = 0
    end
    if text.kind == "guild" and text.npcRole == nil then
      text.playerGuild = true
      text.npcRole = true
    end
    if text.autoColors then
      UpdateAutoColors(text.autoColors)
      RemoveAutoColorsAlpha(text.autoColors)
    end
  end

  for _, highlight in ipairs(design.highlights) do
    if highlight.layer == nil then
      highlight.layer = 0
    end
    if highlight.color.a == nil then
      highlight.color.a = 1
    end

    if highlight.kind == "mouseover" and highlight.includeTarget == nil then
      highlight.includeTarget = true
    end

    if addonTable.Assets.HighlightsLegacy[highlight.asset] then
      local old = addonTable.Assets.HighlightsLegacy[highlight.asset]
      highlight.asset = addonTable.Assets.HighlightsLegacy[highlight.asset].tag
      local new = addonTable.Assets.HighlightsLegacy2[highlight.asset]

      if new.mode == addonTable.Assets.RenderMode.Sliced then
        local baseWidth, baseHeight = 125, 15.625
        highlight.width = old.width / baseWidth
        highlight.height = old.height / baseHeight
      elseif new.mode == addonTable.Assets.RenderMode.Stretch then
        highlight.width = old.width / new.width
        highlight.height = old.height / new.height
      else
        highlight.width = 1
        highlight.height = 1
      end
    end

    if addonTable.Assets.HighlightsLegacy2[highlight.asset] then
      local legacyDetails = addonTable.Assets.HighlightsLegacy2[highlight.asset]
      highlight.asset = legacyDetails.new
      if legacyDetails.shiftModifierH then
        highlight.width = highlight.width * legacyDetails.shiftModifierH
        highlight.height = highlight.height * legacyDetails.shiftModifierV
      end
      if not highlight.kind:match("^animated") then
        highlight.sliced = legacyDetails.mode == addonTable.Assets.RenderMode.Sliced
      end
    end

    if highlight.autoColors then
      UpdateAutoColors(highlight.autoColors)
    end
  end

  for _, bar in ipairs(design.specialBars) do
    if bar.layer == nil then
      bar.layer = 3
    end
  end

  if design.font.shadow == nil or design.font.flags ~= nil then
    design.font.shadow = true
    design.font.outline = design.font.flags == "OUTLINE"
    design.font.flags = nil
  end

  if design.font.slug == nil then
    design.font.slug = true
  end
  design.slug = nil

  if design.font.asset == "ArialShort" then
    design.font.asset = "ArialNarrow"
  end
end

function addonTable.Core.MigrateSettings()
  local legacyDesign = addonTable.Config.Get(addonTable.Config.Options.LEGACY_DESIGN)

  if legacyDesign.appliesToAll then
    local mapping = addonTable.Config.Get(addonTable.Config.Options.DESIGNS_ASSIGNED)
    local styleName = addonTable.Config.Get(addonTable.Config.Options.STYLE)
    if styleName == "custom" then
      mapping["friend"] = addonTable.Constants.CustomName
      mapping["enemy"] = addonTable.Constants.CustomName
    else
      mapping["friend"] = "_" .. styleName
      mapping["enemy"] = "_" .. styleName
    end
    addonTable.Config.Get(addonTable.Config.Options.DESIGNS)[addonTable.Constants.CustomName] = legacyDesign
    addonTable.Config.Set(addonTable.Config.Options.LEGACY_DESIGN, {})
    addonTable.Config.Set(addonTable.Config.Options.STYLE, mapping["friend"])
  end

  for _, design in pairs(addonTable.Config.Get(addonTable.Config.Options.DESIGNS)) do
    addonTable.Core.UpgradeDesign(design)
  end

  local mapping = addonTable.Config.Get(addonTable.Config.Options.DESIGNS_ASSIGNED)
  if mapping["enemySimplified"] == nil or addonTable.Core.GetDesignByName(mapping["enemySimplified"]) == nil then
    mapping["enemySimplified"] = "_hare_simplified"
  end

  local simplified = addonTable.Config.Get(addonTable.Config.Options.SIMPLIFIED_NAMEPLATES)
  if simplified["instancesNormal"] == nil then
    simplified["instancesNormal"] = true
  end

  if type(addonTable.Config.Get(addonTable.Config.Options.STACKING_NAMEPLATES)) == "boolean" then
    local state = addonTable.Config.Get(addonTable.Config.Options.STACKING_NAMEPLATES)
    addonTable.Config.Set(addonTable.Config.Options.STACKING_NAMEPLATES, {
      friend = false,
      enemy = state,
    })
  end

  if addonTable.Config.Get(addonTable.Config.Options.SHOW_NAMEPLATES).enemyMinion == nil then
    local state = addonTable.Config.Get(addonTable.Config.Options.SHOW_NAMEPLATES)
    state.enemyMinion = true
    state.enemyMinor = true
    state.friendlyMinion = false
    state.friendlyPlayer = state.player
    state.friendlyNPC = state.npc
    state.player = nil
    state.npc = nil
  end
end

local function SetStyle(isInit)
  local mapping = addonTable.Config.Get(addonTable.Config.Options.DESIGNS_ASSIGNED)

  local styleName = addonTable.Config.Get(addonTable.Config.Options.STYLE)
  if not isInit then
    if mapping["friend"] == mapping["enemy"] and mapping["enemySimplified"] ~= styleName then
      mapping["friend"] = styleName
      mapping["enemy"] = styleName
    elseif mapping["friend"] ~= styleName and mapping["enemy"] ~= styleName and mapping["enemySimplified"] ~= styleName then
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

function addonTable.Core.GetDesign(kind)
  local name = addonTable.Config.Get(addonTable.Config.Options.DESIGNS_ASSIGNED)[kind]
  return addonTable.Core.GetDesignByName(name)
end

local hasSimplifiedScale = C_CVar.GetCVarInfo("nameplateSimplifiedScale")

function addonTable.Core.GetDesignScale(kind)
  if kind:find("Simplified") then
    if hasSimplifiedScale then
      return addonTable.Config.Get(addonTable.Config.Options.SIMPLIFIED_SCALE)
    else
      return 0.3
    end
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
  UpdateRect(addonTable.Core.GetDesign("enemy"))
  addonTable.CallbackRegistry:RegisterCallback("RefreshStateChange", function(_, state)
    if state[addonTable.Constants.RefreshReason.Design] then
      UpdateRect(addonTable.Core.GetDesign("enemy"))
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
