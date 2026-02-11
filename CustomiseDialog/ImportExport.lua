---@class addonTablePlatynator
local addonTable = select(2, ...)

function addonTable.CustomiseDialog.ImportData(import, name, overwrite)
  if import.addon ~= "Platynator" then
    return false, 1
  end

  if name:match("^_") then
    return false, 2
  end

  import.version = nil
  import.addon = nil
  if import.kind == nil or import.kind == "style" then
    local designs = addonTable.Config.Get(addonTable.Config.Options.DESIGNS)
    if designs[name] and not overwrite then
      return false, 3
    end
    import.kind = nil
    addonTable.Core.UpgradeDesign(import)
    addonTable.Config.Get(addonTable.Config.Options.DESIGNS)[name] = import
    addonTable.Config.Set(addonTable.Config.Options.STYLE, name)
  elseif import.kind == "profile" then
    import.kind = nil
    if overwrite and PLATYNATOR_CONFIG.Profiles[name] then
      local oldDesigns = PLATYNATOR_CONFIG.Profiles[name].designs
      local old = addonTable.Config.CurrentProfile
      PLATYNATOR_CONFIG.Profiles[name] = import
      local designs = PLATYNATOR_CONFIG.Profiles[name].designs
      for key, design in pairs(oldDesigns) do
        if designs[key] == nil then
          designs[key] = design
        end
      end
      if import.style and not import.designs[import.style] then
        import.style = import.designs_assigned["enemy"]
      end
      addonTable.Config.ChangeProfile(name, old)
    else
      if PLATYNATOR_CONFIG.Profiles[name] then
        return false, 4
      end
      addonTable.Config.MakeProfile(name, false)
      local old = addonTable.Config.CurrentProfile
      PLATYNATOR_CONFIG.Profiles[PLATYNATOR_CURRENT_PROFILE] = import
      if import.style and not import.designs[import.style] then
        import.style = import.designs_assigned["enemy"]
      end
      addonTable.Config.ChangeProfile(PLATYNATOR_CURRENT_PROFILE, old)
    end
  end

  return true
end
