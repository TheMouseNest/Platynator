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
