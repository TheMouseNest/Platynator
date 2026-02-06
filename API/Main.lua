---@class addonTablePlatynator
local addonTable = select(2, ...)

Platynator.API = {}

addonTable.API.TextOverrides = {
  name = {},
  guild = {},
  isActive = false,
}

local frame

-- @param unit - must be in the format nameplate*
function Platynator.API.SetUnitTextOverride(unit, name, guild)
  addonTable.API.TextOverrides.isActive = true

  if not frame then
    frame = CreateFrame("Frame")
    frame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
    frame:SetScript("OnEvent", function(_, _, unit)
      addonTable.API.TextOverrides.name[unit] = nil
      addonTable.API.TextOverrides.guild[unit] = nil
    end)
  end

  addonTable.API.TextOverrides.name[unit] = name
  addonTable.API.TextOverrides.guild[unit] = guild

  addonTable.CallbackRegistry:TriggerEvent("TextOverrideUpdated", unit)
end

function Platynator.API.ImportString(importText, resultName)
  assert(type(importText) == "string")

  local status, data = pcall(C_EncodingUtil.DeserializeJSON, importText)
  if not status then
    error("Invalid Platynator import")
  end

  local result, reason = addonTable.CustomiseDialog.ImportData(data, resultName, true)

  if result then
    addonTable.Utilities.Message(addonTable.Locales.THANKS_FOR_USING_PLATYNATOR_DONATE .. " https://linktr.ee/plusmouse")
  else
    error("Invalid Platynator import")
  end
end

EventRegistry:RegisterCallback("SetItemRef", function(_, link)
  if link == "addon:platynatorsettings" then
    addonTable.CustomiseDialog.Toggle()
  end
end)
