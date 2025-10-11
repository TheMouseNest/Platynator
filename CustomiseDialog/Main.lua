---@class addonTablePlatynator
local addonTable = select(2, ...)

local customisers = {}

local function GetMainDesigner(parent)
  local container = CreateFrame("Frame", nil, parent)

  local design = addonTable.Config.Get(addonTable.Config.Options.DESIGN)

  local function MakeMovable(frame)
    frame:SetDraggable(true)
    frame:SetScript("OnDragStart", function()
      frame:StartMoving()
    end)
    frame:SetScript("OnDragStop", function()
      frame:StopMovingOrSizing()
    end)
  end

  local selector = CreateFrame("Frame")
  local selectionTexture = selector:CreateTexture()
  selectionTexture:SetTexture("Interface/AddOns/Platynator/Assets/selection-outline.png")
  selectionTexture:SetTextureSliceMargins(45, 45, 45, 45)
  selectionTexture:SetTextureSliceMode(Enum.UITextureSliceMode.Tiled)
  selectionTexture:SetScale(0.25)
  selectionTexture:SetAllPoints()

  local hoverMarker = CreateFrame("Frame")
  local hoverTexture = hoverMarker:CreateTexture()
  hoverTexture:SetTexture("Interface/AddOns/Platynator/Assets/selection-outline.png")
  hoverTexture:SetAlpha(0.5)
  hoverTexture:SetTextureSliceMargins(45, 45, 45, 45)
  hoverTexture:SetTextureSliceMode(Enum.UITextureSliceMode.Tiled)
  hoverTexture:SetScale(0.25)
  hoverTexture:SetAllPoints()

  local previewInset = CreateFrame("Frame", nil, container, "InsetFrameTemplate")
  previewInset:SetPoint("TOP")
  previewInset:SetPoint("LEFT", 20, 0)
  previewInset:SetPoint("RIGHT", -20, 0)
  previewInset:SetHeight(200)

  local preview = CreateFrame("Frame", nil, previewInset)

  preview:SetPoint("TOP")
  preview:SetAllPoints()
  preview:SetFlattensRenderLayers(true)
  preview:SetScale(2)

  addonTable.Config.Get(addonTable.Config.Options.DESIGN)
  local widgets = addonTable.Display.GetWidgets(design, preview)
  for _, w in ipairs(widgets) do
    local hover
    if w.kind == "bars" then
      hover = w.statusBar
      local defaultColor
      if w.details.kind == "health" then
        defaultColor = w.details.colors.threat.warning
      else
        defaultColor = w.details.colors.normal
      end
      w.statusBar:SetMinMaxValues(0, 100)
      w.statusBar:SetValue(70)
      w.statusBar:GetStatusBarTexture():SetVertexColor(defaultColor.r, defaultColor.g, defaultColor.b)
      if w.details.colorBackground then
        w.background:SetVertexColor(defaultColor.r, defaultColor.g, defaultColor.b)
      end
      w.marker:SetVertexColor(defaultColor.r, defaultColor.g, defaultColor.b)
    elseif w.kind == "texts" then
      hover = w.text
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
      hover = w.main
      w.main:GetStatusBarTexture():SetVertexColor(234/255, 61/255, 247/255)
      w.main:SetValue(4)
      w.background:SetValue(6)
    end

    hover = hover or w
    hover:SetScript("OnEnter", function()
      hoverMarker:Show()
      hoverMarker:SetFrameStrata("HIGH")
      hoverMarker:SetPoint("TOPLEFT", hover, "TOPLEFT", -2, 2)
      hoverMarker:SetPoint("BOTTOMRIGHT", hover, "BOTTOMRIGHT", 2, -2)
    end)
    hover:SetScript("OnLeave", function()
      hoverMarker:Hide()
    end)
    hover:SetScript("OnMouseUp", function()
      print("hit", w.kind, w.kindIndex)
    end)
  end

  return container
end

local TabSetups = {
  {callback = GetMainDesigner, name = addonTable.Locales.DESIGNER},
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
  frame:SetSize(600, 700)
  frame:SetPoint("CENTER")
  frame:Raise()

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

  frame:SetTitle(addonTable.Locales.CUSTOMISE_CHATTYNATOR)

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
