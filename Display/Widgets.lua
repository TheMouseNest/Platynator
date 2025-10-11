---@class addonTablePlatynator
local addonTable = select(2, ...)

local function ApplyAnchor(frame, anchor)
  if #anchor == 0 then
    frame:SetPoint("CENTER")
  elseif #anchor == 3 then
    frame:SetPoint(anchor[1], frame:GetParent(), "CENTER", anchor[2], anchor[3])
  elseif #anchor == 2 then
    frame:SetPoint("CENTER", frame:GetParent(), "CENTER", anchor[1], anchor[2])
  end
end

function addonTable.Display.GetBar(frame, parent)
  frame = frame or CreateFrame("Frame", nil, parent or UIParent)

  frame.statusBar = CreateFrame("StatusBar", nil, frame)
  frame.statusBar:SetPoint("CENTER")
  frame.statusBar:SetAllPoints()
  frame.statusBar:SetClipsChildren(true)

  frame.marker = frame.statusBar:CreateTexture()
  frame.marker:SetDrawLayer("ARTWORK", 2)

  frame.border = frame.statusBar:CreateTexture()
  frame.border:SetAllPoints()
  frame.border:SetDrawLayer("OVERLAY")
  frame.background = frame.statusBar:CreateTexture()
  frame.background:SetAllPoints()
  frame.background:SetDrawLayer("BACKGROUND")

  local knownKeys = {"statusBar", "marker", "border", "background"}

  function frame:Init(details)
    if frame.Strip then
      frame:Strip()
    end

    ApplyAnchor(frame, details.anchor)

    local foregroundDetails = addonTable.Assets.BarBackgrounds[details.foreground]
    frame:SetSize(foregroundDetails.width * details.scale, foregroundDetails.height * details.scale)

    frame.statusBar:SetStatusBarTexture(foregroundDetails.file)
    frame.statusBar:GetStatusBarTexture():SetDrawLayer("ARTWORK")
    frame.background:SetTexture(addonTable.Assets.BarBackgrounds[details.background].file)
    frame.border:SetTexture(addonTable.Assets.BarBorders[details.border].file)
    if details.marker.texture ~= "none" then
      frame.marker:Show()
      local markerDetails = addonTable.Assets.BarPositionHighlights[details.marker.texture]
      frame.marker:SetTexture(markerDetails.file)
      frame.marker:SetSize(markerDetails.width * details.scale, frame:GetHeight())
      frame.marker:SetPoint("CENTER", frame.statusBar:GetStatusBarTexture(), "RIGHT")
    else
      frame.marker:Hide()
    end

    frame.details = details

    if details.kind == "health" then
      Mixin(frame, addonTable.Display.HealthBarMixin)
    elseif details.kind == "cast" then
      Mixin(frame, addonTable.Display.CastBarMixin)
    else
      assert(false)
    end

    frame:SetScript("OnEvent", frame.OnEvent)

    if frame.PostInit then
      frame:PostInit()
    end
  end

  return frame
end

function addonTable.Display.GetPower(frame, parent)
  frame = frame or CreateFrame("Frame", nil, parent or UIParent)

  frame.background = CreateFrame("StatusBar", nil, frame)
  frame.background:SetAllPoints()
  frame.background:SetFillStyle("CENTER")
  frame.background:SetMinMaxValues(0, 7)

  frame.main = CreateFrame("StatusBar", nil, frame)
  frame.main:SetMinMaxValues(0, 7)

  local knownKeys = {"main", "background"}

  frame:SetScript("OnSizeChanged", function()
    frame.main:SetSize(frame:GetSize())
  end)

  function frame:Init(details)
    if frame.Strip then
      frame:Strip()
    end

    ApplyAnchor(frame, details.anchor)

    local blankDetails = addonTable.Assets.PowerBars[details.blank]
    self.background:SetStatusBarTexture(blankDetails.file)
    self.main:SetStatusBarTexture(addonTable.Assets.PowerBars[details.filled].file)
    self.main:SetPoint("LEFT", frame.background:GetStatusBarTexture())
    self.main:SetWidth(self.background:GetWidth())
    frame:SetSize(blankDetails.width * details.scale, blankDetails.height * details.scale)

    Mixin(frame, addonTable.Display.PowerBarMixin)

    frame:SetScript("OnEvent", frame.OnEvent)

    if frame.PostInit then
      frame:PostInit()
    end
  end
end

function addonTable.Display.GetHighlight(frame, parent)
  frame = frame or CreateFrame("Frame", nil, parent or UIParent)

  frame.highlight = frame:CreateTexture()
  frame.highlight:SetAllPoints()

  function frame:Init(details)
    ApplyAnchor(frame, details.anchor)

    local highlightDetails = addonTable.Assets.Highlights[details.texture]

    frame.highlight:SetTexture(highlightDetails.file)
    frame.highlight:SetVertexColor(details.color.r, details.color.g, details.color.b)
    frame:SetSize(highlightDetails.width * details.scale, highlightDetails.height * details.scale)

    if details.kind == "target" then
      Mixin(frame, addonTable.Display.HighlightMixin)
    else
      assert(false)
    end

    frame:SetScript("OnEvent", frame.OnEvent)

    if frame.PostInit then
      frame:PostInit()
    end
  end

  return frame
end

function addonTable.Display.GetText(frame, parent)
  frame = frame or CreateFrame("Frame", nil, parent or UIParent)

  frame.text = frame:CreateFontString(nil, nil, "PlatynatorNameplateFont") --XXX: Change this later
  frame:SetSize(1, 1)

  local knownKeys = {"text"}

  function frame:Init(details)
    if frame.Strip then
      frame:Strip()
    end

    ApplyAnchor(frame, details.anchor)

    frame.text:SetText("TEST")
    frame.text:SetTextScale(details.scale)
    frame.text:ClearAllPoints()
    frame.text:SetPoint(details.anchor[1] or "CENTER")
    frame:SetHeight(frame.text:GetLineHeight())
    frame.details = details

    if details.kind == "health" then
      Mixin(frame, addonTable.Display.HealthTextMixin)
    elseif details.kind == "creatureName" then
      Mixin(frame, addonTable.Display.CreatureTextMixin)
    elseif details.kind == "castSpellName" then
      Mixin(frame, addonTable.Display.CastTextMixin)
    else
      assert(false)
    end

    frame:SetScript("OnEvent", frame.OnEvent)

    if frame.PostInit then
      frame:PostInit()
    end
  end

  return frame
end

local pools = {
  bar = CreateFramePool("Frame", UIParent, nil, nil, false, addonTable.Display.GetBar),
  text = CreateFramePool("Frame", UIParent, nil, nil, false, addonTable.Display.GetText),
  power = CreateFramePool("Frame", UIParent, nil, nil, false, addonTable.Display.GetPower),
  highlight = CreateFramePool("Frame", UIParent, nil, nil, false, addonTable.Display.GetHighlight),
}

local poolType = {}

function addonTable.Display.GetWidgets(design, parent)
  local widgets = {}

  for _, barDetails in ipairs(design.bars) do
    local w = pools.bar:Acquire()
    w:SetParent(parent)
    w:Init(barDetails)
    w:Show()
    w:SetFrameStrata("LOW")
    w.kind = "bar"
    table.insert(widgets, w)
  end

  for _, textDetails in ipairs(design.texts) do
    local w = pools.text:Acquire()
    poolType[w] = "text"
    w:SetParent(parent)
    w:Init(textDetails)
    w:Show()
    w:SetFrameStrata("MEDIUM")
    w.kind = "text"
    table.insert(widgets, w)
  end

  for _, highlightDetails in ipairs(design.highlights) do
    local w = pools.highlight:Acquire()
    w:SetParent(parent)
    w:Init(highlightDetails)
    w:Show()
    w:SetFrameStrata("BACKGROUND")
    w.kind = "highlight"
    table.insert(widgets, w)
  end

  for _, specialDetails in ipairs(design.specialBars) do
    assert(specialDetails.kind == "power")
    local w = pools.power:Acquire()
    poolType[w] = "power"
    w:SetParent(parent)
    w:Init(specialDetails)
    w:Show()
    w:SetFrameStrata("HIGH")
    w.kind = "power"
    table.insert(widgets, w)
  end

  return widgets
end

function addonTable.Display.ReleaseWidgets(widgets)
  for _, w in ipairs(widgets) do
    pools[poolType[w]]:Release(w)
    pools[poolType[w]] = nil
  end
end
