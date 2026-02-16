---@class addonTablePlatynator
local addonTable = select(2, ...)

local LSM = LibStub("LibSharedMedia-3.0")

local textureHeight = 20

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
      local height = textureHeight
      local width = details.width * height/details.height
      if width > 180 then
        height = 180/width * height
        width = 180
      end
      local text = "|T".. (details.preview or details.file or details.horizontal) .. ":" .. (height - 1) .. ":" .. (width - 1) .. "|t"
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

local function GetLabelsValuesBackgrounds()
  local labels, values = {}, {}
  local assets = LSM:List("statusbar")

  local height = textureHeight
  local width = addonTable.Assets.BarBordersSize.width * height / addonTable.Assets.BarBordersSize.height

  local allKeys = GetKeysArray(addonTable.Assets.BarBackgrounds)
  table.sort(allKeys)
  for _, key in ipairs(allKeys) do
    local details = addonTable.Assets.BarBackgrounds[key]
    local file = LSM:Fetch("statusbar", key)
    local text = "|T".. file .. ":" .. (height - 1) .. ":" .. (width - 1) .. "|t " .. (key:gsub("Platy: ", ""))
    if details.isTransparent then
      text = addonTable.Locales.NONE
    end

    table.insert(labels, text)
    table.insert(values, key)
  end

  for _, key in ipairs(assets) do
    if not addonTable.Assets.BarBackgrounds[key] then
      local file = LSM:Fetch("statusbar", key)
      local text = "|T".. file .. ":" .. (height - 1) .. ":" .. (width - 1) .. "|t [Custom] " .. key

      table.insert(labels, text)
      table.insert(values, key)
    end
  end

  return labels, values
end

local function GetLabelsValuesBorders()
  local labels, values = {}, {}
  local assets = LSM:List("ninesliceborder")

  local height = textureHeight

  local allKeys = GetKeysArray(addonTable.Assets.BarBordersSliced)
  table.sort(allKeys)
  for _, key in ipairs(allKeys) do
    local details = addonTable.Assets.BarBordersSliced[key]
    local file = LSM:Fetch("nineslice", LSM:Fetch("ninesliceborder", key).nineslice).file
    local text = "|T".. file .. ":" .. (height - 1) .. ":" .. (height - 1) .. "|t " .. (key:gsub("Platy: ", ""))
    if details.isTransparent then
      text = addonTable.Locales.NONE
    end

    table.insert(labels, text)
    table.insert(values, key)
  end

  for _, key in ipairs(assets) do
    if not addonTable.Assets.BarBordersSliced[key] then
      local file = LSM:Fetch(LSM:Fetch("ninesliceborder", key).nineslice).file
      local text = "|T".. file .. ":" .. (height - 1) .. ":" .. (height - 1) .. "|t [Custom] " .. key

      table.insert(labels, text)
      table.insert(values, key)
    end
  end

  return labels, values
end

local function GetLabelsValuesHighlightsAnimated()
  local labels, values = {}, {}

  local height = textureHeight - 1
  local width = addonTable.Assets.BarBordersSize.width * height / addonTable.Assets.BarBordersSize.height

  local allKeys = tFilter(GetKeysArray(addonTable.Assets.Highlights), function(a)
    local assetDetails = addonTable.Assets.Highlights[a]
    return assetDetails.kind and assetDetails.kind:match("^animated")
  end, true)

  table.sort(allKeys)

  for _, key in ipairs(allKeys) do
    local file = addonTable.Assets.Highlights[key].preview
    local text = "|T".. file .. ":" .. height .. ":" .. width .. "|t " .. (key:gsub("Platy: ", ""))

    table.insert(labels, text)
    table.insert(values, {sliced = nil, asset = key})
  end

  return labels, values
end

local function GetLabelsValuesHighlightsNotAnimated()
  local labels, values = {}, {}
  local slicedAssets = LSM:List("nineslice")
  local regularAssets = LSM:List("platynator/sizedtexture")

  local platySliced = GetKeysArray(addonTable.Assets.BarBordersSliced)
  tAppendAll(platySliced, tFilter(GetKeysArray(addonTable.Assets.Highlights), function(a)
    return addonTable.Assets.Highlights[a].mode == addonTable.Assets.RenderMode.Sliced
  end, true))
  local platyRegular = tFilter(GetKeysArray(addonTable.Assets.Highlights), function(a)
    local assetDetails = addonTable.Assets.Highlights[a]
    return assetDetails.mode ~= addonTable.Assets.RenderMode.Sliced
      and (not assetDetails.kind or not assetDetails.kind:match("^animated"))
  end, true)

  local together = {}
  for _, key in ipairs(platySliced) do
    table.insert(together, {sliced = true, asset = key})
  end
  for _, key in ipairs(platyRegular) do
    table.insert(together, {sliced = false, asset = key})
  end
  table.sort(together, function(a, b)
    return a.asset < b.asset
  end)

  local height = textureHeight - 1

  local seen = {}

  for _, keyDetails in ipairs(together) do
    seen[keyDetails.asset] = true
    if keyDetails.sliced then
      local details = addonTable.Assets.BarBordersSliced[keyDetails.asset]
      if not details or not details.isTransparent then
        local assetDetails = LSM:Fetch("nineslice", keyDetails.asset)
        local width = assetDetails.previewWidth * height/assetDetails.previewHeight
        local text = "|T".. assetDetails.file .. ":" .. height .. ":" .. width .. "|t " .. (keyDetails.asset:gsub("Platy: ", ""))

        table.insert(labels, text)
        table.insert(values, {sliced = true, asset = keyDetails.asset})
      end
    else
      local details = LSM:Fetch("platynator/sizedtexture", keyDetails.asset)

      local width = details.width * height/details.height
      if width > 180 then
        height = 180/width * height
        width = 180
      end

      local text = "|T".. details.file .. ":" .. height .. ":" .. width .. "|t " .. (keyDetails.asset:gsub("Platy: ", ""))

      table.insert(labels, text)
      table.insert(values, {sliced = false, asset = keyDetails.asset})
    end
  end

  for _, key in ipairs(slicedAssets) do
    if not seen[key] then
      local file = LSM:Fetch("nineslice", key).file
      local text = "|T".. file .. ":" .. height .. ":" .. height .. "|t [Custom]" .. key

      table.insert(labels, text)
      table.insert(values, {sliced = true, asset = key})
    end
  end

  for _, key in ipairs(regularAssets) do
    if not seen[key] then
      local details = LSM:Fetch("platynator/sizedtexture", key)

      local width = details.width * height/details.height
      if width > 180 then
        height = 180/width * height
        width = 180
      end

      local text = "|T".. details.file .. ":" .. height .. ":" .. width .. "|t [Custom]" .. key

      table.insert(labels, text)
      table.insert(values, {sliced = false, asset = key})
    end
  end

  return labels, values
end

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
              return GetLabelsValuesBorders()
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
              return GetLabelsValuesBackgrounds()
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
              return GetLabelsValuesBackgrounds()
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
        label = addonTable.Locales.GENERAL,
        entries = {
          {
            label = addonTable.Locales.ANIMATE,
            kind = "checkbox",
            setter = function(details, value)
              details.animate = value
            end,
            getter = function(details)
              return details.animate
            end,
          },
        }
      },
      {
        label = addonTable.Locales.TEXTURES,
        entries = {
          {
            label = addonTable.Locales.ABSORB,
            kind = "dropdown",
            getInitData = function()
              return GetLabelsValuesBackgrounds()
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
            valuePattern = "%d%%",
            setter = function(details, value)
              details.maxWidth = value / 100
            end,
            getter = function(details)
              return details.maxWidth * 100
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
            hide = addonTable.Constants.IsRetail,
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
      {
        label = addonTable.Locales.VALUES,
        entries = {
          {
            label = addonTable.Locales.PLAYER_GUILD,
            kind = "checkbox",
            setter = function(details, value)
              details.playerGuild = value
            end,
            getter = function(details)
              return details.playerGuild
            end,
          },
          {
            label = addonTable.Locales.NPC_ROLE,
            kind = "checkbox",
            setter = function(details, value)
              details.npcRole = value
            end,
            getter = function(details)
              return details.npcRole
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
        label = addonTable.Locales.GENERAL,
        entries = {
          {
            label = addonTable.Locales.SHOW_ENRAGE_DISPEL,
            kind = "checkbox",
            setter = function(details, value)
              details.showDispel.enrage = value
            end,
            getter = function(details)
              return details.showDispel.enrage
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
              if details.kind:match("^animated") then
                return GetLabelsValuesHighlightsAnimated()
              else
                return GetLabelsValuesHighlightsNotAnimated()
              end
            end,
            setter = function(details, value)
              details.sliced = value.sliced
              details.asset = value.asset
            end,
            getter = function(details)
              if details.kind:match("^animated") then
                return {asset = details.asset}
              else
                return {sliced = details.sliced, asset = details.asset}
              end
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
    ["mouseover"] = {
      {
        label = addonTable.Locales.GENERAL,
        entries = {
          {
            label = addonTable.Locales.INCLUDE_TARGET,
            kind = "checkbox",
            setter = function(details, value)
              details.includeTarget = value
            end,
            getter = function(details)
              return details.includeTarget
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
    },
    ["animatedBorder"] = {
      {
        label = addonTable.Locales.GENERAL,
        entries = {
          {
            label = addonTable.Locales.BORDER_WIDTH,
            kind = "slider",
            min = 50, max = 500,
            valuePattern = "%d%%",
            setter = function(details, value)
              details.borderWidth = value / 100
            end,
            getter = function(details)
              return details.borderWidth * 100
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
