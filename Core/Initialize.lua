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

local function SetStyle()
  if addonTable.Config.Get(addonTable.Config.Options.STYLE) == "slight" then
    addonTable.Config.Set(addonTable.Config.Options.DESIGN, addonTable.Design.GetDefaultDesignSlight())
  elseif addonTable.Config.Get(addonTable.Config.Options.STYLE) == "tooltip" then
    addonTable.Config.Set(addonTable.Config.Options.DESIGN, addonTable.Design.GetDefaultDesignTooltip())
  else
    addonTable.Config.Set(addonTable.Config.Options.DESIGN, addonTable.Design.GetDefaultDesignBold())
  end
end

function addonTable.Core.Initialize()
  addonTable.Config.InitializeData()

  --if next(addonTable.Config.Get(addonTable.Config.Options.DESIGN)) == nil then
  --  addonTable.Config.Set(addonTable.Config.Options.DESIGN, addonTable.Design.GetDefaultDesignSlight())
  --end

  SetStyle()
  addonTable.CallbackRegistry:RegisterCallback("SettingChanged", function(_, name)
    if name == addonTable.Config.Options.STYLE then
      SetStyle()
    end
  end)

  addonTable.SlashCmd.Initialize()

  if addonTable.Constants.IsMidnight then
    SetCVarBitfield(NamePlateConstants.INFO_DISPLAY_CVAR, Enum.NamePlateInfoDisplay.CurrentHealthPercent, true)
    SetCVarBitfield(NamePlateConstants.INFO_DISPLAY_CVAR, Enum.NamePlateInfoDisplay.CurrentHealthValue, true)
  end

  addonTable.Display.Initialize()
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(_, eventName, data)
  if eventName == "ADDON_LOADED" and data == "Platynator" then
    addonTable.Core.Initialize()
  end
end)
