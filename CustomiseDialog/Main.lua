---@class addonTablePlatynator
local addonTable = select(2, ...)

local customisers = {}

local function SetupGeneral(parent)
  local container = CreateFrame("Frame", nil, parent)

  local allFrames = {}
  local infoInset = CreateFrame("Frame", nil, container, "InsetFrameTemplate")
  do
    table.insert(allFrames, infoInset)
    infoInset:SetPoint("TOP")
    infoInset:SetPoint("LEFT", 20, 0)
    infoInset:SetPoint("RIGHT", -20, 0)
    infoInset:SetHeight(75)
    --addonTable.Skins.AddFrame("InsetFrame", infoInset)

    local logo = infoInset:CreateTexture(nil, "ARTWORK")
    logo:SetTexture("Interface\\AddOns\\Platynator\\Assets\\logo.png")
    logo:SetSize(52, 52)
    logo:SetPoint("LEFT", 8, 0)

    local name = infoInset:CreateFontString(nil, "ARTWORK", "GameFontHighlightHuge")
    name:SetText(addonTable.Locales.PLATYNATOR)
    name:SetPoint("TOPLEFT", logo, "TOPRIGHT", 10, 0)

    local credit = infoInset:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    credit:SetText(addonTable.Locales.BY_PLUSMOUSE)
    credit:SetPoint("BOTTOMLEFT", name, "BOTTOMRIGHT", 5, 0)

    local discordButton = CreateFrame("Button", nil, infoInset, "UIPanelDynamicResizeButtonTemplate")
    discordButton:SetText(addonTable.Locales.JOIN_THE_DISCORD)
    DynamicResizeButton_Resize(discordButton)
    discordButton:SetPoint("BOTTOMLEFT", logo, "BOTTOMRIGHT", 8, 0)
    discordButton:SetScript("OnClick", function()
      addonTable.Dialogs.ShowCopy("https://discord.gg/cUvDQT9JqK")
    end)
    --addonTable.Skins.AddFrame("Button", discordButton)
    local discordText = infoInset:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    discordText:SetPoint("LEFT", discordButton, "RIGHT", 10, 0)
    discordText:SetText(addonTable.Locales.DISCORD_DESCRIPTION)
  end

  do
    local header = addonTable.CustomiseDialog.Components.GetHeader(container, addonTable.Locales.DEVELOPMENT_IS_TIME_CONSUMING)
    header:SetPoint("TOP", allFrames[#allFrames], "BOTTOM", 0, -30)
    table.insert(allFrames, header)

    local donateFrame = CreateFrame("Frame", nil, container)
    donateFrame:SetPoint("LEFT")
    donateFrame:SetPoint("RIGHT")
    donateFrame:SetPoint("TOP", allFrames[#allFrames], "BOTTOM")
    donateFrame:SetHeight(40)
    local text = donateFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("RIGHT", donateFrame, "CENTER", -50, 0)
    text:SetText(addonTable.Locales.DONATE)
    text:SetJustifyH("RIGHT")

    local button = CreateFrame("Button", nil, donateFrame, "UIPanelDynamicResizeButtonTemplate")
    button:SetText(addonTable.Locales.LINK)
    DynamicResizeButton_Resize(button)
    button:SetPoint("LEFT", donateFrame, "CENTER", -35, 0)
    button:SetScript("OnClick", function()
      addonTable.Dialogs.ShowCopy("https://linktr.ee/plusmouse")
    end)
    --addonTable.Skins.AddFrame("Button", button)
    table.insert(allFrames, donateFrame)
  end

  local profileDropdown = addonTable.CustomiseDialog.Components.GetBasicDropdown(container, addonTable.Locales.PROFILES)
  do
    profileDropdown.SetValue = nil

    local clone = false
    local function ValidateAndCreate(profileName)
      if profileName ~= "" and PLATYNATOR_CONFIG.Profiles[profileName] == nil then
        local oldSkin = addonTable.Config.Get(addonTable.Config.Options.CURRENT_SKIN)
        addonTable.Config.MakeProfile(profileName, clone)
        profileDropdown.DropDown:GenerateMenu()
        if addonTable.Config.Get(addonTable.Config.Options.CURRENT_SKIN) ~= oldSkin then
          addonTable.Dialogs.ShowConfirm(addonTable.Locales.RELOAD_REQUIRED, YES, NO, function() ReloadUI() end)
        end
      end
    end
    profileDropdown:SetPoint("TOP", allFrames[#allFrames], "BOTTOM", 0, -30)
    profileDropdown.DropDown:SetupMenu(function(menu, rootDescription)
      local profiles = addonTable.Config.GetProfileNames()
      table.sort(profiles, function(a, b) return a:lower() < b:lower() end)
      for _, name in ipairs(profiles) do
        local button = rootDescription:CreateRadio(name ~= "DEFAULT" and name or LIGHTBLUE_FONT_COLOR:WrapTextInColorCode(DEFAULT), function()
          return PLATYNATOR_CURRENT_PROFILE == name
        end, function()
          local oldSkin = addonTable.Config.Get(addonTable.Config.Options.CURRENT_SKIN)
          addonTable.Config.ChangeProfile(name)
          if addonTable.Config.Get(addonTable.Config.Options.CURRENT_SKIN) ~= oldSkin then
            addonTable.Dialogs.ShowConfirm(addonTable.Locales.RELOAD_REQUIRED, YES, NO, function() ReloadUI() end)
          end
        end)
        if name ~= "DEFAULT" and name ~= PLATYNATOR_CURRENT_PROFILE then
          button:AddInitializer(function(button, description, menu)
            local delete = MenuTemplates.AttachAutoHideButton(button, "transmog-icon-remove")
            delete:SetPoint("RIGHT")
            delete:SetSize(18, 18)
            delete.Texture:SetAtlas("transmog-icon-remove")
            delete:SetScript("OnClick", function()
              menu:Close()
              addonTable.Dialogs.ShowConfirm(addonTable.Locales.CONFIRM_DELETE_PROFILE_X:format(name), YES, NO, function()
                addonTable.Config.DeleteProfile(name)
              end)
            end)
            MenuUtil.HookTooltipScripts(delete, function(tooltip)
              GameTooltip_SetTitle(tooltip, DELETE);
            end);
          end)
        end
      end
      rootDescription:CreateButton(NORMAL_FONT_COLOR:WrapTextInColorCode(addonTable.Locales.NEW_PROFILE_CLONE), function()
        clone = true
        addonTable.Dialogs.ShowEditBox(addonTable.Locales.ENTER_PROFILE_NAME, ACCEPT, CANCEL, ValidateAndCreate)
      end)
      rootDescription:CreateButton(NORMAL_FONT_COLOR:WrapTextInColorCode(addonTable.Locales.NEW_PROFILE_BLANK), function()
        clone = false
        addonTable.Dialogs.ShowEditBox(addonTable.Locales.ENTER_PROFILE_NAME, ACCEPT, CANCEL, ValidateAndCreate)
      end)
    end)
  end
  table.insert(allFrames, profileDropdown)

  if C_EncodingUtil then
    local exportButton = CreateFrame("Button", nil, container, "UIPanelDynamicResizeButtonTemplate")
    exportButton:SetPoint("TOPLEFT", allFrames[#allFrames], "BOTTOM", -33, -10)
    exportButton:SetText(addonTable.Locales.EXPORT)
    DynamicResizeButton_Resize(exportButton)
    exportButton:SetScript("OnClick", function()
      local design = CopyTable(addonTable.Config.Get(addonTable.Config.Options.DESIGN))
      design.addon = "Platynator"
      design.version = 1
      addonTable.Dialogs.ShowCopy(C_EncodingUtil.SerializeJSON(design):gsub("%|%|", "|"):gsub("%|", "||"))
    end)
    --addonTable.Skins.AddFrame("Button", exportButton)

    local importButton = CreateFrame("Button", nil, container, "UIPanelDynamicResizeButtonTemplate")
    importButton:SetPoint("TOPRIGHT", allFrames[#allFrames], "BOTTOM", -45, -10)
    importButton:SetText(addonTable.Locales.IMPORT)
    DynamicResizeButton_Resize(importButton)
    importButton:SetScript("OnClick", function()
      addonTable.CustomiseDialog.ShowImportDialog(function(text)
        local newDesign = C_EncodingUtil.DeserializeJSON(text)
        addonTable.Core.MigrateSettings(newDesign)
        newDesign.version = nil
        newDesign.addon = nil
        addonTable.Config.Set(addonTable.Config.Options.DESIGN, newDesign)
        addonTable.Config.Set(addonTable.Config.Options.STYLE, "_custom")
      end)
    end)
    --addonTable.Skins.AddFrame("Button", importButton)
  end

  container:SetScript("OnShow", function()
    for _, f in ipairs(allFrames) do
      if f.SetValue then
        f:SetValue(addonTable.Config.Get(f.option))
      end
    end
  end)

  return container
end

local function SetupBehaviour(parent)
  local container = CreateFrame("Frame", nil, parent)

  local allFrames = {}

  local friendlyStyleDropdown = addonTable.CustomiseDialog.Components.GetBasicDropdown(container, addonTable.Locales.FRIENDLY_STYLE, function(value)
    return addonTable.Config.Get(addonTable.Config.Options.DESIGNS_ASSIGNED)["friend"] == value
  end, function(value)
    addonTable.Config.Get(addonTable.Config.Options.DESIGNS_ASSIGNED)["friend"] = value
    addonTable.CallbackRegistry:TriggerEvent("RefreshStateChange", {[addonTable.Constants.RefreshReason.Design] = true})
  end)
  friendlyStyleDropdown:SetPoint("TOP")
  table.insert(allFrames, friendlyStyleDropdown)

  local enemyStyleDropdown = addonTable.CustomiseDialog.Components.GetBasicDropdown(container, addonTable.Locales.ENEMY_STYLE, function(value)
    return addonTable.Config.Get(addonTable.Config.Options.DESIGNS_ASSIGNED)["enemy"] == value
  end, function(value)
    addonTable.Config.Get(addonTable.Config.Options.DESIGNS_ASSIGNED)["enemy"] = value
    addonTable.CallbackRegistry:TriggerEvent("RefreshStateChange", {[addonTable.Constants.RefreshReason.Design] = true})
  end)
  enemyStyleDropdown:SetPoint("TOP", allFrames[#allFrames], "BOTTOM")
  table.insert(allFrames, enemyStyleDropdown)

  local targetDropdown = addonTable.CustomiseDialog.Components.GetBasicDropdown(container, addonTable.Locales.ON_TARGETING, function(value)
    return addonTable.Config.Get(addonTable.Config.Options.TARGET_BEHAVIOUR) == value
  end, function(value)
    addonTable.Config.Set(addonTable.Config.Options.TARGET_BEHAVIOUR, value)
  end)
  targetDropdown:SetPoint("TOP", allFrames[#allFrames], "BOTTOM", 0, -30)
  do
    local entries = {
      addonTable.Locales.DO_NOTHING,
      addonTable.Locales.ENLARGE_NAMEPLATE,
    }
    local values = {
      "none",
      "enlarge",
    }
    targetDropdown:Init(entries, values)
  end
  table.insert(allFrames, targetDropdown)

  local notTargetDropdown = addonTable.CustomiseDialog.Components.GetBasicDropdown(container, addonTable.Locales.ON_NOT_TARGETING, function(value)
    return addonTable.Config.Get(addonTable.Config.Options.NOT_TARGET_BEHAVIOUR) == value
  end, function(value)
    addonTable.Config.Set(addonTable.Config.Options.NOT_TARGET_BEHAVIOUR, value)
  end)
  notTargetDropdown:SetPoint("TOP", allFrames[#allFrames], "BOTTOM")
  do
    local entries = {
      addonTable.Locales.DO_NOTHING,
      addonTable.Locales.FADE,
    }
    local values = {
      "none",
      "fade",
    }
    notTargetDropdown:Init(entries, values)
  end
  table.insert(allFrames, notTargetDropdown)

  container:SetScript("OnShow", function()
    local styles = {}
    for key, value in pairs(addonTable.Config.Get(addonTable.Config.Options.DESIGNS)) do
      table.insert(styles, {label = key ~= "_custom" and key or addonTable.Locales.CUSTOM, value = key})
    end
    table.sort(styles, function(a, b) return a.label < b.label end)
    local stylesBuiltIn = {}
    for key, label in pairs(addonTable.Design.NameMap) do
      if key ~= "_custom" then
        table.insert(stylesBuiltIn, {label = label .. " " .. addonTable.Locales.DEFAULT_BRACKETS, value = key})
      end
    end
    table.sort(stylesBuiltIn, function(a, b) return a.label < b.label end)
    tAppendAll(styles, stylesBuiltIn)
    local labels, values = {}, {}
    for _, entry in ipairs(styles) do
      table.insert(labels, entry.label)
      table.insert(values, entry.value)
    end

    friendlyStyleDropdown:Init(labels, values)
    enemyStyleDropdown:Init(labels, values)

    for _, f in ipairs(allFrames) do
      if f.SetValue then
        if f.option then
          f:SetValue(addonTable.Config.Get(f.option))
        else
          f:SetValue()
        end
      end
    end
  end)

  return container
end

local function SetupFont(parent)
  local container = CreateFrame("Frame", nil, parent)

  local allFrames = {}

  local fontDropdown = addonTable.CustomiseDialog.Components.GetBasicDropdown(container, addonTable.Locales.FONT)
  fontDropdown:SetPoint("TOP")
  table.insert(allFrames, fontDropdown)

  local fonts = {}
  for key, value in pairs(addonTable.Assets.Fonts) do
    table.insert(fonts, {label = value.preview, id = key})
  end
  table.sort(fonts, function(a, b) return a.label < b.label end)

  fontDropdown.DropDown:SetupMenu(function(_, rootDescription)
    for _, details in ipairs(fonts) do
      local radio = rootDescription:CreateRadio(details.label,
        function()
          return addonTable.Core.GetDesign("enemy").font.asset == details.id
        end,
        function()
          local design = addonTable.Core.GetDesign("enemy")
          local oldAsset = design.font.asset
          if details.id ~= oldAsset then
            design.font.asset = details.id
            addonTable.Config.Set(addonTable.Config.Options.STYLE, "_custom")
            addonTable.CallbackRegistry:TriggerEvent("RefreshStateChange", {[addonTable.Constants.RefreshReason.Design] = true})
          end
        end
      )
      radio:AddInitializer(function(button, elementDescription, menu)
        button.fontString:SetFontObject(addonTable.Core.GetFontByID(details.id, 13))
      end)
    end
    rootDescription:SetScrollMode(20 * 20)
  end)

  local outlineCheckbox = addonTable.CustomiseDialog.Components.GetCheckbox(container, addonTable.Locales.SHOW_OUTLINE, 28, function(value)
    local design = addonTable.Core.GetDesign("enemy")
    if value ~= design.font.outline then
      design.font.outline = value
      addonTable.Config.Set(addonTable.Config.Options.STYLE, "_custom")
      addonTable.CallbackRegistry:TriggerEvent("RefreshStateChange", {[addonTable.Constants.RefreshReason.Design] = true})
    end
  end)
  outlineCheckbox:SetPoint("TOP", allFrames[#allFrames], "BOTTOM")
  table.insert(allFrames, outlineCheckbox)

  local shadowCheckbox = addonTable.CustomiseDialog.Components.GetCheckbox(container, addonTable.Locales.SHOW_SHADOW, 28, function(value)
    local design = addonTable.Core.GetDesign("enemy")
    if value ~= design.font.shadow then
      design.font.shadow = value
      addonTable.Config.Set(addonTable.Config.Options.STYLE, "_custom")
      addonTable.CallbackRegistry:TriggerEvent("RefreshStateChange", {[addonTable.Constants.RefreshReason.Design] = true})
    end
  end)
  shadowCheckbox:SetPoint("TOP", allFrames[#allFrames], "BOTTOM")
  table.insert(allFrames, shadowCheckbox)

  container:SetScript("OnShow", function()
    local design = addonTable.Core.GetDesign("enemy")
    outlineCheckbox:SetValue(design.font.outline)
    shadowCheckbox:SetValue(design.font.shadow)

    for _, f in ipairs(allFrames) do
      if f.DropDown then
        f:SetValue()
      end
    end
  end)

  return container
end

local TabSetups = {
  {callback = SetupGeneral, name = addonTable.Locales.GENERAL},
  {callback = addonTable.CustomiseDialog.GetMainDesigner, name = addonTable.Locales.DESIGNER},
  {callback = SetupBehaviour, name = addonTable.Locales.BEHAVIOUR},
  {callback = SetupFont, name = addonTable.Locales.FONT},
}

function addonTable.CustomiseDialog.Toggle()
  if customisers[addonTable.Config.Get(addonTable.Config.Options.CURRENT_SKIN)] then
    local frame = customisers[addonTable.Config.Get(addonTable.Config.Options.CURRENT_SKIN)]
    frame:SetShown(not frame:IsVisible())
    return
  end

  local frame = CreateFrame("Frame", "PlatynatorCustomiseDialog" .. addonTable.Config.Get(addonTable.Config.Options.CURRENT_SKIN), UIParent, "ButtonFrameTemplate")
  frame:SetToplevel(true)
  customisers[addonTable.Config.Get(addonTable.Config.Options.CURRENT_SKIN)] = frame
  table.insert(UISpecialFrames, frame:GetName())
  frame:SetSize(600, 790)
  frame:SetPoint("CENTER")
  frame:Raise()

  frame.CloseButton:SetScript("OnClick", function()
    frame:Hide()
  end)

  frame:SetMovable(true)
  frame:SetClampedToScreen(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", function()
    frame:StartMoving()
    frame:SetUserPlaced(false)
  end)
  frame:SetScript("OnDragStop", function()
    frame:StopMovingOrSizing()
    frame:SetUserPlaced(false)
  end)

  ButtonFrameTemplate_HidePortrait(frame)
  ButtonFrameTemplate_HideButtonBar(frame)
  frame.Inset:Hide()
  frame:EnableMouse(true)
  frame:SetScript("OnMouseWheel", function() end)

  frame:SetTitle(addonTable.Locales.CUSTOMISE_PLATYNATOR)

  local containers = {}
  local lastTab
  local Tabs = {}
  for _, setup in ipairs(TabSetups) do
    local tabContainer = setup.callback(frame)
    tabContainer:SetPoint("TOPLEFT", 0 + addonTable.Constants.ButtonFrameOffset, -65)
    tabContainer:SetPoint("BOTTOMRIGHT")

    local tabButton = addonTable.CustomiseDialog.Components.GetTab(frame, setup.name)
    if lastTab then
      tabButton:SetPoint("LEFT", lastTab, "RIGHT", 5, 0)
    else
      tabButton:SetPoint("TOPLEFT", 0 + addonTable.Constants.ButtonFrameOffset + 5, -25)
    end
    lastTab = tabButton
    tabContainer.button = tabButton
    tabButton:SetScript("OnClick", function()
      for _, c in ipairs(containers) do
        PanelTemplates_DeselectTab(c.button)
        c:Hide()
      end
      PanelTemplates_SelectTab(tabButton)
      tabContainer:Show()
    end)
    tabContainer:Hide()

    table.insert(Tabs, tabButton)
    table.insert(containers, tabContainer)
  end
  frame.Tabs = Tabs
  PanelTemplates_SetNumTabs(frame, #frame.Tabs)
  containers[1].button:Click()

  frame:SetScript("OnShow", function()
    local shownContainer = FindValueInTableIf(containers, function(c) return c:IsShown() end)
    if shownContainer then
      PanelTemplates_SetTab(frame, tIndexOf(containers, shownContainer))
    end
  end)

  --addonTable.Skins.AddFrame("ButtonFrame", frame, {"customise"})
end
