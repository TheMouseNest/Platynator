---@class addonTablePlatynator
local addonTable = select(2, ...)

local healthScale = 1/8

local function GetColor(rgb)
  local color = CreateColorFromRGBHexString(rgb)
  return {r = color.r, g = color.g, b = color.b}
end

function addonTable.Design.GetDefaultDesignSlight()
  return {
    appliesToAll = true,
    font = {
      asset = "RobotoCondensed-Bold",
      flags = "OUTLINE",
    },
    highlights = {
      {
        anchor = {},
        kind = "target",
        texture = "wide/glow",
        color = GetColor("1CE2ED"),
        scale = healthScale,
      },
    },
    bars = {
      {
        kind = "health",
        anchor = {},
        relativeTo = 0,
        scale = healthScale,
        colorBackground = true,
        background = "wide/slight-1",
        backgroundAlpha = 1,
        foreground = "wide/slight-2",
        border = "wide/slight-1",
        marker = {
          texture = "wide/glow",
        },
        colors = {
          threat = {
            safe = GetColor("0F96E6"),
            transition = GetColor("FFA000"),
            warning = GetColor("CC0000"),
          },
          npc = {
            friendly = GetColor("00FF00"),
            neutral = GetColor("FFFF00"),
            hostile = GetColor("FF0000"),
          },
        }
      },
      {
        kind = "cast",
        anchor = {"TOP", 0, -9},
        colors = {
          normal = GetColor("FC8C00"),
          uninterruptable = GetColor("83C0C3")
        },
        marker = {
          texture = "wide/glow",
        },
        colorBackground = true,
        backgroundAlpha = 1,
        background = "wide/slight-1",
        backgroundAlpha = 1,
        foreground = "wide/slight-2",
        border = "wide/slight-1",
        scale = healthScale,
      },
    },
    specialBars = {
      {
        kind = "power",
        blank = "normal/gradient-faded",
        filled = "normal/gradient-full",
        scale = healthScale * 0.60,
        anchor = {0, -7},
      },
    },
    texts = {
      {
        kind = "health",
        scale = 0.98,
        anchor = {"BOTTOMRIGHT", 61, -12},
        displayTypes = {"percentage"}, -- or "absolute", or both
      },
      {
        kind = "health",
        scale = 1.08,
        anchor = {"LEFT", -60, 0},
        displayTypes = {"absolute"}, -- or "absolute", or both
      },
      {
        kind = "creatureName",
        scale = 1.1,
        anchor = {"BOTTOM", 0, 9},
      },
      {
        kind = "castName",
        scale = 1.08,
        anchor = {},
        anchor = {"TOP", 0, -12},
      }
    },
  }
end
