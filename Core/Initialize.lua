---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.CallbackRegistry = CreateFromMixins(CallbackRegistryMixin)
addonTable.CallbackRegistry:OnLoad()
addonTable.CallbackRegistry:GenerateCallbackEvents(addonTable.Constants.Events)

local hidden = CreateFrame("Frame")
hidden:Hide()
addonTable.hiddenFrame = hidden

local offscreen = CreateFrame("Frame")
offscreen:SetPoint("TOPLEFT", UIParent, "TOPRIGHT")
addonTable.offscreenFrame = hidden

local function SetStyle(isInit)
  local styleName = addonTable.Config.Get(addonTable.Config.Options.STYLE)
  if styleName:match("^_") then
    local designs = addonTable.Config.Get(addonTable.Config.Options.DESIGNS)
    designs[addonTable.Constants.CustomName] = CopyTable(addonTable.Core.GetDesignByName(styleName))
  end

  if isInit then
    return
  end

  if addonTable.CustomiseDialog.IsUsingDefaultStyleSelect() then
    local assigments = addonTable.Config.Get(addonTable.Config.Options.DESIGN_ASSIGNMENTS)
    local enemyStyle = assigments[#assigments].style
    local toChange = {}
    local alreadySet = false
    for _, a in ipairs(assigments) do
      if a.style == styleName then
        alreadySet = true
      end
      if a.style == enemyStyle then
        table.insert(toChange, a)
      end
    end
    if not alreadySet then
      for _, a in ipairs(toChange) do
        a.style = styleName
      end
    end
    addonTable.CallbackRegistry:TriggerEvent("CustomiseDesignsAssigned")
  end
  addonTable.CallbackRegistry:TriggerEvent("RefreshStateChange", {[addonTable.Constants.RefreshReason.Design] = true})
end

function addonTable.Core.GetDesignByName(name)
  if addonTable.Design.Defaults[name] then
    if not addonTable.Design.ParsedDefaults[name] then
      local design = C_EncodingUtil.DeserializeJSON(addonTable.Design.Defaults[name])
      design.kind = nil
      design.addon = nil
      addonTable.Core.UpgradeDesign(design)
      addonTable.Design.ParsedDefaults[name] = design
    end
    return addonTable.Design.ParsedDefaults[name]
  else
    return addonTable.Config.Get(addonTable.Config.Options.DESIGNS)[name]
  end
end

function addonTable.Core.GetDesignScale(isSimplified)
  if isSimplified then
    return addonTable.Config.Get(addonTable.Config.Options.SIMPLIFIED_SCALE)
  else
    return 1
  end
end

function addonTable.Core.Initialize()
  addonTable.Config.InitializeData()
  addonTable.SlashCmd.Initialize()

  addonTable.Assets.ApplyScale()

  addonTable.Core.MigrateSettings()

  SetStyle(true)
  addonTable.CallbackRegistry:RegisterCallback("SettingChanged", function(_, name)
    if name == addonTable.Config.Options.STYLE then
      SetStyle()
    end
  end)

  addonTable.CustomiseDialog.Initialize()

  addonTable.Display.Initialize()
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(_, eventName, data)
  if eventName == "ADDON_LOADED" and data == "Platynator" then
    addonTable.Core.Initialize()
  end
end)
