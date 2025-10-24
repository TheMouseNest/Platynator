---@class addonTablePlatynator
local addonTable = select(2, ...)

local function Announce()
  addonTable.Config.Set(addonTable.Config.Options.STYLE, "custom")
  addonTable.CallbackRegistry:TriggerEvent("RefreshStateChange", {[addonTable.Constants.RefreshReason.Design] = true})
end

function addonTable.CustomiseDialog.GetMainDesigner(parent)
  local container = CreateFrame("Frame", nil, parent)

  local allFrames = {}

  do
    local styleDropdown = addonTable.CustomiseDialog.Components.GetBasicDropdown(container, addonTable.Locales.STYLE, function(value)
      return addonTable.Config.Get(addonTable.Config.Options.STYLE) == value
    end, function(value)
      addonTable.Config.Set(addonTable.Config.Options.STYLE, value)
    end)
    styleDropdown.option = addonTable.Config.Options.STYLE

    styleDropdown:Init({
      addonTable.Locales.CUSTOM,
      addonTable.Locales.SQUIRREL,
      addonTable.Locales.RABBIT,
      addonTable.Locales.HARE,
      addonTable.Locales.HEDGEHOG,
      addonTable.Locales.BEAVER,
      addonTable.Locales.BLIZZARD,
      addonTable.Locales.BLIZZARD_CLASSIC,
    }, {
      "custom",
      "squirrel",
      "rabbit",
      "hare",
      "hedgehog",
      "beaver",
      "blizzard",
      "blizzard-classic",
    })

    styleDropdown:SetPoint("TOP")
    table.insert(allFrames, styleDropdown)

    addonTable.CallbackRegistry:RegisterCallback("SettingChanged", function(_, name)
      if name == addonTable.Config.Options.STYLE then
        styleDropdown:SetValue()
      end
    end)
  end

  do
    local globalScale = addonTable.CustomiseDialog.Components.GetSlider(container, addonTable.Locales.GLOBAL_SCALE, 1, 300, "%d%%", function(value)
      addonTable.Config.Set(addonTable.Config.Options.GLOBAL_SCALE, value/100)
    end)
    globalScale:SetValue(addonTable.Config.Get(addonTable.Config.Options.GLOBAL_SCALE) * 100)
    globalScale.option = addonTable.Config.Options.GLOBAL_SCALE
    globalScale.scale = 100

    globalScale:SetPoint("TOP", allFrames[#allFrames], "BOTTOM")
    table.insert(allFrames, globalScale)
  end

  local UpdateSelection
  local UpdateWidgetPoints
  local widgets
  local selectionIndexes = {}
  local autoSelectedDetails

  local previewInset = CreateFrame("Frame", nil, container, "InsetFrameTemplate")
  previewInset:SetPoint("TOP", allFrames[#allFrames], "BOTTOM", 0, -30)
  previewInset:SetPoint("LEFT", 20, 0)
  previewInset:SetPoint("RIGHT", -20, 0)
  previewInset:SetHeight(220)

  local preview = CreateFrame("Frame", nil, previewInset)

  preview:SetPoint("TOP")

  preview:SetAllPoints()
  preview:SetFlattensRenderLayers(true)
  preview:SetScale(2)

  local function ToggleSelection(w)
    local index = tIndexOf(widgets, w)
    if IsShiftKeyDown() then
      local selectionIndex = tIndexOf(selectionIndexes, index)
      if selectionIndex ~= nil then
        table.remove(selectionIndexes, selectionIndex)
      else
        table.insert(selectionIndexes, index)
      end
    elseif #selectionIndexes > 1 or #selectionIndexes == 0 or selectionIndexes[1] ~= index then
      selectionIndexes = {index}
    else
      selectionIndexes = {}
    end
    UpdateSelection()
  end
  local function ForceSelection(w)
    local index = tIndexOf(widgets, w)
    if tIndexOf(selectionIndexes, index) == nil then
      selectionIndexes = {index}
    end
    UpdateSelection()
  end

  UpdateWidgetPoints = function(w, snapping, offsetX, offsetY)
    snapping = snapping or 2
    offsetX = offsetX or 0
    offsetY = offsetY or 0
    local left, bottom, width, height = w:GetRect()
    local widgetRect = {left = left + offsetX, bottom = bottom + offsetY, width = width, height = height}
    left, bottom, width, height = preview:GetRect()
    local previewRect = {left = left, bottom = bottom, width = width, height = height}
    local widgetCenter = {x = widgetRect.left + widgetRect.width / 2, y = widgetRect.bottom + widgetRect.height / 2}
    local previewCenter = {x = previewRect.left + previewRect.width / 2, y = previewRect.bottom + previewRect.height / 2}

    local point, x, y = "", 0, 0

    local snapX, snapY, xLock, yLock = 0, 0, false, false
    if math.abs(widgetCenter.y - previewCenter.y) < snapping then
      snapY = previewCenter.y - widgetCenter.y
      point = point
      yLock = true
    elseif widgetCenter.y < previewCenter.y then
      point = "TOP" .. point
      y = widgetRect.bottom + widgetRect.height - previewCenter.y
    else
      point = "BOTTOM" .. point
      y = widgetRect.bottom - previewCenter.y
    end

    if math.abs(widgetCenter.x - previewCenter.x) < snapping then
      snapX = previewCenter.x - widgetCenter.x
      xLock = true
      point = point
    elseif widgetCenter.x < previewCenter.x then
      point = point .. "LEFT"
      x = widgetRect.left - previewCenter.x
    else
      point = point .. "RIGHT"
      x = widgetRect.left + widgetRect.width - previewCenter.x
    end

    if point == "" then
      w.details.anchor = {}
    elseif x == 0 and y == 0 then
      w.details.anchor = {point}
    else
      w.details.anchor = {point, Round(x), Round(y)}
    end

    if x ~= 0 then
      snapX = Round(x) - x
    end
    if y ~= 0 then
      snapY = Round(y) - y
    end

    -- snapX, snapY used to offset other widgets to keep them all consistent to each other
    -- xLock, yLock used to prevent a widget shifting because its been centered on an axis
    -- (this prevents infinite loops from the shifts bouncing around)
    return snapX, snapY, xLock, yLock
  end

  local function AlignForRelativePoints(offsets, snappingAmount)
    snappingAmount = snappingAmount or 3
    local snapped = true
    local iteration = 0
    -- Shift items around until we reach a happy medium where everything is approximately in the same
    -- relative place to the other items as it was before moving, complext because of allowing widgets to snap to center points
    while snapped and
      -- Capped iterations to a reasonably high number that it isn't expected to reach (unless dozens of items are selected)
      iteration < 200
      do

      iteration = iteration + 1
      snapped = false
      local snapX, snapY, xLock, yLock = 0, 0
      local endIndex = #selectionIndexes
      for indexIndex, index in ipairs(selectionIndexes) do
        local w = widgets[index]
        snapX, snapY, xLock, yLock = UpdateWidgetPoints(w, snappingAmount, offsets[indexIndex].x, offsets[indexIndex].y)
        local o = offsets[indexIndex]
        if math.abs(snapX) >= 0.5 and not o.xLock or math.abs(snapY) >= 0.5 and not o.yLock then
          -- See UpdateWidgetPoints for usage of xLock/yLock
          o.xLock = o.xLock or xLock
          o.yLock = o.yLock or yLock
          if o.xLock then
            o.x = o.x + snapX
          end
          if o.yLock then
            o.y = o.y + snapY
          end
          endIndex = indexIndex
          snapped = true
          break
        else
          offsets[indexIndex] = {x = offsets[indexIndex].x + snapX, y = offsets[indexIndex].y + snapY}
        end
      end

      if snapped then
        for indexIndex, index in ipairs(selectionIndexes) do
          local o = offsets[indexIndex]
          if not o.xLock then
            o.x = o.x + snapX
          end
          if not o.yLock then
            o.y = o.y + snapY
          end
        end
      end
    end
  end

  local movingMonitor = CreateFrame("Frame")
  movingMonitor:RegisterEvent("GLOBAL_MOUSE_UP")
  local cursorX, cursorY = GetCursorPosition()
  local function NotifyMouseDown()
    cursorX, cursorY = GetCursorPosition()
    cursorX = cursorX / preview:GetEffectiveScale()
    cursorY = cursorY / preview:GetEffectiveScale()
  end
  local function StartMovingSelection()
    local backupSelectionIndexes = CopyTable(selectionIndexes)

    movingMonitor:SetScript("OnUpdate", function()
      local newCursorX, newCursorY = GetCursorPosition()
      newCursorX = newCursorX / preview:GetEffectiveScale()
      newCursorY = newCursorY / preview:GetEffectiveScale()
      for _, index in ipairs(backupSelectionIndexes) do
        local w = widgets[index]
        w:AdjustPointsOffset(newCursorX - cursorX, newCursorY - cursorY)
      end
      cursorX = newCursorX
      cursorY = newCursorY
    end)
    movingMonitor:SetScript("OnEvent", function()
      movingMonitor:SetScript("OnUpdate", nil)
      movingMonitor:SetScript("OnEvent", nil)
      selectionIndexes = backupSelectionIndexes
      local offsets = {}
      for _, index in ipairs(selectionIndexes) do
        table.insert(offsets, {x = 0, y = 0, xLock = false, yLock = false})
      end
      AlignForRelativePoints(offsets)
      Announce()
    end)
  end

  local function DeleteCurrentWidget()
    table.sort(selectionIndexes, function(a, b) return a > b end)
    for _, index in ipairs(selectionIndexes) do
      local kind = widgets[index].kind
      local details = widgets[index].details
      local design = addonTable.Config.Get(addonTable.Config.Options.DESIGN)
      local index = tIndexOf(design[kind], details)
      table.remove(design[kind], index)
    end
    selectionIndexes = {}
    Announce()
  end

  local selectorPool = CreateFramePool("Frame", container, nil, nil, false, function(selector)
    local selectionTexture = selector:CreateTexture()
    selectionTexture:SetTexture("Interface/AddOns/Platynator/Assets/selection-outline.png")
    selectionTexture:SetTextureSliceMargins(45, 45, 45, 45)
    selectionTexture:SetTextureSliceMode(Enum.UITextureSliceMode.Tiled)
    selectionTexture:SetVertexColor(78/255, 165/255, 252/255, 0.9)
    selectionTexture:SetScale(0.25)
    selectionTexture:SetAllPoints()
  end)
  local keyboardTrap = CreateFrame("Frame", nil, container)
  keyboardTrap:Hide()

  local hoverMarker = CreateFrame("Frame", nil, container)
  local hoverTexture = hoverMarker:CreateTexture()
  hoverTexture:SetTexture("Interface/AddOns/Platynator/Assets/selection-outline.png")
  hoverTexture:SetVertexColor(78/255, 165/255, 252/255, 0.45)
  hoverTexture:SetTextureSliceMargins(45, 45, 45, 45)
  hoverTexture:SetTextureSliceMode(Enum.UITextureSliceMode.Tiled)
  hoverTexture:SetScale(0.25)
  hoverTexture:SetAllPoints()

  local titleText = container:CreateFontString(nil, nil, "GameFontHighlightLarge")
  titleText:SetPoint("TOP", previewInset, "BOTTOM", 0, -15)
  titleText:SetPoint("LEFT", 40, 0)
  titleText:SetJustifyH("CENTER")
  titleText:SetPoint("RIGHT", -20, 0)
  titleText:SetShadowOffset(1, -1)

  local function OffsetWidgets(x, y)
    local offsets = {}
    for _, index in ipairs(selectionIndexes) do
      table.insert(offsets, {x = x, y = y, xLock = x == 0, yLock = y == 0})
    end
    AlignForRelativePoints(offsets, 0.6)
    Announce()
  end

  keyboardTrap:SetScript("OnKeyDown", function(_, key)
    keyboardTrap:SetPropagateKeyboardInput(false)
    local amount = 1
    if key == "LEFT" then
      OffsetWidgets(-amount, 0)
    elseif key == "RIGHT" then
      OffsetWidgets(amount, 0)
    elseif key == "UP" then
      OffsetWidgets(0, amount)
    elseif key == "DOWN" then
      OffsetWidgets(0, -amount)
    elseif key == "DELETE" then
      DeleteCurrentWidget()
    else
      keyboardTrap:SetPropagateKeyboardInput(true)
    end
  end)
  keyboardTrap:RegisterEvent("PLAYER_REGEN_ENABLED")
  keyboardTrap:RegisterEvent("PLAYER_REGEN_DISABLED")
  keyboardTrap:SetScript("OnEvent", function(_, event)
    keyboardTrap:SetShown(event == "PLAYER_REGEN_ENABLED" and selectionIndex ~= 0)
  end)

  local addButton = CreateFrame("DropdownButton", nil, previewInset, "UIPanelDynamicResizeButtonTemplate")
  addButton:SetText(addonTable.Locales.ADD_WIDGET)
  DynamicResizeButton_Resize(addButton)
  addButton:SetPoint("TOPLEFT", 0, addButton:GetHeight() + 2)
  addButton:SetupMenu(function(menu, rootDescription)
    local design = addonTable.Config.Get(addonTable.Config.Options.DESIGN)
    for _, details in ipairs(addonTable.CustomiseDialog.DesignWidgets) do
      if details.special == "header" then
        rootDescription:CreateTitle(details.name)
      else
        local skip = false
        if details.noDuplicates then
          for _, entry in ipairs(design[details.kind]) do
            if entry.kind == details.default.kind then
              skip = true
              break
            end
          end
        end
        if not skip then
          rootDescription:CreateButton(details.name, function()
            table.insert(design[details.kind], CopyTable(details.default))
            autoSelectedDetails = design[details.kind][#design[details.kind]]
            Announce()
          end)
        else
          rootDescription:CreateTitle(GRAY_FONT_COLOR:WrapTextInColorCode(details.name))
        end
      end
    end
  end)

  local titleMap = {}

  local lastHeader
  for _, entry in ipairs(addonTable.CustomiseDialog.DesignWidgets) do
    if entry.special == "header" then
      lastHeader = entry.name
    else
      if not titleMap[entry.kind] then
        titleMap[entry.kind] = {}
      end
      titleMap[entry.kind][entry.default.kind] = lastHeader .. ": " .. entry.name
    end
  end

  local deleteButton = CreateFrame("Button", nil, previewInset, "UIPanelDynamicResizeButtonTemplate")
  deleteButton:SetText(addonTable.Locales.DELETE_WIDGET)
  DynamicResizeButton_Resize(deleteButton)
  deleteButton:SetPoint("TOPRIGHT", 0, addButton:GetHeight() + 2)
  deleteButton:SetScript("OnClick", function()
    DeleteCurrentWidget()
  end)

  local auraContainers = {
    buffs = CreateFrame("Frame", nil, preview),
    debuffs = CreateFrame("Frame", nil, preview),
    crowdControl = CreateFrame("Frame", nil, preview),
  }
  do
    local textures = {
      buffs = {132117},
      debuffs = {135959},
      crowdControl = {135860},
    }
    for kind, w in pairs(auraContainers) do
      w:SetSize(10, 10)
      w.Wrapper = CreateFrame("Frame", nil, w)
      w.Wrapper:SetSize(10, 20)
      w.Wrapper:SetPoint("BOTTOMLEFT")
      w.count = #textures[kind]
      for index, tex in ipairs(textures[kind]) do
        local buff = CreateFrame("Frame", nil, w.Wrapper, "PlatynatorNameplateBuffButtonTemplate")
        buff:Show()
        buff.Icon:SetTexture(tex)
        buff:SetPoint("LEFT", (index - 1) * 22, 0)
      end
      w.kind = "auras"
      w:SetScript("OnEnter", function()
        hoverMarker:Show()
        hoverMarker:SetFrameStrata("HIGH")
        hoverMarker:ClearAllPoints()
        hoverMarker:SetPoint("TOPLEFT", w, "TOPLEFT", -2, 2)
        hoverMarker:SetPoint("BOTTOMRIGHT", w, "BOTTOMRIGHT", 2, -2)
      end)
      w:SetScript("OnLeave", function()
        hoverMarker:Hide()
      end)

      w:SetMovable(true)
      w:EnableMouse(true)
      w:RegisterForDrag("LeftButton")
      w:SetScript("OnMouseDown", function()
        NotifyMouseDown()
      end)
      w:SetScript("OnDragStart", function()
        ForceSelection(w)
        StartMovingSelection()
      end)
      w:SetScript("OnMouseUp", function()
        ToggleSelection(w)
      end)
    end
  end

  local function GenerateWidgets()
    if widgets then
      addonTable.Display.ReleaseWidgets(tFilter(widgets, function(w) return w.Strip end, true), true)
    end
    local design = addonTable.Config.Get(addonTable.Config.Options.DESIGN)
    widgets = addonTable.Display.GetWidgets(design, preview, true)
    for _, w in ipairs(widgets) do
      w:SetClampedToScreen(true)
      if w.kind == "bars" then
        local defaultColor
        if w.details.kind == "health" and w.details.aggroColoursOnHostiles then
          defaultColor = w.details.colors.threat.warning
        elseif w.details.kind == "health" then
          defaultColor = w.details.colors.npc.hostile
        else
          defaultColor = w.details.colors.normal
        end
        w.statusBar:SetMinMaxValues(0, 100)
        w.statusBar:SetValue(70)
        w.statusBar:GetStatusBarTexture():SetVertexColor(defaultColor.r, defaultColor.g, defaultColor.b)
        if w.details.background.applyColor then
          w.background:SetVertexColor(defaultColor.r, defaultColor.g, defaultColor.b)
        end
        w.marker:SetVertexColor(defaultColor.r, defaultColor.g, defaultColor.b)
      elseif w.kind == "texts" then
        local display
        if w.details.kind == "health" then
          local types = w.details.displayTypes
          local values = {
            absolute = AbbreviateNumbers(70000),
            percentage = "70%",
          }
          if #types == 2 then
            display = string.format("%s (%s)", values[types[1]], values[types[2]])
          elseif #types == 1 then
            display = string.format("%s", values[types[1]])
          else
            display = addonTable.Locales.NO_VALUE_UPPER
          end
        elseif w.details.kind == "creatureName" then
          display = "Cheesanator"
        elseif w.details.kind == "castSpellName" then
          display = addonTable.Locales.ARCANE_FLURRY
        elseif w.details.kind == "level" then
          display = "60"
        end
        if display then
          w.text:SetText(display)
        end
      elseif w.kind == "specialBars" and w.details.kind == "power" then
        w.main:GetStatusBarTexture():SetVertexColor(234/255, 61/255, 247/255)
        w.main:SetValue(4)
        w.background:SetValue(6)
      elseif w.kind == "markers" then
        local asset = addonTable.Assets.Markers[w.details.asset]
        if asset.preview then
          w.marker:SetTexture(asset.preview)
        end
      end

      w:SetScript("OnEnter", function()
        hoverMarker:Show()
        hoverMarker:SetFrameStrata("HIGH")
        hoverMarker:ClearAllPoints()
        hoverMarker:SetPoint("TOPLEFT", w, "TOPLEFT", -2, 2)
        hoverMarker:SetPoint("BOTTOMRIGHT", w, "BOTTOMRIGHT", 2, -2)
      end)
      w:SetScript("OnLeave", function()
        hoverMarker:Hide()
      end)

      w:SetMovable(true)
      w:EnableMouse(true)
      w:RegisterForDrag("LeftButton")
      w:SetScript("OnMouseDown", function()
        NotifyMouseDown()
      end)
      w:SetScript("OnDragStart", function()
        ForceSelection(w)
        StartMovingSelection()
      end)
      w:SetScript("OnMouseUp", function()
        ToggleSelection(w)
      end)
    end
    for _, container in pairs(auraContainers) do
      container:Hide()
    end
    for _, details in ipairs(design.auras) do
      local container = auraContainers[details.kind]
      container:Show()
      if details.kind == "debuffs" then
        container:SetFrameLevel(801)
      elseif details.kind == "buffs" then
        container:SetFrameLevel(802)
      else
        container:SetFrameLevel(803)
      end
      container:SetSize(22 * container.count * details.scale, 20 * details.scale)
      container.Wrapper:SetScale(details.scale)
      container.details = details
      table.insert(widgets, container)
      container:ClearAllPoints()
      addonTable.Display.ApplyAnchor(container, details.anchor)
    end
  end

  GenerateWidgets()

  addonTable.CallbackRegistry:RegisterCallback("RefreshStateChange", function(_, state)
    if state[addonTable.Constants.RefreshReason.Design] then
      local design = addonTable.Config.Get(addonTable.Config.Options.DESIGN)
      addonTable.CurrentFont = addonTable.Core.GetFontByID(design.font.asset)
      GenerateWidgets()
      if autoSelectedDetails then
        for index, w in ipairs(widgets) do
          if w.details == autoSelectedDetails then
            selectionIndex = index
            break
          end
        end
        autoSelectedDetails = nil
      end
      UpdateSelection()
    end
  end)

  table.insert(allFrames, previewInset)

  local settingsFrames = {}

  local function Generate()
    local function AddToTab(tab, entries, kind)
      local parent, yOffset = nil, -40
      if kind == "*" then
        parent = tab
      else
        parent = CreateFrame("Frame", nil, tab)
        if tab.lastOption then
          parent:SetPoint("TOP", tab.lastOption, "BOTTOM", 0, -30)
        else
          parent:SetPoint("TOP", 0, yOffset)
        end
        yOffset = 0
        parent:SetPoint("LEFT")
        parent:SetPoint("RIGHT")
        parent:SetHeight(300)
        parent:Hide()
        tab.kindSpecificSettings[kind] = parent
      end

      local allFrames = {}

      for _, e in ipairs(entries) do
        local frame
        local function Setter(value)
          if not parent.details then
            return
          end
          local oldValue = e.getter(parent.details)
          e.setter(parent.details, value)
          if oldValue ~= e.getter(parent.details) then
            Announce()
          end
        end
        local function Getter(value)
          if not parent.details then
            return
          end
          return e.getter(parent.details)
        end
        if e.kind == "slider" then
          frame = addonTable.CustomiseDialog.Components.GetSlider(parent, e.label, e.min, e.max, e.valuePattern, Setter)
        elseif e.kind == "dropdown" then
          frame = addonTable.CustomiseDialog.Components.GetBasicDropdown(parent, e.label, function(value)
            if not parent.details then
              return false
            end
            return value == e.getter(parent.details)
          end, Setter)
        elseif e.kind == "checkbox" then
          frame = addonTable.CustomiseDialog.Components.GetCheckbox(parent, e.label, 28, Setter)
        elseif e.kind == "colorPicker" then
          frame = addonTable.CustomiseDialog.Components.GetColorPicker(parent, e.label, Setter)
        end

        if frame then
          frame.kind = e.kind
          frame.getInitData = e.getInitData
          frame.Getter = Getter
          if #allFrames == 0 then
            frame:SetPoint("TOP", 0, yOffset)
          else
            frame:SetPoint("TOP", allFrames[#allFrames], "BOTTOM", 0, yOffset)
          end
          table.insert(allFrames, frame)
          yOffset = 0
        elseif e.kind == "spacer" then
          yOffset = -30
        end

        if parent == tab then
          tab.lastOption = allFrames[#allFrames]
        end
      end

      function parent:UpdateOptions(details)
        parent.details = details
        for _, f in ipairs(allFrames) do
          if f.getInitData then
            f:Init(f.getInitData(details))
          end
          f:SetValue(f.Getter())
        end
      end
    end
    for kind, details in pairs(addonTable.CustomiseDialog.WidgetsConfig) do
      local settingsContainer = CreateFrame("Frame", nil, container)
      settingsContainer:SetPoint("TOP", previewInset, "BOTTOM")
      settingsContainer:SetPoint("LEFT")
      settingsContainer:SetPoint("RIGHT")
      settingsContainer:SetHeight(300)
      settingsContainer:Hide()
      table.insert(settingsFrames, settingsContainer)

      local tabs = {}
      local tabMap = {}
      local function InitTab(tab, tabButton, label)
        tab:SetPoint("LEFT")
        tab:SetPoint("RIGHT")
        tab:SetHeight(300)
        tab.button = tabButton
        if #tabs == 0 then
          tabButton:SetPoint("TOPLEFT", 20, 0)
        else
          tabButton:SetPoint("TOPLEFT", tabs[#tabs].button, "TOPRIGHT", 5, 0)
        end
        tabButton.kind = label
        tabButton.label = label
        tabButton:SetScript("OnClick", function()
          tabButton:GetParent():SetTab(tabButton.label)
        end)
        tab.kindSpecificSettings = {}

        tabMap[label] = tab
        table.insert(tabs, tab)
        function tab:Set(details)
          if tab.UpdateOptions then
            tab:UpdateOptions(details)
          end
          for subKind, nestedContainer in pairs(self.kindSpecificSettings) do
            if subKind == details.kind then
              nestedContainer.details = nil
              nestedContainer:Show()
              nestedContainer:UpdateOptions(details)
            else
              nestedContainer:Hide()
            end
          end
        end
      end

      function settingsContainer:IsFor(newKind, details)
        return newKind == kind
      end

      settingsContainer.tabIndex = 1
      local tabManager = CreateFrame("Frame", nil, settingsContainer)
      tabManager:SetPoint("TOP", 0, -5)
      tabManager:SetPoint("LEFT")
      tabManager:SetPoint("RIGHT")
      tabManager:SetHeight(30)
      function tabManager:SetTab(label)
        local currentTab
        for index, t in ipairs(tabs) do
          if t.button.label ~= label then
            PanelTemplates_DeselectTab(t.button)
            t:Hide()
          else
            currentTab = t
            settingsContainer.tabIndex = index
          end
        end
        PanelTemplates_SelectTab(currentTab.button)
        currentTab.details = nil
        currentTab:Show()
        currentTab:Set(settingsContainer.details)
      end
      function settingsContainer:Set(details)
        settingsContainer.details = details
        tabManager:SetTab(tabs[settingsContainer.tabIndex].button.label)
      end
      if details["*"] then
        for _, tabDetails in ipairs(details["*"]) do
          local tabContainer = CreateFrame("Frame", nil, settingsContainer)
          local tabButton = addonTable.CustomiseDialog.Components.GetTab(tabManager, tabDetails.label)
          InitTab(tabContainer, tabButton, tabDetails.label)
          AddToTab(tabContainer, tabDetails.entries, "*")
        end
      end
      for key in pairs(details) do
        if key ~= "*" then
          for _, tabDetails in ipairs(details[key]) do
            if not tabMap[tabDetails.label] then
              local tabContainer = CreateFrame("Frame", nil, settingsContainer)
              local tabButton = addonTable.CustomiseDialog.Components.GetTab(tabManager, tabDetails.label)
              InitTab(tabContainer, tabButton, tabDetails.label)
            end
            AddToTab(tabMap[tabDetails.label], tabDetails.entries, key)
          end
        end
      end

      tabManager.Tabs = {}
      for _, tabContainer in ipairs(tabs) do
        table.insert(tabManager.Tabs, tabContainer.button)
      end
    end
  end

  Generate()

  UpdateSelection = function()
    selectionIndexes = tFilter(selectionIndexes, function(i) return i <= #widgets end, true)
    if #selectionIndexes == 0 then
      keyboardTrap:Hide()
      deleteButton:Disable()
      for _, frame in ipairs(settingsFrames) do
        frame:Hide()
      end
      selectorPool:ReleaseAll()
      titleText:SetText("")
      return
    end
    deleteButton:Enable()

    if #selectionIndexes > 1 then
      titleText:SetText(addonTable.Locales.MULTIPLE_SELECTED)

      for _, frame in ipairs(settingsFrames) do
        frame:Hide()
      end
    else
      local w = widgets[selectionIndexes[1]]
      titleText:SetText(titleMap[w.kind] and titleMap[w.kind][w.details.kind] or UNKNOWN)

      for _, frame in ipairs(settingsFrames) do
        if not frame:IsFor(w.kind, w.details) then
          frame:Hide()
        end
      end

      for _, frame in ipairs(settingsFrames) do
        if frame:IsFor(w.kind, w.details) then
          frame.details = nil
          frame:Show()
          frame:Set(w.details)
        end
      end
    end

    selectorPool:ReleaseAll()
    for _, index in ipairs(selectionIndexes) do
      local w = widgets[index]
      local selector = selectorPool:Acquire()
      selector:Show()
      selector:SetFrameStrata("HIGH")
      selector:SetPoint("TOPLEFT", w, "TOPLEFT", -2, 2)
      selector:SetPoint("BOTTOMRIGHT", w, "BOTTOMRIGHT", 2, -2)
    end

    keyboardTrap:SetShown(not InCombatLockdown())
  end

  container:SetScript("OnShow", function()
    for _, f in ipairs(allFrames) do
      if f.SetValue and f.scale then
        f:SetValue(addonTable.Config.Get(f.option) * f.scale)
      elseif f.SetValue and f.option then
        f:SetValue(addonTable.Config.Get(f.option))
      elseif f.SetValue then
        f:SetValue()
      end
    end

    selectionIndexes = {}
    UpdateSelection()
  end)

  return container
end
