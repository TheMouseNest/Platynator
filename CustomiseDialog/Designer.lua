---@class addonTablePlatynator
local addonTable = select(2, ...)

local function GetLabelsValues(allAssets, filter)
  local labels, values = {}, {}

  for _, key in ipairs(GetKeysArray(allAssets)) do
    if not filter or filter(key) then
      local details = allAssets[key]
      local height = 20
      local width = details.width * height/details.height
      if width > 180 then
        height = 180/width * height
        width = 180
      end

      table.insert(labels, "|T".. details.file .. ":" .. height .. ":" .. width .. "|t")
      table.insert(values, key)
    end
  end

  return labels, values
end

local function GetBarSettings(parent)
  local container = CreateFrame("Frame", nil, parent)
  local allFrames = {}

  local currentBar

  local function Announce()
    addonTable.Config.Set(addonTable.Config.Options.STYLE, "custom")
    addonTable.CallbackRegistry:TriggerEvent("RefreshStateChange", {[addonTable.Constants.RefreshReason.Design] = true})
  end

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
      if addonTable.Assets.BarBackgrounds[value].special then
          ApplySpecial(value)
      elseif addonTable.Assets.BarBackgrounds[currentBar.foreground.asset].special then
        local design = addonTable.Design.GetDefaultDesignSquirrel()
        currentBar.background.asset = design.bars[1].background.asset
        currentBar.border.asset = design.bars[1].border.asset
      end
      currentBar.foreground.asset = value
      Announce()
    end)

    foregroundDropdown:Init(GetLabelsValues(addonTable.Assets.BarBackgrounds))

    foregroundDropdown:SetPoint("TOP")
    table.insert(allFrames, foregroundDropdown)
  end

  do
    local backgroundDropdown = addonTable.CustomiseDialog.Components.GetBasicDropdown(container, addonTable.Locales.BACKGROUND_TEXTURE, function(value)
      return currentBar and currentBar.background.asset == value
    end, function(value)
      if addonTable.Assets.BarBackgrounds[value].special then
        ApplySpecial(value)
      elseif addonTable.Assets.BarBackgrounds[currentBar.background.asset].special then
        local design = addonTable.Design.GetDefaultDesignSquirrel()
        currentBar.foreground.asset = design.bars[1].foreground.asset
        currentBar.border.asset = design.bars[1].border.asset
      end
      currentBar.background.asset = value
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
      if addonTable.Assets.BarBackgrounds[value].special then
        ApplySpecial(value)
      elseif addonTable.Assets.BarBorders[currentBar.background.asset].special then
        local design = addonTable.Design.GetDefaultDesignSquirrel()
        currentBar.foreground.asset = design.bars[1].foreground.asset
        currentBar.background.asset = design.bars[1].background.asset
      end
      currentBar.border.asset = value
      Announce()
    end)

    borderDropdown:Init(GetLabelsValues(addonTable.Assets.BarBorders))

    borderDropdown:SetPoint("TOP", allFrames[#allFrames], "BOTTOM")
    table.insert(allFrames, borderDropdown)
  end

  function container:SetBar(details)
    currentBar = details

    for _, f in ipairs(allFrames) do
      if f.SetValue and f.scale then
        f:SetValue(addonTable.Config.Get(f.option) * f.scale)
      elseif f.SetValue and f.option then
        f:SetValue(addonTable.Config.Get(f.option))
      else
        f:SetValue()
      end
    end
  end

  container:SetScript("OnHide", function()
    currentBar = nil
  end)

  container:SetHeight(200)
  container:SetPoint("LEFT")
  container:SetPoint("RIGHT")

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
      addonTable.Locales.HEDGEHOG,
      addonTable.Locales.BLIZZARD,
    }, {
      "custom",
      "squirrel",
      "rabbit",
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

  local function MakeMovable(frame)
    frame:SetDraggable(true)
    frame:SetScript("OnDragStart", function()
      frame:StartMoving()
    end)
    frame:SetScript("OnDragStop", function()
      frame:StopMovingOrSizing()
    end)
  end

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
        hoverMarker:SetPoint("TOPLEFT", w, "TOPLEFT", -2, 2)
        hoverMarker:SetPoint("BOTTOMRIGHT", w, "BOTTOMRIGHT", 2, -2)
      end)
      w:SetScript("OnLeave", function()
        hoverMarker:Hide()
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

  local barSettingsContainer = GetBarSettings(container)
  barSettingsContainer:SetPoint("TOP", allFrames[#allFrames], "BOTTOM")
  table.insert(allFrames, barSettingsContainer)
  table.insert(settingsFrames, barSettingsContainer)

  SetSelection = function(w)
    for _, frame in ipairs(settingsFrames) do
      frame:Hide()
    end

    if not w then
      selectionIndex = 0
      selector:Hide()
      return
    end

    selectionIndex = tIndexOf(widgets, w)

    local kind, details = w.kind, w.details
    if kind == "bars" then
      barSettingsContainer:Show()
      barSettingsContainer:SetBar(details)
    end

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

    barSettingsContainer:Hide()
  end)

  return container
end
