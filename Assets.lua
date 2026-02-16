---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Assets.RenderMode = {
  Sliced = 1,
  Fixed = 2,
  Stretch = 3,
}

addonTable.Assets.Mode = {
  Special = -1,
  Percent50 = 50, -- Height 63, Width 1000
  Percent75 = 75, -- Height 94, Width 1000
  Percent100 = 100, -- Height 125, Width 1000
  Percent125 = 125, -- Height 157, Width 1000
  Percent150 = 150, -- Height 189, Width 1000
  Percent175 = 175, -- Height 219, Width 1000
  Percent200 = 200, -- Height 250, Width 1000
}

addonTable.Assets.BarBordersSize = {
  width = 1000 / 8,
  height = 125 / 8,
}

local legacyMode = addonTable.Assets.Mode
local renderMode = addonTable.Assets.RenderMode

local LSM = LibStub("LibSharedMedia-3.0")
LSM:Register(LSM.MediaType.FONT, addonTable.Constants.DefaultFont, "Interface/AddOns/Platynator/Assets/Fonts/RobotoCondensed-Bold.ttf", LSM.LOCALE_BIT_western + LSM.LOCALE_BIT_ruRU)
LSM:Register(LSM.MediaType.FONT, "Lato", "Interface/AddOns/Platynator/Assets/Fonts/Lato-Regular.ttf")
LSM:Register(LSM.MediaType.FONT, "Poppins SemiBold", "Interface/AddOns/Platynator/Assets/Fonts/Poppins-SemiBold.ttf")
LSM:Register(LSM.MediaType.FONT, "Diablo Heavy", "Interface/AddOns/Platynator/Assets/Fonts/DiabloHeavy.ttf")
LSM:Register(LSM.MediaType.FONT, "Atkinson Hyperlegible Next", "Interface/AddOns/Platynator/Assets/Fonts/AtkinsonHyperlegibleNext-Regular.otf")

addonTable.Assets.BarBackgrounds = {
  ["Platy: Solid Transparency"] = {file = "Interface/AddOns/Platynator/Assets/Special/transparent.png", isTransparent = true},
  ["Platy: Solid Black"] = {file = "Interface/AddOns/Platynator/Assets/Special/black.png"},
  ["Platy: Solid Grey"] = {file = "Interface/AddOns/Platynator/Assets/Special/grey.png"},
  ["Platy: Solid Grey (Raid)"] = {file = "Interface/AddOns/Platynator/Assets/Special/grey-raid.png"},
  ["Platy: Solid White"] = {file = "Interface/AddOns/Platynator/Assets/Special/white.png"},

  ["Platy: Bevelled"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBackgrounds/bevelled.png", has4k = true},
  ["Platy: Bevelled Grey"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBackgrounds/bevelled-grey.png", has4k = true},

  ["Platy: Fade Bottom"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBackgrounds/fade-bottom.png", has4k = true},
  ["Platy: Fade Top"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBackgrounds/fade-top.png", has4k = true},
  ["Platy: Fade Left"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBackgrounds/fade-left.png", has4k = true},
  ["Platy: Fade Right"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBackgrounds/fade-right.png", has4k = true},

  ["Platy: GW2"] = {file = "Interface/AddOns/Platynator/Assets/Special/BarBackgrounds/gw2.png"},
  ["Platy: Blizzard Cast Bar"] = {file = "Interface/AddOns/Platynator/Assets/Special/BarBackgrounds/blizzard-cast-bar.png"},

  ["Platy: Absorb Wide"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBackgrounds/blizzard-absorb.png", has4k = true},
  ["Platy: Absorb Narrow"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBackgrounds/blizzard-absorb-narrow.png", has4k = true},
}

addonTable.Assets.BarBordersSliced = {
  ["Platy: Transparent"] = {file = "Interface/AddOns/Platynator/Assets/Special/transparent.png", width = 20, height = 20, isTransparent = true, margin = 0.5, extra = 0, modifier = 1},

  ["Platy: 7px"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/bold-square.png", width = 20, height = 20, has4k = true, masked = true, margin = 0.45, extra = 0, modifier = 0.35, DPIScale = 1/2},
  ["Platy: 4px"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/slight-square.png", width = 20, height = 20, has4k = true, masked = true, margin = 0.3, extra = 0, modifier = 0.35, DPIScale = 1/2},
  ["Platy: 2px"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/thin-square.png", width = 20, height = 20, has4k = true, masked = true, margin = 0.2, extra = 0, modifier = 0.35, DPIScale = 1/2},
  ["Platy: 1px"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/1px-square.png", width = 20, height = 20, has4k = true, masked = true, margin = 0.3, extra = 0, modifier = 0.35, DPIScale = 1/2},

  ["Platy: Round Bold"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/round-square.png", width = 48, height = 48, has4k = true, margin = 0.48, extra = 0, modifier = 0.3, DPIScale = 1/2},
  ["Platy: Round Medium"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/round-slight-square.png", width = 48, height = 48, has4k = true, margin = 0.48, extra = 0, modifier = 0.3, DPIScale = 1/2},
  ["Platy: Round Thin"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/round-thin-square.png", width = 48, height = 48, has4k = true, margin = 0.48, extra = 0, modifier = 0.3, DPIScale = 1/2},

  ["Platy: Soft"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/soft-square.png", width = 66, height = 66, has4k = true, margin = 0.33, extra = 9, modifier = 0.25, DPIScale = 4/6},
  ["Platy: GW2"] = {file = "Interface/AddOns/Platynator/Assets/Special/BarBorders/gw2.png", width = 33, height = 33, masked = false, margin = 0.3, extra = 12, modifier = 1},

  ["Platy: Blizzard Health"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-health-square.png", width = 48, height = 48, has4k = true, margin = 0.4, extra = 0, modifier = 0.3, DPIScale = 1/2},
  ["Platy: Blizzard Cast Bar"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-cast-bar-square.png", width = 48, height = 48, has4k = true, margin = 0.35, extra = 0, modifier = 0.35, DPIScale = 1/2},
  ["Platy: Blizzard Classic"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-classic-square.png", width = 48, height = 48, has4k = true, margin = 0.4, extra = 0, modifier = 0.3, DPIScale = 1/2},
}

addonTable.Assets.BarMasks = {
  ["Platy: Solid"] = {file = "Interface/AddOns/Platynator/Assets/Special/white.png", width = 10, height = 10},
  ["Platy: 7px"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/bold-square-mask.png", width = 20, height = 20, has4k = true},
  ["Platy: 4px"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/slight-square-mask.png", width = 20, height = 20, has4k = true},
  ["Platy: 2px"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/thin-square-mask.png", width = 20, height = 20, has4k = true},
  --["1px"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/1px-square-mask.png", width = 20, height = 20, has4k = true, margin = 0.3},

  ["Platy: Round Bold"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/round-square-mask.png", width = 48, height = 48, has4k = true, margin = 0.48},
  ["Platy: Round Medium"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/round-slight-square-mask.png", width = 48, height = 48, has4k = true, margin = 0.48},
  ["Platy: Round Thin"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/round-thin-square-mask.png", width = 48, height = 48, has4k = true, margin = 0.48},

  ["Platy: Soft"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/soft-square-mask.png", width = 48, height = 48, has4k = true, margin = 0.33},

  ["Platy: Blizzard Health"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-health-square-mask.png", width = 48, height = 48, has4k = true, margin = 0.49},
  ["Platy: Blizzard Classic"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-classic-square-mask.png", width = 48, height = 48, has4k = true, margin = 0.35},
  ["Platy: Blizzard Cast Bar"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-cast-bar-square-mask.png", width = 48, height = 48, has4k = true, margin = 0.35},
}

addonTable.Assets.Highlights = {
  ["Platy: White"] = {file = "Interface/AddOns/Platynator/Assets/Special/white.png", width = 10, height = 10, mode = renderMode.Sliced, tag = "white", margin = 0.4, extra = 0, modifier = 1, minSize = 1, modifier = 1},

  ["Platy: Blizzard Health Bold"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-health-square.png", width = 48, height = 48, has4k = true, masked = true, tag = "blizzard-health", margin = 0.4, extra = 0, minSize = 100, modifier = 0.3, DPIScale = 1/2, mode = renderMode.Sliced},
  ["Platy: Soft Glow"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/soft-glow-square.png", width = 59, height = 59, has4k = true, masked = true, tag = "soft", margin = 0.4, extra = 11, modifier = 0.3, DPIScale = 1/2, mode = renderMode.Sliced},
  ["Platy: Feathered"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/feathered-square.png", width = 60, height = 60, has4k = true, masked = true, tag = "soft", margin = 0.48, extra = 0, modifier = 0.25, DPIScale = 1/2, mode = renderMode.Sliced},

  ["Platy: Glow"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/glow-100.png", width = 1563, height = 680, has4k = true, mode = renderMode.Stretch, tag = "glow"},

  ["Platy: Striped"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/striped.png", width = 1000, height = 125, has4k = true, mode = renderMode.Stretch, tag = "striped"},
  ["Platy: Striped Reverse"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/striped-reverse.png", width = 1000, height = 125, has4k = true, mode = renderMode.Stretch, tag = "striped-reverse"},

  ["Platy: Arrows In"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/arrows-in.png", width = 1000, height = 125, has4k = true, mode = renderMode.Stretch, tag = "arrows-in"},
  ["Platy: Arrows Out"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/arrows-out.png", width = 1000, height = 125, has4k = true, mode = renderMode.Stretch, tag = "arrows-out"},
  ["Platy: Arrows In Close"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/arrows-in-close.png", width = 1000, height = 125, has4k = true, mode = renderMode.Stretch, tag = "arrows-in-close"},
  ["Platy: Arrows Out Close"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/arrows-out-close.png", width = 1000, height = 125, has4k = true, mode = renderMode.Stretch, tag = "arrows-out-close"},

  ["Platy: Arrow"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/arrows.png", width = 86, height = 66, has4k = true, margin = 0.5, extra = 0, modifier = 0.29, DPIScale = 8/10, mode = renderMode.Sliced, tag = "arrows"},
  ["Platy: Arrow Double"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/double-arrows.png", width = 149, height = 69, has4k = true, margin = 0.5, extra = 0, modifier = 0.31, DPIScale = 8/10, mode = renderMode.Sliced, tag = "arrows"},
  ["Platy: Arrow Double Down"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/double-arrows-down.png", width = 173, height = 153, has4k = true, mode = renderMode.Fixed, tag = "arrows"},
  ["Platy: Arrow Solid"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/arrows-solid.png", width = 97, height = 69, has4k = true, margin = 0.5, extra = 0, modifier = 0.30, DPIScale = 8/10, mode = renderMode.Sliced, tag = "arrows"},
  ["Platy: Arrow Solid Down"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/arrow-solid-down.png", width = 207, height = 132, has4k = true, mode = renderMode.Fixed, tag = "arrows"},
  ["Platy: Arrow Hi-vis"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/hi-vis-arrows.png", width = 158, height = 50, has4k = true, margin = 0.5, extra = 0, modifier = 0.42, shiftModifierV = 1, DPIScale = 8/10, mode = renderMode.Sliced, tag = "arrows"},
  ["Platy: Arrow Hi-vis Down"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/hi-vis-arrow-down.png", width = 125, height = 185, has4k = true, mode = renderMode.Fixed, tag = "arrows"},

  ["Platy: Blizzard Classic Level"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/blizzard-classic-level.png", width = 178, height = 125, has4k = true, mode = renderMode.Fixed, tag = "blizzard-classic-level"},

  ["Platy: Animated Dashes Short"] = {offset = -1, defaultWidth = 1, preview = "Interface/AddOns/Platynator/Assets/Special/Animations/important-preview.png", horizontal = "Interface/AddOns/Platynator/Assets/Special/Animations/important.png", vertical = "Interface/AddOns/Platynator/Assets/Special/Animations/important-90.png", columns = 1, rows = 11, duration = 0.5, kind = "animatedBorder"},
  ["Platy: Animated Dashes Long"] = {offset = -1, defaultWidth = 1, preview = "Interface/AddOns/Platynator/Assets/Special/Animations/pandemic-preview.png", horizontal = "Interface/AddOns/Platynator/Assets/Special/Animations/pandemic.png", vertical = "Interface/AddOns/Platynator/Assets/Special/Animations/pandemic-90.png", columns = 1, rows = 11, duration = 0.5, kind = "animatedBorder"},
}

addonTable.Assets.BarPositionHighlights = {
  ["none"] = {file = "", width = 0, height = 0},
  ["wide/glow"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarPosition/highlight.png", width = 54, height = 125, mask = "Interface/AddOns/Platynator/Assets/%s/BarPosition/highlight-mask.png", offset = 0.25, has4k = true},
  ["gw2"] = {file = "Interface/AddOns/Platynator/Assets/Special/BarPosition/gw2.png", width = 137, height = 125, offset = 0.5},
}

addonTable.Assets.PowerBars = {
  ["transparent"] = {file = "Interface/AddOns/Platynator/Assets/Special/transparent.png", width = 993, height = 147, has4k = true},
  ["normal/gradient-faded"] = {file = "Interface/AddOns/Platynator/Assets/%s/Power/gradient-inactive.png", width = 993, height = 147, has4k = true},
  ["normal/gradient-full"] = {file = "Interface/AddOns/Platynator/Assets/%s/Power/gradient-active.png", width = 993, height = 147, has4k = true},
  ["normal/gradient-square-faded"] = {file = "Interface/AddOns/Platynator/Assets/%s/Power/gradient-square-empty.png", width = 993, height = 147, has4k = true},
  ["normal/gradient-square-full"] = {file = "Interface/AddOns/Platynator/Assets/%s/Power/gradient-square-filled.png", width = 993, height = 147, has4k = true},
  ["normal/soft-faded"] = {file = "Interface/AddOns/Platynator/Assets/%s/Power/soft-inactive.png", width = 993, height = 147, has4k = true},
  ["normal/soft-full"] = {file = "Interface/AddOns/Platynator/Assets/%s/Power/soft-active.png", width = 993, height = 147, has4k = true},
  ["normal/soft-square-faded"] = {file = "Interface/AddOns/Platynator/Assets/%s/Power/soft-square-empty.png", width = 993, height = 147, has4k = true},
  ["normal/soft-square-full"] = {file = "Interface/AddOns/Platynator/Assets/%s/Power/soft-square-filled.png", width = 993, height = 147, has4k = true},
}

addonTable.Assets.Markers = {
  ["normal/cast-icon"] = {file = addonTable.Constants.IsRetail and 236205 or 135753, width = 120, height = 120, tag = "castIcon"},

  ["normal/quest-gradient"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/quest-gradient.png", width = 48, height = 170, has4k = true, tag = "quest"},
  ["normal/quest-boss-blizzard"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/blizzard-quest-boss.png", width = 164, height = 208, has4k = true, tag = "quest"},
  ["normal/quest-blizzard"] = {file = "Interface/AddOns/Platynator/Assets/Special/Markers/quest-blizzard.png", width = 97, height = 170, tag = "quest"},

  ["normal/shield-gradient"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/shield-gradient.png", width = 150, height = 155, has4k = true, tag = "cannotInterrupt"},
  ["normal/shield-soft"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/shield-soft.png", width = 160, height = 165, has4k = true, tag = "cannotInterrupt"},
  ["normal/blizzard-shield"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/blizzard-shield.png", width = 136, height = 165, has4k = true, tag = "cannotInterrupt"},
  ["normal/gw2-shield"] = {file = "Interface/AddOns/Platynator/Assets/Special/Markers/gw2-shield.png", width = 165, height = 165, has4k = true, tag = "cannotInterrupt"},

  ["special/blizzard-elite"] = {file = "Interface/AddOns/Platynator/Assets/Special/Markers/eliterarecombo-blizzard.png", width = 150, height = 155, mode = legacyMode.Special, tag = "elite"},
  ["normal/blizzard-elite"] = {file = "Interface/AddOns/Platynator/Assets/Special/Markers/elite-blizzard.png", width = 150, height = 155},
  ["normal/blizzard-rareelite"] = {file = "Interface/AddOns/Platynator/Assets/Special/Markers/rareelite-blizzard.png", width = 150, height = 155},

  ["special/blizzard-elite-around"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/blizzard-rareelitecombo.png", width = 183, height = 155, has4k = true, mode = legacyMode.Special, tag = "elite"},
  ["normal/blizzard-elite-around"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/blizzard-elite.png", width = 183, height = 150, has4k = true},
  ["normal/blizzard-rareelite-around"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/blizzard-rareelite.png", width = 183, height = 150, has4k = true},

  ["special/blizzard-elite-midnight"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/blizzard-midnight-eliterarecombo.png", width = 150, height = 150, has4k = true, mode = legacyMode.Special, tag = "elite"},
  ["normal/blizzard-elite-midnight"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/blizzard-midnight-elite.png", width = 150, height = 150, has4k = true},
  ["normal/blizzard-rareelite-midnight"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/blizzard-midnight-rareelite.png", width = 150, height = 150, has4k = true},

  ["special/blizzard-elite-star"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/blizzard-rare-old.png", width = 140, height = 140, has4k = true, tag = "elite"},

  ["normal/blizzard-rare"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/blizzard-rare.png", width = 162, height = 159, has4k = true, tag = "rare"},
  ["normal/blizzard-rare-old"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/blizzard-rare-old.png", width = 140, height = 140, has4k = true, tag = "rare"},
  ["normal/blizzard-rare-silver-star"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/blizzard-rare-star.png", width = 140, height = 140, has4k = true, tag = "rare"},
  ["normal/blizzard-rare-midnight"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/blizzard-midnight-rare.png", width = 162, height = 162, has4k = true, tag = "rare"},

  ["normal/blizzard-raid"] = {file = "Interface/TargetingFrame/UI-RaidTargetingIcons", preview = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_1.blp", width = 150, height = 150, tag = "raid"},

  ["normal/blizzard-pvp"] = {file = "Interface/AddOns/Platynator/Assets/Special/Markers/pvp.png", width = 150, height = 150, tag = "pvp"},

  ["normal/class"] = {file = "Interface/AddOns/Platynator/Assets/Special/Markers/classicon-monk.png", width = 200, height = 200, tag = "class"},
}

addonTable.Assets.SpecialBars = {
}

addonTable.Assets.SpecialEliteMarkers = {
  ["special/blizzard-elite"] = {
    elite = "normal/blizzard-elite",
    rareElite = "normal/blizzard-rareelite",
  },
  ["special/blizzard-elite-around"] = {
    elite = "normal/blizzard-elite-around",
    rareElite = "normal/blizzard-rareelite-around",
  },
  ["special/blizzard-elite-midnight"] = {
    elite = "normal/blizzard-elite-midnight",
    rareElite = "normal/blizzard-rareelite-midnight",
  },
}

function addonTable.Assets.ApplyScale()
  local DPIScale = "DPI144"
  if GetScreenDPIScale() < 1.4 then
    DPIScale = "DPI96"
  end

  local function IterateLSMBackground(list)
    for key, entry in pairs(list) do
      if entry.has4k then
        entry.file = entry.file:format(DPIScale)
      end
      LSM:Register(LSM.MediaType.STATUSBAR, key, entry.file)
    end
  end

  local function ResizeSlicedAssets(list, scales)
    for key, entry in pairs(list) do
      if entry.has4k then
        entry.file = entry.file:format(DPIScale)
        if DPIScale ~= "DPI144" then
          local scale = scales[key].DPIScale
          entry.width = scale * entry.width
          entry.height = scale * entry.height
          if entry.modifier then
            entry.modifier = entry.modifier / scale
          end
        end
      end
    end
  end

  local function ResizeAssets(list)
    for _, entry in pairs(list) do
      if entry.has4k then
        entry.file = entry.file:format(DPIScale)
        if type(entry.mask) == "string" then
          entry.mask = entry.mask:format(DPIScale)
        end
      end
      entry.width = entry.width / 8
      entry.height = entry.height / 8
    end
  end

  local function IterateLSMSlicedBorder(list, masks)
    ResizeSlicedAssets(list, list)
    ResizeSlicedAssets(masks, list)
    for key, entry in pairs(list) do
      LSM:Register("nineslice", key, {
        file = entry.file,
        previewWidth = entry.width,
        previewHeight = entry.height,
        padding = {left = entry.extra / 2, right = entry.extra / 2, top = entry.extra / 2, bottom = entry.extra / 2},
        margins = {left = entry.width * entry.margin, right = entry.width * entry.margin, top = entry.height * entry.margin, bottom = entry.height * entry.margin},
        scaleModifier = entry.modifier,
        mode = Enum.UITextureSliceMode.Stretched,
      })
      local maskKey = masks[key] and key or "Platy: Solid"
      local maskData = masks[maskKey]
      local maskMargin = maskData.margin or 0.49
      LSM:Register("ninesliceborder", key, {
        nineslice = key,
        mask = {
          file = maskData.file,
          margins = {left = maskData.width * maskMargin, right = maskData.width * maskMargin, top = maskData.height * maskMargin, bottom = maskData.height * maskMargin},
        },
      })
    end
  end

  local function IterateLSMHighlights(list)
    for key, entry in pairs(list) do
      if entry.mode == renderMode.Sliced then
        ResizeSlicedAssets({entry}, {entry})
        LSM:Register("nineslice", key, {
          file = entry.file,
          previewWidth = entry.width,
          previewHeight = entry.height,
          margins = {left = entry.width * entry.margin, right = entry.width * entry.margin, top = entry.height * entry.margin, bottom = entry.height * entry.margin},
          padding = {left = 0, right = 0, top = 0, bottom = 0},
          scaleModifier = entry.modifier,
          mode = Enum.UITextureSliceMode.Stretched,
        })
      elseif entry.kind == "animatedBorder" then
        -- Not registered on purpose
      else
        ResizeAssets({entry})
        LSM:Register("platynator/sizedtexture", key, {
          file = entry.file,
          width = entry.width,
          height = entry.height,
        })
      end
    end
  end

  local lowerScale = 1
  if DPIScale == "DPI96" then
    lowerScale = 2
  end
  IterateLSMBackground(addonTable.Assets.BarBackgrounds)
  IterateLSMSlicedBorder(addonTable.Assets.BarBordersSliced, addonTable.Assets.BarMasks)
  IterateLSMHighlights(addonTable.Assets.Highlights)
  ResizeAssets(addonTable.Assets.BarPositionHighlights)
  ResizeAssets(addonTable.Assets.PowerBars)
  ResizeAssets(addonTable.Assets.Markers)
end
