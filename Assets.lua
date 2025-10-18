---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Assets.Mode = {
  Special = 1,
  Wide = 2, -- Height 125, Width 1000
  Narrow = 3, -- Height 63, Width 1000
}

local mode = addonTable.Assets.Mode

addonTable.Assets.Fonts = {
  ["ArialNarrow"] = {file = "Fonts\\ARIALN.TTF", size = 10},
  ["FritzQuadrata"] = {file = "Fonts\\FRIZQT__.TTF", size = 10},
  ["RobotoCondensed-Bold"] = {file = "Interface/AddOns/Platynator/Assets/RobotoCondensed-Bold.ttf", size = 10},
}

addonTable.Assets.BarBackgrounds = {
  ["transparent"] = {file = "Interface/AddOns/Platynator/Assets/Special/transparent.tga", width = 1000, height = 125},
  ["grey"] = {file = "Interface/AddOns/Platynator/Assets/Special/grey.tga", width = 1000, height = 125},
  ["white"] = {file = "Interface/AddOns/Platynator/Assets/Special/white.tga", width = 1000, height = 125},
  ["wide/bevelled"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBackgrounds/bevelled.tga", width = 1000, height = 125, has4k = true, mode = mode.Wide},
  ["wide/bevelled-grey"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBackgrounds/bevelled-grey.tga", width = 1000, height = 125, has4k = true, mode = mode.Wide},
  ["wide/fade-bottom"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBackgrounds/fade-bottom.tga", width = 1000, height = 125, has4k = true, mode = mode.Wide},
  ["wide/fade-top"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBackgrounds/fade-top.tga", width = 1000, height = 125, has4k = true, mode = mode.Wide},
  ["wide/fade-left"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBackgrounds/fade-left.tga", width = 1000, height = 125, has4k = true, mode = mode.Wide},
  ["special/blizzard-cast-bar"] = {file = "Interface/AddOns/Platynator/Assets/Special/BarBackgrounds/blizzard-cast-bar.tga", width = 1000, height = 57, mode = mode.Special},
}

addonTable.Assets.BarBorders = {
  ["wide/transparent"] = {file = "Interface/AddOns/Platynator/Assets/Special/transparent.tga", width = 1000, height = 125, mode = mode.Wide},
  ["narrow/transparent"] = {file = "Interface/AddOns/Platynator/Assets/Special/transparent.tga", width = 1000, height = 63, mode = mode.Narrow},
  ["wide/blizzard-health"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-health.tga", width = 1116, height = 248, has4k = true, masked = true, mode = mode.Wide},
  ["narrow/blizzard-health"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-health-narrow.tga", width = 1116, height = 180, has4k = true, masked = true, mode = mode.Narrow},
  ["wide/blizzard-classic"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-classic.tga", width = 1000, height = 125, has4k = true, masked = true, mode = mode.Wide},
  ["wide/blizzard-classic-level"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-classic-full.tga", width = 1338, height = 125, has4k = true, masked = true, mode = mode.Wide},
  ["wide/bold"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/bold.tga", width = 1000, height = 125, has4k = true, masked = true, mode = mode.Wide},
  ["wide/soft"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/soft.tga", width = 1023, height = 149, has4k = true, masked = true, mode = mode.Wide},
  ["narrow/soft"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/soft-narrow.tga", width = 1023, height = 88, has4k = true, masked = true, mode = mode.Narrow},
  ["wide/slight"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/slight.tga", width = 1000, height = 125, has4k = true, mode = mode.Wide},
  ["narrow/slight"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/slight-narrow.tga", width = 1000, height = 63, has4k = true, mode = mode.Narrow},
  ["special/blizzard-cast-bar"] = {file = "Interface/AddOns/Platynator/Assets/Special/BarBorders/blizzard-cast-bar.tga", width = 1000, height = 57, mode = mode.Special},
}

addonTable.Assets.BarMasks = {
  ["wide/blizzard-health"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-health-mask.tga", width = 1000, height = 125, has4k = true, mode = mode.Wide},
  ["narrow/blizzard-health"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-health-narrow-mask.tga", width = 1000, height = 63, has4k = true, mode = mode.Narrow},
  ["wide/blizzard-classic"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-classic-mask.tga", width = 1000, height = 125, has4k = true, mode = mode.Wide},
  ["wide/blizzard-classic-level"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/blizzard-classic-full-mask.tga", width = 1338, height = 125, has4k = true, mode = mode.Wide},
  ["wide/bold"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/bold-mask.tga", width = 1000, height = 125, has4k = true, mode = mode.Wide},
  ["wide/soft"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/soft-mask.tga", width = 1000, height = 125, has4k = true, mode = mode.Wide},
  ["narrow/soft"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/soft-narrow-mask.tga", width = 1000, height = 63, has4k = true, mode = mode.Narrow},
  ["wide/slight"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/slight-mask.tga", width = 1000, height = 125, has4k = true, mode = mode.Wide},
  ["narrow/slight"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarBorders/slight-narrow-mask.tga", width = 1000, height = 63, has4k = true, mode = mode.Narrow},
  ["special/blizzard-cast-bar"] = {file = "Interface/AddOns/Platynator/Assets/Special/BarBorders/blizzard-cast-bar-mask.tga", width = 1000, height = 63, has4k = true, mode = mode.Special},
}

addonTable.Assets.Highlights = {
  ["wide/outline"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/outline.tga", width = 1030, height = 155, has4k = true, mode = mode.Wide},
  ["wide/outline-narrow"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/outline-narrow.tga", width = 1030, height = 93, has4k = true, mode = mode.Narrow},
  ["wide/glow"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/glow.tga", width = 1472, height = 592, has4k = true, mode = mode.Wide},
  ["wide/soft-glow"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/soft-glow.tga", width = 1066, height = 193, has4k = true, mode = mode.Wide},
  ["wide/soft-glow-narrow"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/soft-glow-narrow.tga", width = 1066, height = 123, has4k = true, mode = mode.Narrow},
  ["wide/arrows"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/arrows.tga", width = 1230, height = 164, has4k = true, mode = mode.Wide},
  ["wide/double-arrows"] = {file = "Interface/AddOns/Platynator/Assets/%s/Highlights/double-arrows.tga", width = 1351, height = 173, has4k = true, mode = mode.Wide},
}

addonTable.Assets.BarPositionHighlights = {
  ["none"] = {file = "", width = 0, height = 0},
  ["wide/glow"] = {file = "Interface/AddOns/Platynator/Assets/%s/BarPosition/highlight.tga", width = 54, height = 125, has4k = true, mode = mode.Wide},
}

addonTable.Assets.PowerBars = {
  ["transparent"] = {file = "Interface/AddOns/Platynator/Assets/Special/transparent.tga", width = 993, height = 147, has4k = true},
  ["normal/gradient-faded"] = {file = "Interface/AddOns/Platynator/Assets/%s/Power/gradient-inactive.tga", width = 993, height = 147, has4k = true},
  ["normal/gradient-full"] = {file = "Interface/AddOns/Platynator/Assets/%s/Power/gradient-active.tga", width = 993, height = 147, has4k = true},
  ["normal/soft-faded"] = {file = "Interface/AddOns/Platynator/Assets/%s/Power/soft-inactive.tga", width = 993, height = 147, has4k = true},
  ["normal/soft-full"] = {file = "Interface/AddOns/Platynator/Assets/%s/Power/soft-active.tga", width = 993, height = 147, has4k = true},
}

addonTable.Assets.Markers = {
  ["normal/quest-gradient"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/quest-gradient.tga", width = 48, height = 170, has4k = true, tag = "quest"},
  ["normal/quest-blizzard"] = {file = "Interface/AddOns/Platynator/Assets/Special/Markers/quest-blizzard.tga", width = 97, height = 170, tag = "quest"},
  ["normal/shield-gradient"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/shield-gradient.tga", width = 150, height = 155, has4k = true, tag = "cannotInterrupt"},
  ["normal/shield-soft"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/shield-soft.tga", width = 160, height = 165, has4k = true, tag = "cannotInterrupt"},
  ["normal/blizzard-shield"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/blizzard-shield.tga", width = 136, height = 165, has4k = true, tag = "cannotInterrupt"},
  ["special/blizzard-elite"] = {file = "Interface/AddOns/Platynator/Assets/Special/Markers/eliterarecombo-blizzard.tga", width = 150, height = 155, mode = mode.Special, tag = "elite"},
  ["normal/blizzard-elite"] = {file = "Interface/AddOns/Platynator/Assets/Special/Markers/elite-blizzard.tga", width = 150, height = 155},
  ["normal/blizzard-rareelite"] = {file = "Interface/AddOns/Platynator/Assets/Special/Markers/rareelite-blizzard.tga", width = 150, height = 155},
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
  }
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
