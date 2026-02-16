---@class addonTablePlatynator
local addonTable = select(2, ...)

local legacyMode = addonTable.Assets.Mode
local renderMode = addonTable.Assets.RenderMode

local function ResizeAssets(list)
  for _, entry in pairs(list) do
    entry.width = entry.width / 8
    entry.height = entry.height / 8
  end
end

addonTable.Assets.BarBackgroundsLegacyMap = {
  ["transparent"] = "Platy: Solid Transparency",
  ["black"] = "Platy: Solid Black",
  ["grey"] = "Platy: Solid Grey",
  ["grey-raid"] = "Platy: Solid Raid Grey",
  ["white"] = "Platy: Solid White",
  ["wide/bevelled"] = "Platy: Bevelled",
  ["wide/bevelled-grey"] = "Platy: Bevelled Grey",
  ["wide/fade-bottom"] = "Platy: Fade Bottom",
  ["wide/fade-top"] = "Platy: Fade Top",
  ["wide/fade-left"] = "Platy: Fade Left",
  ["wide/fade-right"] = "Platy: Fade Right",
  ["gw2"] = "Platy: GW2",
  ["special/blizzard-cast-bar"] = "Platy: Blizzard Cast Bar",
  ["wide/blizzard-absorb"] = "Platy: Absorb Wide",
  ["narrow/blizzard-absorb"] = "Platy: Absorb Narrow",
}

addonTable.Assets.BarBordersSlicedLegacy = {
  ["transparent"] = "Platy: Transparent",

  ["bold"] = "Platy: 7px",
  ["slight"] = "Platy: 4px",
  ["thin"] = "Platy: 2px",
  ["1px"] = "Platy: 1px",

  ["round-bold"] = "Platy: Round Bold",
  ["round-slight"] = "Platy: Round Medium",
  ["round-thin"] = "Platy: Round Thin",

  ["soft"] = "Platy: Soft",
  ["gw2"] = "Platy: GW2",

  ["blizzard-health"] = "Platy: Blizzard Health",
  ["blizzard-cast-bar"] = "Platy: Blizzard Cast Bar",
  ["blizzard-classic"] = "Platy: Blizzard Classic",
}

-- Kept around ONLY to convert old saves into new ones
addonTable.Assets.BarBordersLegacy = {
  ["tall/transparent"] = {mode = legacyMode.Percent200, tag = "transparent"},
  ["175/transparent"] = {mode = legacyMode.Percent175, tag = "transparent"},
  ["150/transparent"] = {mode = legacyMode.Percent150, tag = "transparent"},
  ["125/transparent"] = {mode = legacyMode.Percent125, tag = "transparent"},
  ["wide/transparent"] = {mode = legacyMode.Percent100, tag = "transparent"},
  ["75/transparent"] = {mode = legacyMode.Percent75, tag = "transparent"},
  ["narrow/transparent"] = {mode = legacyMode.Percent50, tag = "transparent"},

  ["200/blizzard-health"] = {mode = legacyMode.Percent200, tag = "blizzard-health"},
  ["175/blizzard-health"] = {mode = legacyMode.Percent175, tag = "blizzard-health"},
  ["150/blizzard-health"] = {mode = legacyMode.Percent150, tag = "blizzard-health"},
  ["125/blizzard-health"] = {mode = legacyMode.Percent125, tag = "blizzard-health"},
  ["wide/blizzard-health"] = {mode = legacyMode.Percent100, tag = "blizzard-health"},
  ["75/blizzard-health"] = {mode = legacyMode.Percent75, tag = "blizzard-health"},
  ["narrow/blizzard-health"] = {mode = legacyMode.Percent50, tag = "blizzard-health"},

  ["wide/blizzard-classic"] = {mode = legacyMode.Percent100, tag = "blizzard-classic"},

  ["wide/blizzard-classic-level"] = {mode = legacyMode.Percent100, tag = "blizzard-classic-level"},

  ["wide/bold"] = {mode = legacyMode.Percent100, tag = "bold"},

  ["tall/soft"] = {mode = legacyMode.Percent200, tag = "soft"},
  ["175/soft"] = {mode = legacyMode.Percent175, tag = "soft"},
  ["150/soft"] = {mode = legacyMode.Percent150, tag = "soft"},
  ["125/soft"] = {mode = legacyMode.Percent125, tag = "soft"},
  ["wide/soft"] = {mode = legacyMode.Percent100, tag = "soft"},
  ["75/soft"] = {mode = legacyMode.Percent75, tag = "soft"},
  ["narrow/soft"] = {mode = legacyMode.Percent50, tag = "soft"},

  ["200/slight"] = {mode = legacyMode.Percent200, tag = "slight"},
  ["175/slight"] = {mode = legacyMode.Percent175, tag = "slight"},
  ["150/slight"] = {mode = legacyMode.Percent150, tag = "slight"},
  ["125/slight"] = {mode = legacyMode.Percent125, tag = "slight"},
  ["wide/slight"] = {mode = legacyMode.Percent100, tag = "slight"},
  ["75/slight"] = {mode = legacyMode.Percent75, tag = "slight"},
  ["narrow/slight"] = {mode = legacyMode.Percent50, tag = "slight"},

  ["200/thin"] = {mode = legacyMode.Percent200, tag = "thin"},
  ["175/thin"] = {mode = legacyMode.Percent175, tag = "thin"},
  ["150/thin"] = {mode = legacyMode.Percent150, tag = "thin"},
  ["125/thin"] = {mode = legacyMode.Percent125, tag = "thin"},
  ["wide/thin"] = {mode = legacyMode.Percent100, tag = "thin"},
  ["75/thin"] = {mode = legacyMode.Percent75, tag = "thin"},
  ["narrow/thin"] = {mode = legacyMode.Percent50, tag = "thin"},

  ["200/blizzard-cast-bar-white"] = {mode = legacyMode.Percent200, tag = "blizzard-cast-bar"},
  ["175/blizzard-cast-bar-white"] = {mode = legacyMode.Percent175, tag = "blizzard-cast-bar"},
  ["150/blizzard-cast-bar-white"] = {mode = legacyMode.Percent150, tag = "blizzard-cast-bar"},
  ["125/blizzard-cast-bar-white"] = {mode = legacyMode.Percent125, tag = "blizzard-cast-bar"},
  ["100/blizzard-cast-bar-white"] = {mode = legacyMode.Percent100, tag = "blizzard-cast-bar"},
  ["75/blizzard-cast-bar-white"] = {mode = legacyMode.Percent75, tag = "blizzard-cast-bar"},
  ["50/blizzard-cast-bar-white"] = {mode = legacyMode.Percent50, tag = "blizzard-cast-bar"},
}

addonTable.Assets.HighlightsLegacy2 = {
  ["white"] = {new = "Platy: White", width = 20, height = 20, mode = renderMode.Sliced, tag = "white", margin = 0.4, extra = 0, padding = 0, modifier = 1, minSize = 1, modifier = 1, group = 0, order = 1},

  ["bold"] = {new = "Platy: 7px", width = 20, height = 20, has4k = true, masked = true, tag = "bold", margin = 0.45, extra = 0, minSize = 50, modifier = 0.35, DPIScale = 1/2, mode = renderMode.Sliced, group = 1, order = 1},
  ["slight"] = {new = "Platy: 4px", width = 20, height = 20, has4k = true, masked = true, tag = "slight", margin = 0.3, extra = 0, minSize = 50, modifier = 0.35, DPIScale = 1/2, mode = renderMode.Sliced, group = 1, order = 2},
  ["thin"] = {new = "Platy: 2px", width = 20, height = 20, has4k = true, masked = true, tag = "thin", margin = 0.2, extra = 0, minSize = 50, modifier = 0.35, DPIScale = 1/2, mode = renderMode.Sliced, group = 1, order = 3},
  ["1px"] = {new = "Platy: 1px", width = 20, height = 20, has4k = true, masked = true, tag = "1px", margin = 0.3, extra = 0, minSize = 50, modifier = 0.35, DPIScale = 1/2, mode = renderMode.Sliced, group = 1, order = 4},

  ["round-bold"] = {new = "Platy: Round Bold", width = 48, height = 48, has4k = true, masked = true, tag = "round-bold", margin = 0.48, extra = 0, minSize = 50, modifier = 0.3, DPIScale = 1/2, mode = renderMode.Sliced, group = 2, order = 1},
  ["round-slight"] = {new = "Platy: Round Medium", width = 48, height = 48, has4k = true, masked = true, tag = "round-slight", margin = 0.48, extra = 0, minSize = 50, modifier = 0.3, DPIScale = 1/2, mode = renderMode.Sliced, group = 2, order = 2},
  ["round-thin"] = {new = "Platy: Round Thin", width = 47, height = 48, has4k = true, masked = true, tag = "round-thin", margin = 0.48, extra = 0, minSize = 50, modifier = 0.3, DPIScale = 1/2, mode = renderMode.Sliced, group = 2, order = 3},

  ["soft"] = {"Platy: Soft", width = 66, height = 66, has4k = true, masked = true, tag = "soft", margin = 0.33, extra = 9, minSize = 50, modifier = 0.25, DPIScale = 4/6, mode = renderMode.Sliced, group = 3, order = 1},
  ["gw2"] = {"Platy: GW2", width = 33, height = 33, masked = false, tag = "gw2", margin = 0.3, extra = 8, minSize = 50, modifier = 1, mode = renderMode.Sliced, group = 3, order = 2},

  ["blizzard-health"] = {new = "Platy: Blizzard Health", width = 48, height = 48, has4k = true, masked = true, tag = "blizzard-health", margin = 0.4, extra = 0, minSize = 100, modifier = 0.3, DPIScale = 1/2, mode = renderMode.Sliced, group = 4, order = 1},
  ["blizzard-bold-health"] = {new = "Platy: Blizzard Health Bold", width = 48, height = 48, has4k = true, masked = true, tag = "blizzard-bold-health", margin = 0.4, extra = 0, minSize = 100, modifier = 0.3, DPIScale = 1/2, mode = renderMode.Sliced, group = 4, order = 2},
  ["blizzard-cast-bar"] = {new = "Platy: Blizzard Cast Bar", width = 48, height = 48, has4k = true, masked = true, tag = "blizzard-cast-bar", margin = 0.35, extra = 0, minSize = 50, modifier = 0.35, DPIScale = 1/2, mode = renderMode.Sliced, group = 4, order = 3},
  ["blizzard-classic"] = {new = "Platy: Blizzard Classic", width = 48, height = 48, has4k = true, masked = true, tag = "blizzard-classic", margin = 0.4, extra = 0, minSize = 100, modifier = 0.3, DPIScale = 1/2, mode = renderMode.Sliced, group = 4, order = 4},

  ["soft-glow"] = {new = "Platy: Soft Glow", width = 59, height = 59, has4k = true, masked = true, tag = "soft", margin = 0.4, extra = 11, padding = 0, minSize = 50, modifier = 0.3, DPIScale = 1/2, mode = renderMode.Sliced, group = 5, order = 1},
  ["feathered"] = {new = "Platy: Feathered", width = 60, height = 60, has4k = true, masked = true, tag = "soft", margin = 0.48, extra = 0, padding = 0, minSize = 50, modifier = 0.25, DPIScale = 1/2, mode = renderMode.Sliced, group = 5, order = 2},

  ["glow"] = {new = "Platy: Glow", width = 1563, height = 680, has4k = true, mode = renderMode.Stretch, tag = "glow", group = 6, order = 1},

  ["striped"] = {new = "Platy: Striped", width = 1000, height = 125, has4k = true, mode = renderMode.Stretch, tag = "striped", group = 7, order = 1},
  ["striped-reverse"] = {new = "Platy: Striped Reverse", width = 1000, height = 125, has4k = true, mode = renderMode.Stretch, tag = "striped-reverse", group = 7, order = 2},

  ["arrows-in"] = {new = "Platy: Arrows In", width = 1000, height = 125, has4k = true, mode = renderMode.Stretch, tag = "arrows-in", group = 8, order = 1},
  ["arrows-out"] = {new = "Platy: Arrows Out", width = 1000, height = 125, has4k = true, mode = renderMode.Stretch, tag = "arrows-out", group = 8, order = 2},
  ["arrows-in-close"] = {new = "Platy: Arrows In Close", width = 1000, height = 125, has4k = true, mode = renderMode.Stretch, tag = "arrows-in-close", group = 8, order = 3},
  ["arrows-out-close"] = {new = "Platy: Arrows Out Close", width = 1000, height = 125, has4k = true, mode = renderMode.Stretch, tag = "arrows-out-close", group = 8, order = 4},

  ["arrows"] = {new = "Platy: Arrow", width = 86, height = 66, has4k = true, margin = 0.5, extra = 0, padding = 0, modifier = 0.29, shiftModifierH = 1.23, shiftModifierV = 1.22, DPIScale = 8/10, mode = renderMode.Sliced, tag = "arrows", group = 9, order = 1},
  ["double-arrows"] = {new = "Platy: Arrow Double", width = 149, height = 69, has4k = true, margin = 0.5, extra = 0, padding = 0, modifier = 0.31, shiftModifierH = 1.36, shiftModifierV = 1.36, DPIScale = 8/10, mode = renderMode.Sliced, tag = "arrows", group = 9, order = 2},
  ["double-arrows-down"] = {new = "Platy: Arrow Double Down", width = 173, height = 153, has4k = true, mode = renderMode.Fixed, tag = "arrows", group = 9, order = 3},
  ["solid-arrows"] = {new = "Platy: Arrow Solid", width = 97, height = 69, has4k = true, margin = 0.5, extra = 0, padding = 0, modifier = 0.30, shiftModifierH = 1.27, shiftModifierV = 1.36, DPIScale = 8/10, mode = renderMode.Sliced, tag = "arrows", group = 9, order = 4},
  ["solid-arrow-down"] = {new = "Platy: Arrow Solid Down", width = 207, height = 132, has4k = true, mode = renderMode.Fixed, tag = "arrows", group = 9, order = 5},
  ["hi-vis-arrows"] = {new = "Platy: Arrow Hi-vis", width = 158, height = 50, has4k = true, margin = 0.5, extra = 0, padding = 0, modifier = 0.42, shiftModifierH = 1.41, shiftModifierV = 1, DPIScale = 8/10, mode = renderMode.Sliced, tag = "arrows", group = 9, order = 6},
  ["hi-vis-arrow-down"] = {new = "Platy: Arrow Hi-vis Down", width = 125, height = 185, has4k = true, mode = renderMode.Fixed, tag = "arrows", group = 9, order = 7},

  ["blizzard-classic-level"] = {new = "Platy: Blizzard Classic Level", width = 178, height = 125, has4k = true, mode = renderMode.Fixed, tag = "blizzard-classic-level", group = 10, order = 1},

  ["important"] = {new = "Platy: Animated Dashes Short", width = 1000, height = 125, preview = "Interface/AddOns/Platynator/Assets/Special/Animations/important-preview.png", horizontal = "Interface/AddOns/Platynator/Assets/Special/Animations/important.png", vertical = "Interface/AddOns/Platynator/Assets/Special/Animations/important-90.png", columns = 1, rows = 11, duration = 0.5, kind = "animatedBorder", group = 10, order = 2},
  ["pandemic"] = {new = "Platy: Animated Dashes Long", width = 1000, height = 125, preview = "Interface/AddOns/Platynator/Assets/Special/Animations/pandemic-preview.png", horizontal = "Interface/AddOns/Platynator/Assets/Special/Animations/pandemic.png", vertical = "Interface/AddOns/Platynator/Assets/Special/Animations/pandemic-90.png", columns = 1, rows = 11, duration = 0.5, kind = "animatedBorder", group = 10, order = 3},
}
ResizeAssets(addonTable.Assets.HighlightsLegacy2)

addonTable.Assets.HighlightsLegacy = {
  ["200/outline"] = {width = 1030, height = 280, mode = legacyMode.Percent200, tag = "bold"},
  ["175/outline"] = {width = 1030, height = 249, mode = legacyMode.Percent175, tag = "bold"},
  ["150/outline"] = {width = 1030, height = 218, mode = legacyMode.Percent150, tag = "bold"},
  ["125/outline"] = {width = 1030, height = 186, mode = legacyMode.Percent125, tag = "bold"},
  ["wide/outline"] = {width = 1030, height = 155, mode = legacyMode.Percent100, tag = "bold"},
  ["wide/outline"] = {width = 1030, height = 155, mode = legacyMode.Percent100, tag = "bold"},
  ["75/outline"] = {width = 1030, height = 125, mode = legacyMode.Percent75, tag = "bold"},
  ["wide/outline-narrow"] = {width = 1030, height = 93, mode = legacyMode.Percent50, tag = "bold"},

  ["200/glow"] = {width = 1588, height = 870, mode = legacyMode.Percent200, tag = "glow"},
  ["175/glow"] = {width = 1588, height = 763, mode = legacyMode.Percent175, tag = "glow"},
  ["150/glow"] = {width = 1588, height = 735, mode = legacyMode.Percent150, tag = "glow"},
  ["125/glow"] = {width = 1588, height = 692, mode = legacyMode.Percent125, tag = "glow"},
  ["wide/glow"] = {width = 1563, height = 680, mode = legacyMode.Percent100, tag = "glow"},
  ["75/glow"] = {width = 1585, height = 628, mode = legacyMode.Percent75, tag = "glow"},
  ["50/glow"] = {width = 1610, height = 578, mode = legacyMode.Percent50, tag = "glow"},

  ["tall/soft-glow"] = {width = 1066, height = 324, mode = legacyMode.Percent200, tag = "soft-glow"},
  ["175/soft-glow"] = {width = 1066, height = 287, mode = legacyMode.Percent175, tag = "soft-glow"},
  ["150/soft-glow"] = {width = 1066, height = 257, mode = legacyMode.Percent150, tag = "soft-glow"},
  ["125/soft-glow"] = {width = 1066, height = 225, mode = legacyMode.Percent125, tag = "soft-glow"},
  ["wide/soft-glow"] = {width = 1066, height = 193, mode = legacyMode.Percent100, tag = "soft-glow"},
  ["75/soft-glow"] = {width = 1066, height = 160, mode = legacyMode.Percent75, tag = "soft-glow"},
  ["wide/soft-glow-narrow"] = {width = 1066, height = 123, mode = legacyMode.Percent50, tag = "soft-glow"},

  ["200/slight"] = {width = 1000, height = 250, mode = legacyMode.Percent200, tag = "slight"},
  ["175/slight"] = {width = 1000, height = 219, mode = legacyMode.Percent175, tag = "slight"},
  ["150/slight"] = {width = 1000, height = 189, mode = legacyMode.Percent150, tag = "slight"},
  ["125/slight"] = {width = 1000, height = 157, mode = legacyMode.Percent125, tag = "slight"},
  ["100/slight"] = {width = 1000, height = 125, mode = legacyMode.Percent100, tag = "slight"},
  ["75/slight"] = {width = 1000, height = 94, mode = legacyMode.Percent75, tag = "slight"},
  ["50/slight"] = {width = 1000, height = 63, mode = legacyMode.Percent50, tag = "slight"},

  ["200/soft"] = {width = 1023, height = 274, mode = legacyMode.Percent200, tag = "soft"},
  ["175/soft"] = {width = 1023, height = 243, mode = legacyMode.Percent175, tag = "soft"},
  ["150/soft"] = {width = 1023, height = 213, mode = legacyMode.Percent150, tag = "soft"},
  ["125/soft"] = {width = 1023, height = 181, mode = legacyMode.Percent125, tag = "soft"},
  ["125/soft"] = {width = 1023, height = 149, mode = legacyMode.Percent100, tag = "soft"},
  ["75/soft"] = {width = 1023, height = 118, mode = legacyMode.Percent75, tag = "soft"},
  ["50/soft"] = {width = 1023, height = 88, mode = legacyMode.Percent50, tag = "soft"},

  ["200/blizzard-bold-health"] = {width = 1018, height = 270, mode = legacyMode.Percent200, tag = "blizzard-bold-health"},
  ["175/blizzard-bold-health"] = {width = 1018, height = 238, mode = legacyMode.Percent175, tag = "blizzard-bold-health"},
  ["150/blizzard-bold-health"] = {width = 1018, height = 208, mode = legacyMode.Percent150, tag = "blizzard-bold-health"},
  ["125/blizzard-bold-health"] = {width = 1018, height = 175, mode = legacyMode.Percent125, tag = "blizzard-bold-health"},
  ["100/blizzard-bold-health"] = {width = 1018, height = 145, mode = legacyMode.Percent100, tag = "blizzard-bold-health"},
  ["75/blizzard-bold-health"] = {width = 1000, height = 113, mode = legacyMode.Percent75, tag = "blizzard-bold-health"},
  ["50/blizzard-bold-health"] = {width = 1000, height = 83, mode = legacyMode.Percent50, tag = "blizzard-bold-health"},

  ["200/striped"] = {width = 1000, height = 250, mode = legacyMode.Percent200, tag = "striped"},
  ["175/striped"] = {width = 1000, height = 219, mode = legacyMode.Percent175, tag = "striped"},
  ["150/striped"] = {width = 1000, height = 189, mode = legacyMode.Percent150, tag = "striped"},
  ["125/striped"] = {width = 1000, height = 157, mode = legacyMode.Percent125, tag = "striped"},
  ["100/striped"] = {width = 1000, height = 125, mode = legacyMode.Percent100, tag = "striped"},
  ["75/striped"] = {width = 1000, height = 94, mode = legacyMode.Percent75, tag = "striped"},
  ["50/striped"] = {width = 1000, height = 63, mode = legacyMode.Percent50, tag = "striped"},

  ["200/striped-reverse"] = {width = 1000, height = 250, mode = legacyMode.Percent200, tag = "striped-reverse"},
  ["175/striped-reverse"] = {width = 1000, height = 219, mode = legacyMode.Percent175, tag = "striped-reverse"},
  ["150/striped-reverse"] = {width = 1000, height = 189, mode = legacyMode.Percent150, tag = "striped-reverse"},
  ["125/striped-reverse"] = {width = 1000, height = 157, mode = legacyMode.Percent125, tag = "striped-reverse"},
  ["100/striped-reverse"] = {width = 1000, height = 125, mode = legacyMode.Percent100, tag = "striped-reverse"},
  ["75/striped-reverse"] = {width = 1000, height = 94, mode = legacyMode.Percent75, tag = "striped-reverse"},
  ["50/striped-reverse"] = {width = 1000, height = 63, mode = legacyMode.Percent50, tag = "striped-reverse"},

  ["200/arrows-in"] = {width = 1000, height = 250, mode = legacyMode.Percent200, tag = "arrows-in"},
  ["175/arrows-in"] = {width = 1000, height = 219, mode = legacyMode.Percent175, tag = "arrows-in"},
  ["150/arrows-in"] = {width = 1000, height = 189, mode = legacyMode.Percent150, tag = "arrows-in"},
  ["125/arrows-in"] = {width = 1000, height = 157, mode = legacyMode.Percent125, tag = "arrows-in"},
  ["100/arrows-in"] = {width = 1000, height = 125, mode = legacyMode.Percent100, tag = "arrows-in"},
  ["75/arrows-in"] = {width = 1000, height = 94, mode = legacyMode.Percent75, tag = "arrows-in"},
  ["50/arrows-in"] = {width = 1000, height = 63, mode = legacyMode.Percent50, tag = "arrows-in"},

  ["200/arrows-out"] = {width = 1000, height = 250, mode = legacyMode.Percent200, tag = "arrows-out"},
  ["175/arrows-out"] = {width = 1000, height = 219, mode = legacyMode.Percent175, tag = "arrows-out"},
  ["150/arrows-out"] = {width = 1000, height = 189, mode = legacyMode.Percent150, tag = "arrows-out"},
  ["125/arrows-out"] = {width = 1000, height = 157, mode = legacyMode.Percent125, tag = "arrows-out"},
  ["100/arrows-out"] = {width = 1000, height = 125, mode = legacyMode.Percent100, tag = "arrows-out"},
  ["75/arrows-out"] = {width = 1000, height = 94, mode = legacyMode.Percent75, tag = "arrows-out"},
  ["50/arrows-out"] = {width = 1000, height = 63, mode = legacyMode.Percent50, tag = "arrows-out"},

  ["200/arrows-in-close"] = {width = 1000, height = 250, mode = legacyMode.Percent200, tag = "arrows-in-close"},
  ["175/arrows-in-close"] = {width = 1000, height = 219, mode = legacyMode.Percent175, tag = "arrows-in-close"},
  ["150/arrows-in-close"] = {width = 1000, height = 189, mode = legacyMode.Percent150, tag = "arrows-in-close"},
  ["125/arrows-in-close"] = {width = 1000, height = 157, mode = legacyMode.Percent125, tag = "arrows-in-close"},
  ["100/arrows-in-close"] = {width = 1000, height = 125, mode = legacyMode.Percent100, tag = "arrows-in-close"},
  ["75/arrows-in-close"] = {width = 1000, height = 94, mode = legacyMode.Percent75, tag = "arrows-in-close"},
  ["50/arrows-in-close"] = {width = 1000, height = 63, mode = legacyMode.Percent50, tag = "arrows-in-close"},

  ["200/arrows-out-close"] = {width = 1000, height = 250, mode = legacyMode.Percent200, tag = "arrows-out-close"},
  ["175/arrows-out-close"] = {width = 1000, height = 219, mode = legacyMode.Percent175, tag = "arrows-out-close"},
  ["150/arrows-out-close"] = {width = 1000, height = 189, mode = legacyMode.Percent150, tag = "arrows-out-close"},
  ["125/arrows-out-close"] = {width = 1000, height = 157, mode = legacyMode.Percent125, tag = "arrows-out-close"},
  ["100/arrows-out-close"] = {width = 1000, height = 125, mode = legacyMode.Percent100, tag = "arrows-out-close"},
  ["75/arrows-out-close"] = {width = 1000, height = 94, mode = legacyMode.Percent75, tag = "arrows-out-close"},
  ["50/arrows-out-close"] = {width = 1000, height = 63, mode = legacyMode.Percent50, tag = "arrows-out-close"},

  ["wide/arrows"] = {width = 1000, height = 125, mode = legacyMode.Percent100, tag = "arrows"},
  ["wide/double-arrows"] = {width = 1000, height = 125, mode = legacyMode.Percent100, tag = "arrows"},
  ["normal/double-arrows-down"] = {width = 173, height = 153, mode = legacyMode.Percent100, tag = "arrows"},
  ["normal/solid-arrows"] = {width = 1000, height = 125, mode = legacyMode.Percent100, tag = "arrows"},
  ["normal/solid-arrow-down"] = {width = 207, height = 132, mode = legacyMode.Percent100, tag = "arrows"},

  ["200/feathered"] = {width = 1000, height = 250, mode = legacyMode.Percent200, tag = "feathered"},
  ["175/feathered"] = {width = 1000, height = 219, mode = legacyMode.Percent175, tag = "feathered"},
  ["150/feathered"] = {width = 1000, height = 189, mode = legacyMode.Percent150, tag = "feathered"},
  ["125/feathered"] = {width = 1000, height = 157, mode = legacyMode.Percent125, tag = "feathered"},
  ["100/feathered"] = {width = 1000, height = 125, mode = legacyMode.Percent100, tag = "feathered"},
  ["75/feathered"] = {width = 1000, height = 94, mode = legacyMode.Percent75, tag = "feathered"},
  ["50/feathered"] = {width = 1000, height = 63, mode = legacyMode.Percent50, tag = "feathered"},

  ["100/classic-level"] = {width = 178, height = 125, mode = legacyMode.Percent100, tag = "blizzard-classic-level"},
}
ResizeAssets(addonTable.Assets.HighlightsLegacy)
