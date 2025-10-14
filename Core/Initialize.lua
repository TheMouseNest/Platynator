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
  local design = addonTable.Config.Get(addonTable.Config.Options.DESIGN)

  if addonTable.Config.Get(addonTable.Config.Options.STYLE) == "hedgehog" then
    design = addonTable.Design.GetDefaultDesignHedgehog()
  elseif addonTable.Config.Get(addonTable.Config.Options.STYLE) == "rabbit" then
    design = addonTable.Design.GetDefaultDesignRabbit()
  elseif addonTable.Config.Get(addonTable.Config.Options.STYLE) == "blizzard" then
    design = addonTable.Design.GetDefaultDesignBlizzard()
  elseif addonTable.Config.Get(addonTable.Config.Options.STYLE) ~= "custom" then
    design = addonTable.Design.GetDefaultDesignSquirrel()
  end

  local function GetRect(asset, scale, anchor)
    local width = asset.width * scale
    local height = asset.height * scale
    local left, bottom
    if anchor[1] == "BOTTOMLEFT" then
      left = anchor[2] or 0
      bottom = anchor[3] or 0
    elseif anchor[1] == "BOTTOM" then
      left = anchor[2] and anchor[2] - width / 2 or -width / 2
      bottom = anchor[3] or 0
    elseif anchor[1] == "BOTTOMRIGHT" then
      left = anchor[2] and anchor[2] - width or -width
      bottom = anchor[3] or 0
    elseif anchor[1] == "TOPLEFT" then
      left = anchor[2] or 0
      bottom = anchor[3] and anchor[3] - height
    elseif anchor[1] == "TOP" then
      left = anchor[2] and anchor[2] - width / 2 or -width / 2
      bottom = anchor[3] and anchor[3] - height
    elseif anchor[1] == "TOPRIGHT" then
      left = anchor[2] and anchor[2] - width or -width
      bottom = anchor[3] and anchor[3] - height
    else
      left = -width / 2
      bottom = -height / 2
    end
    return {left = left, bottom = bottom, width = width, height = height}
  end

  local left, right, top, bottom = 0, 0, 0, 0

  local function CacheSize(rect)
    left = math.min(left, rect.left)
    bottom = math.min(bottom, rect.bottom)
    top = math.max(rect.bottom + rect.height, top)
    right = math.max(rect.left + rect.width, right)
  end

  for index, barDetails in ipairs(design.bars) do
    local rect = GetRect(addonTable.Assets.BarBackgrounds[barDetails.foreground.asset], barDetails.scale, barDetails.anchor)
    CacheSize(rect)
  end

  for index, textDetails in ipairs(design.texts) do
    local rect = GetRect({width = textDetails.widthLimit or 20, height = 10}, textDetails.scale, textDetails.anchor)
    CacheSize(rect)
  end

  for index, specialDetails in ipairs(design.specialBars) do
    if specialDetails.kind == "power" then
      local rect = GetRect(addonTable.Assets.PowerBars[specialDetails.blank], specialDetails.scale, specialDetails.anchor)
      CacheSize(rect)
    end
  end

  addonTable.Rect = {left = left, bottom = bottom, width = right - left, height = top - bottom}

  addonTable.Config.Set(addonTable.Config.Options.DESIGN, design)
end

function addonTable.Core.Initialize()
  addonTable.Config.InitializeData()

  addonTable.SlashCmd.Initialize()

  --if next(addonTable.Config.Get(addonTable.Config.Options.DESIGN)) == nil then
  --  addonTable.Config.Set(addonTable.Config.Options.DESIGN, addonTable.Design.GetDefaultDesignSlight())
  --end

  SetStyle()
  addonTable.CallbackRegistry:RegisterCallback("SettingChanged", function(_, name)
    if name == addonTable.Config.Options.STYLE then
      SetStyle()
    end
  end)

  addonTable.Assets.ApplyScale()

  addonTable.CustomiseDialog.Initialize()

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
