---@class addonTablePlatynator
local addonTable = select(2, ...)

local healthScale = addonTable.Constants.IsMidnight and 1/7 or 1/9

addonTable.Display.Styles = {
  ["bold"] = {
    font = {
      file = "Interface/AddOns/Platynator/Assets/RobotoCondensed-Bold.ttf",
      size = addonTable.Constants.IsMidnight and 12 or 10,
      flags = "",
    },
    healthBar = {
      colorBackground = false,
      background = "Interface/AddOns/Platynator/Assets/Bars/Wide/bold-bar-background.png",
      foreground = "Interface/AddOns/Platynator/Assets/Bars/Wide/bold-bar-background.png",
      backgroundAlpha = 0.5,
      border = "Interface/AddOns/Platynator/Assets/Bars/Wide/bold-bar-border.png",
      width = 1000,
      height = 125,
      scale = healthScale,
      marker = {
        texture = nil,
        width = 0,
      },
      targetHighlight = {
        color = CreateColorFromRGBHexString("FFFFFF"),
        texture = "Interface/AddOns/Platynator/Assets/Bars/Wide/outline.png",
        target = CreateColorFromRGBHexString("FFFFFF"),
        width = 1030,
        height = 155,
      },
      colors = {
        threat = {
          safe = CreateColorFromRGBHexString("0F96E6"),
          transition = CreateColorFromRGBHexString("FFA000"),
          warning = CreateColorFromRGBHexString("CC0000"),
        },
        npc = {
          friendly = CreateColorFromRGBHexString("00FF00"),
          neutral = CreateColorFromRGBHexString("FFFF00"),
          hostile = CreateColorFromRGBHexString("FF0000"),
        },
        --[[player = {
          friendly = CreateColorFromRGBHexString("FC8C00"),
          hostile = CreateColorFromRGBHexString("FF0000"),
          guild = CreateColorFromRGBHexString("3CA8FF"),
        },]]
      }
    },
    healthText = {
      scale = 1,
      anchor = {"CENTER"},
      types = {},
    },
    power = {
      blank = "Interface/AddOns/Platynator/Assets/Power/gradient-inactive.png",
      filled = "Interface/AddOns/Platynator/Assets/Power/gradient-active.png",
      width = 993,
      height = 147,
      scale = 2/3 * healthScale,
      offset = {x = 0, y = 2}
    },
    castBar = {
      colors = {
        normal = CreateColorFromRGBHexString("FC8C00"),
        uninterruptable = CreateColorFromRGBHexString("83C0C3")
      },
      marker = {
        texture = nil,
        width = 0,
      },
      colorBackground = false,
      backgroundAlpha = 0.5,
      background = "Interface/AddOns/Platynator/Assets/Bars/Wide/bold-bar-background.png",
      foreground = "Interface/AddOns/Platynator/Assets/Bars/Wide/bold-bar-background.png",
      border = "Interface/AddOns/Platynator/Assets/Bars/Wide/bold-bar-border.png",
      width = 1000,
      height = 125,
      scale = healthScale,
    },
    castText = {
      scale = 1,
    },
  },
  ["slight"] = {
    font = {
      file = "Interface/AddOns/Platynator/Assets/RobotoCondensed-Bold.ttf",
      size = addonTable.Constants.IsMidnight and 12 or 10,
      flags = "OUTLINE",
    },
    healthBar = {
      colorBackground = true,
      background = "Interface/AddOns/Platynator/Assets/Bars/Wide/slight-bar-background.png",
      backgroundAlpha = 1,
      foreground = "Interface/AddOns/Platynator/Assets/Bars/Wide/slight-bar-foreground.png",
      border = "Interface/AddOns/Platynator/Assets/Bars/Wide/slight-bar-border.png",
      width = 1000,
      height = 125,
      scale = healthScale,
      marker = {
        texture = "Interface/AddOns/Platynator/Assets/Bars/Wide/highlight.png",
        width = 54,
      },
      targetHighlight = {
        texture = "Interface/AddOns/Platynator/Assets/Bars/Wide/glow.png",
        width = 1474,
        height = 592,
        color = CreateColorFromRGBHexString("1CE2ED"),
      },
      colors = {
        threat = {
          safe = CreateColor(15/255, 150/255, 230/255),
          transition = CreateColor(255/255, 160/255, 0/255),
          warning = CreateColor(204/255, 0/255, 0/255),
        },
        npc = {
          friendly = CreateColor(0, 1, 0),
          neutral = CreateColor(1, 1, 0),
          hostile = CreateColor(1, 0, 0),
        },
      },
    },
    healthText = {
      scale = 0.9,
      anchor = {"BOTTOMRIGHT", -2, -3},
      types = {"percentage"},
    },
    power = {
      blank = "Interface/AddOns/Platynator/Assets/Power/gradient-inactive.png",
      filled = "Interface/AddOns/Platynator/Assets/Power/gradient-active.png",
      width = 993,
      height = 147,
      scale = healthScale,
      offset = {x = 0, y = addonTable.Constants.IsMidnight and 7 or 6}
    },
    castBar = {
      colors = {
        normal = CreateColorFromRGBHexString("FC8C00"),
        uninterruptable = CreateColorFromRGBHexString("83C0C3")
      },
      marker = {
        texture = "Interface/AddOns/Platynator/Assets/Slight/highlight.png",
        width = 54,
      },
      colorBackground = true,
      backgroundAlpha = 1,
      background = "Interface/AddOns/Platynator/Assets/Bars/Wide/slight-bar-background.png",
      backgroundAlpha = 1,
      foreground = "Interface/AddOns/Platynator/Assets/Bars/Wide/slight-bar-foreground.png",
      border = "Interface/AddOns/Platynator/Assets/Bars/Wide/slight-bar-border.png",
      width = 1000,
      height = 125,
      scale = healthScale,
    },
    castText = {
      scale = 0.9,
    },
  },
}
