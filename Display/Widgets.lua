---@class addonTablePlatynator
local addonTable = select(2, ...)

function addonTable.Display.ApplyAnchor(frame, anchor)
  if #anchor == 0 then
    frame:SetPoint("CENTER")
  elseif #anchor == 3 then
    frame:SetPoint(anchor[1], frame:GetParent(), "CENTER", anchor[2], anchor[3])
  elseif #anchor == 2 then
    frame:SetPoint("CENTER", frame:GetParent(), "CENTER", anchor[1], anchor[2])
  end
end

local ApplyAnchor = addonTable.Display.ApplyAnchor

function addonTable.Display.GetBar(frame, parent)
  frame = frame or CreateFrame("Frame", nil, parent or UIParent)

  frame.statusBar = CreateFrame("StatusBar", nil, frame)
  frame.statusBar:SetAllPoints()
  frame.statusBar:SetClipsChildren(true)

  frame.reverseStatusTexture = frame.statusBar:CreateTexture()
  frame.reverseStatusTexture:SetPoint("LEFT", frame)
  frame.reverseStatusTexture:SetDrawLayer("ARTWORK", -1)

  frame.marker = frame.statusBar:CreateTexture()
  frame.marker:SetSnapToPixelGrid(false)

  local borderHolder = CreateFrame("Frame", nil, frame)
  frame.border = borderHolder:CreateTexture()
  frame.border:SetDrawLayer("OVERLAY")
  frame.border:SetPoint("CENTER", frame)

  function frame:SetReverseFill(value)
    if value then
      frame.statusBar:SetFillStyle("REVERSE")
      frame.marker:SetPoint("CENTER", frame.reverseStatusTexture, "RIGHT")
      self.statusBar:GetStatusBarTexture():SetColorTexture(1, 1, 1, 0)
      self.reverseStatusTexture:Show()
    else
      frame.statusBar:SetFillStyle("STANDARD")
      frame.marker:SetPoint("CENTER", frame.statusBar:GetStatusBarTexture(), "RIGHT")
      self.statusBar:SetStatusBarTexture(addonTable.Assets.BarBackgrounds[frame.details.foreground.asset].file)
      self.reverseStatusTexture:Hide()
    end
  end

  frame.mask = frame:CreateMaskTexture()
  frame.mask:SetPoint("CENTER")

  frame.background = frame.statusBar:CreateTexture()
  frame.background:SetAllPoints()
  frame.background:SetDrawLayer("BACKGROUND")

  local knownKeys = {"statusBar", "marker", "border", "background"}

  function frame:Init(details)
    if frame.Strip then
      frame:Strip()
    end

    ApplyAnchor(frame, details.anchor)

    local foregroundDetails = addonTable.Assets.BarBackgrounds[details.foreground.asset]
    local borderDetails = addonTable.Assets.BarBorders[details.border.asset]
    local borderMaskDetails = addonTable.Assets.BarMasks[details.border.asset]
    local width, height = foregroundDetails.width, foregroundDetails.height
    if borderDetails.mode and borderDetails.mode ~= foregroundDetails.mode then
      if borderMaskDetails then
        width, height = math.min(borderMaskDetails.width, width), math.min(borderMaskDetails.height, height)
      else
        width, height = math.min(borderDetails.width, width), math.min(borderDetails.height, height)
      end
    end
    frame:SetSize(width * details.scale, height * details.scale)

    frame.statusBar:SetStatusBarTexture(foregroundDetails.file)
    frame.statusBar:GetStatusBarTexture():SetDrawLayer("ARTWORK")
    frame.statusBar:GetStatusBarTexture():SetSnapToPixelGrid(false)
    frame.statusBar:GetStatusBarTexture():SetTexelSnappingBias(0)

    frame.reverseStatusTexture:Hide()
    -- Scaling to avoid zooming in on the texture at the current size
    frame.reverseStatusTexture:SetScale(frame:GetWidth() / foregroundDetails.width)
    frame.reverseStatusTexture:SetTexture(foregroundDetails.file)
    frame.reverseStatusTexture:SetHeight(height)
    frame.reverseStatusTexture:SetPoint("RIGHT", frame.statusBar:GetStatusBarTexture(), "LEFT")
    frame.reverseStatusTexture:SetHorizTile(true)

    local backgroundDetails = addonTable.Assets.BarBackgrounds[details.background.asset]
    frame.background:SetTexture(backgroundDetails.file)
    frame.background:SetSize(backgroundDetails.width * details.scale, backgroundDetails.height * details.scale)
    frame.background:SetAlpha(details.background.alpha)
    frame.background:SetVertexColor(1, 1, 1)
    local borderDetails = addonTable.Assets.BarBorders[details.border.asset]
    frame.border:SetTexture(borderDetails.file)
    frame.border:SetSize(borderDetails.width * details.scale, borderDetails.height * details.scale)
    frame.border:SetVertexColor(details.border.color.r, details.border.color.g, details.border.color.b)
    if details.marker.asset ~= "none" then
      frame.marker:Show()
      local markerDetails = addonTable.Assets.BarPositionHighlights[details.marker.asset]
      frame.marker:SetTexture(markerDetails.file)
      frame.marker:SetSize(markerDetails.width * details.scale, frame:GetHeight())
      frame.marker:SetPoint("CENTER", frame.statusBar:GetStatusBarTexture(), "RIGHT")
    else
      frame.marker:Hide()
    end

    frame.statusBar:GetStatusBarTexture():RemoveMaskTexture(frame.mask)
    frame.reverseStatusTexture:RemoveMaskTexture(frame.mask)
    frame.background:RemoveMaskTexture(frame.mask)
    frame.marker:RemoveMaskTexture(frame.mask)

    local maskInfo = addonTable.Assets.BarMasks[details.border.asset]
    if maskInfo then
      frame.mask:SetTexture(maskInfo.file, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
      frame.mask:SetSize(maskInfo.width * details.scale, maskInfo.height * details.scale)
      frame.mask:SetSnapToPixelGrid(false)
      frame.mask:SetTexelSnappingBias(0)

      frame.statusBar:GetStatusBarTexture():AddMaskTexture(frame.mask)
      frame.reverseStatusTexture:AddMaskTexture(frame.mask)
      frame.background:AddMaskTexture(frame.mask)
      frame.marker:AddMaskTexture(frame.mask)
    end

    frame.details = details

    frame.reverseStatusTexture:SetSnapToPixelGrid(false)
    frame.reverseStatusTexture:SetTexelSnappingBias(0)
    frame.marker:SetTexelSnappingBias(0)
    frame.marker:SetDrawLayer("ARTWORK", 2)
    frame.border:SetSnapToPixelGrid(false)
    frame.border:SetTexelSnappingBias(0)
    frame.background:SetSnapToPixelGrid(false)
    frame.background:SetTexelSnappingBias(0)

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

    frame.details = details

    local blankDetails = addonTable.Assets.PowerBars[details.blank]
    self.background:SetStatusBarTexture(blankDetails.file)
    self.main:SetStatusBarTexture(addonTable.Assets.PowerBars[details.filled].file)
    self.main:SetPoint("LEFT", frame.background:GetStatusBarTexture())
    self.main:SetWidth(self.background:GetWidth())
    self.main:GetStatusBarTexture():SetSnapToPixelGrid(false)
    self.main:GetStatusBarTexture():SetTexelSnappingBias(0)
    self.background:GetStatusBarTexture():SetSnapToPixelGrid(false)
    self.background:GetStatusBarTexture():SetTexelSnappingBias(0)
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

    local highlightDetails = addonTable.Assets.Highlights[details.asset]
    frame.details = details

    frame.highlight:SetTexture(highlightDetails.file)
    frame.highlight:SetVertexColor(details.color.r, details.color.g, details.color.b)
    frame:SetSize(highlightDetails.width * details.scale, highlightDetails.height * details.scale)

    frame.highlight:SetSnapToPixelGrid(false)
    frame.highlight:SetTexelSnappingBias(0)

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

function addonTable.Display.GetMarker(frame, parent)
  frame = frame or CreateFrame("Frame", nil, parent or UIParent)

  frame.marker = frame:CreateTexture()

  frame.marker:SetAllPoints()

  function frame:Init(details)
    ApplyAnchor(frame, details.anchor)
    frame.details = details

    local markerDetails = addonTable.Assets.Markers[details.asset]

    frame.marker:SetTexture(markerDetails.file)
    if details.color then
      frame.marker:SetVertexColor(details.color.r, details.color.g, details.color.b)
    else
      frame.marker:SetVertexColor(1, 1, 1)
    end
    frame.marker:SetSnapToPixelGrid(false)
    frame.marker:SetTexelSnappingBias(0)
    frame:SetSize(markerDetails.width * details.scale, markerDetails.height * details.scale)

    if details.kind == "quest" then
      Mixin(frame, addonTable.Display.QuestMarkerMixin)
    elseif details.kind == "cannotInterrupt" then
      Mixin(frame, addonTable.Display.CannotInterruptMarkerMixin)
    elseif details.kind == "elite" then
      Mixin(frame, addonTable.Display.EliteMarkerMixin)
    elseif details.kind == "raid" then
      Mixin(frame, addonTable.Display.RaidMarkerMixin)
    elseif details.kind == "castIcon" then
      Mixin(frame, addonTable.Display.CastIconMarkerMixin)
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
  frame.text:SetPoint("CENTER")
  hooksecurefunc(frame.text, "SetText", function()
    frame:SetSize(frame.text:GetSize())
  end)
  frame:SetSize(1, 1)

  local knownKeys = {"text"}

  function frame:Init(details)
    if frame.Strip then
      frame:Strip()
    end

    ApplyAnchor(frame, details.anchor)
    frame.text:ClearAllPoints()
    frame.text:SetPoint(details.anchor[1] or "CENTER")
    frame.text:SetTextColor(details.color.r, details.color.g, details.color.b)

    if details.widthLimit then
      frame.text:SetWidth(details.widthLimit)
    else
      frame.text:SetWidth(0)
    end

    frame.text:SetText("TEST")
    frame.text:SetTextScale(details.scale)
    frame.text:SetJustifyH(details.align)
    frame.details = details

    if details.kind == "health" then
      Mixin(frame, addonTable.Display.HealthTextMixin)
    elseif details.kind == "creatureName" then
      Mixin(frame, addonTable.Display.CreatureTextMSPMixin or addonTable.Display.CreatureTextMixin)
    elseif details.kind == "castSpellName" then
      Mixin(frame, addonTable.Display.CastTextMixin)
    elseif details.kind == "level" then
      Mixin(frame, addonTable.Display.LevelTextMixin)
    elseif details.kind == "target" then
      Mixin(frame, addonTable.Display.UnitTargetTextMixin)
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

local livePools = {
  bars = CreateFramePool("Frame", UIParent, nil, nil, false, addonTable.Display.GetBar),
  texts = CreateFramePool("Frame", UIParent, nil, nil, false, addonTable.Display.GetText),
  powers = CreateFramePool("Frame", UIParent, nil, nil, false, addonTable.Display.GetPower),
  highlights = CreateFramePool("Frame", UIParent, nil, nil, false, addonTable.Display.GetHighlight),
  markers = CreateFramePool("Frame", UIParent, nil, nil, false, addonTable.Display.GetMarker),
}

local editorPools = {
  bars = CreateFramePool("Frame", UIParent, nil, nil, false, addonTable.Display.GetBar),
  texts = CreateFramePool("Frame", UIParent, nil, nil, false, addonTable.Display.GetText),
  powers = CreateFramePool("Frame", UIParent, nil, nil, false, addonTable.Display.GetPower),
  highlights = CreateFramePool("Frame", UIParent, nil, nil, false, addonTable.Display.GetHighlight),
  markers = CreateFramePool("Frame", UIParent, nil, nil, false, addonTable.Display.GetMarker),
}

local poolType = {}

function addonTable.Display.GetWidgets(design, parent, isEditor)
  local widgets = {}

  local pools = isEditor and editorPools or livePools

  for index, barDetails in ipairs(design.bars) do
    local w = pools.bars:Acquire()
    poolType[w] = "bars"
    w:SetParent(parent)
    w:Show()
    w:Init(barDetails)
    w:SetFrameStrata("MEDIUM")
    w:SetFrameLevel(500 + index)
    w.kind = "bars"
    w.kindIndex = index
    table.insert(widgets, w)
  end

  for index, textDetails in ipairs(design.texts) do
    local w = pools.texts:Acquire()
    poolType[w] = "texts"
    w:SetParent(parent)
    w:Show()
    w:Init(textDetails)
    w:SetFrameStrata("MEDIUM")
    w:SetFrameLevel(1000 + index)
    w.kind = "texts"
    w.kindIndex = index
    table.insert(widgets, w)
  end

  for index, highlightDetails in ipairs(design.highlights) do
    local w = pools.highlights:Acquire()
    poolType[w] = "highlights"
    w:SetParent(parent)
    w:Show()
    w:Init(highlightDetails)
    w:SetFrameStrata("MEDIUM")
    w:SetFrameLevel(200 + index)
    w.kind = "highlights"
    w.kindIndex = index
    table.insert(widgets, w)
  end

  for index, specialDetails in ipairs(design.specialBars) do
    assert(specialDetails.kind == "power")
    local w = pools.powers:Acquire()
    poolType[w] = "powers"
    w:SetParent(parent)
    w:Show()
    w:Init(specialDetails)
    w:SetFrameStrata("HIGH")
    w.kind = "specialBars"
    w.kindIndex = index
    table.insert(widgets, w)
  end

  for index, markerDetails in ipairs(design.markers) do
    local w = pools.markers:Acquire()
    poolType[w] = "markers"
    w:SetParent(parent)
    w:Show()
    w:Init(markerDetails)
    w:SetFrameStrata("HIGH")
    w.kind = "markers"
    w.kindIndex = index
    table.insert(widgets, w)
  end

  return widgets
end

function addonTable.Display.ReleaseWidgets(widgets, isEditor)
  local pools = isEditor and editorPools or livePools

  for _, w in ipairs(widgets) do
    w:Strip()
    pools[poolType[w]]:Release(w)
    poolType[w] = nil
  end
end
