---@class addonTablePlatynator
local addonTable = select(2, ...)

local function Announce()
  if addonTable.Config.Get(addonTable.Config.Options.STYLE):match("^_") then
    addonTable.Config.Set(addonTable.Config.Options.STYLE, addonTable.Constants.CustomName)
  end
  addonTable.CallbackRegistry:TriggerEvent("RefreshStateChange", {[addonTable.Constants.RefreshReason.Design] = true})
end

local pixelStep = 0.5

local function RoundPixel(pixel)
  return Round(pixel / pixelStep) * pixelStep
end

local function GetAutomaticColors(rootParent, lockedElements, addAlpha)
  local selectedValue = ""
  local UpdateSelected

  local container = CreateFrame("Frame", nil, rootParent)
  container:SetAllPoints()

  local colorsListContainer = CreateFrame("Frame", nil, container)

  local inset = CreateFrame("Frame", nil, colorsListContainer, "InsetFrameTemplate")
  inset:SetPoint("TOPLEFT")
  inset:SetPoint("BOTTOMRIGHT", -15, 0)
  --addonTable.Skins.AddFrame("InsetFrame", inset)
  colorsListContainer.ScrollBox = CreateFrame("Frame", nil, colorsListContainer, "WowScrollBoxList")
  colorsListContainer.ScrollBox:SetPoint("TOPLEFT", 1, -3)
  colorsListContainer.ScrollBox:SetPoint("BOTTOMRIGHT", -15, 3)

  local scrollView = CreateScrollBoxListLinearView()
  scrollView:SetElementExtent(40)
  scrollView:SetElementInitializer("Button", function(frame, elementData)
    if not frame.initialized then
      frame.initialized = true
      frame:SetNormalFontObject(GameFontHighlight)
      frame:SetHighlightAtlas("Options_List_Hover")
      frame.selectedTexture = frame:CreateTexture(nil, "ARTWORK")
      frame.selectedTexture:SetAllPoints(true)
      frame.selectedTexture:Hide()
      frame.selectedTexture:SetAtlas("Options_List_Active")
      frame:SetScript("OnClick", function(self, button)
        UpdateSelected(self.value)
      end)
      frame:SetText(" ")
      frame:GetFontString():SetWordWrap(false)
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
      frame.shiftDown:SetPoint("RIGHT", -5, 2)
      frame.shiftDown:SetScript("OnEnter", function()
        frame.shiftDown:GetNormalTexture():SetAlpha(0.5)
      end)
      frame.shiftDown:SetScript("OnLeave", function()
        frame.shiftDown:GetNormalTexture():SetAlpha(1)
      end)
      frame.shiftUp:SetPoint("RIGHT", frame.shiftDown, "LEFT", -2, 0)

      frame.shiftUp:SetScript("OnClick", function()
        UpdateSelected(frame.value)
        if frame.index > 1 then
          local old = container.details[frame.index - 1]
          if lockedElements[old.kind] then
            return
          end
          container.details[frame.index - 1] = container.details[frame.index]
          container.details[frame.index] = old
          Announce()
        end
      end)

      frame.shiftDown:SetScript("OnClick", function()
        UpdateSelected(frame.value)
        if frame.index < #container.details then
          local old = container.details[frame.index + 1]
          if lockedElements[old.kind] then
            return
          end
          container.details[frame.index + 1] = container.details[frame.index]
          container.details[frame.index] = old
          Announce()
        end
      end)
    end
    frame.value = elementData.value
    frame.index = elementData.index
    frame.selectedTexture:SetShown(frame.value == selectedValue)
    frame.shiftUp:SetShown(not lockedElements[frame.value] and frame.index > 1 and not lockedElements[container.details[frame.index - 1].kind])
    frame.shiftDown:SetShown(not lockedElements[frame.value] and frame.index < #container.details and not lockedElements[container.details[frame.index + 1].kind])
    frame:SetText(elementData.label)
    frame:GetFontString():SetPoint("RIGHT", -8, 0)
    frame:GetFontString():SetPoint("LEFT", 20, 0)
    frame:GetFontString():SetJustifyH("LEFT")
  end)

  local colorsDropdown = CreateFrame("DropdownButton", nil, colorsListContainer, "WowStyle1DropdownTemplate")
  colorsDropdown:SetWidth(250)
  colorsDropdown:SetPoint("LEFT")
  colorsDropdown:SetPoint("RIGHT")
  colorsDropdown:SetPoint("TOP", colorsListContainer, "BOTTOM", 0, -5)
  colorsDropdown:SetupMenu(function(menu, rootDescription)
    if not container.details then
      return
    end
    local seen = {}
    for _, entry in ipairs(container.details) do
      seen[entry.kind] = true
    end
    for _, kind in ipairs(addonTable.CustomiseDialog.ColorsConfigOrder) do
      if not seen[kind] then
        local details = addonTable.CustomiseDialog.ColorsConfig[kind]
        rootDescription:CreateButton(details.label, function()
          if addAlpha then
            table.insert(container.details, 1, addonTable.CustomiseDialog.AddAlphaToColors(CopyTable(details.default)))
          else
            table.insert(container.details, 1, CopyTable(details.default))
          end
          Announce()
          UpdateSelected(details.default.kind)
        end)
      end
    end
  end)
  colorsDropdown:SetDefaultText(addonTable.Locales.ADD_COLORS)

  colorsListContainer.ScrollBar = CreateFrame("EventFrame", nil, colorsListContainer, "MinimalScrollBar")
  colorsListContainer.ScrollBar:SetPoint("TOPRIGHT")
  colorsListContainer.ScrollBar:SetPoint("BOTTOMRIGHT")
  ScrollUtil.InitScrollBoxListWithScrollBar(colorsListContainer.ScrollBox, colorsListContainer.ScrollBar, scrollView)
  --addonTable.Skins.AddFrame("TrimScrollBar", colorsListContainer.ScrollBar)

  colorsListContainer:SetPoint("TOPLEFT", 20, 0)
  colorsListContainer:SetSize(200, 350)

  local optionsContainer = CreateFrame("Frame", nil, container)
  optionsContainer:SetPoint("TOPLEFT", colorsListContainer, "TOPRIGHT", 10, 0)
  optionsContainer:SetPoint("BOTTOMRIGHT", container)

  local configsByKind = {}
  for kind, colorDetails in pairs(addonTable.CustomiseDialog.ColorsConfig) do
    local allFrames = {}
    local yOffset = 0
    local parent = CreateFrame("Frame", nil, optionsContainer)
    parent:SetAllPoints()

    for _, e in ipairs(colorDetails.entries) do
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

      if e.kind == "checkbox" then
        frame = addonTable.CustomiseDialog.Components.GetCheckbox(parent, e.label, -30, Setter)
      elseif e.kind == "colorPicker" then
        frame = addonTable.CustomiseDialog.Components.GetColorPicker(parent, e.label, -30, Setter)
      end

      if frame then
        frame.kind = e.kind
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
    end

    if not lockedElements[kind] then
      local deleteButton = CreateFrame("Button", nil, parent, "UIPanelDynamicResizeButtonTemplate")
      deleteButton:SetText(DELETE)
      DynamicResizeButton_Resize(deleteButton)
      if #allFrames > 0 then
        deleteButton:SetPoint("BOTTOMRIGHT", -15, 0)
      else
        deleteButton:SetPoint("TOP", 0, -15)
      end
      deleteButton:SetScript("OnClick", function()
        table.remove(container.details, tIndexOf(container.details, parent.details))
        parent:Hide()
        Announce()
      end)
    end

    function parent:UpdateOptions(details)
      parent.details = nil
      for _, e in ipairs(details) do
        if e.kind == kind then
          parent.details = e
          break
        end
      end
      if not parent.details then
        parent:Hide()
        return
      end
      for _, f in ipairs(allFrames) do
        f:SetValue(f.Getter())
      end
    end
    parent:Hide()
    configsByKind[kind] = parent
  end

  local function GetListing()
    local listing = {}
    for index, e in ipairs(container.details) do
      table.insert(listing, {
        label = addonTable.CustomiseDialog.ColorsConfig[e.kind].label,
        value = e.kind,
        index = index,
      })
    end

    return listing
  end

  function container:SetValue(details)
    container.details = details
    colorsDropdown:GenerateMenu()

    colorsListContainer.ScrollBox:SetDataProvider(CreateDataProvider(GetListing()))

    for _, c in pairs(configsByKind) do
      if c:IsShown() then
        c:UpdateOptions(container.details)
      end
    end
  end

  UpdateSelected = function(value)
    selectedValue = value
    for kind, c in pairs(configsByKind) do
      if kind == value then
        c:Show()
        c:UpdateOptions(container.details)
      else
        c:Hide()
      end
    end
    colorsListContainer.ScrollBox:SetDataProvider(CreateDataProvider(GetListing()))
  end

  return container
end

function addonTable.CustomiseDialog.GetMainDesigner(parent)
  local container = CreateFrame("Frame", nil, parent)

  local allFrames = {}

  local styleDropdown = addonTable.CustomiseDialog.GetStyleDropdown(container)
  styleDropdown:SetPoint("TOP")
  table.insert(allFrames, styleDropdown)

  do
    local globalScale = addonTable.CustomiseDialog.Components.GetSlider(container, addonTable.Locales.GLOBAL_SCALE, 1, 300, function(val) return ("%d%%"):format(val) end, function(value)
      addonTable.Config.Set(addonTable.Config.Options.GLOBAL_SCALE, value/100)
    end)
    globalScale:SetValue(addonTable.Config.Get(addonTable.Config.Options.GLOBAL_SCALE) * 100)
    globalScale.option = addonTable.Config.Options.GLOBAL_SCALE
    globalScale.scale = 100

    globalScale:SetPoint("TOP", allFrames[#allFrames], "BOTTOM", 0, 0)
    table.insert(allFrames, globalScale)
  end

  local UpdateSelection
  local UpdateWidgetPoints
  local widgets
  local selectionIndexes = {}
  local fociOnDown = {}
  local autoSelectedDetails

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

  local contextHoverMarker = CreateFrame("Frame", nil, container)
  local contextHoverTexture = contextHoverMarker:CreateTexture()
  contextHoverTexture:SetTexture("Interface/AddOns/Platynator/Assets/selection-outline.png")
  contextHoverTexture:SetVertexColor(78/255, 165/255, 252/255, 0.8)
  contextHoverTexture:SetTextureSliceMargins(45, 45, 45, 45)
  contextHoverTexture:SetTextureSliceMode(Enum.UITextureSliceMode.Tiled)
  contextHoverTexture:SetScale(0.25)
  contextHoverTexture:SetAllPoints()

  local function ToggleSelection(rawFoci)
    local foci = tFilter(rawFoci, function(w) return w:GetParent() == preview end, true)
    local ApplyIndex
    if IsShiftKeyDown() then
      ApplyIndex = function(index)
        local selectionIndex = tIndexOf(selectionIndexes, index)
        if selectionIndex ~= nil then
          table.remove(selectionIndexes, selectionIndex)
        else
          table.insert(selectionIndexes, index)
        end
        UpdateSelection()
      end
    else
      ApplyIndex = function(index)
        if #selectionIndexes > 1 or #selectionIndexes == 0 or selectionIndexes[1] ~= index then
          selectionIndexes = {index}
        else
          selectionIndexes = {}
        end
        UpdateSelection()
      end
    end
    if #foci > 1 then
      MenuUtil.CreateContextMenu(foci[1], function(_, rootDescription)
        rootDescription:SetMinimumWidth(1)
        for _, w in ipairs(foci) do
          local button = rootDescription:CreateButton(titleMap[w.kind][w.details.kind], function()
            local index = tIndexOf(widgets, w)
            ApplyIndex(index)
          end)
          button:SetOnEnter(function()
            contextHoverMarker:Show()
            contextHoverMarker:SetFrameStrata("HIGH")
            contextHoverMarker:ClearAllPoints()
            contextHoverMarker:SetPoint("TOPLEFT", w, "TOPLEFT", -2, 2)
            contextHoverMarker:SetPoint("BOTTOMRIGHT", w, "BOTTOMRIGHT", 2, -2)
          end)
          button:SetOnLeave(function()
            contextHoverMarker:Hide()
          end)
        end
        rootDescription:CreateDivider()
        rootDescription:CreateButton(addonTable.Locales.CLEAR_SELECTION, function()
          selectionIndexes = {}
          UpdateSelection()
        end)
      end)
    else
      local index = tIndexOf(widgets, foci[1])
      ApplyIndex(index)
    end
  end
  local function ForceSelection(rawFoci)
    local foci = tFilter(rawFoci, function(w) return w:GetParent() == preview end, true)
    local any = false
    for _, w in ipairs(foci) do
      local index = tIndexOf(widgets, w)
      if tIndexOf(selectionIndexes, index) ~= nil then
        any = true
      end
    end
    if not any then
      local index = tIndexOf(widgets, foci[1])
      selectionIndexes = {index}
      UpdateSelection()
    end
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
      w.details.anchor = {point, RoundPixel(x), RoundPixel(y)}
    end

    if x ~= 0 then
      snapX = RoundPixel(x) - x
    end
    if y ~= 0 then
      snapY = RoundPixel(y) - y
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
    -- relative place to the other items as it was before moving, complex because of allowing widgets to snap to center points
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
        if math.abs(snapX) >= pixelStep/2 and not o.xLock or math.abs(snapY) >= pixelStep/2 and not o.yLock then
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
    fociOnDown = GetMouseFoci()
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
        if w.kind == "texts" then -- Because the Wrapper determines the base position
          w.Wrapper:AdjustPointsOffset(newCursorX - cursorX, newCursorY - cursorY)
        else
          w:AdjustPointsOffset(newCursorX - cursorX, newCursorY - cursorY)
        end
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
      local design = addonTable.CustomiseDialog.GetCurrentDesign()
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
  titleText:SetJustifyH("RIGHT")
  titleText:SetPoint("RIGHT", -40, 0)
  titleText:SetShadowOffset(1, -1)

  local suggestionToClick = container:CreateFontString(nil, nil, "GameFontHighlightLarge")
  suggestionToClick:SetText(addonTable.Locales.CLICK_ON_A_WIDGET)
  suggestionToClick:SetPoint("TOP", previewInset, "BOTTOM", 0, -15)

  local function OffsetWidgets(x, y)
    local offsets = {}
    for _, index in ipairs(selectionIndexes) do
      table.insert(offsets, {x = x, y = y, xLock = x == 0, yLock = y == 0})
    end
    AlignForRelativePoints(offsets, 0.4)
    Announce()
  end

  keyboardTrap:SetScript("OnKeyDown", function(_, key)
    keyboardTrap:SetPropagateKeyboardInput(false)
    local amount = pixelStep
    if IsShiftKeyDown() then
      amount = amount * 4
    end
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
    local design = addonTable.CustomiseDialog.GetCurrentDesign()
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

  local deleteButton = CreateFrame("Button", nil, previewInset, "UIPanelDynamicResizeButtonTemplate")
  deleteButton:SetText(addonTable.Locales.DELETE_WIDGET)
  DynamicResizeButton_Resize(deleteButton)
  deleteButton:SetPoint("TOPRIGHT", 0, addButton:GetHeight() + 2)
  deleteButton:SetScript("OnClick", function()
    DeleteCurrentWidget()
  end)

  local auraContainers = {
    buffs = CreateFrame("Frame", nil, preview, "PlatynatorPropagateMouseTemplate"),
    debuffs = CreateFrame("Frame", nil, preview, "PlatynatorPropagateMouseTemplate"),
    crowdControl = CreateFrame("Frame", nil, preview, "PlatynatorPropagateMouseTemplate"),
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
      w.auras = {}
      for index, tex in ipairs(textures[kind]) do
        local buff = CreateFrame("Frame", nil, w.Wrapper, "PlatynatorNameplateBuffButtonTemplate")
        buff:Show()
        buff.Icon:SetTexture(tex)
        buff:SetPoint("LEFT", (index - 1) * 22, 0)
        table.insert(w.auras, buff)
      end
      w.kind = "auras"
      w:SetScript("OnEnter", function()
        if w == GetMouseFoci()[1] then
          hoverMarker:Show()
          hoverMarker:SetFrameStrata("HIGH")
          hoverMarker:ClearAllPoints()
          hoverMarker:SetPoint("TOPLEFT", w, "TOPLEFT", -2, 2)
          hoverMarker:SetPoint("BOTTOMRIGHT", w, "BOTTOMRIGHT", 2, -2)
        end
      end)
      w:SetScript("OnLeave", function()
        local foci = GetMouseFoci()
        if foci[1] and foci[1]:GetParent() == preview then
          foci[1]:GetScript("OnEnter")()
        else
          hoverMarker:Hide()
        end
      end)

      w:SetMovable(true)
      w:EnableMouse(true)
      w:RegisterForDrag("LeftButton")
      w:SetScript("OnMouseDown", function()
        NotifyMouseDown()
      end)
      w:SetScript("OnDragStart", function()
        ForceSelection(fociOnDown)
        StartMovingSelection()
      end)
      w:SetScript("OnMouseUp", function()
        ToggleSelection(GetMouseFoci())
      end)
    end
  end

  local function GenerateWidgets()
    if widgets then
      addonTable.Display.ReleaseWidgets(tFilter(widgets, function(w) return w.Strip end, true), true)
    end
    local design = addonTable.CustomiseDialog.GetCurrentDesign()
    widgets = addonTable.Display.GetWidgets(design, preview, true)
    for _, w in ipairs(widgets) do
      w:SetClampedToScreen(true)
      if w.kind == "bars" then
        local defaultColor = {1, 1, 1}
        if w.details.kind == "health" then
          for _, s in ipairs(w.details.autoColors) do
            if s.kind == "threat" then
              defaultColor = s.colors.warning
              break
            elseif s.kind == "reaction" then
              defaultColor = s.colors.hostile
              break
            end
          end
        else
          defaultColor = w.details.autoColors[#w.details.autoColors].colors.cast
        end
        w.statusBar:SetMinMaxValues(0, 100)
        w.statusBar:SetValue(70)
        if w.details.kind == "cast" then
          if w.details.interruptMarker.asset ~= "none" then
            w.interruptMarker:Show()
            w.interruptMarker:SetMinMaxValues(0, 100)
            w.interruptMarker:SetValue(10)
          else
            w.interruptMarker:Hide()
          end
        end
        w.statusBar:GetStatusBarTexture():SetVertexColor(defaultColor.r, defaultColor.g, defaultColor.b)
        if w.details.background.applyColor then
          local mod = w.details.background.color
          w.background:SetVertexColor(defaultColor.r * mod.r, defaultColor.g * mod.g, defaultColor.b * mod.b, mod.a)
        end
        if w.details.kind == "health" then
          w.statusBarAbsorb:SetMinMaxValues(0, 100)
          w.statusBarAbsorb:SetValue(10)
        end
        w.marker:SetVertexColor(defaultColor.r, defaultColor.g, defaultColor.b)
      elseif w.kind == "texts" then
        local display
        if w.details.kind == "health" then
          local types = w.details.displayTypes
          local values = {
            absolute = AbbreviateNumbers(71255),
            percentage = "71%"
          }
          if w.details.significantFigures > 0 then
            values.percentage = (w.abbreviateCallback and w.abbreviateCallback(71.255) or w.abbreviateData and AbbreviateNumbers(71.255, w.abbreviateData)) .. "%"
          end
          if #types == 2 then
            display = string.format("%s (%s)", values[types[1]], values[types[2]])
          elseif #types == 1 then
            display = string.format("%s", values[types[1]])
          else
            display = addonTable.Locales.NO_VALUE_UPPER
          end
        elseif w.details.kind == "damageAbsorb" then
          w.text:SetText("+" .. AbbreviateNumbers(10290))
        elseif w.details.kind == "creatureName" or w.details.kind == "target" or w.details.kind == "castTarget" or w.details.kind == "castInterrupter" then
          display = "Cheesanator" .. (w.details.kind ~= "creatureName" and "2?" or "")
          if w.details.applyClassColors then
            local c = RAID_CLASS_COLORS["MAGE"]
            w.text:SetTextColor(c.r, c.g, c.b)
          elseif w.details.autoColors then
            for _, s in ipairs(w.details.autoColors) do
              if s.kind == "classColors" then
                local c = RAID_CLASS_COLORS["MAGE"]
                w.text:SetTextColor(c.r, c.g, c.b)
                break
              elseif s.kind == "threat" then
                local c = s.colors.warning
                w.text:SetTextColor(c.r, c.g, c.b)
                break
              elseif s.kind == "reaction" then
                local c = s.colors.hostile
                w.text:SetTextColor(c.r, c.g, c.b)
                break
              end
            end
          end
        elseif w.details.kind == "castTimeLeft" then
          w.text:SetText("1.2")
        elseif w.details.kind == "guild" then
          display = "Surge of Awesome"
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
        if w.details.kind == "castIcon" and w.details.square then
          w.background:Show()
        end
      elseif w.kind == "highlights" then
        w:Show(true)
      end

      w:SetScript("OnEnter", function()
        if w == GetMouseFoci()[1] then
          hoverMarker:Show()
          hoverMarker:SetFrameStrata("HIGH")
          hoverMarker:ClearAllPoints()
          hoverMarker:SetPoint("TOPLEFT", w, "TOPLEFT", -2, 2)
          hoverMarker:SetPoint("BOTTOMRIGHT", w, "BOTTOMRIGHT", 2, -2)
        end
      end)
      w:SetScript("OnLeave", function()
        local foci = GetMouseFoci()
        if foci[1] and foci[1]:GetParent() == preview then
          foci[1]:GetScript("OnEnter")()
        else
          hoverMarker:Hide()
        end
      end)

      w:SetMovable(true)
      w:EnableMouse(true)
      w:RegisterForDrag("LeftButton")
      w:SetScript("OnMouseDown", function()
        NotifyMouseDown()
      end)
      w:SetScript("OnDragStart", function()
        ForceSelection(fociOnDown)
        StartMovingSelection()
      end)
      w:SetScript("OnMouseUp", function()
        ToggleSelection(GetMouseFoci())
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
      local cdText = container.auras[1].Cooldown:GetRegions()
      cdText:SetFontObject(addonTable.CurrentFont)
      cdText:SetTextScale(14/12 * details.textScale)
      container.auras[1].Cooldown:SetCooldown(GetTime() - 2, 5)
      container.auras[1].Cooldown:Pause()
      container.auras[1].Cooldown:SetHideCountdownNumbers(not details.showCountdown)
      container.auras[1].CountFrame.Count:SetText(2);
      container.auras[1].CountFrame.Count:SetFontObject(addonTable.CurrentFont)
      container.auras[1].CountFrame.Count:SetTextScale(11/12 * details.textScale)
      container.auras[1].CountFrame.Count:Show();
      container:SetSize(22 * container.count * details.scale, 20 * details.height * details.scale)
      container.Wrapper:SetHeight(20 * details.height)
      container.Wrapper:SetScale(details.scale)
      container.details = details
      local texBase = 0.95 * (1 - details.height) / 2
      for _, aura in ipairs(container.auras) do
        aura:SetHeight(20 * details.height)
        aura.Icon:SetHeight(19 * details.height)
        aura.Icon:SetTexCoord(0.05, 0.95, 0.05 + texBase, 0.95 - texBase)
      end
      table.insert(widgets, container)
      container:ClearAllPoints()
      addonTable.Display.ApplyAnchor(container, details.anchor)
    end
  end

  GenerateWidgets()

  addonTable.CallbackRegistry:RegisterCallback("RefreshStateChange", function(_, state)
    if state[addonTable.Constants.RefreshReason.Design] then
      local design = addonTable.CustomiseDialog.GetCurrentDesign()
      addonTable.CurrentFont = addonTable.Core.GetFontByDesign(design)
      GenerateWidgets()
      if autoSelectedDetails then
        for index, w in ipairs(widgets) do
          if w.details == autoSelectedDetails then
            selectionIndexes = {index}
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
        parent:SetHeight(350)
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
        if e.hide then
          frame = nil
        elseif e.kind == "slider" then
          if e.valuePattern then
            frame = addonTable.CustomiseDialog.Components.GetSlider(parent, e.label, e.min, e.max, function(val) return e.valuePattern:format(val) end, Setter)
          else
            frame = addonTable.CustomiseDialog.Components.GetSlider(parent, e.label, e.min, e.max, e.formatter, Setter)
          end
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
          frame = addonTable.CustomiseDialog.Components.GetColorPicker(parent, e.label, 28, Setter)
        elseif e.kind == "autoColors" then
          frame = GetAutomaticColors(parent, e.lockedElements, e.addAlpha)
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
        function tab:IsFor(details)
          if tab.UpdateOptions then
            return true
          end
          for subKind, nestedContainer in pairs(self.kindSpecificSettings) do
            if subKind == details.kind then
              return true
            end
          end
          return false
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
        local lastTab
        for index, t in ipairs(tabs) do
          local tabButton = t.button
          if t:IsFor(details) then
            tabButton:Show()
            if not lastTab then
              tabButton:SetPoint("TOPLEFT", 20, 0)
            else
              tabButton:SetPoint("TOPLEFT", lastTab, "TOPRIGHT", 5, 0)
            end
            lastTab = t.button
          else
            tabButton:Hide()
          end
        end
        titleText:SetPoint("LEFT", lastTab, "RIGHT", 10, 0)
        tabManager:SetTab(tabs[settingsContainer.tabIndex].button.label)
      end
      if details["*"] then
        for _, tabDetails in ipairs(details["*"]) do
          local tabContainer = CreateFrame("Frame", nil, settingsContainer)
          local tabButton = addonTable.CustomiseDialog.Components.GetTab(tabManager, tabDetails.label)
          InitTab(tabContainer, tabButton, tabDetails.label)
          if #tabDetails.entries > 0 then
            AddToTab(tabContainer, tabDetails.entries, "*")
          end
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
      suggestionToClick:Show()
      return
    end
    suggestionToClick:Hide()
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
