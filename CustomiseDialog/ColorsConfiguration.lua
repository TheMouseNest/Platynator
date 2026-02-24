---@class addonTablePlatynator
local addonTable = select(2, ...)

local function GetColor(rgb)
  local color = CreateColorFromRGBHexString(rgb)
  return {r = color.r, g = color.g, b = color.b}
end

function addonTable.CustomiseDialog.AddAlphaToColors(details)
  for _, c in pairs(details.colors) do
    c.a = 1
  end
  
  return details
end

local function BuildSection(label, key)
  return {
    label = label,
    kind = "section",
    fields = {
      {
        kind = "colorPicker",
        label = addonTable.Locales.COLOR,
        setter = function(details, value)
          details.colors[key] = value
        end,
        getter = function(details)
          return details.colors[key]
        end,
      },
      {
        kind = "texture",
        label = addonTable.Locales.FOREGROUND,
        getter = function(details)
          return details.textures and details.textures[key] or ""
        end,
        setter = function(details, value)
          if value == "" then
            if details.textures then
              details.textures[key] = nil
              if next(details.textures) == nil then
                details.textures = nil
              end
            end
          else
            if not details.textures then
              details.textures = {}
            end
            details.textures[key] = value
          end
        end,
      },
    },
  }
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
      BuildSection(addonTable.Locales.TAPPED, "tapped"),
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
      BuildSection(addonTable.Locales.TARGET, "target"),
    },
  },
  ["softTarget"] = {
    label = addonTable.Locales.SOFT_TARGET,
    default = {
      kind = "softTarget",
      colors = {
        softTarget = GetColor("34edd1"),
      },
    },
    entries = {
      BuildSection(addonTable.Locales.SOFT_TARGET_SENTENCE_CASE, "softTarget"),
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
      BuildSection(addonTable.Locales.FOCUS, "focus"),
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
      BuildSection(addonTable.Locales.SAFE, "safe"),
      BuildSection(addonTable.Locales.OFFTANK, "offtank"),
      BuildSection(addonTable.Locales.TRANSITION, "transition"),
      BuildSection(addonTable.Locales.WARNING, "warning"),
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
      {
        label = addonTable.Locales.USE_SAFE_COLOR,
        kind = "checkbox",
        setter = function(details, value)
          details.useSafeColor = value
        end,
        getter = function(details)
          return details.useSafeColor
        end,
      },
    },
  },
  ["rarity"] = {
    label = addonTable.Locales.RARITY,
    default = {
      kind = "rarity",
      colors = {
        rare = GetColor("d5d5d5"),
        rareElite = GetColor("f8de7e"),
      },
    },
    entries = {
      BuildSection(addonTable.Locales.RARE, "rare"),
      BuildSection(addonTable.Locales.RARE_ELITE, "rareElite"),
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
        trivial = GetColor("b28e55"),
      },
      instancesOnly = true,
    },
    entries = {
      BuildSection(addonTable.Locales.BOSS, "boss"),
      BuildSection(addonTable.Locales.MINIBOSS, "miniboss"),
      BuildSection(addonTable.Locales.CASTER, "caster"),
      BuildSection(addonTable.Locales.MELEE, "melee"),
      BuildSection(addonTable.Locales.TRIVIAL, "trivial"),
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
        friendly = GetColor("E0FF00"),
        neutral = GetColor("FFEC4A"),
        hostile = GetColor("FFB963"),
      },
    },
    entries = {
      BuildSection(addonTable.Locales.FRIENDLY, "friendly"),
      BuildSection(addonTable.Locales.NEUTRAL, "neutral"),
      BuildSection(addonTable.Locales.HOSTILE, "hostile"),
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
      BuildSection(addonTable.Locales.GUILD, "guild"),
    },
  },
  ["classColors"] = {
    label = addonTable.Locales.CLASS_COLORS,
    default = {
      kind = "classColors",
      colors = {},
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
      BuildSection(addonTable.Locales.FRIENDLY, "friendly"),
      BuildSection(addonTable.Locales.NEUTRAL, "neutral"),
      BuildSection(addonTable.Locales.UNFRIENDLY, "unfriendly"),
      BuildSection(addonTable.Locales.HOSTILE, "hostile"),
    },
  },
  ["difficulty"] = {
    label = addonTable.Locales.DIFFICULTY,
    default = {
      kind = "difficulty",
      colors = {
        impossible = { r = 1.00, g = 0.10, b = 0.10 },
        verydifficult = { r = 1.00, g = 0.50, b = 0.25 },
        difficult = { r = 1.00, g = 0.82, b = 0.00 },
        standard = { r = 0.25, g = 0.75, b = 0.25 },
        trivial = { r = 0.50, g = 0.50, b = 0.50 },
      },
    },
    entries = {
      BuildSection(addonTable.Locales.TRIVIAL, "trivial"),
      BuildSection(addonTable.Locales.STANDARD, "standard"),
      BuildSection(addonTable.Locales.DIFFICULT, "difficult"),
      BuildSection(addonTable.Locales.VERY_DIFFICULT, "verydifficult"),
      BuildSection(addonTable.Locales.IMPOSSIBLE, "impossible"),
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
      BuildSection(addonTable.Locales.FIXED, "fixed"),
    },
  },
  ["interruptReady"] = {
    label = addonTable.Locales.INTERRUPT_READY,
    default = {
      kind = "interruptReady",
      colors = {
        ready = GetColor("00FF00"),
      },
    },
    entries = {
      BuildSection(addonTable.Locales.READY, "ready"),
    },
  },
  ["castTargetsYou"] = {
    label = addonTable.Locales.CAST_TARGETS_YOU,
    default = {
      kind = "castTargetsYou",
      colors = {
        targeted = GetColor("FF0000"),
      },
    },
    entries = {
      BuildSection(addonTable.Locales.TARGETED, "targeted"),
    },
  },
  ["importantCast"] = {
    label = addonTable.Locales.IMPORTANT_CAST,
    default = {
      kind = "importantCast",
      colors = {
        cast = GetColor("FF1827"),
        channel = GetColor("0A43FF"),
      },
    },
    entries = {
      BuildSection(addonTable.Locales.CAST, "cast"),
      BuildSection(addonTable.Locales.CHANNEL, "channel"),
    }
  },
  ["cast"] = {
    label = addonTable.Locales.CASTING,
    default = {
      kind = "cast",
      colors = {
        cast = GetColor("FC8C00"),
        channel = GetColor("3EC637"),
        interrupted = GetColor("FC36E0"),
      },
    },
    entries = {
      BuildSection(addonTable.Locales.CAST, "cast"),
      BuildSection(addonTable.Locales.CHANNEL, "channel"),
      BuildSection(addonTable.Locales.INTERRUPTED_CAST, "interrupted"),
    }
  },
  ["uninterruptableCast"] = {
    label = addonTable.Locales.UNINTERRUPTABLE_CAST,
    default = {
      kind = "uninterruptableCast",
      colors = {
        uninterruptable = GetColor("83C0C3"),
      },
    },
    entries = {
      BuildSection(addonTable.Locales.UNINTERRUPTABLE, "uninterruptable"),
    }
  },
  ["execute"] = {
    label = addonTable.Locales.EXECUTE,
    default = {
      kind = "execute",
      colors = {
        execute = GetColor("D1D1D1"),
      },
    },
    entries = {
      BuildSection(addonTable.Locales.EXECUTE, "execute"),
    }
  },
}

addonTable.CustomiseDialog.ColorsConfigOrder = {
  "tapped",
  "target",
  "softTarget",
  "focus",
  "threat",
  "eliteType",
  "rarity",
  "quest",
  "guild",
  "classColors",
  "difficulty",
  "execute",
  "reaction",
  "interruptReady",
  "castTargetsYou",
  "importantCast",
  "uninterruptableCast",
  "cast",
}
