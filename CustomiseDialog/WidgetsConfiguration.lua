---@class addonTablePlatynator
local addonTable = select(2, ...)

local function GetLabelsValues(allAssets, filter, showHeight)
  local labels, values = {}, {}

  local allKeys = GetKeysArray(allAssets)
  table.sort(allKeys, function(a, b)
    local aGroup, bGroup = allAssets[a].group, allAssets[b].group
    local aOrder, bOrder = allAssets[a].order, allAssets[b].order
    if aOrder then
      if aGroup == bGroup then
        return aOrder < bOrder
      else
        return aGroup < bGroup
      end
    end
    return a < b
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
      local text = "|T".. (details.preview or details.file) .. ":" .. (height - 1) .. ":" .. (width - 1) .. "|t"
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
            min = 50, max = 300,
            formatter = function(value) return value .. "%" end,
            setter = function(details, value)
              details.border.height = value / 100
            end,
            getter = function(details)
              return details.border.height * 100
            end,
          },
          {
            label = addonTable.Locales.WIDTH,
            kind = "slider",
            min = 50, max = 300,
            formatter = function(value) return value .. "%" end,
            setter = function(details, value)
              details.border.width = value / 100
            end,
            getter = function(details)
              return details.border.width * 100
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
              return GetLabelsValues(addonTable.Assets.BarBordersSliced)
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
            label = addonTable.Locales.BACKGROUND_COLOR,
            kind = "colorPicker",
            setter = function(details, value)
              details.background.color = value
            end,
            getter = function(details)
              return details.background.color
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
        label = addonTable.Locales.TEXTURES,
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
            label = "",
            kind = "autoColors",
            lockedElements = {reaction = true},
            setter = function() end,
            getter = function(details)
              return details.autoColors
            end,
          },
        },
      },
    },
    ["cast"] = {
      {
        label = addonTable.Locales.TEXTURES,
        entries = {
          {
            label = addonTable.Locales.MARK_INTERRUPT_READY_POINT,
            kind = "checkbox",
            setter = function(details, value)
              details.interruptMarker.asset = value and "wide/glow" or "none"
            end,
            getter = function(details)
              return details.interruptMarker.asset ~= "none"
            end,
          },
          {
            label = addonTable.Locales.INTERRUPT_POINT_COLOR,
            kind = "colorPicker",
            setter = function(details, value)
              details.interruptMarker.color = value
            end,
            getter = function(details)
              return details.interruptMarker.color
            end,
          },
        },
      },
      {
        label = addonTable.Locales.COLORS,
        entries = {
          {
            label = "",
            kind = "autoColors",
            lockedElements = {cast = true},
            setter = function() end,
            getter = function(details)
              return details.autoColors
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
        label = addonTable.Locales.VALUES,
        entries = {
          {
            label = addonTable.Locales.ABSOLUTE,
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
          { kind = "spacer" },
          {
            label = addonTable.Locales.PERCENTAGE,
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
          {
            label = addonTable.Locales.SIGNIFICANT_FIGURES,
            kind = "slider",
            min = 0, max = 4,
            formatter = function(value)
              if value == 0 then
                return addonTable.Locales.ROUNDED
              else
                return tostring(value + 1)
              end
            end,
            setter = function(details, value)
              if value == 0 then
                details.significantFigures = value
              else
                details.significantFigures = value + 1
              end
            end,
            getter = function(details)
              if value == 0 then
                return details.significantFigures
              else
                return details.significantFigures - 1
              end
            end,
          },
        }
      }
    },
    ["creatureName"] = {
      {
        label = addonTable.Locales.GENERAL,
        entries = {
          {
            label = addonTable.Locales.SHOW_WHEN_WOW_DOES,
            kind = "checkbox",
            setter = function(details, value)
              details.showWhenWowDoes = value
            end,
            getter = function(details)
              return details.showWhenWowDoes
            end,
          },
        }
      },
      {
        label = addonTable.Locales.COLORS,
        entries = {
          {
            label = "",
            kind = "autoColors",
            lockedElements = {},
            setter = function() end,
            getter = function(details)
              return details.autoColors
            end,
          },
        },
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
    ["castInterrupter"] = {
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
            hide = addonTable.Constants.IsMidnight,t
          },
        }
      }
    },
    ["level"] = {
      {
        label = addonTable.Locales.COLORS,
        entries = {
          {
            label = "",
            kind = "autoColors",
            lockedElements = {},
            setter = function() end,
            getter = function(details)
              return details.autoColors
            end,
          },
        },
      }
    },
    ["guild"] = {
      {
        label = addonTable.Locales.GENERAL,
        entries = {
          {
            label = addonTable.Locales.SHOW_WHEN_WOW_DOES,
            kind = "checkbox",
            setter = function(details, value)
              details.showWhenWowDoes = value
            end,
            getter = function(details)
              return details.showWhenWowDoes
            end,
          },
        }
      },
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
              return details.square
            end,
          }
        }
      },
    },
    ["elite"] = {
      {
        label = addonTable.Locales.GENERAL,
        entries = {
          {
            label = addonTable.Locales.SHOW_ONLY_IN_OPEN_WORLD,
            kind = "checkbox",
            setter = function(details, value)
              details.openWorldOnly = value
            end,
            getter = function(details)
              return details.openWorldOnly
            end,
          }
        }
      },
    },
    ["rare"] = {
      {
        label = addonTable.Locales.GENERAL,
        entries = {
          {
            label = addonTable.Locales.INCLUDE_ELITE_RARES,
            kind = "checkbox",
            setter = function(details, value)
              details.includeElites = value
            end,
            getter = function(details)
              return details.includeElites
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
          {
            label = addonTable.Locales.TEXT_SCALE,
            kind = "slider",
            min = 1, max = 300,
            valuePattern = "%d%%",
            setter = function(details, value)
              details.textScale = value / 100
            end,
            getter = function(details)
              return details.textScale * 100
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
      {
        label = addonTable.Locales.SORTING,
        entries = {
          {
            label = addonTable.Locales.METHOD,
            kind = "dropdown",
            getInitData = function()
              return {
                addonTable.Locales.BLIZZARD,
                addonTable.Locales.DURATION,
              }, {
                "blizzard",
                "duration",
              }
            end,
            setter = function(details, value)
              details.sorting.kind = value
            end,
            getter = function(details)
              return details.sorting.kind
            end
          },
          {
            label = addonTable.Locales.REVERSED,
            kind = "checkbox",
            setter = function(details, value)
              details.sorting.reversed = value
            end,
            getter = function(details)
              return details.sorting.reversed
            end,
          },
        }
      }
    },
    ["debuffs"] = {
      {
        label = addonTable.Locales.GENERAL,
        entries = {
          {
            label = addonTable.Locales.SHOW_PANDEMIC,
            kind = "checkbox",
            setter = function(details, value)
              details.showPandemic = value
            end,
            getter = function(details)
              return details.showPandemic
            end,
          },
        },
      },
      {
        label = addonTable.Locales.FILTERS,
        entries = {
          {
            label = addonTable.Locales.IMPORTANT,
            kind = "checkbox",
            setter = function(details, value)
              details.filters.important = value
            end,
            getter = function(details)
              return details.filters.important
            end,
            hide = addonTable.Constants.IsClassic,
          },
          {
            label = addonTable.Locales.FROM_YOU,
            kind = "checkbox",
            setter = function(details, value)
              details.filters.fromYou = value
            end,
            getter = function(details)
              return details.filters.fromYou
            end,
          },
        }
      }
    },
    ["buffs"] = {
      {
        label = addonTable.Locales.FILTERS,
        entries = {
          {
            label = addonTable.Locales.IMPORTANT,
            kind = "checkbox",
            setter = function(details, value)
              details.filters.important = value
            end,
            getter = function(details)
              return details.filters.important
            end,
          },
          {
            label = addonTable.Locales.DISPELLABLE,
            kind = "checkbox",
            setter = function(details, value)
              details.filters.dispelable = value
            end,
            getter = function(details)
              return details.filters.dispelable
            end,
          },
        }
      }
    },
    ["crowdControl"] = {
      {
        label = addonTable.Locales.FILTERS,
        entries = {
          {
            label = addonTable.Locales.FROM_YOU,
            kind = "checkbox",
            setter = function(details, value)
              details.filters.fromYou = value
            end,
            getter = function(details)
              return details.filters.fromYou
            end,
          },
        }
      }
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
            min = 50, max = 300,
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
            min = 50, max = 300,
            valuePattern = "%d%%",
            setter = function(details, value)
              local asset = addonTable.Assets.Highlights[details.asset]
              if asset.mode == addonTable.Assets.RenderMode.Fixed then
                return
              end
              details.height = value / 100
            end,
            getter = function(details)
              return details.height * 100
            end,
          },
          {
            label = addonTable.Locales.WIDTH,
            kind = "slider",
            min = 50, max = 300,
            valuePattern = "%d%%",
            setter = function(details, value)
              local asset = addonTable.Assets.Highlights[details.asset]
              if asset.mode == addonTable.Assets.RenderMode.Fixed then
                return
              end
              details.width = value / 100
            end,
            getter = function(details)
              return details.width * 100
            end,
          },
          {
            label = addonTable.Locales.VISUAL,
            kind = "dropdown",
            getInitData = function(details)
              return GetLabelsValues(addonTable.Assets.Highlights)
            end,
            setter = function(details, value)
              details.asset = value
              local asset = addonTable.Assets.Highlights[details.asset]
              if asset.mode == addonTable.Assets.RenderMode.Fixed then
                details.width = 1
                details.height = 1
              end
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
    ["automatic"] = {
      {
        label = addonTable.Locales.COLORS,
        entries = {
          {
            label = "",
            kind = "autoColors",
            lockedElements = {},
            addAlpha = true,
            setter = function() end,
            getter = function(details)
              return details.autoColors
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
