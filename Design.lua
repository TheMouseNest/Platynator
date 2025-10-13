---@class addonTablePlatynator
local addonTable = select(2, ...)

local healthScale = 1/8

local function GetColor(rgb)
  local color = CreateColorFromRGBHexString(rgb)
  return {r = color.r, g = color.g, b = color.b}
end

function addonTable.Design.GetDefaultDesignRabbit()
  return {
    appliesToAll = true,
    font = {
      asset = "RobotoCondensed-Bold",
      flags = "",
    },
    highlights = {
      {
        anchor = {},
        kind = "target",
        asset = "wide/outline",
        color = GetColor("FFFFFF"),
        scale = healthScale,
      },
    },
    bars = {
      {
        kind = "health",
        anchor = {},
        relativeTo = 0,
        scale = healthScale,
        background = {
          asset = "wide/bold-1",
          alpha = 0.5,
          applyColor = false,
        },
        foreground = {
          asset = "wide/bold-1",
        },
        border = {
          asset = "wide/bold-1",
          color = GetColor("000000")
        },
        marker = {
          asset = "none",
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
        anchor = {"TOP", 0, -10},
        colors = {
          normal = GetColor("FC8C00"),
          uninterruptable = GetColor("83C0C3")
        },
        marker = {
          asset = "none",
        },
        background = {
          asset = "wide/bold-1",
          alpha = 0.5,
          applyColor = false,
        },
        foreground = {
          asset = "wide/bold-1",
        },
        border = {
          asset = "wide/bold-1",
          color = GetColor("000000")
        },
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
        kind = "creatureName",
        scale = 1.1,
        anchor = {"BOTTOM", 0, 10},
        widthLimit = 124,
      },
      {
        kind = "castSpellName",
        scale = 1,
        anchor = {},
        anchor = {"TOP", 0, -12},
      }
    },
    markers = {
      {
        kind = "quest",
        scale = healthScale * 0.9,
        asset = "normal/quest-blizzard",
        anchor = {"RIGHT", -65, 0}
      },
      {
        kind = "cannotInterrupt",
        scale = healthScale * 0.5,
        asset = "normal/shield-gradient",
        color = GetColor("647b7f"),
        anchor = {"TOPRIGHT", -50, -12}
      }
    }
  }
end

function addonTable.Design.GetDefaultDesignHedgehog()
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
        asset = "wide/glow",
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
        background = {
          asset = "wide/slight-1",
          applyColor = true,
          alpha = 1,
        },
        foreground = {
          asset = "wide/slight-2",
        },
        border = {
          asset = "wide/slight-1",
          color = GetColor("000000")
        },
        marker = {
          asset = "wide/glow",
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
          asset = "wide/glow",
        },
        background = {
          asset = "wide/slight-1",
          applyColor = true,
          alpha = 1,
        },
        foreground = {
          asset = "wide/slight-2",
        },
        border = {
          asset = "wide/slight-1",
          color = GetColor("000000")
        },
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
        kind = "creatureName",
        scale = 1.1,
        anchor = {"BOTTOM", 0, 9},
        widthLimit = 124,
      },
      {
        kind = "castSpellName",
        scale = 1,
        anchor = {},
        anchor = {"TOP", 0, -12},
      }
    },
    markers = {
      {
        kind = "quest",
        scale = healthScale * 0.9,
        asset = "normal/quest-gradient",
        anchor = {"RIGHT", -64, 0}
      },
      {
        kind = "cannotInterrupt",
        scale = healthScale * 0.5,
        asset = "normal/shield-gradient",
        color = GetColor("647b7f"),
        anchor = {"TOPRIGHT", -50, -12}
      }
    }
  }
end

function addonTable.Design.GetDefaultDesignSquirrel()
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
        asset = "wide/soft-glow",
        color = GetColor("999999"),
        scale = healthScale,
      },
    },
    bars = {
      {
        kind = "health",
        anchor = {},
        relativeTo = 0,
        scale = healthScale,
        background = {
          asset = "wide/slight-1",
          applyColor = true,
          alpha = 1,
        },
        foreground = {
          asset = "wide/slight-2",
        },
        border = {
          asset = "wide/soft-1",
          color = GetColor("808080")
        },
        marker = {
          asset = "wide/glow",
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
          asset = "wide/glow",
        },
        background = {
          asset = "wide/slight-1",
          applyColor = true,
          alpha = 1,
        },
        foreground = {
          asset = "wide/slight-2",
        },
        border = {
          asset = "wide/soft-1",
          color = GetColor("AAAAAA")
        },
        scale = healthScale,
      },
    },
    specialBars = {
      {
        kind = "power",
        blank = "normal/soft-faded",
        filled = "normal/soft-full",
        scale = healthScale * 0.60,
        anchor = {0, -7},
      },
    },
    texts = {
      {
        kind = "health",
        scale = 0.98,
        anchor = {},
        displayTypes = {"percentage"}, -- or "absolute", or both
      },
      {
        kind = "creatureName",
        scale = 1.1,
        anchor = {"BOTTOM", 0, 9},
        widthLimit = 124,
      },
      {
        kind = "castSpellName",
        scale = 1,
        anchor = {},
        anchor = {"TOP", 0, -12},
      }
    },
    markers = {
      {
        kind = "quest",
        scale = healthScale * 0.9,
        asset = "normal/quest-gradient",
        anchor = {"RIGHT", -64, 0}
      },
      {
        kind = "cannotInterrupt",
        scale = healthScale * 0.5,
        asset = "normal/shield-soft",
        color = GetColor("647b7f"),
        anchor = {"TOPRIGHT", -50, -12}
      }
    }
  }
end

function addonTable.Design.GetDefaultDesignBlizzard()
  return {
    appliesToAll = true,
    font = {
      asset = "FritzQuadrata",
      flags = "OUTLINE",
    },
    highlights = {
      --[[{
        anchor = {},
        kind = "target",
        asset = "wide/glow",
        color = GetColor("1CE2ED"),
        scale = healthScale,
      },]]
    },
    bars = {
      {
        kind = "health",
        anchor = {},
        relativeTo = 0,
        scale = healthScale,
        background = {
          asset = "wide/blizzard-1",
          applyColor = false,
          alpha = 0.3,
        },
        foreground = {
          asset = "wide/blizzard-1",
        },
        border = {
          asset = "wide/blizzard-normal",
          color = GetColor("DDDDDD")
        },
        marker = {
          asset = "wide/glow",
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
        anchor = {"TOP", 0, -10},
        colors = {
          normal = GetColor("ffbd00"),
          uninterruptable = GetColor("878787")
        },
        marker = {
          asset = "wide/glow",
        },
        background = {
          asset = "transparent",
          applyColor = true,
          alpha = 1,
        },
        foreground = {
          asset = "special/blizzard-cast-bar",
        },
        border = {
          asset = "special/blizzard-cast-bar",
          color = GetColor("FFFFFF")
        },
        scale = healthScale,
      },
    },
    specialBars = {
    },
    texts = {
      {
        kind = "health",
        scale = 0.98,
        anchor = {"RIGHT", 61, 0},
        displayTypes = {"percentage"}, -- or "absolute", or both
      },
      {
        kind = "creatureName",
        scale = 1.1,
        anchor = {"BOTTOM", 0, 10},
        widthLimit = 124,
      },
      {
        kind = "castSpellName",
        scale = 0.8,
        anchor = {},
        anchor = {"LEFT", -61, -20},
      }
    },
    markers = {
      {
        kind = "quest",
        scale = healthScale * 0.9,
        asset = "normal/quest-blizzard",
        anchor = {"RIGHT", -66, -1}
      },
    }
  }
end

function addonTable.Design.GetDefaultDesignSquirrel()
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
        asset = "wide/soft-glow",
        color = GetColor("999999"),
        scale = healthScale,
      },
    },
    bars = {
      {
        kind = "health",
        anchor = {},
        relativeTo = 0,
        scale = healthScale,
        background = {
          asset = "wide/slight-1",
          applyColor = true,
          alpha = 1,
        },
        foreground = {
          asset = "wide/slight-2",
        },
        border = {
          asset = "wide/soft-1",
          color = GetColor("808080")
        },
        marker = {
          asset = "wide/glow",
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
          asset = "wide/glow",
        },
        background = {
          asset = "wide/slight-1",
          applyColor = true,
          alpha = 1,
        },
        foreground = {
          asset = "wide/slight-2",
        },
        border = {
          asset = "wide/soft-1",
          color = GetColor("AAAAAA")
        },
        scale = healthScale,
      },
    },
    specialBars = {
      {
        kind = "power",
        blank = "normal/soft-faded",
        filled = "normal/soft-full",
        scale = healthScale * 0.60,
        anchor = {0, -7},
      },
    },
    texts = {
      {
        kind = "health",
        scale = 0.98,
        anchor = {},
        displayTypes = {"percentage"}, -- or "absolute", or both
      },
      {
        kind = "creatureName",
        scale = 1.1,
        anchor = {"BOTTOM", 0, 9},
        widthLimit = 124,
      },
      {
        kind = "castSpellName",
        scale = 1,
        anchor = {},
        anchor = {"TOP", 0, -12},
      }
    },
    markers = {
      {
        kind = "quest",
        scale = healthScale * 0.9,
        asset = "normal/quest-blizzard",
        anchor = {"RIGHT", -64, 0}
      },
      {
        kind = "cannotInterrupt",
        scale = healthScale * 0.5,
        asset = "normal/shield-soft",
        color = GetColor("647b7f"),
        anchor = {"TOPRIGHT", -50, -12}
      }
    }
  }
end
