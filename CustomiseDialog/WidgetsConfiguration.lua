---@class addonTablePlatynator
local addonTable = select(2, ...)

local function GetLabelsValues(allAssets, filter)
  local labels, values = {}, {}

  local allKeys = GetKeysArray(allAssets)
  table.sort(allKeys, function(a, b)
    local aType, aMain = a:match("(.+)%/(.+)")
    local bType, bMain = b:match("(.+)%/(.+)")
    local aMode, bMode = allAssets[a].mode, allAssets[b].mode
    if not aMode and bMode then
      return true
    elseif not bMode and aMode then
      return false
    elseif not bMode and not aMode then
      return a < b
    elseif bMain == aMain then
      return aMode > bMode
    else
      return aMain < bMain
    end
  end)

  for _, key in ipairs(allKeys) do
    if not filter or filter(allAssets[key]) then
      local details = allAssets[key]
      local height = 20
      local width = details.width * height/details.height
      if width > 180 then
        height = 180/width * height
        width = 180
      end
      local text = "|T".. (details.preview or details.file) .. ":" .. height .. ":" .. width .. "|t"
      if details.isTransparent then
        text = addonTable.Locales.NONE
      end
      if details.mode == addonTable.Assets.Mode.Special then
        text = text .. " " .. addonTable.Locales.SPECIAL_BRACKETS
      elseif details.mode ~= nil then
        text = text .. " " .. addonTable.Locales.PERCENT_BRACKETS:format(details.mode)
      end

      table.insert(labels, text)
      table.insert(values, key)
    end
  end

  return labels, values
end
local function ApplySpecial(details, value)
  local group = addonTable.Assets.SpecialBars[value]
  details.foreground.asset = group.foreground
  details.background.asset = group.background
  details.border.asset = group.border
end

addonTable.CustomiseDialog.WidgetsConfig = {
  ["bars"] = {
    ["*"] = {
      {
        label = addonTable.Locales.TEXTURES,
        entries = {
          {
            label = addonTable.Locales.SCALE,
            kind = "slider",
            min = 1, max = 300,
            valuePattern = "%d%%",
            setter = function(details, value)
              details.scale = value / 100
            end,
            getter = function(details)
              return details.scale * 100
            end,
          },
          {
            label = addonTable.Locales.BORDER,
            kind = "dropdown",
            getInitData = function()
              return GetLabelsValues(addonTable.Assets.BarBorders)
            end,
            setter = function(details, value)
              if addonTable.Assets.BarBackgrounds[details.background.asset].mode == addonTable.Assets.Mode.Special then
                local design = addonTable.Core.GetDesignByName("_squirrel")
                details.background.asset = design.bars[1].background.asset
                details.foreground.asset = design.bars[1].foreground.asset
              end
              if addonTable.Assets.BarBorders[value].mode == addonTable.Assets.Mode.Special then
                ApplySpecial(details, value)
              else
                details.border.asset = value
              end
            end,
            getter = function(details)
              return details.border.asset
            end
          },
          {
            label = addonTable.Locales.BORDER_COLOR,
            kind = "colorPicker",
            setter = function(details, value)
              details.border.color = value
            end,
            getter = function(details)
              return details.border.color
            end,
          },
          {
            label = addonTable.Locales.FOREGROUND,
            kind = "dropdown",
            getInitData = function()
              return GetLabelsValues(addonTable.Assets.BarBackgrounds)
            end,
            setter = function(details, value)
              if addonTable.Assets.BarBackgrounds[details.foreground.asset].mode == addonTable.Assets.Mode.Special then
                local design = addonTable.Core.GetDesignByName("_squirrel")
                details.border.asset = design.bars[1].border.asset
                details.background.asset = design.bars[1].background.asset
              end
              if addonTable.Assets.BarBackgrounds[value].mode == addonTable.Assets.Mode.Special then
                ApplySpecial(details, value)
              else
                details.foreground.asset = value
              end
            end,
            getter = function(details)
              return details.foreground.asset
            end
          },
          {
            label = addonTable.Locales.BACKGROUND,
            kind = "dropdown",
            getInitData = function()
              return GetLabelsValues(addonTable.Assets.BarBackgrounds)
            end,
            setter = function(details, value)
              if addonTable.Assets.BarBackgrounds[details.background.asset].mode == addonTable.Assets.Mode.Special then
                local design = addonTable.Core.GetDesignByName("_squirrel")
                details.border.asset = design.bars[1].border.asset
                details.foreground.asset = design.bars[1].foreground.asset
              end
              if addonTable.Assets.BarBackgrounds[value].mode == addonTable.Assets.Mode.Special then
                ApplySpecial(details, value)
              else
                details.background.asset = value
              end
            end,
            getter = function(details)
              return details.background.asset
            end
          },
          {
            label = addonTable.Locales.BACKGROUND_TRANSPARENCY,
            kind = "slider",
            min = 0, max = 100,
            valuePattern = "%d%%",
            setter = function(details, value)
              details.background.alpha = 1 - value / 100
            end,
            getter = function(details)
              return (1 - details.background.alpha) * 100
            end,
          },
          { kind = "spacer" },
          {
            label = addonTable.Locales.APPLY_MAIN_COLOR_TO_BACKGROUND,
            kind = "checkbox",
            setter = function(details, value)
              details.background.applyColor = value
            end,
            getter = function(details)
              return details.background.applyColor or false
            end,
          },
        }
      },
    },
    ["health"] = {
      {
        label = addonTable.Locales.COLORS,
        entries = {
          {
            label = addonTable.Locales.AGGRO_SAFE,
            kind = "colorPicker",
            setter = function(details, value)
              details.colors.threat.safe = value
            end,
            getter = function(details)
              return details.colors.threat.safe
            end,
          },
          {
            label = addonTable.Locales.AGGRO_OFFTANK,
            kind = "colorPicker",
            setter = function(details, value)
              details.colors.threat.offtank = value
            end,
            getter = function(details)
              return details.colors.threat.offtank
            end,
          },
          {
            label = addonTable.Locales.AGGRO_TRANSITION,
            kind = "colorPicker",
            setter = function(details, value)
              details.colors.threat.transition = value
            end,
            getter = function(details)
              return details.colors.threat.transition
            end,
          },
          {
            label = addonTable.Locales.AGGRO_WARNING,
            kind = "colorPicker",
            setter = function(details, value)
              details.colors.threat.warning = value
            end,
            getter = function(details)
              return details.colors.threat.warning
            end,
          },
          { kind = "spacer" },
          {
            label = addonTable.Locales.FRIENDLY,
            kind = "colorPicker",
            setter = function(details, value)
              details.colors.npc.friendly = value
            end,
            getter = function(details)
              return details.colors.npc.friendly
            end,
          },
          {
            label = addonTable.Locales.NEUTRAL,
            kind = "colorPicker",
            setter = function(details, value)
              details.colors.npc.neutral = value
            end,
            getter = function(details)
              return details.colors.npc.neutral
            end,
          },
          {
            label = addonTable.Locales.HOSTILE,
            kind = "colorPicker",
            setter = function(details, value)
              details.colors.npc.hostile = value
            end,
            getter = function(details)
              return details.colors.npc.hostile
            end,
          },
          {
            label = addonTable.Locales.AGGRO_COLORS_ON_HOSTILES,
            kind = "checkbox",
            setter = function(details, value)
              details.aggroColoursOnHostiles = value
            end,
            getter = function(details)
              return details.aggroColoursOnHostiles
            end,
          },
        },
      },
    },
    ["cast"] = {
      {
        label = addonTable.Locales.COLORS,
        entries = {
          {
            label = addonTable.Locales.NORMAL_CAST_COLOR,
            kind = "colorPicker",
            setter = function(details, value)
              details.colors.normal = value
            end,
            getter = function(details)
              return details.colors.normal
            end,
          },
          {
            label = addonTable.Locales.UNINTERRUPTABLE_CAST_COLOR,
            kind = "colorPicker",
            setter = function(details, value)
              details.colors.uninterruptable = value
            end,
            getter = function(details)
              return details.colors.uninterruptable
            end,
          },
          {
            label = addonTable.Locales.INTERRUPTED_CAST_COLOR,
            kind = "colorPicker",
            setter = function(details, value)
              details.colors.interrupted = value
            end,
            getter = function(details)
              return details.colors.interrupted
            end,
          },
        },
      },
    },
  },
  ["texts"] = {
    ["*"] = {
      {
        label = addonTable.Locales.GENERAL,
        entries = {
          {
            label = addonTable.Locales.SCALE,
            kind = "slider",
            min = 1, max = 300,
            valuePattern = "%d%%",
            setter = function(details, value)
              details.scale = value / 100
            end,
            getter = function(details)
              return details.scale * 100
            end,
          },
          {
            label = addonTable.Locales.WIDTH_RESTRICTION,
            kind = "slider",
            min = 0, max = 300,
            valuePattern = "%dpx",
            setter = function(details, value)
              details.widthLimit = value
            end,
            getter = function(details)
              return details.widthLimit or 0
            end,
          },
          {
            label = addonTable.Locales.ALIGNMENT,
            kind = "dropdown",
            getInitData = function()
              return {
                addonTable.Locales.CENTER,
                addonTable.Locales.LEFT,
                addonTable.Locales.RIGHT,
              }, {
                "CENTER",
                "LEFT",
                "RIGHT",
              }
            end,
            setter = function(details, value)
              details.align = value
            end,
            getter = function(details)
              return details.align
            end
          },
          {
            label = addonTable.Locales.SHORTEN,
            kind = "dropdown",
            getInitData = function()
              return {
                addonTable.Locales.SHOW_ALL,
                addonTable.Locales.LAST_WORD,
                addonTable.Locales.FIRST_WORD,
              }, {
                "NONE",
                "LEFT",
                "RIGHT",
              }
            end,
            setter = function(details, value)
              details.truncate = value
            end,
            getter = function(details)
              return details.truncate
            end
          },
          {
            label = addonTable.Locales.COLOR,
            kind = "colorPicker",
            setter = function(details, value)
              details.color = value
            end,
            getter = function(details)
              return details.color
            end,
          },
        }
      },
    },
    ["health"] = {
      {
        label = addonTable.Locales.GENERAL,
        entries = {
          {
            label = addonTable.Locales.ABSOLUTE_VALUE,
            kind = "checkbox",
            setter = function(details, value)
              if value and tIndexOf(details.displayTypes, "absolute") == nil then
                table.insert(details.displayTypes, 1, "absolute")
              elseif not value then
                local index = tIndexOf(details.displayTypes, "absolute")
                if index then
                  table.remove(details.displayTypes, index)
                end
              end
            end,
            getter = function(details)
              return tIndexOf(details.displayTypes, "absolute") ~= nil
            end,
          },
          {
            label = addonTable.Locales.PERCENTAGE_VALUE,
            kind = "checkbox",
            setter = function(details, value)
              if value and tIndexOf(details.displayTypes, "percentage") == nil then
                table.insert(details.displayTypes, 1, "percentage")
              elseif not value then
                local index = tIndexOf(details.displayTypes, "percentage")
                if index then
                  table.remove(details.displayTypes, index)
                end
              end
            end,
            getter = function(details)
              return tIndexOf(details.displayTypes, "percentage") ~= nil
            end,
          },
        }
      }
    }
  },
  ["markers"] = {
    ["*"] = {
      {
        label = addonTable.Locales.TEXTURES,
        entries = {
          {
            label = addonTable.Locales.SCALE,
            kind = "slider",
            min = 1, max = 300,
            valuePattern = "%d%%",
            setter = function(details, value)
              details.scale = value / 100
            end,
            getter = function(details)
              return details.scale * 100
            end,
          },
          {
            label = addonTable.Locales.VISUAL,
            kind = "dropdown",
            getInitData = function(details)
              return GetLabelsValues(addonTable.Assets.Markers, function(a) return a.tag == details.kind end)
            end,
            setter = function(details, value)
              details.asset = value
            end,
            getter = function(details)
              return details.asset
            end
          },
          {
            label = addonTable.Locales.COLOR,
            kind = "colorPicker",
            setter = function(details, value)
              details.color = value
            end,
            getter = function(details)
              return details.color
            end,
          },
        },
      },
    },
  },
  ["auras"] = {
    ["*"] = {
      {
        label = addonTable.Locales.GENERAL,
        entries = {
          {
            label = addonTable.Locales.SCALE,
            kind = "slider",
            min = 1, max = 300,
            valuePattern = "%d%%",
            setter = function(details, value)
              details.scale = value / 100
            end,
            getter = function(details)
              return details.scale * 100
            end,
          },
          {
            label = addonTable.Locales.DIRECTION,
            kind = "dropdown",
            getInitData = function()
              return {
                addonTable.Locales.LEFT,
                addonTable.Locales.RIGHT,
              }, {
                "LEFT",
                "RIGHT",
              }
            end,
            setter = function(details, value)
              details.direction = value
            end,
            getter = function(details)
              return details.direction
            end
          },
        },
      },
    },
  },
  ["highlights"] = {
    ["*"] = {
      {
        label = addonTable.Locales.TEXTURES,
        entries = {
          {
            label = addonTable.Locales.SCALE,
            kind = "slider",
            min = 1, max = 300,
            valuePattern = "%d%%",
            setter = function(details, value)
              details.scale = value / 100
            end,
            getter = function(details)
              return details.scale * 100
            end,
          },
          {
            label = addonTable.Locales.VISUAL,
            kind = "dropdown",
            getInitData = function()
              return GetLabelsValues(addonTable.Assets.Highlights)
            end,
            setter = function(details, value)
              details.asset = value
            end,
            getter = function(details)
              return details.asset
            end
          },
          {
            label = addonTable.Locales.COLOR,
            kind = "colorPicker",
            setter = function(details, value)
              details.color = value
            end,
            getter = function(details)
              return details.color
            end,
          },
        },
      },
    },
  },
  ["specialBars"] = {
    ["power"] = {
      {
        label = addonTable.Locales.TEXTURES,
        entries = {
          {
            label = addonTable.Locales.SCALE,
            kind = "slider",
            min = 1, max = 300,
            valuePattern = "%d%%",
            setter = function(details, value)
              details.scale = value / 100
            end,
            getter = function(details)
              return details.scale * 100
            end,
          },
          {
            label = addonTable.Locales.FILLED,
            kind = "dropdown",
            getInitData = function()
              return GetLabelsValues(addonTable.Assets.PowerBars)
            end,
            setter = function(details, value)
              details.filled = value
            end,
            getter = function(details)
              return details.filled
            end
          },
          {
            label = addonTable.Locales.EMPTY,
            kind = "dropdown",
            getInitData = function()
              return GetLabelsValues(addonTable.Assets.PowerBars)
            end,
            setter = function(details, value)
              details.blank = value
            end,
            getter = function(details)
              return details.blank
            end
          },
        }
      }
    }
  }
}
