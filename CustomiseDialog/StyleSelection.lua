---@class addonTablePlatynator
local addonTable = select(2, ...)

local function Announce()
  addonTable.CallbackRegistry:TriggerEvent("CustomiseDesignsAssigned")
end

local contextCriteria = {
  {title = addonTable.Locales.ATTACK},
  {key = "can-attack", label = addonTable.Locales.CAN_ATTACK},
  {key = "cannot-attack", label = addonTable.Locales.CANNOT_ATTACK},

  {title = addonTable.Locales.COMBAT},
  {key = "in-combat", label = addonTable.Locales.IN_COMBAT},
  {key = "out-combat", label = addonTable.Locales.OUT_OF_COMBAT},

  {title = addonTable.Locales.ALIGNMENT},
  {key = "friend", label = addonTable.Locales.FRIENDLY},
  {key = "hostile", label = addonTable.Locales.HOSTILE},
  {key = "neutral", label = addonTable.Locales.NEUTRAL},

  {title = addonTable.Locales.SPECIAL},
  {key = "player", label = addonTable.Locales.PLAYER},
  {key = "npc", label = addonTable.Locales.NPC},
  {key = "minion", label = addonTable.Locales.MINION},

  {title = addonTable.Locales.MOB_CLASSIFICATION},
  {key = "class-rare", label = addonTable.Locales.RARE},
  {key = "class-elite", label = addonTable.Locales.ELITE},
  {key = "class-worldboss", label = addonTable.Locales.WORLD_BOSS},
  {key = "class-normal", label = addonTable.Locales.NORMAL},
  {key = "class-minor", label = addonTable.Locales.MINOR},
  {key = "class-trivial", label = addonTable.Locales.TRIVIAL},

  {title = addonTable.Locales.LOCATION},
  {key = "loc-world", label = addonTable.Locales.WORLD},
  {key = "loc-dungeon", label = addonTable.Locales.DUNGEON},
  {key = "loc-raid", label = addonTable.Locales.RAID},
  {key = "loc-pvp", label = addonTable.Locales.PVP},
  {key = "loc-delve", label = addonTable.Locales.DELVE},

  {title = addonTable.Locales.ELITE_TYPE},
  {key = "elite-boss", label = addonTable.Locales.BOSS},
  {key = "elite-miniboss", label = addonTable.Locales.MINIBOSS},
  {key = "elite-caster", label = addonTable.Locales.CASTER},
  {key = "elite-melee", label = addonTable.Locales.MELEE},
  {key = "elite-trivial", label = addonTable.Locales.TRIVIAL},

  {title = addonTable.Locales.DELVE_TYPE},
  {key = "delve-boss", label = addonTable.Locales.BOSS},
  {key = "delve-elite", label = addonTable.Locales.MINIBOSS},
  {key = "delve-rare", label = addonTable.Locales.RARE},
  {key = "delve-caster", label = addonTable.Locales.CASTER},
  {key = "delve-melee", label = addonTable.Locales.MELEE},
  {key = "delve-trivial", label = addonTable.Locales.TRIVIAL},
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

local function AddStyles(rootDescription, isSet, onSet)
  local styles = {}
  for key, _ in pairs(addonTable.Config.Get(addonTable.Config.Options.DESIGNS)) do
    table.insert(styles, {label = key ~= addonTable.Constants.CustomName and key or addonTable.Locales.CUSTOM, value = key})
  end
  table.sort(styles, function(a, b) return a.label < b.label end)
  local stylesBuiltIn = {}
  for key, label in pairs(addonTable.Design.NameMap) do
    if key ~= addonTable.Constants.CustomName then
      table.insert(stylesBuiltIn, {label = label .. " " .. addonTable.Locales.DEFAULT_BRACKETS, value = key})
    end
  end
  table.sort(stylesBuiltIn, function(a, b) return a.label < b.label end)
  tAppendAll(styles, stylesBuiltIn)

  for _, entry in ipairs(styles) do
    rootDescription:CreateRadio(entry.label, isSet, onSet, entry.value)
  end
end

function addonTable.CustomiseDialog.IsUsingDefaultStyleSelect()
  local cmp = {
    {criteria = {"cannot-attack"}, simplified = false, scale = 1, style = "_name-only"},
    {criteria = {"can-attack", "class-minor"}, simplified = true, scale = 1, style = "_hare_simplified"},
    {criteria = {"can-attack", "minion"}, simplified = true, scale = 1, style = "_hare_simplified"},
    {criteria = {"can-attack", "loc-dungeon", "class-normal"}, simplified = true, scale = 1, style = "_hare_simplified"},
    {criteria = {"can-attack"}, simplified = false, scale = 1, style = "_deer"},
  }

  local current = addonTable.Config.Get(addonTable.Config.Options.DESIGN_ASSIGNMENTS)

  if #current > #cmp or #current < 2 then
    return false
  end

  if not tCompare(current[1].criteria, cmp[1].criteria) or current[1].simplified or current[1].scale ~= 1 then
    return false
  end
  local tail = #current
  if not tCompare(current[tail].criteria, cmp[#cmp].criteria) or current[tail].simplified or current[tail].scale ~= 1 then
    return false
  end

  if #current > 2 then
    local first = current[2].style
    for i = 2, #current - 1 do
      if current[i].style ~= first or not current[i].simplified or current[i].scale ~= 1 then
        return false
      end
      local any = false
      for j = 2, 4 do
        if tCompare(cmp[j].criteria, current[i].criteria) then
          any = true
          break
        end
      end
      if not any then
        return false
      end
    end
  end

  return true
end

local function GetDefaultOptions(container)
  local defaultContainer = CreateFrame("Frame", nil, container)
  local allFrames = {}

  local function GenerateDropdown(parent, label, criteria)
    local dropdown = addonTable.CustomiseDialog.Components.GetBasicDropdown(parent, label)
    dropdown.customSetter = function(val)
      local assignments = addonTable.Config.Get(addonTable.Config.Options.DESIGN_ASSIGNMENTS)
      for _, c in ipairs(criteria) do
        for _, a in ipairs(assignments) do
          if tCompare(a.criteria, c) then
            a.style = val
          end
        end
      end
      addonTable.CallbackRegistry:TriggerEvent("CustomiseDesignsAssigned")
    end
    dropdown.customGetter = function(val)
      local assignments = addonTable.Config.Get(addonTable.Config.Options.DESIGN_ASSIGNMENTS)
      for _, c in ipairs(criteria) do
        for _, a in ipairs(assignments) do
          if tCompare(a.criteria, c) then
            return a.style == val
          end
        end
      end
    end
    return dropdown
  end

  local friendlyStyleDropdown = GenerateDropdown(defaultContainer, addonTable.Locales.FRIENDLY, {{"cannot-attack"}})
  friendlyStyleDropdown:SetPoint("TOP")
  table.insert(allFrames, friendlyStyleDropdown)

  local enemyStyleDropdown = GenerateDropdown(defaultContainer, addonTable.Locales.ENEMY, {{"can-attack"}})
  enemyStyleDropdown:SetPoint("TOP", allFrames[#allFrames], "BOTTOM")
  table.insert(allFrames, enemyStyleDropdown)

  local simplifiedStyleDropdown
  if C_NamePlateManager and C_NamePlateManager.SetNamePlateSimplified then
    local allCriteria = {{"can-attack", "class-minor"}, {"can-attack", "minion"}, {"can-attack", "loc-dungeon", "class-normal"}}
    simplifiedStyleDropdown = GenerateDropdown(defaultContainer, addonTable.Locales.SIMPLIFIED, allCriteria)
    simplifiedStyleDropdown:SetPoint("TOP", allFrames[#allFrames], "BOTTOM", 0, -30)
    table.insert(allFrames, simplifiedStyleDropdown)

    local fallback = addonTable.Config.Get(addonTable.Config.Options.SIMPLIFIED_ASSIGNED_FALLBACK)
    simplifiedStyleDropdown.DropDown:SetDefaultText(GRAY_FONT_COLOR:WrapTextInColorCode(addonTable.Design.NameMap[fallback] or fallback))

    local appliesToDropdown = addonTable.CustomiseDialog.Components.GetBasicDropdown(defaultContainer, addonTable.Locales.APPLIES_TO)
    appliesToDropdown.DropDown:SetDefaultText(addonTable.Locales.NONE)

    local function GetOption(rootDescription, label, criteria)
      rootDescription:CreateCheckbox(label, function()
        local assignments = addonTable.Config.Get(addonTable.Config.Options.DESIGN_ASSIGNMENTS)
        for _, a in ipairs(assignments) do
          if tCompare(a.criteria, criteria) then
            return true
          end
        end
        return false
      end, function()
        local assignments = addonTable.Config.Get(addonTable.Config.Options.DESIGN_ASSIGNMENTS)
        local index
        for i, a in ipairs(assignments) do
          if tCompare(a.criteria, criteria) then
              index = i
          end
        end
        if index then
          addonTable.Config.Set(addonTable.Config.Options.SIMPLIFIED_ASSIGNED_FALLBACK, assignments[index].style)
          table.remove(assignments, index)
        elseif #assignments > 2 then
          table.insert(assignments, 2,
            {criteria = CopyTable(criteria), simplified = true, scale = 1, style = assignments[2].style}
          )
        else
          local fallback = addonTable.Config.Get(addonTable.Config.Options.SIMPLIFIED_ASSIGNED_FALLBACK)
          if not addonTable.Core.GetDesignByName(fallback) then
            fallback = "_hare_simplified"
          end
          table.insert(assignments, 2,
            {criteria = CopyTable(criteria), simplified = true, scale = 1, style = fallback}
          )
        end
        Announce()
        simplifiedStyleDropdown.DropDown:GenerateMenu()
      end)
    end
    appliesToDropdown.DropDown:SetupMenu(function(_, rootDescription)
      GetOption(rootDescription, addonTable.Locales.NORMAL_INSTANCES_ONLY, allCriteria[3])
      GetOption(rootDescription, addonTable.Locales.MINION, allCriteria[2])
      GetOption(rootDescription, addonTable.Locales.MINOR, allCriteria[1])
    end)
    appliesToDropdown:SetPoint("TOP", simplifiedStyleDropdown, "BOTTOM")

    addonTable.CallbackRegistry:RegisterCallback("SettingChanged", function(_, setting)
      if setting == addonTable.Config.Options.SIMPLIFIED_ASSIGNED_FALLBACK then
        local fallback = addonTable.Config.Get(addonTable.Config.Options.SIMPLIFIED_ASSIGNED_FALLBACK)
        simplifiedStyleDropdown.DropDown:SetDefaultText(GRAY_FONT_COLOR:WrapTextInColorCode(addonTable.Design.NameMap[fallback] or fallback))
      end
    end)
  end

  defaultContainer:SetScript("OnShow", function()
    for _, dropdown in ipairs(allFrames) do
      dropdown.DropDown:SetupMenu(function(_, rootDescription)
        AddStyles(rootDescription, dropdown.customGetter, dropdown.customSetter)
      end)
    end
  end)

  return defaultContainer
end

local function GetCustomOptions(container)
  local customContainer = CreateFrame("Frame", nil, container)

  local ScrollBox = CreateFrame("Frame", nil, customContainer, "WowScrollBox")
  ScrollBox:SetPoint("TOPLEFT")
  ScrollBox:SetPoint("BOTTOMRIGHT", 0, 50)
  local ScrollBar = CreateFrame("EventFrame", nil, customContainer, "MinimalScrollBar")
  ScrollBar:SetPoint("TOPRIGHT", -10, 0)
  ScrollBar:SetPoint("BOTTOMRIGHT", -10, 50)
  --addonTable.Skins.AddFrame("TrimScrollBar", ScrollBar)
  local ScrollChild = CreateFrame("Frame", nil, ScrollBox)
  ScrollChild.scrollable = true
  ScrollUtil.InitScrollBoxWithScrollBar(ScrollBox, ScrollBar, CreateScrollBoxLinearView())
  ScrollUtil.AddManagedScrollBarVisibilityBehavior(ScrollBox, ScrollBar)
  ScrollBox:SetPanExtent(100)
  local allFrames = {}
  local Refresh

  local holderPool = CreateFramePool("Frame", ScrollChild, nil, nil, false, function(frame)
    frame:SetHeight(100)

    frame.removeEntryButton = CreateFrame("Button", nil, frame)
    frame.removeEntryButton:SetSize(30, 30)
    frame.removeEntryButton:SetNormalAtlas("128-RedButton-Delete")
    frame.removeEntryButton:SetPushedAtlas("128-RedButton-Delete-Pressed")
    frame.removeEntryButton:SetHighlightAtlas("128-RedButton-Delete-Highlight")
    frame.removeEntryButton:SetPoint("RIGHT", 5, 38)
    frame.removeEntryButton:SetScript("OnClick", function()
      local assignments = addonTable.Config.Get(addonTable.Config.Options.DESIGN_ASSIGNMENTS)
      local index = tIndexOf(assignments, frame.entry)
      if index then
        table.remove(assignments, index)
        Announce()
        Refresh()
      end
    end)

    frame.shiftUp = CreateFrame("Button", nil, frame)
    frame.shiftUp:SetSize(16, 20)
    frame.shiftUp:SetNormalAtlas("bag-arrow")
    frame.shiftUp:GetNormalTexture():SetRotation(- math.pi / 2)
    frame.shiftUp:GetNormalTexture():SetSize(16, 10)
    frame.shiftUp:SetScript("OnEnter", function()
      frame.shiftUp:GetNormalTexture():SetAlpha(0.5)
    end)
    frame.shiftUp:SetScript("OnLeave", function()
      frame.shiftUp:GetNormalTexture():SetAlpha(1)
    end)
    frame.shiftDown = CreateFrame("Button", nil, frame)
    frame.shiftDown:SetSize(16, 20)
    frame.shiftDown:SetNormalAtlas("bag-arrow")
    frame.shiftDown:GetNormalTexture():SetRotation(math.pi / 2)
    frame.shiftDown:GetNormalTexture():SetSize(16, 10)
    frame.shiftDown:SetScript("OnEnter", function()
      frame.shiftDown:GetNormalTexture():SetAlpha(0.5)
    end)
    frame.shiftDown:SetScript("OnLeave", function()
      frame.shiftDown:GetNormalTexture():SetAlpha(1)
    end)
    frame.shiftUp:SetPoint("TOPLEFT", -20, -10)
    frame.shiftDown:SetPoint("TOPLEFT", -20, -30)

    frame.shiftUp:SetScript("OnClick", function()
      local assignments = addonTable.Config.Get(addonTable.Config.Options.DESIGN_ASSIGNMENTS)
      local index = tIndexOf(assignments, frame.entry)
      assignments[index] = assignments[index - 1]
      assignments[index - 1] = frame.entry
      Announce()
      Refresh()
    end)
    frame.shiftDown:SetScript("OnClick", function()
      local assignments = addonTable.Config.Get(addonTable.Config.Options.DESIGN_ASSIGNMENTS)
      local index = tIndexOf(assignments, frame.entry)
      assignments[index] = assignments[index + 1]
      assignments[index + 1] = frame.entry
      Announce()
      Refresh()
    end)

    frame.criteriaDropdown = CreateFrame("DropdownButton", nil, frame, "WowStyle1DropdownTemplate")
    frame.criteriaDropdown:SetWidth(210)
    frame.criteriaDropdown:SetDefaultText(addonTable.Locales.SELECT_CRITERIA)
    frame.criteriaDropdown:SetPoint("TOP")
    frame.criteriaDropdown:SetPoint("RIGHT", frame, "CENTER", 20, 0)
    frame.criteriaDropdown:SetupMenu(function(_, rootDescription)
      AddCriteria(rootDescription,
        function(key)
          if not frame.entry then
            return false
          end
          return tIndexOf(frame.entry.criteria, key) ~= nil
        end,
        function(key)
          if not frame.entry then
            return
          end
          local index = tIndexOf(frame.entry.criteria, key)
          if index == nil then
            table.insert(frame.entry.criteria, key)
          else
            table.remove(frame.entry.criteria, index)
          end
          Announce()
        end
      )
    end)
    local criteriaLabel = frame:CreateFontString(nil, nil, "GameFontHighlight")
    criteriaLabel:SetText(addonTable.Locales.ACTIVATION)
    criteriaLabel:SetPoint("RIGHT", frame.criteriaDropdown, "LEFT", -10, 0)

    frame.styleDropdown = CreateFrame("DropdownButton", nil, frame, "WowStyle1DropdownTemplate")
    frame.styleDropdown:SetWidth(150)
    frame.styleDropdown:SetPoint("TOP")
    frame.styleDropdown:SetPoint("RIGHT", -35, 0)
    frame.styleDropdown:SetupMenu(function(_, rootDescription)
      AddStyles(rootDescription,
        function(key)
          return frame.entry ~= nil and frame.entry.style == key
        end,
        function(key)
          if not frame.entry then
            return
          end
          if key ~= frame.entry.style then
            frame.entry.style = key
            Announce()
          end
        end
      )
    end)
    local styleLabel = frame:CreateFontString(nil, nil, "GameFontHighlight")
    styleLabel:SetText(addonTable.Locales.STYLE)
    styleLabel:SetPoint("RIGHT", frame.styleDropdown, "LEFT", -10, 0)

    frame.scaleSlider = addonTable.CustomiseDialog.Components.GetSlider(frame, addonTable.Locales.SCALE, 25, 300, function(val)
      return val .. "%"
    end, function(val)
      local newVal = val / 100
      if frame.entry.scale ~= newVal then
        frame.entry.scale = val / 100
        Announce()
      end
    end)
    frame.scaleSlider:ClearAllPoints()
    frame.scaleSlider:SetPoint("LEFT", -55, 0)
    frame.scaleSlider:SetPoint("RIGHT", frame.criteriaDropdown)
    frame.scaleSlider:SetPoint("TOP", frame, 0, -30)

    frame.simplifiedCheckbox = addonTable.CustomiseDialog.Components.GetCheckbox(frame, addonTable.Locales.SIMPLIFIED, 0, function(value)
      if frame.entry.simplified ~= value then
        frame.entry.simplified = value
        Announce()
      end
    end)

    frame.simplifiedCheckbox:ClearAllPoints()
    frame.simplifiedCheckbox:SetPoint("TOP", frame, 0, -30)
    frame.simplifiedCheckbox:SetPoint("LEFT", styleLabel, -10, 0)
    frame.simplifiedCheckbox:SetPoint("RIGHT", frame.styleDropdown)

    function frame:SetEntry(entry)
      frame.entry = entry
      local assignments = addonTable.Config.Get(addonTable.Config.Options.DESIGN_ASSIGNMENTS)
      local index = tIndexOf(assignments, entry)
      frame.shiftUp:SetShown(index > 1)
      frame.shiftDown:SetShown(index < #assignments)

      frame.simplifiedCheckbox:SetValue(frame.entry.simplified)
      frame.scaleSlider:SetValue(frame.entry.scale * 100)
      frame:Show()
    end
  end)

  local addButton = CreateFrame("Button", nil, customContainer, "UIPanelDynamicResizeButtonTemplate")
  addButton:SetText(addonTable.Locales.ADD)
  DynamicResizeButton_Resize(addButton)
  addButton:SetPoint("BOTTOM", 0, 25)
  addButton:SetPoint("RIGHT", customContainer, "CENTER", -10, 0)
  addButton:SetScript("OnClick", function()
    local assignments = addonTable.Config.Get(addonTable.Config.Options.DESIGN_ASSIGNMENTS)
    table.insert(assignments, {criteria = {"can-attack"}, simplified = false, scale = 1, style = "_deer"})
    Refresh()
    Announce()
  end)

  local resetButton = CreateFrame("Button", nil, customContainer, "UIPanelDynamicResizeButtonTemplate")
  resetButton:SetText(addonTable.Locales.DEFAULT)
  DynamicResizeButton_Resize(resetButton)
  resetButton:SetPoint("BOTTOM", 0, 25)
  resetButton:SetPoint("LEFT", customContainer, "CENTER", 10, 0)
  resetButton:SetScript("OnClick", function()
    local enemy = addonTable.Display.Context:GetDefaultEnemyNPCDesign()
    local friendly = addonTable.Display.Context:GetDefaultFriendlyPlayerDesign()
    addonTable.Config.ResetOne(addonTable.Config.Options.DESIGN_ASSIGNMENTS)
    local assignments = addonTable.Config.Get(addonTable.Config.Options.DESIGN_ASSIGNMENTS)
    assignments[1].style = friendly
    assignments[#assignments].style = enemy
    Refresh()
    Announce()
  end)

  Refresh = function()
    holderPool:ReleaseAll()
    allFrames = {}

    local assignments = addonTable.Config.Get(addonTable.Config.Options.DESIGN_ASSIGNMENTS)

    local offsetY = 0
    for _, entry in ipairs(assignments) do
      if addonTable.Constants.IsSimplifiedAvailable or not entry.simplified then
        local holder = holderPool:Acquire()
        table.insert(allFrames, holder)
        holder:SetEntry(entry)
        holder:SetPoint("TOP", 0, offsetY)
        holder:SetPoint("LEFT", 30, 0)
        holder:SetPoint("RIGHT", -30, 0)
        offsetY = offsetY - holder:GetHeight()
      end
    end

    ScrollChild:SetHeight(-offsetY)
    ScrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately)
  end

  customContainer:SetScript("OnShow", Refresh)

  return customContainer
end

function addonTable.CustomiseDialog.GetStyleSelection(parent)
  local container = CreateFrame("Frame", nil, parent)

  local defaultContainer = GetDefaultOptions(container)
  local customContainer = GetCustomOptions(container)

  local tabContainers = {
    {name = addonTable.Locales.DEFAULT, container = defaultContainer},
    {name = addonTable.Locales.CUSTOM, container = customContainer},
  }

  local Tabs = {}
  local lastTab
  for _, setup in ipairs(tabContainers) do
    local tabContainer = setup.container
    tabContainer:SetPoint("TOPLEFT", addonTable.Constants.ButtonFrameOffset, -45)
    tabContainer:SetPoint("BOTTOMRIGHT")

    local tabButton = addonTable.CustomiseDialog.Components.GetTab(container, setup.name)
    if lastTab then
      tabButton:SetPoint("LEFT", lastTab, "RIGHT", 5, 0)
    else
      tabButton:SetPoint("TOPLEFT", 0 + addonTable.Constants.ButtonFrameOffset + 5, 0)
    end
    lastTab = tabButton
    tabContainer.button = tabButton
    tabButton:SetScript("OnClick", function()
      for _, c in ipairs(tabContainers) do
        PanelTemplates_DeselectTab(c.container.button)
        c.container:Hide()
      end
      PanelTemplates_SelectTab(tabButton)
      tabContainer:Show()
    end)
    tabContainer:Hide()

    table.insert(Tabs, tabButton)
  end
  container.Tabs = Tabs
  PanelTemplates_SetNumTabs(container, #container.Tabs)

  local wasDefault = true
  container:SetScript("OnShow", function()
    local usingDefault = addonTable.CustomiseDialog.IsUsingDefaultStyleSelect()
    wasDefault = usingDefault
    Tabs[1]:SetEnabled(usingDefault)
    Tabs[1]:SetAlpha(usingDefault and 1 or 0.5)
    if usingDefault then
      Tabs[1]:Click()
    else
      C_Timer.After(0, function()
        Tabs[1]:SetEnabled(usingDefault)
      end)
      Tabs[2]:Click()
    end
  end)

  addonTable.CallbackRegistry:RegisterCallback("CustomiseDesignsAssigned", function()
    local usingDefault = addonTable.CustomiseDialog.IsUsingDefaultStyleSelect()
    if wasDefault and usingDefault then
      return
    end
    wasDefault = usingDefault
    Tabs[1]:SetEnabled(usingDefault)
    Tabs[1]:SetAlpha(usingDefault and 1 or 0.5)
  end)

  return container
end
