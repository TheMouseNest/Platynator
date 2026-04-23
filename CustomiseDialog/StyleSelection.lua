---@class addonTablePlatynator
local addonTable = select(2, ...)

local contextCriteria = {
  {title = addonTable.Locales.ATTACK},
  {key = "can-attack", label = addonTable.Locales.CAN_ATTACK},
  {key = "cannot-attack", label = addonTable.Locales.CANNOT_ATTACK},

  {title = addonTable.Locales.COMBAT},
  {key = "in-combat", label = addonTable.Locales.IN_COMBAT},
  {key = "out-combat", label = addonTable.Locales.OUT_OF_COMBAT},

  {title = addonTable.Locales.FACTION},
  {key = "friend", label = addonTable.Locales.FRIENDLY},
  {key = "hostile", label = addonTable.Locales.HOSTILE},
  {key = "neutral", label = addonTable.Locales.NEUTRAL},

  {title = addonTable.Locales.SPECIAL},
  {key = "player", label = addonTable.Locales.PLAYER},
  {key = "npc", label = addonTable.Locales.NPC},
  {key = "minion", label = addonTable.Locales.MINION},

  {title = addonTable.Locales.MOB_CLASSIFICATION},
  {key = "class-rare", label = addonTable.Locales.RARE},
  {key = "class-elite", label = addonTable.Locales.ELITE},
  {key = "class-worldboss", label = addonTable.Locales.WORLD_BOSS},
  {key = "class-minor", label = addonTable.Locales.MINOR},
  {key = "class-trivial", label = addonTable.Locales.TRIVIAL},

  {title = addonTable.Locales.LOCATION},
  {key = "loc-world", label = addonTable.Locales.WORLD},
  {key = "loc-dungeon", label = addonTable.Locales.DUNGEON},
  {key = "loc-raid", label = addonTable.Locales.RAID},
  {key = "loc-pvp", label = addonTable.Locales.PVP},
  {key = "loc-delve", label = addonTable.Locales.DELVE},

  {title = addonTable.Locales.ELITE_TYPE},
  {key = "elite-boss", label = addonTable.Locales.BOSS},
  {key = "elite-miniboss", label = addonTable.Locales.MINIBOSS},
  {key = "elite-caster", label = addonTable.Locales.CASTER},
  {key = "elite-melee", label = addonTable.Locales.MELEE},
  {key = "elite-trivial", label = addonTable.Locales.TRIVIAL},

  {title = addonTable.Locales.DELVE_TYPE},
  {key = "delve-boss", label = addonTable.Locales.BOSS},
  {key = "delve-elite", label = addonTable.Locales.MINIBOSS},
  {key = "delve-rare", label = addonTable.Locales.RARE},
  {key = "delve-caster", label = addonTable.Locales.CASTER},
  {key = "delve-melee", label = addonTable.Locales.MELEE},
  {key = "delve-trivial", label = addonTable.Locales.TRIVIAL},
}

local function AddCriteria(rootDescription, isSet, onSet)
  for _, entry in ipairs(contextCriteria) do
    if entry.title then
      rootDescription:CreateTitle(entry.title)
    else
      rootDescription:CreateCheckbox(entry.label, function()
        return isSet(entry.key)
      end,
      function()
        onSet(entry.key)
      end)
    end
  end
  rootDescription:SetScrollMode(30 * 20)
end

local function AddStyles(rootDescription, isSet, onSet)
  local styles = {}
  for key, _ in pairs(addonTable.Config.Get(addonTable.Config.Options.DESIGNS)) do
    table.insert(styles, {label = key ~= addonTable.Constants.CustomName and key or addonTable.Locales.CUSTOM, value = key})
  end
  table.sort(styles, function(a, b) return a.label < b.label end)
  local stylesBuiltIn = {}
  for key, label in pairs(addonTable.Design.NameMap) do
    if key ~= addonTable.Constants.CustomName then
      table.insert(stylesBuiltIn, {label = label .. " " .. addonTable.Locales.DEFAULT_BRACKETS, value = key})
    end
  end
  table.sort(stylesBuiltIn, function(a, b) return a.label < b.label end)
  tAppendAll(styles, stylesBuiltIn)

  for _, entry in ipairs(styles) do
    rootDescription:CreateRadio(entry.label, isSet, onSet, entry.value)
  end
end

function addonTable.CustomiseDialog.GetMainStyleSelection(parent)
  local container = CreateFrame("Frame", nil, parent)

  local allFrames = {}

  local holderPool = CreateFramePool("Frame", container, nil, nil, false, function(frame)
    frame:SetPoint("LEFT", 30, 0)
    frame:SetPoint("RIGHT", -30, 0)
    frame.criteriaDropdown = CreateFrame("DropdownButton", nil, frame, "WowStyle1DropdownTemplate")
    frame.criteriaDropdown:SetWidth(250)
    frame.criteriaDropdown:SetDefaultText(addonTable.Locales.SELECT_CRITERIA)
    frame.criteriaDropdown:SetPoint("RIGHT", frame, "CENTER", -50, 0)
    frame.criteriaDropdown:SetupMenu(function(_, rootDescription)
      AddCriteria(rootDescription,
        function(key)
          if not frame.entry then
            return false
          end
          return tIndexOf(frame.entry.criteria, key) ~= nil
        end,
        function(key)
          if not frame.entry then
            return
          end
          local index = tIndexOf(frame.entry.criteria, key)
          if index == nil then
            table.insert(frame.entry.criteria, key)
          else
            table.remove(frame.entry.criteria, index)
          end
        end
      )
    end)
    frame.styleDropdown = CreateFrame("DropdownButton", nil, frame, "WowStyle1DropdownTemplate")
    frame.styleDropdown:SetWidth(250)
    frame.styleDropdown:SetPoint("LEFT", frame, "CENTER", -32, 0)
    frame.styleDropdown:SetupMenu(function(_, rootDescription)
      AddStyles(rootDescription,
        function(key)
          return frame.entry ~= nil and frame.entry.design == key
        end,
        function(key)
          if not frame.entry then
            return
          end
          frame.entry.design = key
        end
      )
    end)

    function frame:SetEntry(entry)
      frame.entry = entry
      frame.criteriaDropdown:GenerateMenu()
      frame.styleDropdown:GenerateMenu()
    end
  end)

  return container
end
