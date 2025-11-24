---@class addonTablePlatynator
local addonTable = select(2, ...)

local function GetLabelsValues(allAssets, filter, showHeight)
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
      elseif details.mode ~= nil and showHeight then
        text = text .. " " .. addonTable.Locales.PERCENT_BRACKETS:format(details.mode)
      end

      table.insert(labels, text)
      table.insert(values, key)
    end
  end

  return labels, values
end

local sizes = {
  addonTable.Assets.Mode.Percent50,
  addonTable.Assets.Mode.Percent75,
  addonTable.Assets.Mode.Percent100,
  addonTable.Assets.Mode.Percent125,
  addonTable.Assets.Mode.Percent150,
  addonTable.Assets.Mode.Percent175,
  addonTable.Assets.Mode.Percent200,
}
local sizeFormatter = function(val)
  return ({"50%", "75%", "100%", "125%", "150%", "175%", "200%"})[val] or UNKNOWN
end

local minSize = 1
local maxSize = 7

addonTable.CustomiseDialog.WidgetsConfig = {
  ["bars"] = {
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
            label = addonTable.Locales.LAYER,
            kind = "slider",
            min = 0, max = 6,
            valuePattern = "%d",
            setter = function(details, value)
              details.layer = value
            end,
            getter = function(details)
              return details.layer
            end,
          },
          { kind = "spacer" },
          {
            label = addonTable.Locales.HEIGHT,
            kind = "slider",
            min = minSize, max = maxSize,
            formatter = sizeFormatter,
            setter = function(details, value)
              local newMode = sizes[value] 

              local asset = addonTable.Assets.BarBorders[details.border.asset]
              local mode = asset.mode
              local tag = asset.tag
              for key, alt in pairs(addonTable.Assets.BarBorders) do
                if alt.tag == tag and alt.mode == newMode then
                  details.border.asset = key
                  return
                end
              end

              for key, alt in pairs(addonTable.Assets.BarBorders) do
                if alt.tag == "soft" and alt.mode == newMode then
                  details.border.asset = key
                  break
                end
              end
            end,
            getter = function(details)
              local mode = addonTable.Assets.BarBorders[details.border.asset].mode
              assert(mode)
              return tIndexOf(sizes, mode) or 3
            end,
          },
        },
      },
      {
        label = addonTable.Locales.TEXTURES,
        entries = {
          {
            label = addonTable.Locales.BORDER,
            kind = "dropdown",
            getInitData = function(details)
              local height = addonTable.Assets.BarBorders[details.border.asset].mode
              return GetLabelsValues(addonTable.Assets.BarBorders, function(asset) return asset.mode == height end)
            end,
            setter = function(details, value)
              details.border.asset = value
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
              return GetLabelsValues(addonTable.Assets.BarBackgrounds, nil, true)
            end,
            setter = function(details, value)
              details.foreground.asset = value
            end,
            getter = function(details)
              return details.foreground.asset
            end
          },
          {
            label = addonTable.Locales.BACKGROUND,
            kind = "dropdown",
            getInitData = function()
              return GetLabelsValues(addonTable.Assets.BarBackgrounds, nil, true)
            end,
            setter = function(details, value)
              details.background.asset = value
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
          {
            label = addonTable.Locales.HIGHLIGHT_BAR_EDGE,
            kind = "checkbox",
            setter = function(details, value)
              details.marker.asset = value and "wide/glow" or "none"
            end,
            getter = function(details)
              return details.marker.asset ~= "none"
            end,
          },
        }
      },
    },
    ["health"] = {
      {
        label =addonTable.Locales.TEXTURES,
        entries = {
          {
            label = addonTable.Locales.ABSORB,
            kind = "dropdown",
            getInitData = function()
              return GetLabelsValues(addonTable.Assets.BarBackgrounds, nil, true)
            end,
            setter = function(details, value)
              details.absorb.asset = value
            end,
            getter = function(details)
              return details.absorb.asset
            end
          },
          {
            label = addonTable.Locales.ABSORB_COLOR,
            kind = "colorPicker",
            setter = function(details, value)
              details.absorb.color = value
            end,
            getter = function(details)
              return details.absorb.color
            end,
          },
        }
      },
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
            label = addonTable.Locales.NEUTRAL_QUEST_OBJECTIVE,
            kind = "colorPicker",
            setter = function(details, value)
              details.colors.npc.neutral_quest_objective = value
            end,
            getter = function(details)
              return details.colors.npc.neutral_quest_objective
            end,
          },
          {
            label = addonTable.Locales.UNFRIENDLY,
            kind = "colorPicker",
            setter = function(details, value)
              details.colors.npc.unfriendly = value
            end,
            getter = function(details)
              return details.colors.npc.unfriendly
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
            label = addonTable.Locales.HOSTILE_QUEST_OBJECTIVE,
            kind = "colorPicker",
            setter = function(details, value)
              details.colors.npc.hostile_quest_objective = value
            end,
            getter = function(details)
              return details.colors.npc.hostile_quest_objective
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
            label = addonTable.Locales.LAYER,
            kind = "slider",
            min = 0, max = 6,
            valuePattern = "%d",
            setter = function(details, value)
              details.layer = value
            end,
            getter = function(details)
              return details.layer
            end,
          },
          { kind = "spacer" },
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
            label = addonTable.Locales.TRUNCATE,
            kind = "checkbox",
            setter = function(details, value)
              details.truncate = value
            end,
            getter = function(details)
              return details.truncate
            end,
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
    },
    ["creatureName"] = {
      {
        label = addonTable.Locales.COLORS,
        entries = {
          {
            label = addonTable.Locales.CLASS_COLORED,
            kind = "checkbox",
            setter = function(details, value)
              details.applyClassColors = value
            end,
            getter = function(details)
              return details.applyClassColors
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
            label = addonTable.Locales.UNFRIENDLY,
            kind = "colorPicker",
            setter = function(details, value)
              details.colors.npc.unfriendly = value
            end,
            getter = function(details)
              return details.colors.npc.unfriendly
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
        }
      }
    },
    ["target"] = {
      {
        label = addonTable.Locales.COLORS,
        entries = {
          {
            label = addonTable.Locales.CLASS_COLORED,
            kind = "checkbox",
            setter = function(details, value)
              details.applyClassColors = value
            end,
            getter = function(details)
              return details.applyClassColors
            end,
          },
        }
      }
    },
    ["castTarget"] = {
      {
        label = addonTable.Locales.COLORS,
        entries = {
          {
            label = addonTable.Locales.CLASS_COLORED,
            kind = "checkbox",
            setter = function(details, value)
              details.applyClassColors = value
            end,
            getter = function(details)
              return details.applyClassColors
            end,
          },
        }
      }
    },
    ["level"] = {
      {
        label = addonTable.Locales.COLORS,
        entries = {
          {
            label = addonTable.Locales.DIFFICULTY_COLORED,
            kind = "checkbox",
            setter = function(details, value)
              details.applyDifficultyColors = value
            end,
            getter = function(details)
              return details.applyDifficultyColors
            end,
          },
          { kind = "spacer" },
          {
            label = addonTable.Locales.TRIVIAL,
            kind = "colorPicker",
            setter = function(details, value)
              details.colors.difficulty.trivial = value
            end,
            getter = function(details)
              return details.colors.difficulty.trivial
            end,
          },
          {
            label = addonTable.Locales.STANDARD,
            kind = "colorPicker",
            setter = function(details, value)
              details.colors.difficulty.standard = value
            end,
            getter = function(details)
              return details.colors.difficulty.standard
            end,
          },
          {
            label = addonTable.Locales.DIFFICULT,
            kind = "colorPicker",
            setter = function(details, value)
              details.colors.difficulty.difficult = value
            end,
            getter = function(details)
              return details.colors.difficulty.difficult
            end,
          },
          {
            label = addonTable.Locales.VERY_DIFFICULT,
            kind = "colorPicker",
            setter = function(details, value)
              details.colors.difficulty.verydifficult = value
            end,
            getter = function(details)
              return details.colors.difficulty.verydifficult
            end,
          },
          {
            label = addonTable.Locales.IMPOSSIBLE,
            kind = "colorPicker",
            setter = function(details, value)
              details.colors.difficulty.impossible = value
            end,
            getter = function(details)
              return details.colors.difficulty.impossible
            end,
          },
        }
      }
    },
  },
  ["markers"] = {
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
            label = addonTable.Locales.LAYER,
            kind = "slider",
            min = 0, max = 6,
            valuePattern = "%d",
            setter = function(details, value)
              details.layer = value
            end,
            getter = function(details)
              return details.layer
            end,
          },
          { kind = "spacer" },
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
    ["castIcon"] = {
      {
        label = addonTable.Locales.GENERAL,
        entries = {
          {
            label = addonTable.Locales.SQUARE,
            kind = "checkbox",
            setter = function(details, value)
              details.square = value
            end,
            getter = function(details)
              return details.square == true
            end,
          }
        }
      },
    }
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
          { kind = "spacer" },
          {
            label = addonTable.Locales.HEIGHT,
            kind = "slider",
            min = 25, max = 100,
            valuePattern = "%d%%",
            setter = function(details, value)
              details.height = value / 100
            end,
            getter = function(details)
              return details.height * 100
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
          {
            label = addonTable.Locales.SHOW_COUNTDOWN,
            kind = "checkbox",
            setter = function(details, value)
              details.showCountdown = value
            end,
            getter = function(details)
              return details.showCountdown
            end,
          },
        },
      },
    },
  },
  ["highlights"] = {
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
            label = addonTable.Locales.LAYER,
            kind = "slider",
            min = 0, max = 6,
            valuePattern = "%d",
            setter = function(details, value)
              details.layer = value
            end,
            getter = function(details)
              return details.layer
            end,
          },
          { kind = "spacer" },
          {
            label = addonTable.Locales.HEIGHT,
            kind = "slider",
            min = minSize, max = maxSize,
            formatter = sizeFormatter,
            setter = function(details, value)
              local newMode = sizes[value]

              local asset = addonTable.Assets.Highlights[details.asset]
              local mode = asset.mode
              local tag = asset.tag
              for key, alt in pairs(addonTable.Assets.Highlights) do
                if alt.tag == tag and alt.mode == newMode then
                  details.asset = key
                  return
                end
              end

              for key, alt in pairs(addonTable.Assets.Highlights) do
                if alt.tag == "soft-glow" and alt.mode == newMode then
                  details.asset = key
                  break
                end
              end
            end,
            getter = function(details)
              local mode = addonTable.Assets.Highlights[details.asset].mode
              assert(mode)
              return tIndexOf(sizes, mode) or 3
            end,
          },
          {
            label = addonTable.Locales.VISUAL,
            kind = "dropdown",
            getInitData = function(details)
              local height = addonTable.Assets.Highlights[details.asset].mode
              return GetLabelsValues(addonTable.Assets.Highlights, function(asset) return asset.mode == height or (asset.tag == "arrows") end)
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
    }
  },
  ["specialBars"] = {
    ["power"] = {
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
            label = addonTable.Locales.LAYER,
            kind = "slider",
            min = 0, max = 6,
            valuePattern = "%d",
            setter = function(details, value)
              details.layer = value
            end,
            getter = function(details)
              return details.layer
            end,
          },
          { kind = "spacer" },
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
