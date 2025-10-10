---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Assets.Fonts = {
  ["RobotoCondensed-Bold"] = {file = "Interface/AddOns/Platynator/Assets/RobotoCondensed-Bold.ttf", size = 10},
}
addonTable.Assets.BarBackgrounds = {
  ["wide/bold-1"] = {file = "Interface/AddOns/Platynator/Assets/Bars/Wide/bold-bar-background.png", width = 1000, height = 125},
  ["wide/slight-1"] = {file = "Interface/AddOns/Platynator/Assets/Bars/Wide/slight-bar-background.png", width = 1000, height = 125},
  ["wide/slight-2"] = {file = "Interface/AddOns/Platynator/Assets/Bars/Wide/slight-bar-foreground.png", width = 1000, height = 125},
}

addonTable.Assets.BarBorders = {
  ["wide/bold-1"] = {file = "Interface/AddOns/Platynator/Assets/Bars/Wide/bold-bar-border.png", width = 1000, height = 125},
  ["wide/slight-1"] = {file = "Interface/AddOns/Platynator/Assets/Bars/Wide/slight-bar-border.png", width = 1000, height = 125},
}

addonTable.Assets.Highlights = {
  ["wide/outline"] = {file = "Interface/AddOns/Platynator/Assets/Bars/Wide/outline.png", width = 1030, height = 155},
  ["wide/glow"] = {file = "Interface/AddOns/Platynator/Assets/Bars/Wide/glow.png", width = 1472, height = 592},
}

addonTable.Assets.BarPositionHighlights = {
  ["none"] = {file = "", width = 0, height = 0},
  ["wide/glow"] = {file = "Interface/AddOns/Platynator/Assets/Bars/Wide/highlight.png", width = 54, height = 125},
}

addonTable.Assets.PowerBars = {
  ["normal/gradient-faded"] = {file = "Interface/AddOns/Platynator/Assets/Power/gradient-inactive.png", width = 993, height = 147},
  ["normal/gradient-full"] = {file = "Interface/AddOns/Platynator/Assets/Power/gradient-active.png", width = 993, height = 147},
}
