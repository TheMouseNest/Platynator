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
  {key = "friendly", label = addonTable.Locales.FRIENDLY},
  {key = "hostile", label = addonTable.Locales.HOSTILE},
  {key = "neutral", label = addonTable.Locales.NEUTRAL},

  {title = addonTable.Locales.SPECIAL},
  {key = "player", label = addonTable.Locales.PLAYER},
  {key = "npc", label = addonTable.Locales.NPC},
  {key = "minion", label = addonTable.Locales.MINION},

  {title = addonTable.Locales.MOB_CLASSIFICATION},
  {key = "rare", label = addonTable.Locales.RARE},
  {key = "elite", label = addonTable.Locales.ELITE},
  {key = "worldboss", label = addonTable.Locales.WORLD_BOSS},
  {key = "minor", label = addonTable.Locales.MINOR},
  {key = "trivial", label = addonTable.Locales.TRIVIAL},

  {title = addonTable.Locales.LOCATION},
  {key = "world", label = addonTable.Locales.WORLD},
  {key = "relevant-instance", label = addonTable.Locales.RELEVANT_INSTANCE},
  {key = "dungeon", label = addonTable.Locales.DUNGEON},
  {key = "raid", label = addonTable.Locales.RAID},
  {key = "arena", label = addonTable.Locales.ARENA},
  {key = "battleground", label = addonTable.Locales.BATTLEGROUND},
  {key = "delve", label = addonTable.Locales.DELVE},
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
    frame.styleDropdown = CreateFrame("DropdownButton", nil, frame, "WowStyle1DropdownTemplate")
    frame.styleDropdown:SetWidth(250)
    frame.styleDropdown:SetPoint("LEFT", frame, "CENTER", -32, 0)
  end)

  return container
end
