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

function addonTable.Core.Initialize()
  addonTable.Config.InitializeData()

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
