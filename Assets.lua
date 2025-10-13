---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Assets.Fonts = {
  ["ArialNarrow"] = {file = "Fonts\\ARIALN.TTF", size = 10},
  ["FritzQuadrata"] = {file = "Fonts\\FRIZQT__.TTF", size = 10},
  ["RobotoCondensed-Bold"] = {file = "Interface/AddOns/Platynator/Assets/RobotoCondensed-Bold.ttf", size = 10},
}
addonTable.Assets.BarBackgrounds = {
  ["transparent"] = {file = "Interface/AddOns/Platynator/Assets/transparency.png", width = 1000, height = 125},
  ["wide/bold-1"] = {file = "Interface/AddOns/Platynator/Assets/Bars/Wide%s/bold-bar-background.png", width = 1000, height = 125, has4k = true},
  ["wide/slight-1"] = {file = "Interface/AddOns/Platynator/Assets/Bars/Wide%s/slight-bar-background.png", width = 1000, height = 125, has4k = true},
  ["wide/slight-2"] = {file = "Interface/AddOns/Platynator/Assets/Bars/Wide%s/slight-bar-foreground.png", width = 1000, height = 125, has4k = true},
  ["wide/blizzard-1"] = {file = "Interface/AddOns/Platynator/Assets/Bars/Wide%s/blizzard-background.png", width = 1000, height = 125, has4k = true},
  ["special/blizzard-cast-bar"] = {file = "Interface/AddOns/Platynator/Assets/Bars/Special/blizzard-cast-bar.png", width = 1000, height = 57, special = true},
}

addonTable.Assets.BarBorders = {
  ["transparent"] = {file = "Interface/AddOns/Platynator/Assets/transparency.png", width = 1000, height = 125},
  ["wide/bold-1"] = {file = "Interface/AddOns/Platynator/Assets/Bars/Wide%s/bold-bar-border.png", width = 1000, height = 125, has4k = true},
  ["wide/slight-1"] = {file = "Interface/AddOns/Platynator/Assets/Bars/Wide%s/slight-bar-border.png", width = 1000, height = 125, has4k = true},
  ["wide/soft-1"] = {file = "Interface/AddOns/Platynator/Assets/Bars/Wide%s/soft-border.png", width = 1023, height = 149, has4k = true},
  ["wide/blizzard-normal"] = {file = "Interface/AddOns/Platynator/Assets/Bars/Wide%s/blizzard-border.png", width = 1116, height = 248, has4k = true},
  ["special/blizzard-cast-bar"] = {file = "Interface/AddOns/Platynator/Assets/Bars/Special/blizzard-cast-bar-border.png", width = 1000, height = 57, special = true},
}

addonTable.Assets.Highlights = {
  ["wide/outline"] = {file = "Interface/AddOns/Platynator/Assets/Bars/Wide%s/outline.png", width = 1030, height = 155, has4k = true},
  ["wide/glow"] = {file = "Interface/AddOns/Platynator/Assets/Bars/Wide%s/glow.png", width = 1472, height = 592},
  ["wide/soft-glow"] = {file = "Interface/AddOns/Platynator/Assets/Bars/Wide%s/soft-glow.png", width = 1066, height = 193},
}

addonTable.Assets.BarPositionHighlights = {
  ["none"] = {file = "", width = 0, height = 0},
  ["wide/glow"] = {file = "Interface/AddOns/Platynator/Assets/Bars/Wide%s/highlight.png", width = 54, height = 125, has4k = true},
}

addonTable.Assets.PowerBars = {
  ["normal/gradient-faded"] = {file = "Interface/AddOns/Platynator/Assets/Power/%s/gradient-inactive.png", width = 993, height = 147, has4k = true},
  ["normal/gradient-full"] = {file = "Interface/AddOns/Platynator/Assets/Power/%s/gradient-active.png", width = 993, height = 147, has4k = true},
  ["normal/soft-faded"] = {file = "Interface/AddOns/Platynator/Assets/Power/%s/soft-inactive.png", width = 993, height = 147, has4k = true},
  ["normal/soft-full"] = {file = "Interface/AddOns/Platynator/Assets/Power/%s/soft-active.png", width = 993, height = 147, has4k = true},
}

addonTable.Assets.Markers = {
  ["normal/quest-gradient"] = {file = "Interface/AddOns/Platynator/Assets/Markers/%s/quest-gradient.png", width = 48, height = 170, has4k = true},
  ["normal/quest-blizzard"] = {file = "Interface/AddOns/Platynator/Assets/Markers/quest-blizzard.png", width = 97, height = 170},
  ["normal/shield-gradient"] = {file = "Interface/AddOns/Platynator/Assets/Markers/%s/shield-gradient.png", width = 150, height = 155, has4k = true},
  ["normal/shield-soft"] = {file = "Interface/AddOns/Platynator/Assets/Markers/%s/shield-soft.png", width = 160, height = 165, has4k = true},
  ["special/blizzard-elite"] = {file = "Interface/AddOns/Platynator/Assets/Markers/eliterarecombo-blizzard.png", width = 150, height = 155, special = true},
  ["normal/blizzard-elite"] = {file = "Interface/AddOns/Platynator/Assets/Markers/elite-blizzard.png", width = 150, height = 155},
  ["normal/blizzard-rareelite"] = {file = "Interface/AddOns/Platynator/Assets/Markers/rareelite-blizzard.png", width = 150, height = 155},
}

addonTable.Assets.SpecialBars = {
  ["special/blizzard-cast-bar"] = {
    background = "transparent",
    foreground = "special/blizzard-cast-bar",
    border = "special/blizzard-cast-bar",
  }
}

addonTable.Assets.SpecialEliteMarkers = {
  ["special/blizzard-elite"] = {
    elite = "normal/blizzard-elite",
    rareElite = "normal/blizzard-rareelite",
  }
}

function addonTable.Assets.ApplyScale()
  local DPIScale = "1.5"
  if GetScreenDPIScale() < 1.4 then
    DPIScale = "1"
  end

  local function Iterate(list)
    for _, entry in pairs(list) do
      if entry.has4k then
        entry.file = entry.file:format(DPIScale)
      end
    end
  end

  Iterate(addonTable.Assets.BarBackgrounds)
  Iterate(addonTable.Assets.BarBorders)
  Iterate(addonTable.Assets.Highlights)
  Iterate(addonTable.Assets.BarPositionHighlights)
  Iterate(addonTable.Assets.PowerBars)
  Iterate(addonTable.Assets.Markers)
end
