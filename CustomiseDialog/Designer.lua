---@class addonTablePlatynator
local addonTable = select(2, ...)

local function Announce()
  addonTable.Config.Set(addonTable.Config.Options.STYLE, "custom")
  addonTable.CallbackRegistry:TriggerEvent("RefreshStateChange", {[addonTable.Constants.RefreshReason.Design] = true})
end

local function GetLabelsValues(allAssets, filter)
  local labels, values = {}, {}

  local allKeys = GetKeysArray(allAssets)
  table.sort(allKeys)

  for _, key in ipairs(allKeys) do
    if not filter or filter(key) then
      local details = allAssets[key]
      local height = 20
      local width = details.width * height/details.height
      if width > 180 then
        height = 180/width * height
        width = 180
      end
      local tail = ""
      if details.mode == addonTable.Assets.Mode.Special then
        tail = " " .. addonTable.Locales.SPECIAL_BRACKETS
      elseif details.mode == addonTable.Assets.Mode.Narrow then
        tail = " " .. addonTable.Locales.NARROW_BRACKETS
      end

      table.insert(labels, "|T".. details.file .. ":" .. height .. ":" .. width .. "|t" .. tail)
      table.insert(values, key)
    end
  end

  return labels, values
end

local function GetBarSettings(parent)
  local container = CreateFrame("Frame", nil, parent)
  local allFrames = {}

  local currentBar

  local scaleSlider = addonTable.CustomiseDialog.Components.GetSlider(container, addonTable.Locales.BAR_SCALE, 1, 300, "%s%%", function(value)
    local oldScale = currentBar.scale
    currentBar.scale = value / 100
    if currentBar.scale ~= oldScale then
      Announce()
    end
  end)

  scaleSlider:SetPoint("TOP")
  table.insert(allFrames, scaleSlider)

  local function ApplySpecial(value)
    local group = addonTable.Assets.SpecialBars[value]
    currentBar.foreground.asset = group.foreground
    currentBar.background.asset = group.background
    currentBar.border.asset = group.border
  end

  do
    local foregroundDropdown = addonTable.CustomiseDialog.Components.GetBasicDropdown(container, addonTable.Locales.MAIN_TEXTURE, function(value)
      return currentBar and currentBar.foreground.asset == value
    end, function(value)
      if addonTable.Assets.BarBackgrounds[value].mode == addonTable.Assets.Mode.Special then
          ApplySpecial(value)
      else
        if addonTable.Assets.BarBackgrounds[currentBar.foreground.asset].mode == addonTable.Assets.Mode.Special then
          local design = addonTable.Design.GetDefaultDesignSquirrel()
          currentBar.background.asset = design.bars[1].background.asset
          currentBar.border.asset = design.bars[1].border.asset
        end
        currentBar.foreground.asset = value
      end
      Announce()
    end)

    foregroundDropdown:Init(GetLabelsValues(addonTable.Assets.BarBackgrounds))

    foregroundDropdown:SetPoint("TOP", allFrames[#allFrames], "BOTTOM")
    table.insert(allFrames, foregroundDropdown)
  end

  do
    local backgroundDropdown = addonTable.CustomiseDialog.Components.GetBasicDropdown(container, addonTable.Locales.BACKGROUND_TEXTURE, function(value)
      return currentBar and currentBar.background.asset == value
    end, function(value)
      if addonTable.Assets.BarBackgrounds[value].mode == addonTable.Assets.Mode.Special then
        ApplySpecial(value)
      else
        if addonTable.Assets.BarBackgrounds[currentBar.background.asset].mode == addonTable.Assets.Mode.Special then
          local design = addonTable.Design.GetDefaultDesignSquirrel()
          currentBar.foreground.asset = design.bars[1].foreground.asset
          currentBar.border.asset = design.bars[1].border.asset
        end
        currentBar.background.asset = value
      end
      Announce()
    end)

    backgroundDropdown:Init(GetLabelsValues(addonTable.Assets.BarBackgrounds))

    backgroundDropdown:SetPoint("TOP", allFrames[#allFrames], "BOTTOM")
    table.insert(allFrames, backgroundDropdown)
  end

  do
    local borderDropdown = addonTable.CustomiseDialog.Components.GetBasicDropdown(container, addonTable.Locales.BORDER_TEXTURE, function(value)
      return currentBar and currentBar.border.asset == value
    end, function(value)
      if addonTable.Assets.BarBorders[value].mode == addonTable.Assets.Mode.Special then
        ApplySpecial(value)
      else
        if addonTable.Assets.BarBorders[currentBar.border.asset].mode == addonTable.Assets.Mode.Special then
          local design = addonTable.Design.GetDefaultDesignSquirrel()
          currentBar.foreground.asset = design.bars[1].foreground.asset
          currentBar.background.asset = design.bars[1].background.asset
        end
        currentBar.border.asset = value
      end
      Announce()
    end)

    borderDropdown:Init(GetLabelsValues(addonTable.Assets.BarBorders))

    borderDropdown:SetPoint("TOP", allFrames[#allFrames], "BOTTOM")
    table.insert(allFrames, borderDropdown)
  end

  function container:Set(details)
    currentBar = details
    scaleSlider:SetValue(Round(currentBar.scale * 100))

    for _, f in ipairs(allFrames) do
      if f.DropDown then
        f:SetValue()
      end
    end
  end

  function container:IsFor(kind, details)
    return kind == "bars"
  end

  container:SetScript("OnHide", function()
    currentBar = nil
  end)

  container:SetHeight(200)
  container:SetPoint("LEFT")
  container:SetPoint("RIGHT")

  return container
end

local function GetTextSettings(parent)
  local container = CreateFrame("Frame", nil, parent)
  local allFrames = {}

  local currentText

  local scaleSlider = addonTable.CustomiseDialog.Components.GetSlider(container, addonTable.Locales.TEXT_SCALE, 1, 300, "%s%%", function(value)
    local oldScale = currentText.scale
    currentText.scale = value / 100
    if currentText.scale ~= oldScale then
      Announce()
    end
  end)

  scaleSlider:SetPoint("TOP")
  table.insert(allFrames, scaleSlider)

  local colorPicker = addonTable.CustomiseDialog.Components.GetColorPicker(container, addonTable.Locales.COLOR, function(color)
    currentText.color = CopyTable(color)
    Announce()
  end)
  colorPicker:SetPoint("TOP", allFrames[#allFrames], "BOTTOM")
  table.insert(allFrames, colorPicker)

  function container:Set(details)
    currentText = details
    scaleSlider:SetValue(Round(currentText.scale * 100))
    colorPicker:SetValue(currentText.color)

    for _, f in ipairs(allFrames) do
      if f.DropDown then
        f:SetValue()
      end
    end
  end

  function container:IsFor(kind, details)
    return kind == "texts"
  end

  container:SetScript("OnHide", function()
    currentText = nil
  end)

  container:SetHeight(200)
  container:SetPoint("LEFT")
  container:SetPoint("RIGHT")
  container:Hide()

  return container
end

local function GetHighlightSettings(parent)
  local container = CreateFrame("Frame", nil, parent)
  local allFrames = {}

  local currentHighlight

  local scaleSlider = addonTable.CustomiseDialog.Components.GetSlider(container, addonTable.Locales.HIGHLIGHT_SCALE, 1, 300, "%s%%", function(value)
    local oldScale = currentHighlight.scale
    currentHighlight.scale = value / 100
    if currentHighlight.scale ~= oldScale then
      Announce()
    end
  end)

  scaleSlider:SetPoint("TOP")
  table.insert(allFrames, scaleSlider)

  do
    local assetDropdown = addonTable.CustomiseDialog.Components.GetBasicDropdown(container, addonTable.Locales.MAIN_TEXTURE, function(value)
      return currentHighlight and currentHighlight.asset == value
    end, function(value)
      currentHighlight.asset = value
      Announce()
    end)

    assetDropdown:Init(GetLabelsValues(addonTable.Assets.Highlights))

    assetDropdown:SetPoint("TOP", allFrames[#allFrames], "BOTTOM")
    table.insert(allFrames, assetDropdown)
  end

  local colorPicker = addonTable.CustomiseDialog.Components.GetColorPicker(container, addonTable.Locales.COLOR, function(color)
    currentHighlight.color = CopyTable(color)
    Announce()
  end)
  colorPicker:SetPoint("TOP", allFrames[#allFrames], "BOTTOM")
  table.insert(allFrames, colorPicker)

  function container:Set(details)
    currentHighlight = details
    scaleSlider:SetValue(Round(currentHighlight.scale * 100))
    colorPicker:SetValue(currentHighlight.color)

    for _, f in ipairs(allFrames) do
      if f.DropDown then
        f:SetValue()
      end
    end
  end

  function container:IsFor(kind, details)
    return kind == "highlights"
  end

  container:SetScript("OnHide", function()
    currentHighlight = nil
  end)

  container:SetHeight(200)
  container:SetPoint("LEFT")
  container:SetPoint("RIGHT")
  container:Hide()

  return container
end

local function GetMarkerSettings(parent)
  local container = CreateFrame("Frame", nil, parent)
  local allFrames = {}

  local currentMarker

  local scaleSlider = addonTable.CustomiseDialog.Components.GetSlider(container, addonTable.Locales.MARKER_SCALE, 1, 300, "%s%%", function(value)
    local oldScale = currentMarker.scale
    currentMarker.scale = value / 100
    if currentMarker.scale ~= oldScale then
      Announce()
    end
  end)

  scaleSlider:SetPoint("TOP")
  table.insert(allFrames, scaleSlider)

  do
    local assetDropdown = addonTable.CustomiseDialog.Components.GetBasicDropdown(container, addonTable.Locales.MAIN_TEXTURE, function(value)
      return currentMarker and currentMarker.asset == value
    end, function(value)
      currentMarker.asset = value
      Announce()
    end)

    assetDropdown:Init(GetLabelsValues(addonTable.Assets.Markers))

    assetDropdown:SetPoint("TOP", allFrames[#allFrames], "BOTTOM")
    table.insert(allFrames, assetDropdown)
  end

  local colorPicker = addonTable.CustomiseDialog.Components.GetColorPicker(container, addonTable.Locales.COLOR, function(color)
    currentMarker.color = CopyTable(color)
    Announce()
  end)
  colorPicker:SetPoint("TOP", allFrames[#allFrames], "BOTTOM")
  table.insert(allFrames, colorPicker)

  function container:Set(details)
    currentMarker = details
    scaleSlider:SetValue(Round(currentMarker.scale * 100))
    colorPicker:SetValue(currentMarker.color)

    for _, f in ipairs(allFrames) do
      if f.DropDown then
        f:SetValue()
      end
    end
  end

  function container:IsFor(kind, details)
    return kind == "markers"
  end

  container:SetScript("OnHide", function()
    currentHighlight = nil
  end)

  container:SetHeight(200)
  container:SetPoint("LEFT")
  container:SetPoint("RIGHT")
  container:Hide()

  return container
end

local function GetPowerSettings(parent)
  local container = CreateFrame("Frame", nil, parent)
  local allFrames = {}

  local currentPower

  local scaleSlider = addonTable.CustomiseDialog.Components.GetSlider(container, addonTable.Locales.POWER_SCALE, 1, 300, "%s%%", function(value)
    local oldScale = currentPower.scale
    currentPower.scale = value / 100
    if currentPower.scale ~= oldScale then
      Announce()
    end
  end)

  scaleSlider:SetPoint("TOP")
  table.insert(allFrames, scaleSlider)

  do
    local assetDropdown = addonTable.CustomiseDialog.Components.GetBasicDropdown(container, addonTable.Locales.MAIN_TEXTURE, function(value)
      return currentPower and currentPower.filled == value
    end, function(value)
      currentPower.filled = value
      Announce()
    end)

    assetDropdown:Init(GetLabelsValues(addonTable.Assets.PowerBars))

    assetDropdown:SetPoint("TOP", allFrames[#allFrames], "BOTTOM")
    table.insert(allFrames, assetDropdown)
  end

  do
    local assetDropdown = addonTable.CustomiseDialog.Components.GetBasicDropdown(container, addonTable.Locales.MAIN_TEXTURE, function(value)
      return currentPower and currentPower.blank == value
    end, function(value)
      currentPower.blank = value
      Announce()
    end)

    assetDropdown:Init(GetLabelsValues(addonTable.Assets.PowerBars))

    assetDropdown:SetPoint("TOP", allFrames[#allFrames], "BOTTOM")
    table.insert(allFrames, assetDropdown)
  end

  function container:Set(details)
    currentPower = details
    scaleSlider:SetValue(Round(currentPower.scale * 100))

    for _, f in ipairs(allFrames) do
      if f.DropDown then
        f:SetValue()
      end
    end
  end

  function container:IsFor(kind, details)
    return kind == "specialBars" and details.kind == "power"
  end

  container:SetScript("OnHide", function()
    currentPower = nil
  end)

  container:SetHeight(200)
  container:SetPoint("LEFT")
  container:SetPoint("RIGHT")
  container:Hide()

  return container
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
      addonTable.Locales.BLIZZARD,
    }, {
      "custom",
      "squirrel",
      "rabbit",
      "hare",
      "hedgehog",
      "blizzard",
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

  local SetSelection

  local selector = CreateFrame("Frame", nil, container)
  local selectionIndex = 0 
  local selectionTexture = selector:CreateTexture()
  selectionTexture:SetTexture("Interface/AddOns/Platynator/Assets/selection-outline.png")
  selectionTexture:SetTextureSliceMargins(45, 45, 45, 45)
  selectionTexture:SetTextureSliceMode(Enum.UITextureSliceMode.Tiled)
  selectionTexture:SetScale(0.25)
  selectionTexture:SetAllPoints()

  local hoverMarker = CreateFrame("Frame", nil, container)
  local hoverTexture = hoverMarker:CreateTexture()
  hoverTexture:SetTexture("Interface/AddOns/Platynator/Assets/selection-outline.png")
  hoverTexture:SetAlpha(0.5)
  hoverTexture:SetTextureSliceMargins(45, 45, 45, 45)
  hoverTexture:SetTextureSliceMode(Enum.UITextureSliceMode.Tiled)
  hoverTexture:SetScale(0.25)
  hoverTexture:SetAllPoints()

  local previewInset = CreateFrame("Frame", nil, container, "InsetFrameTemplate")
  previewInset:SetPoint("TOP", allFrames[#allFrames], "BOTTOM")
  previewInset:SetPoint("LEFT", 20, 0)
  previewInset:SetPoint("RIGHT", -20, 0)
  previewInset:SetHeight(200)

  local preview = CreateFrame("Frame", nil, previewInset)

  preview:SetPoint("TOP")

  preview:SetAllPoints()
  preview:SetFlattensRenderLayers(true)
  preview:SetScale(2)

  local widgets

  local function GenerateWidgets()
    if widgets then
      addonTable.Display.ReleaseWidgets(widgets, true)
    end
    local design = addonTable.Config.Get(addonTable.Config.Options.DESIGN)
    widgets = addonTable.Display.GetWidgets(design, preview, true)
    for _, w in ipairs(widgets) do
      if w.kind == "bars" then
        local defaultColor
        if w.details.kind == "health" then
          defaultColor = w.details.colors.threat.warning
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
          if #w.details.displayTypes == 1 and w.details.displayTypes[1] == "percentage" then
            display = "70%"
          elseif #w.details.displayTypes == 1 and w.details.displayTypes[1] == "absolute" then
            display = "70,000"
          elseif #w.details.displayTypes == 2 and w.details.displayTypes[1] == "absolute" then
            display = "70,000 (70%)"
          elseif #w.details.displayTypes == 2 and w.details.displayTypes[1] == "percentage" then
            display = "70% (70,000)"
          end
        elseif w.details.kind == "creatureName" then
          display = "Cheesanator"
        elseif w.details.kind == "castSpellName" then
          display = "Arcane Flurry"
        end
        if display then
          w.text:SetText(display)
        end
      elseif w.kind == "specialBars" and w.details.kind == "power" then
        w.main:GetStatusBarTexture():SetVertexColor(234/255, 61/255, 247/255)
        w.main:SetValue(4)
        w.background:SetValue(6)
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
      w:SetScript("OnDragStart", function()
        w:StartMoving()
      end)
      w:SetScript("OnDragStop", function()
        w:StopMovingOrSizing()
        local left, bottom, width, height = w:GetRect()
        local widgetRect = {left = left, bottom = bottom, width = width, height = height}
        left, bottom, width, height = preview:GetRect()
        local previewRect = {left = left, bottom = bottom, width = width, height = height}
        local widgetCenter = {x = widgetRect.left + widgetRect.width / 2, y = widgetRect.bottom + widgetRect.height / 2}
        local previewCenter = {x = previewRect.left + previewRect.width / 2, y = previewRect.bottom + previewRect.height / 2}

        local point, x, y = "", 0, 0
        if math.floor(math.abs(widgetCenter.x - previewCenter.x)) <= 1 then
          point = point
        elseif widgetCenter.x < previewCenter.x then
          point = "LEFT"
          x = widgetRect.left - previewCenter.x
        else
          point = "RIGHT"
          x = widgetRect.left + widgetRect.width - previewCenter.x
        end

        if math.floor((math.abs(widgetCenter.y - previewCenter.y))) <= 1 then
          point = point
        elseif widgetCenter.y < previewCenter.y then
          point = "TOP" .. point
          y = widgetRect.bottom + widgetRect.height - previewCenter.y
        else
          point = "BOTTOM" .. point
          y = widgetRect.bottom - previewCenter.y
        end

        if point == "" then
          w.details.anchor = {}
        elseif x == 0 and y == 0 then
          w.details.anchor = {point}
        else
          w.details.anchor = {point, Round(x), Round(y)}
        end
        C_Timer.After(0, function()
          Announce()
        end)
      end)
      w:SetScript("OnMouseUp", function()
        if selectionIndex == tIndexOf(widgets, w) then
          SetSelection()
        else
          SetSelection(w, w.kind, w.details)
        end
      end)
    end
  end

  GenerateWidgets()

  addonTable.CallbackRegistry:RegisterCallback("RefreshStateChange", function(_, state)
    if state[addonTable.Constants.RefreshReason.Design] then
      GenerateWidgets()
      SetSelection(widgets[selectionIndex])
    end
  end)

  table.insert(allFrames, previewInset)

  local settingsFrames = {}

  local function Generate(func)
    local settingsContainer = func(container)
    settingsContainer:SetPoint("TOP", allFrames[#allFrames], "BOTTOM")
    table.insert(settingsFrames, settingsContainer)
  end

  Generate(GetBarSettings)
  Generate(GetTextSettings)
  Generate(GetHighlightSettings)
  Generate(GetMarkerSettings)
  Generate(GetPowerSettings)

  SetSelection = function(w)
    if not w then
      for _, frame in ipairs(settingsFrames) do
        frame:Hide()
      end
      selectionIndex = 0
      selector:Hide()
      return
    end

    local kind = w.kind
    for _, frame in ipairs(settingsFrames) do
      if frame:IsFor(kind, w.details) then
        frame:Show()
        frame:Set(w.details)
      else
        frame:Hide()
      end
    end


    selectionIndex = tIndexOf(widgets, w)

    selector:Show()
    selector:SetFrameStrata("HIGH")
    selector:SetPoint("TOPLEFT", w, "TOPLEFT", -2, 2)
    selector:SetPoint("BOTTOMRIGHT", w, "BOTTOMRIGHT", 2, -2)
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

    SetSelection(nil)
  end)

  return container
end
