---@class addonTablePlatynator
local addonTable = select(2, ...)

local function GetColor(rgb)
  local color = CreateColorFromRGBHexString(rgb)
  return {r = color.r, g = color.g, b = color.b}
end

addonTable.CustomiseDialog.ColorsConfig = {
  ["tapped"] = {
    label = addonTable.Locales.TAPPED,
    default = {
      kind = "tapped",
      colors = {
        tapped = GetColor("6E6E6E"),
      }
    },
    entries = {
      {
        label = addonTable.Locales.TAPPED,
        kind = "colorPicker",
        setter = function(details, value)
          details.colors.tapped = value
        end,
        getter = function(details)
          return details.colors.tapped
        end,
      },
    },
  },
  ["target"] = {
    label = addonTable.Locales.TARGET,
    default = {
      kind = "target",
      colors = {
        target = GetColor("34edd1"),
      },
    },
    entries = {
      {
        label = addonTable.Locales.TARGET,
        kind = "colorPicker",
        setter = function(details, value)
          details.colors.target = value
        end,
        getter = function(details)
          return details.colors.target
        end,
      },
    },
  },
  ["focus"] = {
    label = addonTable.Locales.FOCUS,
    default = {
      kind = "focus",
      colors = {
        focus = GetColor("46ad32"),
      },
    },
    entries = {
      {
        label = addonTable.Locales.FOCUS,
        kind = "colorPicker",
        setter = function(details, value)
          details.colors.focus = value
        end,
        getter = function(details)
          return details.colors.focus
        end,
      },
    },
  },
  ["threat"] = {
    label = addonTable.Locales.THREAT,
    default = {
      kind = "threat",
      colors = {
        safe = GetColor("0F96E6"),
        transition = GetColor("FFA000"),
        warning = GetColor("CC0000"),
        offtank = GetColor("0FAAC8"),
      },
      instancesOnly = false,
      combatOnly = true,
    },
    entries = {
      {
        label = addonTable.Locales.SAFE,
        kind = "colorPicker",
        setter = function(details, value)
          details.colors.safe = value
        end,
        getter = function(details)
          return details.colors.safe
        end,
      },
      {
        label = addonTable.Locales.OFFTANK,
        kind = "colorPicker",
        setter = function(details, value)
          details.colors.offtank = value
        end,
        getter = function(details)
          return details.colors.offtank
        end,
      },
      {
        label = addonTable.Locales.TRANSITION,
        kind = "colorPicker",
        setter = function(details, value)
          details.colors.transition = value
        end,
        getter = function(details)
          return details.colors.transition
        end,
      },
      {
        label = addonTable.Locales.WARNING,
        kind = "colorPicker",
        setter = function(details, value)
          details.colors.warning = value
        end,
        getter = function(details)
          return details.colors.warning
        end,
      },
      { kind = "spacer" },
      {
        label = addonTable.Locales.ONLY_APPLY_IN_COMBAT,
        kind = "checkbox",
        setter = function(details, value)
          details.combatOnly = value
        end,
        getter = function(details)
          return details.combatOnly
        end,
      },
      {
        label = addonTable.Locales.ONLY_APPLY_IN_INSTANCES,
        kind = "checkbox",
        setter = function(details, value)
          details.instancesOnly = value
        end,
        getter = function(details)
          return details.instancesOnly
        end,
      },
    },
  },
  ["eliteType"] = {
    label = addonTable.Locales.ELITE_TYPE,
    default = {
      kind = "eliteType",
      colors = {
        boss = GetColor("bc1c00"),
        miniboss = GetColor("9000bc"),
        caster = GetColor("0074bc"),
        melee = GetColor("fcfcfc"),
      },
      instancesOnly = true,
    },
    entries = {
      {
        label = addonTable.Locales.BOSS,
        kind = "colorPicker",
        setter = function(details, value)
          details.colors.boss = value
        end,
        getter = function(details)
          return details.colors.boss
        end,
      },
      {
        label = addonTable.Locales.MINIBOSS,
        kind = "colorPicker",
        setter = function(details, value)
          details.colors.miniboss = value
        end,
        getter = function(details)
          return details.colors.miniboss
        end,
      },
      {
        label = addonTable.Locales.CASTER,
        kind = "colorPicker",
        setter = function(details, value)
          details.colors.caster = value
        end,
        getter = function(details)
          return details.colors.caster
        end,
      },
      {
        label = addonTable.Locales.MELEE,
        kind = "colorPicker",
        setter = function(details, value)
          details.colors.melee = value
        end,
        getter = function(details)
          return details.colors.melee
        end,
      },
      { kind = "spacer" },
      {
        label = addonTable.Locales.ONLY_APPLY_IN_INSTANCES,
        kind = "checkbox",
        setter = function(details, value)
          details.instancesOnly = value
        end,
        getter = function(details)
          return details.instancesOnly
        end,
      },
    },
  },
  ["quest"] = {
    label = addonTable.Locales.QUEST,
    default = {
      kind = "quest",
      colors = {
        quest = GetColor("FFFFFF"),
      },
    },
    entries = {
      {
        label = addonTable.Locales.QUEST,
        kind = "colorPicker",
        setter = function(details, value)
          details.colors.quest = value
        end,
        getter = function(details)
          return details.colors.quest
        end,
      },
    },
  },
  ["guild"] = {
    label = addonTable.Locales.GUILD,
    default = {
      kind = "guild",
      colors = {
        guild = GetColor("3bbc14")
      },
    },
    entries = {
      {
        label = addonTable.Locales.GUILD,
        kind = "colorPicker",
        setter = function(details, value)
          details.colors.guild = value
        end,
        getter = function(details)
          return details.colors.guild
        end,
      },
    },
  },
  ["classColors"] = {
    label = addonTable.Locales.CLASS_COLORS,
    default = {
      kind = "classColors",
    },
    entries = {},
  },
  ["reaction"] = {
    label = addonTable.Locales.REACTION,
    default = {
      kind = "reaction",
      colors = {
        friendly = GetColor("00FF00"),
        neutral = GetColor("FFFF00"),
        unfriendly = GetColor("ff8100"),
        hostile = GetColor("FF0000"),
      },
    },
    entries = {
      {
        label = addonTable.Locales.FRIENDLY,
        kind = "colorPicker",
        setter = function(details, value)
          details.colors.friendly = value
        end,
        getter = function(details)
          return details.colors.friendly
        end,
      },
      {
        label = addonTable.Locales.NEUTRAL,
        kind = "colorPicker",
        setter = function(details, value)
          details.colors.neutral = value
        end,
        getter = function(details)
          return details.colors.neutral
        end,
      },
      {
        label = addonTable.Locales.UNFRIENDLY,
        kind = "colorPicker",
        setter = function(details, value)
          details.colors.unfriendly = value
        end,
        getter = function(details)
          return details.colors.unfriendly
        end,
      },
      {
        label = addonTable.Locales.HOSTILE,
        kind = "colorPicker",
        setter = function(details, value)
          details.colors.hostile = value
        end,
        getter = function(details)
          return details.colors.hostile
        end,
      },
    },
  },
  ["difficulty"] = {
    label = addonTable.Locales.DIFFICULTY,
    default = {
      kind = "difficulty",
      colors = {
        impossible = {r = 1.00, g = 0.10, b = 0.10},
        verydifficult = {r = 1.00, g = 0.50, b = 0.25},
        difficult = {r = 1.00, g = 0.82, b = 0.00},
        standard = {r = 0.25, g = 0.75, b = 0.25},
        trivial = {r = 0.50, g = 0.50, b = 0.50},
      },
    },
    entries = {
      {
        label = addonTable.Locales.TRIVIAL,
        kind = "colorPicker",
        setter = function(details, value)
          details.colors.trivial = value
        end,
        getter = function(details)
          return details.colors.trivial
        end,
      },
      {
        label = addonTable.Locales.STANDARD,
        kind = "colorPicker",
        setter = function(details, value)
          details.colors.standard = value
        end,
        getter = function(details)
          return details.colors.standard
        end,
      },
      {
        label = addonTable.Locales.DIFFICULT,
        kind = "colorPicker",
        setter = function(details, value)
          details.colors.difficult = value
        end,
        getter = function(details)
          return details.colors.difficult
        end,
      },
      {
        label = addonTable.Locales.VERY_DIFFICULT,
        kind = "colorPicker",
        setter = function(details, value)
          details.colors.verydifficult = value
        end,
        getter = function(details)
          return details.colors.verydifficult
        end,
      },
      {
        label = addonTable.Locales.IMPOSSIBLE,
        kind = "colorPicker",
        setter = function(details, value)
          details.colors.impossible = value
        end,
        getter = function(details)
          return details.colors.impossible
        end,
      },
    },
  },
  ["fixed"] = {
    label = addonTable.Locales.FIXED,
    default = {
      kind = "fixed",
      colors = {
        fixed = GetColor("FFFFFF"),
      },
    },
    entries = {
      {
        label = addonTable.Locales.FIXED,
        kind = "colorPicker",
        setter = function(details, value)
          details.colors.fixed = value
        end,
        getter = function(details)
          return details.colors.fixed
        end,
      },
    },
  },
}

addonTable.CustomiseDialog.ColorsConfigOrder = {
  "tapped",
  "target",
  "focus",
  "threat",
  "eliteType",
  "quest",
  "guild",
  "classColors",
  "difficulty",
  "reaction",
}
