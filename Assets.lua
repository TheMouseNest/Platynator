---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Assets.Fonts = {
  ["ArialNarrow"] = {file = "Fonts\\ARIALN.TTF", size = 10},
  ["FritzQuadrata"] = {file = "Fonts\\FRIZQT__.TTF", size = 10},
  ["RobotoCondensed-Bold"] = {file = "Interface/AddOns/Platynator/Assets/RobotoCondensed-Bold.ttf", size = 10},
}
addonTable.Assets.BarBackgrounds = {
  ["wide/bold-1"] = {file = "Interface/AddOns/Platynator/Assets/Bars/Wide/bold-bar-background.png", width = 1000, height = 125},
  ["wide/slight-1"] = {file = "Interface/AddOns/Platynator/Assets/Bars/Wide/slight-bar-background.png", width = 1000, height = 125},
  ["wide/slight-2"] = {file = "Interface/AddOns/Platynator/Assets/Bars/Wide/slight-bar-foreground.png", width = 1000, height = 125},
  ["wide/blizzard-1"] = {file = "Interface/AddOns/Platynator/Assets/Bars/Wide/blizzard-background.png", width = 1000, height = 125},
}

addonTable.Assets.BarBorders = {
  ["wide/bold-1"] = {file = "Interface/AddOns/Platynator/Assets/Bars/Wide/bold-bar-border.png", width = 1000, height = 125},
  ["wide/slight-1"] = {file = "Interface/AddOns/Platynator/Assets/Bars/Wide/slight-bar-border.png", width = 1000, height = 125},
  ["wide/soft-1"] = {file = "Interface/AddOns/Platynator/Assets/Bars/Wide/soft-border.png", width = 1023, height = 149},
  ["wide/blizzard-normal"] = {file = "Interface/AddOns/Platynator/Assets/Bars/Wide/blizzard-border.png", width = 1116, height = 248},
  ["wide/blizzard-glow"] = {file = "Interface/AddOns/Platynator/Assets/Bars/Wide/blizzard-border-glow.png", width = 1364, height = 248},
}

addonTable.Assets.Highlights = {
  ["wide/outline"] = {file = "Interface/AddOns/Platynator/Assets/Bars/Wide/outline.png", width = 1030, height = 155},
  ["wide/glow"] = {file = "Interface/AddOns/Platynator/Assets/Bars/Wide/glow.png", width = 1472, height = 592},
  ["wide/soft-glow"] = {file = "Interface/AddOns/Platynator/Assets/Bars/Wide/soft-glow.png", width = 1066, height = 193},
}

addonTable.Assets.BarPositionHighlights = {
  ["none"] = {file = "", width = 0, height = 0},
  ["wide/glow"] = {file = "Interface/AddOns/Platynator/Assets/Bars/Wide/highlight.png", width = 54, height = 125},
}

addonTable.Assets.PowerBars = {
  ["normal/gradient-faded"] = {file = "Interface/AddOns/Platynator/Assets/Power/gradient-inactive.png", width = 993, height = 147},
  ["normal/gradient-full"] = {file = "Interface/AddOns/Platynator/Assets/Power/gradient-active.png", width = 993, height = 147},
  ["normal/soft-faded"] = {file = "Interface/AddOns/Platynator/Assets/Power/soft-inactive.png", width = 993, height = 147},
  ["normal/soft-full"] = {file = "Interface/AddOns/Platynator/Assets/Power/soft-active.png", width = 993, height = 147},
}

addonTable.Assets.Markers = {
  ["normal/quest-gradient"] = {file = "Interface/AddOns/Platynator/Assets/Markers/quest-gradient.png", width = 48, height = 170},
  ["normal/shield-gradient"] = {file = "Interface/AddOns/Platynator/Assets/Markers/shield-gradient.png", width = 150, height = 155},
  ["normal/shield-soft"] = {file = "Interface/AddOns/Platynator/Assets/Markers/shield-soft.png", width = 160, height = 165},
}
