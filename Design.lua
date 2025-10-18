---@class addonTablePlatynator
local addonTable = select(2, ...)

local healthScale = 1

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
    auras = {
      {
        kind = "debuffs",
        anchor = {"BOTTOMLEFT", -63, 25},
        scale = 1,
      },
      {
        kind = "buffs",
        anchor = {"RIGHT", -68, 0},
        scale = 1,
        showCountdown = true,
      },
      {
        kind = "crowdControl",
        anchor = {"LEFT", 68, 0},
        scale = 1,
        showCountdown = true,
      },
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
          asset = "wide/fade-bottom",
          alpha = 0.5,
          applyColor = false,
        },
        foreground = {
          asset = "wide/fade-bottom",
        },
        border = {
          asset = "wide/bold",
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
          asset = "wide/fade-bottom",
          alpha = 0.5,
          applyColor = false,
        },
        foreground = {
          asset = "wide/fade-bottom",
        },
        border = {
          asset = "wide/bold",
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
        color = GetColor("FFFFFF"),
      },
      {
        kind = "castSpellName",
        scale = 1,
        anchor = {"TOP", 0, -12},
        color = GetColor("FFFFFF"),
      }
    },
    markers = {
      {
        kind = "quest",
        scale = healthScale * 0.9,
        asset = "normal/quest-blizzard",
        color = GetColor("ffffff"),
        anchor = {"RIGHT", -65, 0}
      },
      {
        kind = "cannotInterrupt",
        scale = healthScale * 0.5,
        asset = "normal/shield-gradient",
        color = GetColor("647b7f"),
        anchor = {"TOPRIGHT", -50, -12}
      },
      {
        kind = "elite",
        scale = healthScale * 0.7,
        asset = "special/blizzard-elite",
        color = GetColor("ffffff"),
        anchor = {"LEFT", -60, 0}
      },
      {
        kind = "raid",
        scale = healthScale,
        asset = "normal/blizzard-raid",
        color = GetColor("ffffff"),
        anchor = {"BOTTOM", 0, 20}
      },
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
    auras = {
      {
        kind = "debuffs",
        anchor = {"BOTTOMLEFT", -63, 25},
        scale = 1,
      },
      {
        kind = "buffs",
        anchor = {"RIGHT", -68, 0},
        scale = 1,
        showCountdown = true,
      },
      {
        kind = "crowdControl",
        anchor = {"LEFT", 68, 0},
        scale = 1,
        showCountdown = true,
      },
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
          asset = "wide/bevelled-grey",
          applyColor = true,
          alpha = 1,
        },
        foreground = {
          asset = "wide/bevelled",
        },
        border = {
          asset = "wide/slight",
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
          asset = "wide/bevelled-grey",
          applyColor = true,
          alpha = 1,
        },
        foreground = {
          asset = "wide/bevelled",
        },
        border = {
          asset = "wide/slight",
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
        color = GetColor("FFFFFF"),
      },
      {
        kind = "creatureName",
        scale = 1.1,
        anchor = {"BOTTOM", 0, 9},
        widthLimit = 124,
        color = GetColor("FFFFFF"),
      },
      {
        kind = "castSpellName",
        scale = 1,
        anchor = {"TOP", 0, -12},
        color = GetColor("FFFFFF"),
      }
    },
    markers = {
      {
        kind = "quest",
        scale = healthScale * 0.9,
        asset = "normal/quest-gradient",
        color = GetColor("ffffff"),
        anchor = {"RIGHT", -64, 0}
      },
      {
        kind = "cannotInterrupt",
        scale = healthScale * 0.5,
        asset = "normal/shield-gradient",
        color = GetColor("647b7f"),
        anchor = {"TOPRIGHT", -50, -12}
      },
      {
        kind = "elite",
        scale = healthScale * 0.8,
        asset = "special/blizzard-elite",
        color = GetColor("ffffff"),
        anchor = {"LEFT", -61, 0}
      },
      {
        kind = "raid",
        scale = healthScale,
        asset = "normal/blizzard-raid",
        color = GetColor("ffffff"),
        anchor = {"BOTTOM", 0, 20}
      },
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
    auras = {
      {
        kind = "debuffs",
        anchor = {"BOTTOMLEFT", -63, 25},
        scale = 1,
      },
      {
        kind = "buffs",
        anchor = {"RIGHT", -68, 0},
        scale = 1,
        showCountdown = true,
      },
      {
        kind = "crowdControl",
        anchor = {"LEFT", 68, 0},
        scale = 1,
        showCountdown = true,
      },
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
          asset = "grey",
          applyColor = false,
          alpha = 1,
        },
        foreground = {
          asset = "wide/fade-left",
        },
        border = {
          asset = "wide/blizzard-health",
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
        color = GetColor("FFFFFF"),
      },
      {
        kind = "creatureName",
        scale = 1.1,
        anchor = {"BOTTOM", 0, 10},
        widthLimit = 124,
        color = GetColor("FFFFFF"),
      },
      {
        kind = "castSpellName",
        scale = 0.8,
        anchor = {"TOPLEFT", -61, -20},
        color = GetColor("FFFFFF"),
      }
    },
    markers = {
      {
        kind = "quest",
        scale = healthScale * 0.9,
        asset = "normal/quest-blizzard",
        color = GetColor("ffffff"),
        anchor = {"RIGHT", -66, -1}
      },
      {
        kind = "elite",
        scale = healthScale * 0.8,
        asset = "special/blizzard-elite",
        color = GetColor("ffffff"),
        anchor = {"LEFT", -61, 0}
      },
      {
        kind = "cannotInterrupt",
        scale = healthScale * 0.5,
        asset = "normal/blizzard-shield",
        color = GetColor("ffffff"),
        anchor = {"TOPLEFT", -65, -9}
      },
      {
        kind = "raid",
        scale = healthScale,
        asset = "normal/blizzard-raid",
        color = GetColor("ffffff"),
        anchor = {"BOTTOM", 0, 20}
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
    auras = {
      {
        kind = "debuffs",
        anchor = {"BOTTOMLEFT", -63, 25},
        scale = 1,
      },
      {
        kind = "buffs",
        anchor = {"RIGHT", -68, 0},
        scale = 1,
        showCountdown = true,
      },
      {
        kind = "crowdControl",
        anchor = {"LEFT", 68, 0},
        scale = 1,
        showCountdown = true,
      },
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
          asset = "wide/bevelled-grey",
          applyColor = true,
          alpha = 1,
        },
        foreground = {
          asset = "wide/bevelled",
        },
        border = {
          asset = "wide/soft",
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
          asset = "wide/bevelled-grey",
          applyColor = true,
          alpha = 1,
        },
        foreground = {
          asset = "wide/bevelled",
        },
        border = {
          asset = "wide/soft",
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
        color = GetColor("FFFFFF"),
      },
      {
        kind = "creatureName",
        scale = 1.1,
        anchor = {"BOTTOM", 0, 9},
        widthLimit = 124,
        color = GetColor("FFFFFF"),
      },
      {
        kind = "castSpellName",
        scale = 1,
        anchor = {"TOP", 0, -12},
        color = GetColor("FFFFFF"),
      }
    },
    markers = {
      {
        kind = "quest",
        scale = healthScale * 0.9,
        asset = "normal/quest-blizzard",
        color = GetColor("ffffff"),
        anchor = {"RIGHT", -64, 0}
      },
      {
        kind = "cannotInterrupt",
        scale = healthScale * 0.5,
        asset = "normal/shield-soft",
        color = GetColor("647b7f"),
        anchor = {"TOPRIGHT", -50, -12}
      },
      {
        kind = "elite",
        scale = healthScale * 0.8,
        asset = "special/blizzard-elite",
        color = GetColor("ffffff"),
        anchor = {"LEFT", -61, 0}
      },
      {
        kind = "raid",
        scale = healthScale,
        asset = "normal/blizzard-raid",
        color = GetColor("ffffff"),
        anchor = {"BOTTOM", 0, 20}
      },
    }
  }
end

function addonTable.Design.GetDefaultDesignHare()
  return {
    appliesToAll = true,
    font = {
      asset = "RobotoCondensed-Bold",
      flags = "OUTLINE",
    },
    auras = {
      {
        kind = "debuffs",
        anchor = {"BOTTOMLEFT", -63, 25},
        scale = 1,
      },
      {
        kind = "buffs",
        anchor = {"RIGHT", -68, 0},
        scale = 1,
        showCountdown = true,
      },
      {
        kind = "crowdControl",
        anchor = {"LEFT", 68, 0},
        scale = 1,
        showCountdown = true,
      },
    },
    highlights = {
      {
        anchor = {},
        kind = "target",
        asset = "wide/glow",
        color = GetColor("ed25cf"),
        scale = healthScale,
      },
      {
        anchor = {},
        kind = "target",
        asset = "wide/arrows",
        color = GetColor("ffffff"),
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
          asset = "grey",
          applyColor = false,
          alpha = 1,
        },
        foreground = {
          asset = "wide/fade-bottom",
        },
        border = {
          asset = "wide/slight",
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
        anchor = {"TOP", 0, -9},
        colors = {
          normal = GetColor("FC8C00"),
          uninterruptable = GetColor("83C0C3")
        },
        marker = {
          asset = "none",
        },
        background = {
          asset = "grey",
          alpha = 1,
        },
        foreground = {
          asset = "wide/fade-bottom",
        },
        border = {
          asset = "wide/slight",
          color = GetColor("000000")
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
        anchor = {},
        displayTypes = {"absolute"}, -- or "absolute", or both
        color = GetColor("FFFFFF"),
      },
      {
        kind = "creatureName",
        scale = 1.1,
        anchor = {"BOTTOM", 0, 9},
        widthLimit = 124,
        color = GetColor("FFFFFF"),
      },
      {
        kind = "castSpellName",
        scale = 1,
        anchor = {"TOP", 0, -12},
        color = GetColor("FFFFFF"),
      }
    },
    markers = {
      {
        kind = "quest",
        scale = healthScale * 0.9,
        asset = "normal/quest-blizzard",
        color = GetColor("ffffff"),
        anchor = {"RIGHT", -64, 0}
      },
      {
        kind = "cannotInterrupt",
        scale = healthScale * 0.5,
        asset = "normal/shield-soft",
        color = GetColor("647b7f"),
        anchor = {"TOPRIGHT", -50, -12}
      },
      {
        kind = "elite",
        scale = healthScale * 0.8,
        asset = "special/blizzard-elite",
        color = GetColor("ffffff"),
        anchor = {"LEFT", -61, 0}
      },
      {
        kind = "raid",
        scale = healthScale,
        asset = "normal/blizzard-raid",
        color = GetColor("ffffff"),
        anchor = {"BOTTOM", 0, 20}
      },
    }
  }
end

function addonTable.Design.GetDefaultDesignBeaver()
  return {
    ["appliesToAll"] = true,
    ["font"] = {
      ["asset"] = "RobotoCondensed-Bold",
      ["flags"] = "OUTLINE"
    },
    ["auras"] = {
      {
        ["anchor"] = {
          "BOTTOMLEFT",
          -63,
          25
        },
        ["kind"] = "debuffs",
        ["scale"] = 1
      },
      {
        ["anchor"] = {
          "RIGHT",
          -68,
          0
        },
        ["kind"] = "buffs",
        ["showCountdown"] = true,
        ["scale"] = 1
      },
      {
        ["anchor"] = {
          "LEFT",
          68,
          0
        },
        ["kind"] = "crowdControl",
        ["showCountdown"] = true,
        ["scale"] = 1
      }
    },
    ["highlights"] = {
      {
        ["scale"] = 1,
        ["anchor"] = {},
        ["kind"] = "target",
        ["asset"] = "wide/soft-glow-narrow",
        ["color"] = {
          ["b"] = 0.6,
          ["g"] = 0.6,
          ["r"] = 0.6
        }
      }
    },
    ["bars"] = {
      {
        ["relativeTo"] = 0,
        ["scale"] = 1,
        ["border"] = {
          ["asset"] = "narrow/soft",
          ["color"] = {
            ["b"] = 0.5019607843137255,
            ["g"] = 0.5019607843137255,
            ["r"] = 0.5019607843137255
          }
        },
        ["colors"] = {
          ["npc"] = {
            ["neutral"] = {
              ["b"] = 0,
              ["g"] = 1,
              ["r"] = 1
            },
            ["friendly"] = {
              ["b"] = 0,
              ["g"] = 1,
              ["r"] = 0
            },
            ["hostile"] = {
              ["b"] = 0,
              ["g"] = 0,
              ["r"] = 1
            }
          },
          ["threat"] = {
            ["transition"] = {
              ["b"] = 0,
              ["g"] = 0.6274509803921569,
              ["r"] = 1
            },
            ["safe"] = {
              ["b"] = 0.9019607843137255,
              ["g"] = 0.5882352941176471,
              ["r"] = 0.05882352941176471
            },
            ["warning"] = {
              ["b"] = 0,
              ["g"] = 0,
              ["r"] = 0.8
            }
          }
        },
        ["marker"] = {
          ["asset"] = "wide/glow"
        },
        ["anchor"] = {},
        ["kind"] = "health",
        ["foreground"] = {
          ["asset"] = "wide/bevelled"
        },
        ["background"] = {
          ["applyColor"] = true,
          ["asset"] = "wide/bevelled-grey",
          ["alpha"] = 1
        }
      },
      {
        ["scale"] = 1,
        ["background"] = {
          ["applyColor"] = true,
          ["asset"] = "wide/bevelled-grey",
          ["alpha"] = 1
        },
        ["colors"] = {
          ["normal"] = {
            ["b"] = 0,
            ["g"] = 0.5490196078431373,
            ["r"] = 0.9882352941176471
          },
          ["uninterruptable"] = {
            ["b"] = 0.7647058823529411,
            ["g"] = 0.7529411764705882,
            ["r"] = 0.5137254901960784
          }
        },
        ["foreground"] = {
          ["asset"] = "wide/bevelled"
        },
        ["anchor"] = {
          "TOP",
          0,
          -6
        },
        ["kind"] = "cast",
        ["border"] = {
          ["asset"] = "narrow/soft",
          ["color"] = {
            ["b"] = 0.6666666666666666,
            ["g"] = 0.6666666666666666,
            ["r"] = 0.6666666666666666
          }
        },
        ["marker"] = {
          ["asset"] = "wide/glow"
        }
      }
    },
    ["specialBars"] = {},
    ["texts"] = {
      {
        ["displayTypes"] = {
          "percentage"
        },
        ["scale"] = 0.93,
        ["kind"] = "health",
        ["color"] = {
          ["b"] = 1,
          ["g"] = 1,
          ["r"] = 1
        },
        ["anchor"] = {}
      },
      {
        ["widthLimit"] = 124,
        ["scale"] = 1.05,
        ["kind"] = "creatureName",
        ["color"] = {
          ["b"] = 1,
          ["g"] = 1,
          ["r"] = 1
        },
        ["anchor"] = {
          "BOTTOM",
          0,
          9
        }
      },
      {
        ["widthLimit"] = 0,
        ["anchor"] = {
          "TOPLEFT",
          -61,
          -6
        },
        ["kind"] = "castSpellName",
        ["scale"] = 0.88,
        ["color"] = {
          ["b"] = 1,
          ["g"] = 1,
          ["r"] = 1
        }
      }
    },
    ["markers"] = {
      {
        ["anchor"] = {
          "RIGHT",
          -64,
          0
        },
        ["scale"] = 0.8,
        ["kind"] = "quest",
        ["asset"] = "normal/quest-blizzard",
        ["color"] = {
          ["b"] = 1,
          ["g"] = 1,
          ["r"] = 1
        }
      },
      {
        ["anchor"] = {
          "TOPLEFT",
          -73,
          -4
        },
        ["scale"] = 0.6,
        ["kind"] = "cannotInterrupt",
        ["asset"] = "normal/shield-soft",
        ["color"] = {
          ["b"] = 0.4980392156862745,
          ["g"] = 0.4823529411764706,
          ["r"] = 0.392156862745098
        }
      },
      {
        ["anchor"] = {
          "BOTTOMLEFT",
          -64,
          -3
        },
        ["scale"] = 0.7,
        ["kind"] = "elite",
        ["asset"] = "special/blizzard-elite",
        ["color"] = {
          ["b"] = 1,
          ["g"] = 1,
          ["r"] = 1
        }
      },
      {
        ["anchor"] = {
          "BOTTOM",
          0,
          20
        },
        ["scale"] = 1,
        ["kind"] = "raid",
        ["asset"] = "normal/blizzard-raid",
        ["color"] = {
          ["b"] = 1,
          ["g"] = 1,
          ["r"] = 1
        }
      }
    },
  }
end

function addonTable.Design.GetDefaultDesignBlizzardClassic()
  return {
    ["appliesToAll"] = true,
    ["font"] = {
      ["asset"] = "FritzQuadrata",
      ["flags"] = "OUTLINE"
    },
    ["specialBars"] = {},
    ["auras"] = {
      {
        ["anchor"] = {
          "BOTTOMLEFT",
          -63,
          25
        },
        ["kind"] = "debuffs",
        ["showCountdown"] = true,
        ["scale"] = 1
      },
      {
        ["anchor"] = {
          "RIGHT",
          -68,
          0
        },
        ["kind"] = "buffs",
        ["showCountdown"] = true,
        ["scale"] = 1
      },
      {
        ["anchor"] = {
          "LEFT",
          68,
          0
        },
        ["kind"] = "crowdControl",
        ["showCountdown"] = true,
        ["scale"] = 1
      }
    },
    ["highlights"] = {},
    ["bars"] = {
      {
        ["relativeTo"] = 0,
        ["scale"] = 1,
        ["border"] = {
          ["asset"] = "wide/blizzard-classic-level",
          ["color"] = {
            ["a"] = 1,
            ["r"] = 1,
            ["g"] = 0.760784387588501,
            ["b"] = 0.2117647230625153
          }
        },
        ["colors"] = {
          ["npc"] = {
            ["neutral"] = {
              ["b"] = 0.06274509803921569,
              ["g"] = 0.7764705882352941,
              ["r"] = 0.788235294117647
            },
            ["friendly"] = {
              ["b"] = 0.00784313725490196,
              ["g"] = 0.807843137254902,
              ["r"] = 0.05490196078431373
            },
            ["hostile"] = {
              ["b"] = 0.196078431372549,
              ["g"] = 0.1921568627450981,
              ["r"] = 0.9921568627450981
            }
          },
          ["threat"] = {
            ["transition"] = {
              ["r"] = 1,
              ["g"] = 0.6274509803921569,
              ["b"] = 0
            },
            ["safe"] = {
              ["r"] = 0.05882352941176471,
              ["g"] = 0.5882352941176471,
              ["b"] = 0.9019607843137255
            },
            ["warning"] = {
              ["b"] = 0.196078431372549,
              ["g"] = 0.1921568627450981,
              ["r"] = 0.9921568627450981
            }
          }
        },
        ["kind"] = "health",
        ["anchor"] = {},
        ["background"] = {
          ["applyColor"] = true,
          ["asset"] = "grey",
          ["alpha"] = 1
        },
        ["foreground"] = {
          ["asset"] = "wide/fade-bottom"
        },
        ["marker"] = {
          ["asset"] = "wide/glow"
        }
      },
      {
        ["anchor"] = {
          "TOP",
          0,
          -8
        },
        ["marker"] = {
          ["asset"] = "wide/glow"
        },
        ["colors"] = {
          ["normal"] = {
            ["r"] = 0.9882352941176471,
            ["g"] = 0.5490196078431373,
            ["b"] = 0
          },
          ["uninterruptable"] = {
            ["r"] = 0.5137254901960784,
            ["g"] = 0.7529411764705882,
            ["b"] = 0.7647058823529411
          }
        },
        ["kind"] = "cast",
        ["foreground"] = {
          ["asset"] = "wide/fade-bottom"
        },
        ["background"] = {
          ["applyColor"] = true,
          ["asset"] = "grey",
          ["alpha"] = 1
        },
        ["border"] = {
          ["asset"] = "wide/blizzard-classic",
          ["color"] = {
            ["r"] = 0.6666666666666666,
            ["g"] = 0.6666666666666666,
            ["b"] = 0.6666666666666666
          }
        },
        ["scale"] = 1
      }
    },
    ["markers"] = {
      {
        ["anchor"] = {
          "RIGHT",
          -64,
          0
        },
        ["scale"] = 0.9,
        ["kind"] = "quest",
        ["asset"] = "normal/quest-blizzard",
        ["color"] = {
          ["r"] = 1,
          ["g"] = 1,
          ["b"] = 1
        }
      },
      {
        ["anchor"] = {
          "TOPLEFT",
          -68,
          -10
        },
        ["scale"] = 0.53,
        ["kind"] = "cannotInterrupt",
        ["asset"] = "normal/blizzard-shield",
        ["color"] = {
          ["r"] = 0.392156862745098,
          ["g"] = 0.4823529411764706,
          ["b"] = 0.4980392156862745
        }
      },
      {
        ["anchor"] = {
          "LEFT",
          -61,
          0
        },
        ["scale"] = 0.8,
        ["kind"] = "elite",
        ["asset"] = "special/blizzard-elite",
        ["color"] = {
          ["r"] = 1,
          ["g"] = 1,
          ["b"] = 1
        }
      },
      {
        ["anchor"] = {
          "BOTTOM",
          0,
          20
        },
        ["scale"] = 1,
        ["kind"] = "raid",
        ["asset"] = "normal/blizzard-raid",
        ["color"] = {
          ["r"] = 1,
          ["g"] = 1,
          ["b"] = 1
        }
      }
    },
    ["texts"] = {
      {
        ["widthLimit"] = 124,
        ["scale"] = 1,
        ["kind"] = "creatureName",
        ["anchor"] = {
          "BOTTOM",
          0,
          9
        },
        ["color"] = {
          ["r"] = 1,
          ["g"] = 1,
          ["b"] = 1
        }
      },
      {
        ["scale"] = 0.95,
        ["kind"] = "castSpellName",
        ["anchor"] = {
          "TOP",
          0,
          -11
        },
        ["color"] = {
          ["r"] = 1,
          ["g"] = 1,
          ["b"] = 1
        }
      },
      {
        ["widthLimit"] = 18,
        ["color"] = {
          ["r"] = 0.874509871006012,
          ["g"] = 1,
          ["b"] = 0
        },
        ["kind"] = "level",
        ["scale"] = 1,
        ["anchor"] = {
          "RIGHT",
          82,
          0
        }
      }
    }
  }
end
