---@class addonTablePlatynator
local addonTable = select(2, ...)

function Platynator.API.GetProfileNames()
  return addonTable.Config.GetProfileNames()
end

function Platynator.API.GetCurrentProfile()
  return PLATYNATOR_CURRENT_PROFILE
end

function Platynator.API.SwitchProfile(profileName)
  local profiles = addonTable.Config.GetProfileNames()
  if tIndexOf(profiles, profileName) == nil then
    return false
  end
  if profileName == PLATYNATOR_CURRENT_PROFILE then
    return true
  end
  addonTable.Config.ChangeProfile(profileName)
  return true
end
