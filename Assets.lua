---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Assets.Mode = {
  Special = 1,
  Short = 2, -- Height 63, Width 1000
  Medium = 3, -- Height 125, Width 1000
  Tall = 4, -- Height 250, Width 1000
}

local mode = addonTable.Assets.Mode

addonTable.Assets.Fonts = {
  ["ArialShort"] = {file = "Fonts\\ARIALN.TTF", size = 10, preview = "Arial Short"},
  ["FritzQuadrata"] = {file = "Fonts\\FRIZQT__.TTF", size = 10, preview = "Fritz Quadrata"},
  ["RobotoCondensed-Bold"] = {file = "Interface/AddOns/Platynator/Assets/Fonts/RobotoCondensed-Bold.ttf", size = 10, preview = "Roboto Condensed Bold"},
  ["Lato-Regular"] = {file = "Interface/AddOns/Platynator/Assets/Fonts/Lato-Regular.ttf", size = 10, preview = "Lato Regular"},
  ["Poppins-SemiBold"] = {file = "Interface/AddOns/Platynator/Assets/Fonts/Poppins-SemiBold.ttf", size = 10, preview = "Poppins SemiBold"},
  ["DiabloHeavy"] = {file = "Interface/AddOns/Platynator/Assets/Fonts/DiabloHeavy.ttf", size = 10, preview = "Diablo Heavy"},
  ["2002"] = {file = "Fonts\\2002.TTF", size = 10, preview = "2002"},
}

addonTable.Assets.BarBackgrounds = {
  ["transparent"] = {file = "Interface/AddOns/Platynator/Assets/Special/transparent.png", width = 1000, height = 125, isTransparent = true},
  ["grey"] = {file = "Interface/AddOns/Platynator/Assets/Special/grey.png", width = 1000, height = 125},
  ["black"] = {file = "Interface/AddOns/Platynator/Assets/Special/black.png", width = 1000, height = 125},
  ["white"] = {file = "Interface/AddOns/Platynator/Assets/Special/white.png", width = 1000, height = 125},
  ["wide/bevelled"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBackgrounds/bevelled.png", width = 1000, height = 125, has4k = true, mode = mode.Medium},
  ["wide/bevelled-grey"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBackgrounds/bevelled-grey.png", width = 1000, height = 125, has4k = true, mode = mode.Medium},
  ["wide/fade-bottom"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBackgrounds/fade-bottom.png", width = 1000, height = 125, has4k = true, mode = mode.Medium},
  ["wide/fade-top"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBackgrounds/fade-top.png", width = 1000, height = 125, has4k = true, mode = mode.Medium},
  ["wide/fade-left"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBackgrounds/fade-left.png", width = 1000, height = 125, has4k = true, mode = mode.Medium},
  ["special/blizzard-cast-bar"] = {file = "Interface/AddOns/Platynator/Assets/Special/BarBackgrounds/blizzard-cast-bar.png", width = 1000, height = 57, mode = mode.Special},
  ["wide/blizzard-absorb"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBackgrounds/blizzard-absorb.png", width = 1000, height = 125, has4k = true, mode = mode.Medium},
  ["narrow/blizzard-absorb"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBackgrounds/blizzard-absorb-narrow.png", width = 1000, height = 63, has4k = true, mode = mode.Short},
}

addonTable.Assets.BarBorders = {
  ["tall/transparent"] = {file = "Interface/AddOns/Platynator/Assets/Special/transparent.png", width = 1000, height = 250, mode = mode.Tall, isTransparent = true},
  ["wide/transparent"] = {file = "Interface/AddOns/Platynator/Assets/Special/transparent.png", width = 1000, height = 125, mode = mode.Medium, isTransparent = true},
  ["narrow/transparent"] = {file = "Interface/AddOns/Platynator/Assets/Special/transparent.png", width = 1000, height = 63, mode = mode.Short, isTransparent = true},
  ["wide/blizzard-health"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-health.png", width = 1116, height = 248, has4k = true, masked = true, mode = mode.Medium},
  ["narrow/blizzard-health"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-health-narrow.png", width = 1116, height = 180, has4k = true, masked = true, mode = mode.Short},
  ["wide/blizzard-classic"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-classic.png", width = 1000, height = 125, has4k = true, masked = true, mode = mode.Medium},
  ["wide/blizzard-classic-level"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-classic-full.png", width = 1338, height = 125, has4k = true, masked = true, mode = mode.Medium},
  ["wide/bold"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/bold.png", width = 1000, height = 125, has4k = true, masked = true, mode = mode.Medium},
  ["tall/soft"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/soft-tall.png", width = 1023, height = 274, has4k = true, masked = true, mode = mode.Tall},
  ["wide/soft"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/soft.png", width = 1023, height = 149, has4k = true, masked = true, mode = mode.Medium},
  ["narrow/soft"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/soft-narrow.png", width = 1023, height = 88, has4k = true, masked = true, mode = mode.Short},
  ["wide/slight"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/slight.png", width = 1000, height = 125, has4k = true, masked = true, mode = mode.Medium},
  ["narrow/slight"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/slight-narrow.png", width = 1000, height = 63, has4k = true, masked = true, mode = mode.Short},
  ["wide/thin"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/thin.png", width = 1000, height = 125, has4k = true, masked = true, mode = mode.Medium},
  ["narrow/thin"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/thin-narrow.png", width = 1000, height = 63, has4k = true, masked = true, mode = mode.Short},
  ["special/blizzard-cast-bar"] = {file = "Interface/AddOns/Platynator/Assets/Special/BarBorders/blizzard-cast-bar.png", width = 1000, height = 57, masked = true, mode = mode.Special},
}

addonTable.Assets.BarMasks = {
  ["wide/blizzard-health"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-health-mask.png", width = 1000, height = 125, has4k = true, mode = mode.Medium},
  ["narrow/blizzard-health"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-health-narrow-mask.png", width = 1000, height = 63, has4k = true, mode = mode.Short},
  ["wide/blizzard-classic"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-classic-mask.png", width = 1000, height = 125, has4k = true, mode = mode.Medium},
  ["wide/blizzard-classic-level"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-classic-full-mask.png", width = 1338, height = 125, has4k = true, mode = mode.Medium},
  ["wide/bold"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/bold-mask.png", width = 1000, height = 125, has4k = true, mode = mode.Medium},
  ["tall/soft"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/soft-tall-mask.png", width = 1000, height = 250, has4k = true, mode = mode.Tall},
  ["wide/soft"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/soft-mask.png", width = 1000, height = 125, has4k = true, mode = mode.Medium},
  ["narrow/soft"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/soft-narrow-mask.png", width = 1000, height = 63, has4k = true, mode = mode.Short},
  ["wide/slight"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/slight-mask.png", width = 1000, height = 125, has4k = true, mode = mode.Medium},
  ["narrow/slight"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/slight-narrow-mask.png", width = 1000, height = 63, has4k = true, mode = mode.Short},
  ["wide/thin"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/thin-mask.png", width = 1000, height = 125, has4k = true, mode = mode.Medium},
  ["narrow/thin"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/thin-narrow-mask.png", width = 1000, height = 63, has4k = true, mode = mode.Short},
  ["special/blizzard-cast-bar"] = {file = "Interface/AddOns/Platynator/Assets/Special/BarBorders/blizzard-cast-bar-mask.png", width = 1000, height = 63, has4k = true, mode = mode.Special},
}

addonTable.Assets.Highlights = {
  ["wide/outline"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/outline.png", width = 1030, height = 155, has4k = true, mode = mode.Medium},
  ["wide/outline-narrow"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/outline-narrow.png", width = 1030, height = 93, has4k = true, mode = mode.Short},
  ["wide/glow"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/glow.png", width = 1472, height = 592, has4k = true, mode = mode.Medium},
  ["tall/soft-glow"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/soft-glow-tall.png", width = 1066, height = 324, has4k = true, mode = mode.Tall},
  ["wide/soft-glow"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/soft-glow.png", width = 1066, height = 193, has4k = true, mode = mode.Medium},
  ["wide/soft-glow-narrow"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/soft-glow-narrow.png", width = 1066, height = 123, has4k = true, mode = mode.Short},
  ["wide/arrows"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/arrows.png", width = 1230, height = 164, has4k = true, mode = mode.Medium},
  ["wide/double-arrows"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/double-arrows.png", width = 1351, height = 173, has4k = true, mode = mode.Medium},
}

addonTable.Assets.BarPositionHighlights = {
  ["none"] = {file = "", width = 0, height = 0},
  ["wide/glow"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarPosition/highlight.png", width = 54, height = 125, has4k = true, mode = mode.Medium},
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
  ["special/blizzard-elite-star"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/blizzard-rare-old.png", width = 140, height = 140, has4k = true, tag = "elite"},

  ["normal/blizzard-rare"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/blizzard-rare.png", width = 162, height = 159, has4k = true, tag = "rare"},
  ["normal/blizzard-rare-old"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/blizzard-rare-old.png", width = 140, height = 140, has4k = true, tag = "rare"},
  ["normal/blizzard-rare-silver-star"] = {file = "Interface/AddOns/Platynator/Assets/Special/Markers/blizzard-rare-star.png", width = 100, height = 100, tag = "rare"},

  ["normal/blizzard-raid"] = {file = "Interface/TargetingFrame/UI-RaidTargetingIcons", preview = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_1.blp", width = 150, height = 150, tag = "raid"},
}

addonTable.Assets.SpecialBars = {
  ["special/blizzard-cast-bar"] = {
    background = "transparent",
    foreground = "special/blizzard-cast-bar",
    border = "special/blizzard-cast-bar",
  },
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
