---@class addonTablePlatynator
local addonTable = select(2, ...)

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

addonTable.Assets.RenderMode = {
  Sliced = 1,
  Fixed = 2,
  Stretch = 3,
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
  ["transparent"] = {file = "Interface/AddOns/Platynator/Assets/Special/transparent.png", width = 1000, height = 125, isTransparent = true, group = 0, order = 0},
  ["black"] = {file = "Interface/AddOns/Platynator/Assets/Special/black.png", width = 1000, height = 125, group = 1, order = 1},
  ["grey"] = {file = "Interface/AddOns/Platynator/Assets/Special/grey.png", width = 1000, height = 125, group = 1, order = 2},
  ["grey-raid"] = {file = "Interface/AddOns/Platynator/Assets/Special/grey-raid.png", width = 1000, height = 125, group = 1, order = 3},
  ["white"] = {file = "Interface/AddOns/Platynator/Assets/Special/white.png", width = 1000, height = 125, group = 1, order = 4},

  ["wide/bevelled"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBackgrounds/bevelled.png", width = 1000, height = 125, has4k = true, group = 2, order = 1},
  ["wide/bevelled-grey"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBackgrounds/bevelled-grey.png", width = 1000, height = 125, has4k = true, group = 2, order = 2},

  ["wide/fade-bottom"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBackgrounds/fade-bottom.png", width = 1000, height = 125, has4k = true, group = 3, order = 1},
  ["wide/fade-top"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBackgrounds/fade-top.png", width = 1000, height = 125, has4k = true, group = 3, order = 2},
  ["wide/fade-left"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBackgrounds/fade-left.png", width = 1000, height = 125, has4k = true, group = 3, order = 3},
  ["wide/fade-right"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBackgrounds/fade-right.png", width = 1000, height = 125, has4k = true, group = 3, order = 4},

  ["gw2"] = {file = "Interface/AddOns/Platynator/Assets/Special/BarBackgrounds/gw2.png", width = 1000, height = 125, group = 4, order = 1},
  ["special/blizzard-cast-bar"] = {file = "Interface/AddOns/Platynator/Assets/Special/BarBackgrounds/blizzard-cast-bar.png", width = 1000, height = 125, group = 4, order = 2},

  ["wide/blizzard-absorb"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBackgrounds/blizzard-absorb.png", width = 1000, height = 125, has4k = true, group = 5, order = 1},
  ["narrow/blizzard-absorb"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBackgrounds/blizzard-absorb-narrow.png", width = 1000, height = 63, has4k = true, group = 5, order = 2},
}

addonTable.Assets.BarBordersSliced = {
  ["transparent"] = {file = "Interface/AddOns/Platynator/Assets/Special/transparent.png", width = 20, height = 20, isTransparent = true, masked = false, tag = "transparent", margin = 0.5, extra = 0, minSize = 1, modifier = 1, group = 0, order = 1},

  ["bold"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/bold-square.png", width = 20, height = 20, has4k = true, masked = true, tag = "bold", margin = 0.45, extra = 0, minSize = 50, modifier = 0.35, DPIScale = 1/2, group = 1, order = 1},
  ["slight"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/slight-square.png", width = 20, height = 20, has4k = true, masked = true, tag = "slight", margin = 0.3, extra = 0, minSize = 50, modifier = 0.35, DPIScale = 1/2, group = 1, order = 2},
  ["thin"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/thin-square.png", width = 20, height = 20, has4k = true, masked = true, tag = "thin", margin = 0.2, extra = 0, minSize = 50, modifier = 0.35, DPIScale = 1/2, group = 1, order = 4},
  ["1px"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/1px-square.png", width = 20, height = 20, has4k = true, masked = true, tag = "1px", margin = 0.3, extra = 0, minSize = 50, modifier = 0.35, DPIScale = 1/2, group = 1, order = 4},

  ["round-bold"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/round-square.png", width = 48, height = 48, has4k = true, masked = true, tag = "round-bold", margin = 0.48, extra = 0, minSize = 50, modifier = 0.3, DPIScale = 1/2, group = 2, order = 1},
  ["round-slight"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/round-slight-square.png", width = 48, height = 48, has4k = true, masked = true, tag = "round-slight", margin = 0.48, extra = 0, minSize = 50, modifier = 0.3, DPIScale = 1/2, group = 2, order = 2},
  ["round-thin"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/round-thin-square.png", width = 48, height = 48, has4k = true, masked = true, tag = "round-thin", margin = 0.48, extra = 0, minSize = 50, modifier = 0.3, DPIScale = 1/2, group = 2, order = 3},

  ["soft"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/soft-square.png", width = 66, height = 66, has4k = true, masked = true, tag = "soft", margin = 0.33, extra = 9, minSize = 50, modifier = 0.25, DPIScale = 4/6, group = 3, order = 1},
  ["gw2"] = {file = "Interface/AddOns/Platynator/Assets/Special/BarBorders/gw2.png", width = 33, height = 33, masked = false, tag = "gw2", margin = 0.3, extra = 12, minSize = 50, modifier = 1, group = 3, order = 2},

  ["blizzard-health"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-health-square.png", width = 48, height = 48, has4k = true, masked = true, tag = "blizzard-health", margin = 0.4, extra = 0, minSize = 100, modifier = 0.3, DPIScale = 1/2, group = 4, order = 1},
  ["blizzard-cast-bar"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-cast-bar-square.png", width = 48, height = 48, has4k = true, masked = true, tag = "blizzard-cast-bar", margin = 0.35, extra = 0, minSize = 50, modifier = 0.35, DPIScale = 1/2, group = 4, order = 2},
  ["blizzard-classic"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-classic-square.png", width = 48, height = 48, has4k = true, masked = true, tag = "blizzard-classic", margin = 0.4, extra = 0, minSize = 100, modifier = 0.3, DPIScale = 1/2, group = 4, order = 3},
}

addonTable.Assets.BarBordersSize = {
  width = 1000 / 8,
  height = 125 / 8,
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

addonTable.Assets.BarMasks = {
  ["bold"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/bold-square-mask.png", width = 20, height = 20, has4k = true, margin = 0.45},
  ["slight"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/slight-square-mask.png", width = 20, height = 20, has4k = true, margin = 0.3},
  ["thin"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/thin-square-mask.png", width = 20, height = 20, has4k = true, margin = 0.2},
  --["1px"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/1px-square-mask.png", width = 20, height = 20, has4k = true, margin = 0.3},

  ["round-bold"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/round-square-mask.png", width = 48, height = 48, has4k = true, margin = 0.48},
  ["round-slight"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/round-slight-square-mask.png", width = 48, height = 48, has4k = true, margin = 0.48},
  ["round-thin"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/round-thin-square-mask.png", width = 48, height = 48, has4k = true, margin = 0.48},

  ["soft"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/soft-square-mask.png", width = 48, height = 48, has4k = true, margin = 0.33},

  ["blizzard-health"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-health-square-mask.png", width = 48, height = 48, has4k = true, margin = 0.49},
  ["blizzard-classic"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-classic-square-mask.png", width = 48, height = 48, has4k = true, margin = 0.35},
  ["blizzard-cast-bar"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-cast-bar-square-mask.png", width = 48, height = 48, has4k = true, margin = 0.35},
}

addonTable.Assets.Highlights = {
  ["white"] = {file = "Interface/AddOns/Platynator/Assets/Special/white.png", width = 20, height = 20, mode = renderMode.Sliced, tag = "white", margin = 0.4, extra = 0, padding = 0, modifier = 1, minSize = 1, modifier = 1, group = 0, order = 1},

  ["bold"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/bold-square.png", width = 20, height = 20, has4k = true, masked = true, tag = "bold", margin = 0.45, extra = 0, minSize = 50, modifier = 0.35, DPIScale = 1/2, mode = renderMode.Sliced, group = 1, order = 1},
  ["slight"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/slight-square.png", width = 20, height = 20, has4k = true, masked = true, tag = "slight", margin = 0.3, extra = 0, minSize = 50, modifier = 0.35, DPIScale = 1/2, mode = renderMode.Sliced, group = 1, order = 2},
  ["thin"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/thin-square.png", width = 20, height = 20, has4k = true, masked = true, tag = "thin", margin = 0.2, extra = 0, minSize = 50, modifier = 0.35, DPIScale = 1/2, mode = renderMode.Sliced, group = 1, order = 3},
  ["1px"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/1px-square.png", width = 20, height = 20, has4k = true, masked = true, tag = "1px", margin = 0.3, extra = 0, minSize = 50, modifier = 0.35, DPIScale = 1/2, mode = renderMode.Sliced, group = 1, order = 4},

  ["round-bold"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/round-square.png", width = 48, height = 48, has4k = true, masked = true, tag = "round-bold", margin = 0.48, extra = 0, minSize = 50, modifier = 0.3, DPIScale = 1/2, mode = renderMode.Sliced, group = 2, order = 1},
  ["round-slight"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/round-slight-square.png", width = 48, height = 48, has4k = true, masked = true, tag = "round-slight", margin = 0.48, extra = 0, minSize = 50, modifier = 0.3, DPIScale = 1/2, mode = renderMode.Sliced, group = 2, order = 2},
  ["round-thin"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/round-thin-square.png", width = 48, height = 48, has4k = true, masked = true, tag = "round-thin", margin = 0.48, extra = 0, minSize = 50, modifier = 0.3, DPIScale = 1/2, mode = renderMode.Sliced, group = 2, order = 3},

  ["soft"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/soft-square.png", width = 66, height = 66, has4k = true, masked = true, tag = "soft", margin = 0.33, extra = 9, minSize = 50, modifier = 0.25, DPIScale = 4/6, mode = renderMode.Sliced, group = 3, order = 1},
  ["gw2"] = {file = "Interface/AddOns/Platynator/Assets/Special/BarBorders/gw2.png", width = 33, height = 33, masked = false, tag = "gw2", margin = 0.3, extra = 8, minSize = 50, modifier = 1, mode = renderMode.Sliced, group = 3, order = 2},

  ["blizzard-health"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-health-square.png", width = 48, height = 48, has4k = true, masked = true, tag = "blizzard-health", margin = 0.4, extra = 0, minSize = 100, modifier = 0.3, DPIScale = 1/2, mode = renderMode.Sliced, group = 4, order = 1},
  ["blizzard-bold-health"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/blizzard-health-bold-square.png", width = 48, height = 48, has4k = true, masked = true, tag = "blizzard-bold-health", margin = 0.4, extra = 0, minSize = 100, modifier = 0.3, DPIScale = 1/2, mode = renderMode.Sliced, group = 4, order = 2},
  ["blizzard-cast-bar"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-cast-bar-square.png", width = 48, height = 48, has4k = true, masked = true, tag = "blizzard-cast-bar", margin = 0.35, extra = 0, minSize = 50, modifier = 0.35, DPIScale = 1/2, mode = renderMode.Sliced, group = 4, order = 3},
  ["blizzard-classic"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-classic-square.png", width = 48, height = 48, has4k = true, masked = true, tag = "blizzard-classic", margin = 0.4, extra = 0, minSize = 100, modifier = 0.3, DPIScale = 1/2, mode = renderMode.Sliced, group = 4, order = 4},

  ["soft-glow"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/soft-glow-square.png", width = 59, height = 59, has4k = true, masked = true, tag = "soft", margin = 0.4, extra = 11, padding = 0, minSize = 50, modifier = 0.3, DPIScale = 1/2, mode = renderMode.Sliced, group = 5, order = 1},
  ["feathered"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/feathered-square.png", width = 60, height = 60, has4k = true, masked = true, tag = "soft", margin = 0.48, extra = 0, padding = 0, minSize = 50, modifier = 0.25, DPIScale = 1/2, mode = renderMode.Sliced, group = 5, order = 2},

  ["glow"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/glow-100.png", width = 1563, height = 680, has4k = true, mode = renderMode.Stretch, tag = "glow", group = 6, order = 1},

  ["striped"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/striped.png", width = 1000, height = 125, has4k = true, mode = renderMode.Stretch, tag = "striped", group = 7, order = 1},
  ["striped-reverse"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/striped-reverse.png", width = 1000, height = 125, has4k = true, mode = renderMode.Stretch, tag = "striped-reverse", group = 7, order = 2},

  ["arrows-in"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/arrows-in.png", width = 1000, height = 125, has4k = true, mode = renderMode.Stretch, tag = "arrows-in", group = 8, order = 1},
  ["arrows-out"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/arrows-out.png", width = 1000, height = 125, has4k = true, mode = renderMode.Stretch, tag = "arrows-out", group = 8, order = 2},
  ["arrows-in-close"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/arrows-in-close.png", width = 1000, height = 125, has4k = true, mode = renderMode.Stretch, tag = "arrows-in-close", group = 8, order = 3},
  ["arrows-out-close"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/arrows-out-close.png", width = 1000, height = 125, has4k = true, mode = renderMode.Stretch, tag = "arrows-out-close", group = 8, order = 4},

  ["arrows"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/arrows.png", width = 86, height = 66, has4k = true, margin = 0.5, extra = 0, padding = 0, modifier = 0.29, shiftModifierH = 1.23, shiftModifierV = 1.22, DPIScale = 8/10, mode = renderMode.Sliced, tag = "arrows", group = 9, order = 1},
  ["double-arrows"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/double-arrows.png", width = 149, height = 69, has4k = true, margin = 0.5, extra = 0, padding = 0, modifier = 0.31, shiftModifierH = 1.36, shiftModifierV = 1.36, DPIScale = 8/10, mode = renderMode.Sliced, tag = "arrows", group = 9, order = 2},
  ["double-arrows-down"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/double-arrows-down.png", width = 173, height = 153, has4k = true, mode = renderMode.Fixed, tag = "arrows", group = 9, order = 3},
  ["solid-arrows"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/arrows-solid.png", width = 97, height = 69, has4k = true, margin = 0.5, extra = 0, padding = 0, modifier = 0.30, shiftModifierH = 1.27, shiftModifierV = 1.36, DPIScale = 8/10, mode = renderMode.Sliced, tag = "arrows", group = 9, order = 4},
  ["solid-arrow-down"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/arrow-solid-down.png", width = 207, height = 132, has4k = true, mode = renderMode.Fixed, tag = "arrows", group = 9, order = 5},

  ["blizzard-classic-level"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/blizzard-classic-level.png", width = 178, height = 125, has4k = true, mode = renderMode.Fixed, tag = "blizzard-classic-level", group = 10, order = 1},
}

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

addonTable.Assets.BarPositionHighlights = {
  ["none"] = {file = "", width = 0, height = 0},
  ["wide/glow"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarPosition/highlight.png", width = 54, height = 125, has4k = true, mode = legacyMode.Percent100},
  ["gw2"] = {file = "Interface/AddOns/Platynator/Assets/Special/BarPosition/gw2.png", width = 137, height = 125, mode = legacyMode.Percent100},
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

  local function Iterate(list)
    dpiScale = dpiScale or 1
    for _, entry in pairs(list) do
      if entry.has4k then
        entry.file = entry.file:format(DPIScale)
      end
      entry.width = entry.width / 8
      entry.height = entry.height / 8
    end
  end

  local function IterateSlices(list, rootTable)
    local order = 0
    for key, entry in pairs(list) do
      if entry.has4k then
        local root = rootTable[key]
        entry.file = entry.file:format(DPIScale)
        local scale = root.DPIScale
        if DPIScale == "DPI144" then
          scale = 1
        end
        entry.width = entry.width * scale
        entry.height = entry.height * scale
        entry.lowerScale = 1 * scale / root.modifier
      else
        entry.lowerScale = 1 / rootTable[key].modifier
      end
    end
  end

  local function IterateHighlights(list)
    local slices = {}
    local normal = {}
    for key, entry in pairs(list) do
      if entry.mode == renderMode.Sliced then
        slices[key] = entry
        if entry.shiftModifierH == nil then
          entry.shiftModifierH = 1
          entry.shiftModifierV = 1
        end
      else
        normal[key] = entry
      end
    end

    Iterate(normal)
    IterateSlices(slices, addonTable.Assets.Highlights)
  end

  local lowerScale = 1
  if DPIScale == "DPI96" then
    lowerScale = 2
  end
  IterateSlices(addonTable.Assets.BarBordersSliced, addonTable.Assets.BarBordersSliced)
  Iterate(addonTable.Assets.BarBackgrounds)
  IterateSlices(addonTable.Assets.BarMasks, addonTable.Assets.BarBordersSliced)
  IterateHighlights(addonTable.Assets.Highlights)
  Iterate(addonTable.Assets.HighlightsLegacy)
  Iterate(addonTable.Assets.BarPositionHighlights)
  Iterate(addonTable.Assets.PowerBars)
  Iterate(addonTable.Assets.Markers)
end
