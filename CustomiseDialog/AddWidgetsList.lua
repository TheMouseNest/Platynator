---@class addonTablePlatynator
local addonTable = select(2, ...)

local function GetColor(rgb)
  local color = CreateColorFromRGBHexString(rgb)
  return {r = color.r, g = color.g, b = color.b}
end

addonTable.CustomiseDialog.DesignWidgets = {
  {
    name = addonTable.Locales.BARS,
    special = "header",
  },
  {
    name = addonTable.Locales.HEALTH,
    kind = "bars",
    default = {
      kind = "health",
      anchor = {"TOPLEFT", -140, 50},
      relativeTo = 0,
      scale = 1,
      aggroColoursOnHostiles = true,
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
      absorb = {
        asset = "wide/blizzard-absorb",
        color = GetColor("FFFFFF")
      },
      marker = {
        asset = "none",
      },
      colors = {
        threat = {
          safe = GetColor("0F96E6"),
          transition = GetColor("FFA000"),
          warning = GetColor("CC0000"),
          offtank = GetColor("0FAAC8"),
        },
        npc = {
          friendly = GetColor("00FF00"),
          neutral = GetColor("FFFF00"),
          hostile = GetColor("FF0000"),
          tapped = GetColor("6E6E6E"),
        },
      },
    },
  },
  {
    name = addonTable.Locales.CAST,
    kind = "bars",
    default = {
      kind = "cast",
      anchor = {"TOPLEFT", -140, 50},
      colors = {
        normal = GetColor("FC8C00"),
        uninterruptable = GetColor("83C0C3"),
        interrupted = CreateColorFromRGBHexString("FC36E0"),
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
      scale = 1,
    },
  },
  {
    name = addonTable.Locales.POWER,
    kind = "specialBars",
    default = {
      kind = "power",
      blank = "normal/soft-faded",
      filled = "normal/soft-full",
      scale = 1 * 0.60,
      anchor = {"TOPLEFT", -140, 50},
    },
  },
  {
    name = addonTable.Locales.HIGHLIGHTS,
    special = "header",
  },
  {
    name = addonTable.Locales.TARGETED,
    kind = "highlights",
    default = {
      anchor = {"TOPLEFT", -140, 50},
      kind = "target",
      asset = "wide/glow",
      color = GetColor("FFFFFF"),
      scale = 1,
    },
  },
  {
    name = addonTable.Locales.AURAS,
    special = "header",
  },
  {
    name = addonTable.Locales.DEBUFFS,
    kind = "auras",
    noDuplicates = true,
    default = {
      kind = "debuffs",
      anchor = {"TOPLEFT", -140, 50},
      scale = 1,
      showCountdown = true,
      direction = "RIGHT",
    },
  },
  {
    name = addonTable.Locales.BUFFS,
    kind = "auras",
    noDuplicates = true,
    default = {
      kind = "buffs",
      anchor = {"TOPLEFT", -140, 50},
      scale = 1,
      showCountdown = true,
      direction = "LEFT",
    },
  },
  {
    name = addonTable.Locales.CROWD_CONTROL,
    kind = "auras",
    noDuplicates = true,
    default = {
      kind = "crowdControl",
      anchor = {"TOPLEFT", -140, 50},
      scale = 1,
      showCountdown = true,
      direction = "RIGHT",
    },
  },
  {
    name = addonTable.Locales.TEXTS,
    special = "header",
  },
  {
    name = addonTable.Locales.CREATURE_NAME,
    kind = "texts",
    default = {
      kind = "creatureName",
      scale = 1.1,
      anchor = {"TOPLEFT", -140, 50},
      widthLimit = 124,
      color = GetColor("FFFFFF"),
      align = "CENTER",
      truncate = "NONE",
      applyClassColors = false,
      colors = {
        npc = {
          friendly = GetColor("00FF00"),
          neutral = GetColor("FFFF00"),
          hostile = GetColor("FF0000"),
          tapped = GetColor("6E6E6E"),
        },
      },
    },
  },
  {
    name = addonTable.Locales.GUILD,
    kind = "texts",
    default = {
      kind = "guild",
      scale = 1,
      anchor = {"TOPLEFT", -140, 50},
      widthLimit = 124,
      color = GetColor("FFFFFF"),
      align = "CENTER",
      truncate = "NONE",
    },
  },
  {
    name = addonTable.Locales.HEALTH_VALUE,
    kind = "texts",
    default = {
      kind = "health",
      scale = 0.98,
      anchor = {"TOPLEFT", -140, 50},
      displayTypes = {"percentage"}, -- or "absolute", or both
      color = GetColor("FFFFFF"),
      align = "CENTER",
      truncate = "NONE",
    },
  },
  {
    name = addonTable.Locales.CAST_NAME,
    kind = "texts",
    default = {
      kind = "castSpellName",
      scale = 1,
      anchor = {"TOPLEFT", -140, 50},
      color = GetColor("FFFFFF"),
      align = "CENTER",
      truncate = "NONE",
      colors = {
        npc = {
          friendly = GetColor("00FF00"),
          neutral = GetColor("FFFF00"),
          hostile = GetColor("FF0000"),
          tapped = GetColor("6E6E6E"),
        },
      },
    },
  },
  {
    name = addonTable.Locales.LEVEL,
    kind = "texts",
    default = {
      kind = "level",
      scale = 1,
      anchor = {"TOPLEFT", -140, 50},
      color = GetColor("FFFFFF"),
      align = "CENTER",
      truncate = "NONE",
      applyDifficultyColors = true,
      colors = {
        difficulty = {
          impossible = {r = 1.00, g = 0.10, b = 0.10},
          verydifficult = {r = 1.00, g = 0.50, b = 0.25},
          difficult = {r = 1.00, g = 0.82, b = 0.00},
          standard = {r = 0.25, g = 0.75, b = 0.25},
          trivial = {r = 0.50, g = 0.50, b = 0.50},
        }
      },
    },
  },
  {
    name = addonTable.Locales.TARGET,
    kind = "texts",
    default = {
      kind = "target",
      scale = 1,
      anchor = {"TOPLEFT", -140, 50},
      color = GetColor("FFFFFF"),
      applyClassColors = true,
      align = "CENTER",
      truncate = "NONE",
    },
  },
  {
    name = addonTable.Locales.CAST_TARGET,
    kind = "texts",
    default = {
      kind = "castTarget",
      scale = 1,
      anchor = {"TOPLEFT", -140, 50},
      color = GetColor("FFFFFF"),
      applyClassColors = true,
      align = "CENTER",
      truncate = "NONE",
    },
  },
  {
    name = addonTable.Locales.ICONS,
    special = "header",
  },
  {
    name = addonTable.Locales.QUEST_OBJECTIVE,
    kind = "markers",
    default = {
      kind = "quest",
      scale = 1 * 0.9,
      asset = "normal/quest-blizzard",
      color = GetColor("ffffff"),
      anchor = {"TOPLEFT", -140, 50},
    },
  },
  {
    name = addonTable.Locales.CAST,
    kind = "markers",
    default = {
      kind = "castIcon",
      scale = 1,
      asset = "normal/cast-icon",
      color = GetColor("ffffff"),
      anchor = {"TOPLEFT", -140, 50},
    },
  },
  {
    name = addonTable.Locales.CANNOT_INTERRUPT,
    kind = "markers",
    default = {
      kind = "cannotInterrupt",
      scale = 1 * 0.5,
      asset = "normal/shield-soft",
      color = GetColor("647b7f"),
      anchor = {"TOPLEFT", -140, 50},
    },
  },
  {
    name = addonTable.Locales.ELITE,
    kind = "markers",
    default = {
      kind = "elite",
      scale = 1 * 0.8,
      asset = "special/blizzard-elite",
      color = GetColor("ffffff"),
      anchor = {"TOPLEFT", -140, 50},
    },
  },
  {
    name = addonTable.Locales.RARE,
    kind = "markers",
    default = {
      kind = "rare",
      scale = 1,
      asset = "normal/blizzard-rare",
      color = GetColor("ffffff"),
      anchor = {"TOPLEFT", -140, 50},
    },
  },
  {
    name = addonTable.Locales.PVP,
    kind = "markers",
    default = {
      kind = "pvp",
      scale = 1,
      asset = "normal/blizzard-pvp",
      color = GetColor("ffffff"),
      anchor = {"TOPLEFT", -140, 50},
    },
  },
  {
    name = addonTable.Locales.RAID_MARKER,
    kind = "markers",
    default = {
      kind = "raid",
      scale = 1,
      asset = "normal/blizzard-raid",
      color = GetColor("ffffff"),
      anchor = {"TOPLEFT", -140, 50},
    },
  },
}
