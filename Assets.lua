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

local mode = addonTable.Assets.Mode

local LSM = LibStub("LibSharedMedia-3.0")
LSM:Register(LSM.MediaType.FONT, addonTable.Constants.DefaultFont, "Interface/AddOns/Platynator/Assets/Fonts/RobotoCondensed-Bold.ttf")
LSM:Register(LSM.MediaType.FONT, "Lato", "Interface/AddOns/Platynator/Assets/Fonts/Lato-Regular.ttf")
LSM:Register(LSM.MediaType.FONT, "Poppins SemiBold", "Interface/AddOns/Platynator/Assets/Fonts/Poppins-SemiBold.ttf")
LSM:Register(LSM.MediaType.FONT, "Diablo Heavy", "Interface/AddOns/Platynator/Assets/Fonts/DiabloHeavy.ttf")
LSM:Register(LSM.MediaType.FONT, "Atkinson Hyperlegible Next", "Interface/AddOns/Platynator/Assets/Fonts/AtkinsonHyperlegibleNext-Regular.otf")

addonTable.Assets.BarBackgrounds = {
  ["transparent"] = {file = "Interface/AddOns/Platynator/Assets/Special/transparent.png", width = 1000, height = 125, isTransparent = true},
  ["grey"] = {file = "Interface/AddOns/Platynator/Assets/Special/grey.png", width = 1000, height = 125},
  ["black"] = {file = "Interface/AddOns/Platynator/Assets/Special/black.png", width = 1000, height = 125},
  ["white"] = {file = "Interface/AddOns/Platynator/Assets/Special/white.png", width = 1000, height = 125},
  ["wide/bevelled"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBackgrounds/bevelled.png", width = 1000, height = 125, has4k = true, mode = mode.Percent100},
  ["wide/bevelled-grey"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBackgrounds/bevelled-grey.png", width = 1000, height = 125, has4k = true, mode = mode.Percent100},
  ["wide/fade-bottom"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBackgrounds/fade-bottom.png", width = 1000, height = 125, has4k = true, mode = mode.Percent100},
  ["wide/fade-top"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBackgrounds/fade-top.png", width = 1000, height = 125, has4k = true, mode = mode.Percent100},
  ["wide/fade-left"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBackgrounds/fade-left.png", width = 1000, height = 125, has4k = true, mode = mode.Percent100},
  ["special/blizzard-cast-bar"] = {file = "Interface/AddOns/Platynator/Assets/Special/BarBackgrounds/blizzard-cast-bar.png", width = 1000, height = 125, mode = mode.Percent100},
  ["wide/blizzard-absorb"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBackgrounds/blizzard-absorb.png", width = 1000, height = 125, has4k = true, mode = mode.Percent100},
  ["narrow/blizzard-absorb"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBackgrounds/blizzard-absorb-narrow.png", width = 1000, height = 63, has4k = true, mode = mode.Percent50},
}

addonTable.Assets.BarBorders = {
  ["tall/transparent"] = {file = "Interface/AddOns/Platynator/Assets/Special/transparent.png", width = 1000, height = 250, mode = mode.Percent200, isTransparent = true, tag = "transparent"},
  ["175/transparent"] = {file = "Interface/AddOns/Platynator/Assets/Special/transparent.png", width = 1000, height = 219, mode = mode.Percent175, isTransparent = true, tag = "transparent"},
  ["150/transparent"] = {file = "Interface/AddOns/Platynator/Assets/Special/transparent.png", width = 1000, height = 189, mode = mode.Percent150, isTransparent = true, tag = "transparent"},
  ["125/transparent"] = {file = "Interface/AddOns/Platynator/Assets/Special/transparent.png", width = 1000, height = 157, mode = mode.Percent125, isTransparent = true, tag = "transparent"},
  ["wide/transparent"] = {file = "Interface/AddOns/Platynator/Assets/Special/transparent.png", width = 1000, height = 125, mode = mode.Percent100, isTransparent = true, tag = "transparent"},
  ["75/transparent"] = {file = "Interface/AddOns/Platynator/Assets/Special/transparent.png", width = 1000, height = 94, mode = mode.Percent75, isTransparent = true, tag = "transparent"},
  ["narrow/transparent"] = {file = "Interface/AddOns/Platynator/Assets/Special/transparent.png", width = 1000, height = 63, mode = mode.Percent50, isTransparent = true, tag = "transparent"},

  ["200/blizzard-health"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-health-200.png", width = 1021, height = 288, has4k = true, masked = true, mode = mode.Percent200, tag = "blizzard-health"},
  ["175/blizzard-health"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-health-175.png", width = 1021, height = 255, has4k = true, masked = true, mode = mode.Percent175, tag = "blizzard-health"},
  ["150/blizzard-health"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-health-150.png", width = 1021, height = 225, has4k = true, masked = true, mode = mode.Percent150, tag = "blizzard-health"},
  ["125/blizzard-health"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-health-125.png", width = 1021, height = 195, has4k = true, masked = true, mode = mode.Percent125, tag = "blizzard-health"},
  ["wide/blizzard-health"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-health-100.png", width = 1021, height = 163, has4k = true, masked = true, mode = mode.Percent100, tag = "blizzard-health"},
  ["75/blizzard-health"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-health-75.png", width = 1021, height = 133, has4k = true, masked = true, mode = mode.Percent75, tag = "blizzard-health"},
  ["narrow/blizzard-health"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-health-50.png", width = 1021, height = 100, has4k = true, masked = true, mode = mode.Percent50, tag = "blizzard-health"},

  ["wide/blizzard-classic"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-classic.png", width = 1000, height = 125, has4k = true, masked = true, mode = mode.Percent100, tag = "blizzard-classic"},
  ["wide/blizzard-classic-level"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-classic-full.png", width = 1338, height = 125, has4k = true, masked = true, mode = mode.Percent100, tag = "blizzard-classic-level"},

  ["wide/bold"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/bold.png", width = 1000, height = 125, has4k = true, masked = true, mode = mode.Percent100, tag = "bold"},

  ["tall/soft"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/soft-200.png", width = 1023, height = 274, has4k = true, masked = true, mode = mode.Percent200, tag = "soft"},
  ["175/soft"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/soft-175.png", width = 1023, height = 243, has4k = true, masked = true, mode = mode.Percent175, tag = "soft"},
  ["150/soft"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/soft-150.png", width = 1023, height = 213, has4k = true, masked = true, mode = mode.Percent150, tag = "soft"},
  ["125/soft"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/soft-125.png", width = 1023, height = 181, has4k = true, masked = true, mode = mode.Percent125, tag = "soft"},
  ["wide/soft"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/soft-100.png", width = 1023, height = 149, has4k = true, masked = true, mode = mode.Percent100, tag = "soft"},
  ["75/soft"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/soft-75.png", width = 1023, height = 118, has4k = true, masked = true, mode = mode.Percent75, tag = "soft"},
  ["narrow/soft"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/soft-50.png", width = 1023, height = 88, has4k = true, masked = true, mode = mode.Percent50, tag = "soft"},

  ["200/slight"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/slight-200.png", width = 1000, height = 250, has4k = true, masked = true, mode = mode.Percent200, tag = "slight"},
  ["175/slight"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/slight-175.png", width = 1000, height = 219, has4k = true, masked = true, mode = mode.Percent175, tag = "slight"},
  ["150/slight"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/slight-150.png", width = 1000, height = 189, has4k = true, masked = true, mode = mode.Percent150, tag = "slight"},
  ["125/slight"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/slight-125.png", width = 1000, height = 157, has4k = true, masked = true, mode = mode.Percent125, tag = "slight"},
  ["wide/slight"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/slight-100.png", width = 1000, height = 125, has4k = true, masked = true, mode = mode.Percent100, tag = "slight"},
  ["75/slight"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/slight-75.png", width = 1000, height = 94, has4k = true, masked = true, mode = mode.Percent75, tag = "slight"},
  ["narrow/slight"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/slight-50.png", width = 1000, height = 63, has4k = true, masked = true, mode = mode.Percent50, tag = "slight"},

  ["200/thin"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/thin-200.png", width = 1000, height = 250, has4k = true, masked = true, mode = mode.Percent200, tag = "thin"},
  ["175/thin"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/thin-175.png", width = 1000, height = 219, has4k = true, masked = true, mode = mode.Percent175, tag = "thin"},
  ["150/thin"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/thin-150.png", width = 1000, height = 189, has4k = true, masked = true, mode = mode.Percent150, tag = "thin"},
  ["125/thin"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/thin-125.png", width = 1000, height = 157, has4k = true, masked = true, mode = mode.Percent125, tag = "thin"},
  ["wide/thin"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/thin-100.png", width = 1000, height = 125, has4k = true, masked = true, mode = mode.Percent100, tag = "thin"},
  ["75/thin"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/thin-75.png", width = 1000, height = 94, has4k = true, masked = true, mode = mode.Percent75, tag = "thin"},
  ["narrow/thin"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/thin-50.png", width = 1000, height = 63, has4k = true, masked = true, mode = mode.Percent50, tag = "thin"},

  ["200/blizzard-cast-bar-white"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-cast-bar-200.png", width = 1000, height = 250, has4k = true, masked = true, mode = mode.Percent200, tag = "blizzard-cast-bar"},
  ["175/blizzard-cast-bar-white"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-cast-bar-175.png", width = 1000, height = 219, has4k = true, masked = true, mode = mode.Percent175, tag = "blizzard-cast-bar"},
  ["150/blizzard-cast-bar-white"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-cast-bar-150.png", width = 1000, height = 189, has4k = true, masked = true, mode = mode.Percent150, tag = "blizzard-cast-bar"},
  ["125/blizzard-cast-bar-white"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-cast-bar-125.png", width = 1000, height = 157, has4k = true, masked = true, mode = mode.Percent125, tag = "blizzard-cast-bar"},
  ["100/blizzard-cast-bar-white"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-cast-bar-100.png", width = 1000, height = 125, has4k = true, masked = true, mode = mode.Percent100, tag = "blizzard-cast-bar"},
  ["75/blizzard-cast-bar-white"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-cast-bar-75.png", width = 1000, height = 94, has4k = true, masked = true, mode = mode.Percent75, tag = "blizzard-cast-bar"},
  ["50/blizzard-cast-bar-white"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-cast-bar-50.png", width = 1000, height = 63, has4k = true, masked = true, mode = mode.Percent50, tag = "blizzard-cast-bar"},
}

addonTable.Assets.BarMasks = {
  ["200/blizzard-health"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-health-200-mask.png", width = 1000, height = 250, has4k = true, mode = mode.Percent200},
  ["175/blizzard-health"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-health-175-mask.png", width = 1000, height = 219, has4k = true, mode = mode.Percent175},
  ["150/blizzard-health"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-health-150-mask.png", width = 1000, height = 189, has4k = true, mode = mode.Percent150},
  ["125/blizzard-health"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-health-125-mask.png", width = 1000, height = 157, has4k = true, mode = mode.Percent125},
  ["wide/blizzard-health"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-health-100-mask.png", width = 1000, height = 125, has4k = true, mode = mode.Percent100},
  ["75/blizzard-health"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-health-75-mask.png", width = 1000, height = 94, has4k = true, mode = mode.Percent75},
  ["narrow/blizzard-health"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-health-50-mask.png", width = 1000, height = 63, has4k = true, mode = mode.Percent50},

  ["wide/blizzard-classic"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-classic-mask.png", width = 1000, height = 125, has4k = true, mode = mode.Percent100},
  ["wide/blizzard-classic-level"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-classic-full-mask.png", width = 1338, height = 125, has4k = true, mode = mode.Percent100},

  ["wide/bold"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/bold-mask.png", width = 1000, height = 125, has4k = true, mode = mode.Percent100},

  ["tall/soft"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/soft-200-mask.png", width = 1000, height = 250, has4k = true, mode = mode.Percent200},
  ["175/soft"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/soft-200-mask.png", width = 1000, height = 219, has4k = true, mode = mode.Percent175},
  ["150/soft"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/soft-200-mask.png", width = 1000, height = 189, has4k = true, mode = mode.Percent150},
  ["125/soft"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/soft-200-mask.png", width = 1000, height = 157, has4k = true, mode = mode.Percent125},
  ["wide/soft"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/soft-100-mask.png", width = 1000, height = 125, has4k = true, mode = mode.Percent100},
  ["75/soft"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/soft-75-mask.png", width = 1000, height = 94, has4k = true, mode = mode.Percent75},
  ["narrow/soft"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/soft-50-mask.png", width = 1000, height = 63, has4k = true, mode = mode.Percent50},

  ["200/slight"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/slight-200-mask.png", width = 1000, height = 250, has4k = true, mode = mode.Percent200},
  ["175/slight"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/slight-175-mask.png", width = 1000, height = 219, has4k = true, mode = mode.Percent175},
  ["150/slight"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/slight-150-mask.png", width = 1000, height = 189, has4k = true, mode = mode.Percent150},
  ["125/slight"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/slight-125-mask.png", width = 1000, height = 157, has4k = true, mode = mode.Percent125},
  ["wide/slight"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/slight-100-mask.png", width = 1000, height = 125, has4k = true, mode = mode.Percent100},
  ["75/slight"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/slight-75-mask.png", width = 1000, height = 94, has4k = true, mode = mode.Percent75},
  ["narrow/slight"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/slight-50-mask.png", width = 1000, height = 63, has4k = true, mode = mode.Percent50},

  ["200/thin"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/thin-200-mask.png", width = 1000, height = 250, has4k = true, mode = mode.Percent200},
  ["175/thin"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/thin-175-mask.png", width = 1000, height = 219, has4k = true, mode = mode.Percent175},
  ["150/thin"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/thin-150-mask.png", width = 1000, height = 189, has4k = true, mode = mode.Percent150},
  ["125/thin"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/thin-125-mask.png", width = 1000, height = 157, has4k = true, mode = mode.Percent125},
  ["wide/thin"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/thin-100-mask.png", width = 1000, height = 125, has4k = true, mode = mode.Percent100},
  ["75/thin"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/thin-75-mask.png", width = 1000, height = 94, has4k = true, mode = mode.Percent50},
  ["narrow/thin"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/thin-50-mask.png", width = 1000, height = 63, has4k = true, mode = mode.Percent50},


  ["200/blizzard-cast-bar-white"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-cast-bar-200-mask.png", width = 1000, height = 250, has4k = true, mode = mode.Percent200},
  ["175/blizzard-cast-bar-white"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-cast-bar-175-mask.png", width = 1000, height = 219, has4k = true, mode = mode.Percent175},
  ["150/blizzard-cast-bar-white"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-cast-bar-150-mask.png", width = 1000, height = 189, has4k = true, mode = mode.Percent150},
  ["125/blizzard-cast-bar-white"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-cast-bar-125-mask.png", width = 1000, height = 157, has4k = true, mode = mode.Percent125},
  ["100/blizzard-cast-bar-white"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-cast-bar-100-mask.png", width = 1000, height = 125, has4k = true, mode = mode.Percent100},
  ["75/blizzard-cast-bar-white"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-cast-bar-75-mask.png", width = 1000, height = 94, has4k = true, mode = mode.Percent50},
  ["50/blizzard-cast-bar-white"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-cast-bar-50-mask.png", width = 1000, height = 63, has4k = true, mode = mode.Percent50},
}

addonTable.Assets.Highlights = {
  ["200/outline"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/outline-200.png", width = 1030, height = 280, has4k = true, mode = mode.Percent200, tag = "outline"},
  ["175/outline"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/outline-175.png", width = 1030, height = 249, has4k = true, mode = mode.Percent175, tag = "outline"},
  ["150/outline"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/outline-150.png", width = 1030, height = 218, has4k = true, mode = mode.Percent150, tag = "outline"},
  ["125/outline"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/outline-125.png", width = 1030, height = 186, has4k = true, mode = mode.Percent125, tag = "outline"},
  ["wide/outline"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/outline-100.png", width = 1030, height = 155, has4k = true, mode = mode.Percent100, tag = "outline"},
  ["wide/outline"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/outline-100.png", width = 1030, height = 155, has4k = true, mode = mode.Percent100, tag = "outline"},
  ["75/outline"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/outline-75.png", width = 1030, height = 125, has4k = true, mode = mode.Percent75, tag = "outline"},
  ["wide/outline-narrow"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/outline-50.png", width = 1030, height = 93, has4k = true, mode = mode.Percent50, tag = "outline"},

  ["200/glow"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/glow-100.png", width = 1588, height = 870, has4k = true, mode = mode.Percent200, tag = "glow"},
  ["175/glow"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/glow-175.png", width = 1588, height = 763, has4k = true, mode = mode.Percent175, tag = "glow"},
  ["150/glow"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/glow-150.png", width = 1588, height = 735, has4k = true, mode = mode.Percent150, tag = "glow"},
  ["125/glow"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/glow-125.png", width = 1588, height = 692, has4k = true, mode = mode.Percent125, tag = "glow"},
  ["wide/glow"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/glow-100.png", width = 1563, height = 680, has4k = true, mode = mode.Percent100, tag = "glow"},
  ["75/glow"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/glow-75.png", width = 1585, height = 628, has4k = true, mode = mode.Percent75, tag = "glow"},
  ["50/glow"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/glow-50.png", width = 1610, height = 578, has4k = true, mode = mode.Percent50, tag = "glow"},

  ["tall/soft-glow"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/soft-glow-200.png", width = 1066, height = 324, has4k = true, mode = mode.Percent200, tag = "soft-glow"},
  ["175/soft-glow"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/soft-glow-175.png", width = 1066, height = 287, has4k = true, mode = mode.Percent175, tag = "soft-glow"},
  ["150/soft-glow"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/soft-glow-150.png", width = 1066, height = 257, has4k = true, mode = mode.Percent150, tag = "soft-glow"},
  ["125/soft-glow"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/soft-glow-125.png", width = 1066, height = 225, has4k = true, mode = mode.Percent125, tag = "soft-glow"},
  ["wide/soft-glow"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/soft-glow-100.png", width = 1066, height = 193, has4k = true, mode = mode.Percent100, tag = "soft-glow"},
  ["75/soft-glow"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/soft-glow-75.png", width = 1066, height = 160, has4k = true, mode = mode.Percent75, tag = "soft-glow"},
  ["wide/soft-glow-narrow"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/soft-glow-50.png", width = 1066, height = 123, has4k = true, mode = mode.Percent50, tag = "soft-glow"},

  ["200/slight"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/slight-200.png", width = 1000, height = 250, has4k = true, masked = true, mode = mode.Percent200, tag = "slight"},
  ["175/slight"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/slight-175.png", width = 1000, height = 219, has4k = true, masked = true, mode = mode.Percent175, tag = "slight"},
  ["150/slight"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/slight-150.png", width = 1000, height = 189, has4k = true, masked = true, mode = mode.Percent150, tag = "slight"},
  ["125/slight"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/slight-125.png", width = 1000, height = 157, has4k = true, masked = true, mode = mode.Percent125, tag = "slight"},
  ["100/slight"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/slight-100.png", width = 1000, height = 125, has4k = true, masked = true, mode = mode.Percent100, tag = "slight"},
  ["75/slight"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/slight-75.png", width = 1000, height = 94, has4k = true, masked = true, mode = mode.Percent75, tag = "slight"},
  ["50/slight"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/slight-50.png", width = 1000, height = 63, has4k = true, masked = true, mode = mode.Percent50, tag = "slight"},

  ["200/soft"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/soft-200.png", width = 1023, height = 274, has4k = true, masked = true, mode = mode.Percent200, tag = "soft"},
  ["175/soft"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/soft-175.png", width = 1023, height = 243, has4k = true, masked = true, mode = mode.Percent175, tag = "soft"},
  ["150/soft"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/soft-150.png", width = 1023, height = 213, has4k = true, masked = true, mode = mode.Percent150, tag = "soft"},
  ["125/soft"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/soft-125.png", width = 1023, height = 181, has4k = true, masked = true, mode = mode.Percent125, tag = "soft"},
  ["125/soft"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/soft-100.png", width = 1023, height = 149, has4k = true, masked = true, mode = mode.Percent100, tag = "soft"},
  ["75/soft"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/soft-75.png", width = 1023, height = 118, has4k = true, masked = true, mode = mode.Percent75, tag = "soft"},
  ["50/soft"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/soft-50.png", width = 1023, height = 88, has4k = true, masked = true, mode = mode.Percent50, tag = "soft"},

  ["200/blizzard-bold-health"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/blizzard-bold-health-200.png", width = 1018, height = 270, has4k = true, masked = true, mode = mode.Percent200, tag = "blizzard-bold-health"},
  ["175/blizzard-bold-health"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/blizzard-bold-health-175.png", width = 1018, height = 238, has4k = true, masked = true, mode = mode.Percent175, tag = "blizzard-bold-health"},
  ["150/blizzard-bold-health"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/blizzard-bold-health-150.png", width = 1018, height = 208, has4k = true, masked = true, mode = mode.Percent150, tag = "blizzard-bold-health"},
  ["125/blizzard-bold-health"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/blizzard-bold-health-125.png", width = 1018, height = 175, has4k = true, masked = true, mode = mode.Percent125, tag = "blizzard-bold-health"},
  ["100/blizzard-bold-health"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/blizzard-bold-health-100.png", width = 1018, height = 145, has4k = true, masked = true, mode = mode.Percent100, tag = "blizzard-bold-health"},
  ["75/blizzard-bold-health"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/blizzard-bold-health-75.png", width = 1000, height = 113, has4k = true, masked = true, mode = mode.Percent75, tag = "blizzard-bold-health"},
  ["50/blizzard-bold-health"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/blizzard-bold-health-50.png", width = 1000, height = 83, has4k = true, masked = true, mode = mode.Percent50, tag = "blizzard-bold-health"},

  ["200/striped"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/striped.png", width = 1000, height = 250, has4k = true, masked = true, mode = mode.Percent200, tag = "striped"},
  ["175/striped"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/striped.png", width = 1000, height = 219, has4k = true, masked = true, mode = mode.Percent175, tag = "striped"},
  ["150/striped"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/striped.png", width = 1000, height = 189, has4k = true, masked = true, mode = mode.Percent150, tag = "striped"},
  ["125/striped"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/striped.png", width = 1000, height = 157, has4k = true, masked = true, mode = mode.Percent125, tag = "striped"},
  ["100/striped"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/striped.png", width = 1000, height = 125, has4k = true, masked = true, mode = mode.Percent100, tag = "striped"},
  ["75/striped"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/striped.png", width = 1000, height = 94, has4k = true, masked = true, mode = mode.Percent75, tag = "striped"},
  ["50/striped"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/striped.png", width = 1000, height = 63, has4k = true, masked = true, mode = mode.Percent50, tag = "striped"},

  ["200/striped-reverse"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/striped-reverse.png", width = 1000, height = 250, has4k = true, masked = true, mode = mode.Percent200, tag = "striped-reverse"},
  ["175/striped-reverse"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/striped-reverse.png", width = 1000, height = 219, has4k = true, masked = true, mode = mode.Percent175, tag = "striped-reverse"},
  ["150/striped-reverse"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/striped-reverse.png", width = 1000, height = 189, has4k = true, masked = true, mode = mode.Percent150, tag = "striped-reverse"},
  ["125/striped-reverse"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/striped-reverse.png", width = 1000, height = 157, has4k = true, masked = true, mode = mode.Percent125, tag = "striped-reverse"},
  ["100/striped-reverse"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/striped-reverse.png", width = 1000, height = 125, has4k = true, masked = true, mode = mode.Percent100, tag = "striped-reverse"},
  ["75/striped-reverse"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/striped-reverse.png", width = 1000, height = 94, has4k = true, masked = true, mode = mode.Percent75, tag = "striped-reverse"},
  ["50/striped-reverse"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/striped-reverse.png", width = 1000, height = 63, has4k = true, masked = true, mode = mode.Percent50, tag = "striped-reverse"},

  ["200/arrows-in"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/arrows-in.png", width = 1000, height = 250, has4k = true, masked = true, mode = mode.Percent200, tag = "arrows-in"},
  ["175/arrows-in"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/arrows-in.png", width = 1000, height = 219, has4k = true, masked = true, mode = mode.Percent175, tag = "arrows-in"},
  ["150/arrows-in"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/arrows-in.png", width = 1000, height = 189, has4k = true, masked = true, mode = mode.Percent150, tag = "arrows-in"},
  ["125/arrows-in"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/arrows-in.png", width = 1000, height = 157, has4k = true, masked = true, mode = mode.Percent125, tag = "arrows-in"},
  ["100/arrows-in"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/arrows-in.png", width = 1000, height = 125, has4k = true, masked = true, mode = mode.Percent100, tag = "arrows-in"},
  ["75/arrows-in"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/arrows-in.png", width = 1000, height = 94, has4k = true, masked = true, mode = mode.Percent75, tag = "arrows-in"},
  ["50/arrows-in"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/arrows-in.png", width = 1000, height = 63, has4k = true, masked = true, mode = mode.Percent50, tag = "arrows-in"},

  ["200/arrows-out"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/arrows-out.png", width = 1000, height = 250, has4k = true, masked = true, mode = mode.Percent200, tag = "arrows-out"},
  ["175/arrows-out"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/arrows-out.png", width = 1000, height = 219, has4k = true, masked = true, mode = mode.Percent175, tag = "arrows-out"},
  ["150/arrows-out"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/arrows-out.png", width = 1000, height = 189, has4k = true, masked = true, mode = mode.Percent150, tag = "arrows-out"},
  ["125/arrows-out"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/arrows-out.png", width = 1000, height = 157, has4k = true, masked = true, mode = mode.Percent125, tag = "arrows-out"},
  ["100/arrows-out"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/arrows-out.png", width = 1000, height = 125, has4k = true, masked = true, mode = mode.Percent100, tag = "arrows-out"},
  ["75/arrows-out"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/arrows-out.png", width = 1000, height = 94, has4k = true, masked = true, mode = mode.Percent75, tag = "arrows-out"},
  ["50/arrows-out"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/arrows-out.png", width = 1000, height = 63, has4k = true, masked = true, mode = mode.Percent50, tag = "arrows-out"},

  ["200/arrows-in-close"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/arrows-in-close.png", width = 1000, height = 250, has4k = true, masked = true, mode = mode.Percent200, tag = "arrows-in-close"},
  ["175/arrows-in-close"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/arrows-in-close.png", width = 1000, height = 219, has4k = true, masked = true, mode = mode.Percent175, tag = "arrows-in-close"},
  ["150/arrows-in-close"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/arrows-in-close.png", width = 1000, height = 189, has4k = true, masked = true, mode = mode.Percent150, tag = "arrows-in-close"},
  ["125/arrows-in-close"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/arrows-in-close.png", width = 1000, height = 157, has4k = true, masked = true, mode = mode.Percent125, tag = "arrows-in-close"},
  ["100/arrows-in-close"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/arrows-in-close.png", width = 1000, height = 125, has4k = true, masked = true, mode = mode.Percent100, tag = "arrows-in-close"},
  ["75/arrows-in-close"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/arrows-in-close.png", width = 1000, height = 94, has4k = true, masked = true, mode = mode.Percent75, tag = "arrows-in-close"},
  ["50/arrows-in-close"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/arrows-in-close.png", width = 1000, height = 63, has4k = true, masked = true, mode = mode.Percent50, tag = "arrows-in-close"},

  ["200/arrows-out-close"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/arrows-out-close.png", width = 1000, height = 250, has4k = true, masked = true, mode = mode.Percent200, tag = "arrows-out-close"},
  ["175/arrows-out-close"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/arrows-out-close.png", width = 1000, height = 219, has4k = true, masked = true, mode = mode.Percent175, tag = "arrows-out-close"},
  ["150/arrows-out-close"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/arrows-out-close.png", width = 1000, height = 189, has4k = true, masked = true, mode = mode.Percent150, tag = "arrows-out-close"},
  ["125/arrows-out-close"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/arrows-out-close.png", width = 1000, height = 157, has4k = true, masked = true, mode = mode.Percent125, tag = "arrows-out-close"},
  ["100/arrows-out-close"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/arrows-out-close.png", width = 1000, height = 125, has4k = true, masked = true, mode = mode.Percent100, tag = "arrows-out-close"},
  ["75/arrows-out-close"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/arrows-out-close.png", width = 1000, height = 94, has4k = true, masked = true, mode = mode.Percent75, tag = "arrows-out-close"},
  ["50/arrows-out-close"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/arrows-out-close.png", width = 1000, height = 63, has4k = true, masked = true, mode = mode.Percent50, tag = "arrows-out-close"},

  ["wide/arrows"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/arrows.png", width = 1230, height = 164, has4k = true, mode = mode.Percent100, tag = "arrows"},
  ["wide/double-arrows"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/double-arrows.png", width = 1351, height = 173, has4k = true, mode = mode.Percent100, tag = "arrows"},
  ["normal/double-arrows-down"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/double-arrows-down.png", width = 173, height = 153, has4k = true, mode = mode.Percent100, tag = "arrows"},
  ["normal/solid-arrows"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/arrows-solid.png", width = 1265, height = 173, has4k = true, mode = mode.Percent100, tag = "arrows"},
  ["normal/solid-arrow-down"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/arrow-solid-down.png", width = 207, height = 132, has4k = true, mode = mode.Percent100, tag = "arrows"},

  ["200/feathered"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/feathered-200.png", width = 1000, height = 250, has4k = true, masked = true, mode = mode.Percent200, tag = "feathered"},
  ["175/feathered"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/feathered-175.png", width = 1000, height = 219, has4k = true, masked = true, mode = mode.Percent175, tag = "feathered"},
  ["150/feathered"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/feathered-150.png", width = 1000, height = 189, has4k = true, masked = true, mode = mode.Percent150, tag = "feathered"},
  ["125/feathered"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/feathered-125.png", width = 1000, height = 157, has4k = true, masked = true, mode = mode.Percent125, tag = "feathered"},
  ["100/feathered"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/feathered-100.png", width = 1000, height = 125, has4k = true, masked = true, mode = mode.Percent100, tag = "feathered"},
  ["75/feathered"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/feathered-75.png", width = 1000, height = 94, has4k = true, masked = true, mode = mode.Percent75, tag = "feathered"},
  ["50/feathered"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/feathered-50.png", width = 1000, height = 63, has4k = true, masked = true, mode = mode.Percent50, tag = "feathered"},
}

addonTable.Assets.BarPositionHighlights = {
  ["none"] = {file = "", width = 0, height = 0},
  ["wide/glow"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarPosition/highlight.png", width = 54, height = 125, has4k = true, mode = mode.Percent100},
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
  ["normal/cast-icon"] = {file = 236205, width = 120, height = 120, tag = "castIcon"},

  ["normal/quest-gradient"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/quest-gradient.png", width = 48, height = 170, has4k = true, tag = "quest"},
  ["normal/quest-boss-blizzard"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/blizzard-quest-boss.png", width = 164, height = 208, has4k = true, tag = "quest"},
  ["normal/quest-blizzard"] = {file = "Interface/AddOns/Platynator/Assets/Special/Markers/quest-blizzard.png", width = 97, height = 170, tag = "quest"},

  ["normal/shield-gradient"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/shield-gradient.png", width = 150, height = 155, has4k = true, tag = "cannotInterrupt"},
  ["normal/shield-soft"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/shield-soft.png", width = 160, height = 165, has4k = true, tag = "cannotInterrupt"},
  ["normal/blizzard-shield"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/blizzard-shield.png", width = 136, height = 165, has4k = true, tag = "cannotInterrupt"},

  ["special/blizzard-elite"] = {file = "Interface/AddOns/Platynator/Assets/Special/Markers/eliterarecombo-blizzard.png", width = 150, height = 155, mode = mode.Special, tag = "elite"},
  ["normal/blizzard-elite"] = {file = "Interface/AddOns/Platynator/Assets/Special/Markers/elite-blizzard.png", width = 150, height = 155},
  ["normal/blizzard-rareelite"] = {file = "Interface/AddOns/Platynator/Assets/Special/Markers/rareelite-blizzard.png", width = 150, height = 155},

  ["special/blizzard-elite-around"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/blizzard-rareelitecombo.png", width = 183, height = 155, has4k = true, mode = mode.Special, tag = "elite"},
  ["normal/blizzard-elite-around"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/blizzard-elite.png", width = 183, height = 150, has4k = true},
  ["normal/blizzard-rareelite-around"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/blizzard-rareelite.png", width = 183, height = 150, has4k = true},

  ["special/blizzard-elite-midnight"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/blizzard-midnight-eliterarecombo.png", width = 150, height = 150, has4k = true, mode = mode.Special, tag = "elite"},
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
    for _, entry in pairs(list) do
      if entry.has4k then
        entry.file = entry.file:format(DPIScale)
      end
      entry.width = entry.width / 8
      entry.height = entry.height / 8
    end
  end

  Iterate(addonTable.Assets.BarBackgrounds)
  Iterate(addonTable.Assets.BarMasks)
  Iterate(addonTable.Assets.BarBorders)
  Iterate(addonTable.Assets.Highlights)
  Iterate(addonTable.Assets.BarPositionHighlights)
  Iterate(addonTable.Assets.PowerBars)
  Iterate(addonTable.Assets.Markers)
end
