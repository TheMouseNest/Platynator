---@class addonTablePlatynator
local addonTable = select(2, ...)

local LSM = LibStub("LibSharedMedia-3.0")

function addonTable.Display.ApplyAnchor(frame, anchor)
  frame:ClearAllPoints()
  if #anchor == 0 then
    frame:SetPoint("CENTER")
  elseif #anchor == 3 then
    PixelUtil.SetPoint(frame, anchor[1], frame:GetParent(), "CENTER", anchor[2], anchor[3])
  elseif #anchor == 2 then
    PixelUtil.SetPoint(frame, "CENTER", frame:GetParent(), "CENTER", anchor[1], anchor[2])
  elseif #anchor == 1 then
    frame:SetPoint("TOP", frame:GetParent(), "CENTER")
  end
end

local ApplyAnchor = addonTable.Display.ApplyAnchor

local function InitBar(frame, details)
  if frame.Strip then
    frame:Strip()
  end

  local borderDetails = LSM:Fetch("ninesliceborder", details.border.asset, true) or LSM:Fetch("ninesliceborder", "Platy: 4px")
  local borderSliceDetails = LSM:Fetch("nineslice", borderDetails.nineslice)

  frame.lowerScale = 1/borderSliceDetails.scaleModifier
  frame.rawWidth, frame.rawHeight = details.border.width * addonTable.Assets.BarBordersSize.width, details.border.height * addonTable.Assets.BarBordersSize.height
  frame.borderWidth = frame.rawWidth + (borderSliceDetails.padding.left + borderSliceDetails.padding.right) / 2
  frame.borderHeight = frame.rawHeight + (borderSliceDetails.padding.top + borderSliceDetails.padding.bottom) / 2

  local foreground = LSM:Fetch("statusbar", details.foreground.asset, true) or LSM:Fetch("statusbar", "Platy: Solid White")
  frame.statusBar:SetScale(borderSliceDetails.scaleModifier * details.scale)
  frame.statusBar:SetMinMaxValues(0, 1)
  frame.statusBar:SetValue(1)
  frame.statusBar:SetStatusBarTexture(foreground)
  frame.statusBar:GetStatusBarTexture():SetDrawLayer("ARTWORK")

  local background = LSM:Fetch("statusbar", details.background.asset, true) or LSM:Fetch("statusbar", "Platy: Solid Grey")
  frame.background:SetTexture(background)
  frame.background:SetAllPoints()
  frame.background:SetScale(borderSliceDetails.scaleModifier * details.scale)
  frame.background:SetVertexColor(details.background.color.r, details.background.color.g, details.background.color.b, details.background.color.a)
  frame.border:SetTexture(borderSliceDetails.file)
  frame.border:SetScale(borderSliceDetails.scaleModifier * details.scale)
  frame.border:SetVertexColor(details.border.color.r, details.border.color.g, details.border.color.b, details.border.color.a)
  frame.border:SetTextureSliceMargins(borderSliceDetails.margins.left, borderSliceDetails.margins.top, borderSliceDetails.margins.right, borderSliceDetails.margins.bottom)
  if details.marker.asset ~= "none" then
    frame.marker:Show()
    local markerDetails = addonTable.Assets.BarPositionHighlights[details.marker.asset]
    frame.marker:SetTexture(markerDetails.file)
    if markerDetails.mask then
      frame.edgeMask:SetBlockingLoadsRequested(true)
      frame.edgeMask:SetTexture(markerDetails.mask, "CLAMPTOWHITE", "CLAMPTOWHITE")
      frame.statusBar:GetStatusBarTexture():AddMaskTexture(frame.edgeMask)
    else
      frame.statusBar:GetStatusBarTexture():RemoveMaskTexture(frame.edgeMask)
    end
  else
    frame.marker:Hide()
    frame.statusBar:GetStatusBarTexture():RemoveMaskTexture(frame.edgeMask)
  end

  frame.statusBar:GetStatusBarTexture():RemoveMaskTexture(frame.mask)
  frame.background:RemoveMaskTexture(frame.mask)
  frame.marker:RemoveMaskTexture(frame.mask)

  local maskDetails = borderDetails.mask
  frame.mask:SetBlockingLoadsRequested(true)
  frame.mask:SetTexture(maskDetails.file, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
  frame.mask:SetTextureSliceMargins(maskDetails.margins.left, maskDetails.margins.top, maskDetails.margins.right, maskDetails.margins.bottom)
  frame.mask:SetScale(details.scale)

  frame.statusBar:GetStatusBarTexture():AddMaskTexture(frame.mask)
  frame.background:AddMaskTexture(frame.mask)
  frame.marker:AddMaskTexture(frame.mask)

  frame.details = details

  frame.marker:SetDrawLayer("ARTWORK", 2)
end

local function SizeBar(frame, details)
  PixelUtil.SetSize(frame, frame.rawWidth * details.scale, frame.rawHeight * details.scale)

  PixelUtil.SetSize(frame.statusBar, frame.rawWidth * frame.lowerScale, frame.rawHeight * frame.lowerScale)
  PixelUtil.SetSize(frame.border, frame.borderWidth * frame.lowerScale, frame.borderHeight * frame.lowerScale)
  if details.marker.asset ~= "none" then
    local markerDetails = addonTable.Assets.BarPositionHighlights[details.marker.asset]
    PixelUtil.SetSize(frame.marker, markerDetails.width * details.scale * frame.lowerScale, frame.rawHeight * frame.lowerScale)
    PixelUtil.SetSize(frame.edgeMask, markerDetails.width * details.scale, frame.rawHeight * details.scale)
  end

  PixelUtil.SetSize(frame.mask, frame.rawWidth, frame.rawHeight)
end

local function AnchorBar(frame, details)
  ApplyAnchor(frame, frame.details.anchor)
  if details.marker.asset ~= "none" then
    local markerDetails = addonTable.Assets.BarPositionHighlights[details.marker.asset]
    PixelUtil.SetPoint(frame.marker, "RIGHT", frame.statusBar:GetStatusBarTexture(), "RIGHT", markerDetails.width * details.scale * frame.lowerScale * markerDetails.offset, 0)
    PixelUtil.SetPoint(frame.edgeMask, "RIGHT", frame.statusBar:GetStatusBarTexture(), "RIGHT", markerDetails.width * details.scale * markerDetails.offset + 1, 0)
  end
end

function addonTable.Display.GetHealthBar(frame, parent)
  frame = frame or CreateFrame("Frame", nil, parent or UIParent)

  frame.statusBarAbsorb = CreateFrame("StatusBar", nil, frame)
  frame.statusBarAbsorb:SetClipsChildren(true)

  frame.statusBarCutaway = CreateFrame("StatusBar", nil, frame)
  frame.statusBarCutawayAnimation = frame.statusBarCutaway:CreateAnimationGroup()
  frame.statusBarCutawayAnimation:SetToFinalAlpha(true)
  local alpha = frame.statusBarCutawayAnimation:CreateAnimation("Alpha")
  alpha:SetSmoothing("IN_OUT")
  alpha:SetFromAlpha(1)
  alpha:SetToAlpha(0)
  alpha:SetDuration(0.3)
  frame.statusBarCutawayMask = frame:CreateMaskTexture()
  frame.statusBarCutawayMask:SetBlockingLoadsRequested(true)
  frame.statusBarCutawayMask:SetTexture("Interface/AddOns/Platynator/Assets/Special/white.png", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
  frame.statusBarCutawayMask:SetTextureSliceMargins(1, 1, 1, 1)

  frame.statusBar = CreateFrame("StatusBar", nil, frame)
  frame.statusBar:SetPoint("CENTER")
  frame.statusBar:SetClipsChildren(true)

  frame.statusBarCutaway:SetAllPoints(frame.statusBar)

  frame.marker = frame.statusBar:CreateTexture()
  frame.marker:SetSnapToPixelGrid(false)

  local borderHolder = CreateFrame("Frame", nil, frame)
  borderHolder:SetFlattensRenderLayers(true)
  frame.border = borderHolder:CreateTexture()
  frame.border:SetDrawLayer("OVERLAY")
  frame.border:SetPoint("CENTER", frame)

  frame.mask = frame:CreateMaskTexture()
  frame.mask:SetPoint("CENTER")

  frame.edgeMask = frame:CreateMaskTexture()

  frame.background = frame:CreateTexture()
  frame.background:SetPoint("CENTER")
  frame.background:SetDrawLayer("BACKGROUND")

  function frame:Init(details)
    InitBar(frame, details)

    local borderDetails = LSM:Fetch("ninesliceborder", details.border.asset, true) or LSM:Fetch("ninesliceborder", "Platy: 4px")
    local borderSliceDetails = LSM:Fetch("nineslice", borderDetails.nineslice)

    frame.statusBarCutaway:SetFrameLevel(frame:GetFrameLevel() + 1)
    frame.statusBarAbsorb:SetFrameLevel(frame:GetFrameLevel() + 2)
    frame.statusBar:SetFrameLevel(frame:GetFrameLevel() + 3)
    borderHolder:SetFrameLevel(frame:GetFrameLevel() + 5)

    frame.statusBarAbsorb:SetStatusBarTexture(LSM:Fetch("statusbar", details.absorb.asset, true) or LSM:Fetch("statusbar", "Platy: Absorb Wide"))
    frame.statusBarAbsorb:GetStatusBarTexture():SetVertexColor(details.absorb.color.r, details.absorb.color.g, details.absorb.color.b, details.absorb.color.a)
    frame.statusBarAbsorb:SetPoint("LEFT", frame.statusBar:GetStatusBarTexture(), "RIGHT")
    frame.statusBarAbsorb:SetScale(borderSliceDetails.scaleModifier * details.scale)
    frame.statusBarAbsorb:GetStatusBarTexture():RemoveMaskTexture(frame.mask)

    frame.statusBarCutaway:SetStatusBarTexture(LSM:Fetch("statusbar", details.foreground.asset, true) or LSM:Fetch("statusbar", "Platy: Solid White"))
    frame.statusBarCutaway:SetScale(borderSliceDetails.scaleModifier * details.scale)
    frame.statusBarCutaway:GetStatusBarTexture():RemoveMaskTexture(frame.mask)
    frame.statusBarCutaway:SetAlpha(0)
    frame.statusBarCutawayMask:SetPoint("LEFT", frame.statusBar:GetStatusBarTexture(), "RIGHT")
    frame.statusBarCutawayMask:SetScale(details.scale)

    frame.statusBarAbsorb:GetStatusBarTexture():AddMaskTexture(frame.mask)
    frame.statusBarCutaway:GetStatusBarTexture():AddMaskTexture(frame.statusBarCutawayMask)
    frame.statusBarCutaway:GetStatusBarTexture():AddMaskTexture(frame.mask)

    if details.kind == "health" then
      Mixin(frame, addonTable.Display.HealthBarMixin)
    else
      assert(false)
    end

    frame:SetScript("OnEvent", frame.OnEvent)

    if frame.PostInit then
      frame:PostInit()
    end
  end

  function frame:ApplyAnchor()
    AnchorBar(frame, frame.details)
  end

  function frame:ApplySize()
    SizeBar(frame, frame.details)
    PixelUtil.SetSize(frame.statusBarAbsorb, frame.rawWidth * frame.lowerScale, frame.rawHeight * frame.lowerScale)
    PixelUtil.SetSize(frame.statusBarCutawayMask, frame.rawWidth, frame.rawHeight)
  end

  return frame
end

function addonTable.Display.GetCastBar(frame, parent)
  frame = frame or CreateFrame("Frame", nil, parent or UIParent)

  frame.statusBar = CreateFrame("StatusBar", nil, frame)
  frame.statusBar:SetPoint("CENTER")
  frame.statusBar:SetClipsChildren(true)

  frame.reverseStatusTexture = frame.statusBar:CreateTexture()
  frame.reverseStatusTexture:SetPoint("LEFT", frame)
  frame.reverseStatusTexture:SetDrawLayer("ARTWORK")

  frame.marker = frame.statusBar:CreateTexture()
  frame.marker:SetSnapToPixelGrid(false)

  local borderHolder = CreateFrame("Frame", nil, frame)
  borderHolder:SetFlattensRenderLayers(true)
  frame.border = borderHolder:CreateTexture()
  frame.border:SetDrawLayer("OVERLAY")
  frame.border:SetPoint("CENTER", frame)

  function frame:SetReverseFill(value)
    if value then
      if addonTable.Constants.IsRetail then
        frame.statusBar:SetFillStyle(Enum.StatusBarFillStyle.Reverse)
        frame.interruptMarker:SetFillStyle(Enum.StatusBarFillStyle.Reverse)
        frame.interruptPositioner:SetFillStyle(Enum.StatusBarFillStyle.Reverse)
      else
        frame.statusBar:SetFillStyle("REVERSE")
        frame.interruptMarker:SetFillStyle("REVERSE")
        frame.interruptPositioner:SetFillStyle("REVERSE")
      end

      self.statusBar:GetStatusBarTexture():SetColorTexture(1, 1, 1, 0)
      self.reverseStatusTexture:Show()

      frame.marker:SetPoint("CENTER", frame.reverseStatusTexture, "RIGHT")
      frame.interruptMarker:ClearAllPoints()
      frame.interruptMarker:SetPoint("RIGHT", frame.interruptPositioner:GetStatusBarTexture(), "LEFT")
      frame.interruptMarkerPoint:ClearAllPoints()
      frame.interruptMarkerPoint:SetPoint("RIGHT", frame.interruptMarker:GetStatusBarTexture(), "LEFT")
    else
      if addonTable.Constants.IsRetail then
        frame.statusBar:SetFillStyle(Enum.StatusBarFillStyle.Standard)
        frame.interruptMarker:SetFillStyle(Enum.StatusBarFillStyle.Standard)
        frame.interruptPositioner:SetFillStyle(Enum.StatusBarFillStyle.Standard)
      else
        frame.statusBar:SetFillStyle("STANDARD")
        frame.interruptMarker:SetFillStyle("STANDARD")
        frame.interruptPositioner:SetFillStyle("STANDARD")
      end
      self.statusBar:SetStatusBarTexture(LSM:Fetch("statusbar", frame.details.foreground.asset, true) or LSM:Fetch("statusbar", "Platy: Solid White"))
      self.reverseStatusTexture:Hide()

      frame.marker:SetPoint("CENTER", frame.statusBar:GetStatusBarTexture(), "RIGHT")
      frame.interruptMarker:ClearAllPoints()
      frame.interruptMarker:SetPoint("LEFT", frame.interruptPositioner:GetStatusBarTexture(), "RIGHT")
      frame.interruptMarkerPoint:ClearAllPoints()
      frame.interruptMarkerPoint:SetPoint("LEFT", frame.interruptMarker:GetStatusBarTexture(), "RIGHT")
    end
  end

  frame.mask = frame:CreateMaskTexture()
  frame.mask:SetPoint("CENTER")

  frame.edgeMask = frame:CreateMaskTexture()

  frame.background = frame:CreateTexture()
  frame.background:SetPoint("CENTER")
  frame.background:SetDrawLayer("BACKGROUND")

  frame.interruptPositioner = CreateFrame("StatusBar", nil, frame)
  frame.interruptPositioner:SetStatusBarTexture("Interface/AddOns/Platynator/Special/transparent.png")
  frame.interruptPositioner:SetPoint("CENTER")

  frame.interruptMarker = CreateFrame("StatusBar", nil, frame)
  frame.interruptMarker:SetStatusBarTexture("Interface/AddOns/Platynator/Special/transparent.png")
  frame.interruptMarker:SetClipsChildren(true)
  frame.interruptMarkerPoint = frame.interruptMarker:CreateTexture()
  frame.interruptMarkerPoint:SetColorTexture(1, 1, 1)
  frame.interruptMarkerPoint:SetWidth(5)
  frame.interruptMarker:SetPoint("LEFT", frame.interruptPositioner:GetStatusBarTexture(), "RIGHT")
  frame.interruptMarkerPoint:SetPoint("LEFT", frame.interruptMarker:GetStatusBarTexture(), "RIGHT")

  function frame:Init(details)
    InitBar(frame, details)

    local borderDetails = LSM:Fetch("ninesliceborder", details.border.asset, true) or LSM:Fetch("ninesliceborder", "Platy: 4px")
    local borderSliceDetails = LSM:Fetch("nineslice", borderDetails.nineslice)

    frame.statusBar:SetFrameLevel(frame:GetFrameLevel() + 2)
    frame.interruptMarker:SetFrameLevel(frame:GetFrameLevel() + 5)
    borderHolder:SetFrameLevel(frame:GetFrameLevel() + 6)

    local foreground = LSM:Fetch("statusbar", details.foreground.asset, true) or LSM:Fetch("statusbar", "Platy: Solid White")
    frame.reverseStatusTexture:Hide()
    frame.reverseStatusTexture:SetTexture(foreground)
    frame.reverseStatusTexture:SetPoint("RIGHT", frame.statusBar:GetStatusBarTexture(), "LEFT")
    frame.reverseStatusTexture:SetHorizTile(true)

    frame.interruptMarker:SetScale(borderSliceDetails.scaleModifier)
    frame.interruptPositioner:SetScale(borderSliceDetails.scaleModifier)
    if details.interruptMarker.asset ~= "none" then
      local markerDetails = addonTable.Assets.BarPositionHighlights[details.interruptMarker.asset]
      frame.interruptMarkerPoint:SetTexture(markerDetails.file)
      local color = details.interruptMarker.color
      frame.interruptMarkerPoint:SetVertexColor(color.r, color.g, color.b)
    end

    frame.reverseStatusTexture:RemoveMaskTexture(frame.mask)
    frame.interruptMarkerPoint:RemoveMaskTexture(frame.mask)
    frame.reverseStatusTexture:AddMaskTexture(frame.mask)
    frame.interruptMarkerPoint:AddMaskTexture(frame.mask)

    frame.details = details

    if details.kind == "cast" then
      Mixin(frame, addonTable.Display.CastBarMixin)
    else
      assert(false)
    end

    frame:SetScript("OnEvent", frame.OnEvent)

    if frame.PostInit then
      frame:PostInit()
    end
  end

  function frame:ApplyAnchor()
    AnchorBar(frame, frame.details)
  end

  function frame:ApplySize()
    local details = frame.details
    SizeBar(frame, details)

    local borderDetails = LSM:Fetch("ninesliceborder", details.border.asset, true) or LSM:Fetch("ninesliceborder", "Platy: 4px")
    local borderSliceDetails = LSM:Fetch("nineslice", borderDetails.nineslice)

    local lowerScale = 1 / borderSliceDetails.scaleModifier
    frame.reverseStatusTexture:SetHeight(frame.rawHeight * lowerScale)
    frame.interruptMarkerPoint:SetHeight(frame.rawHeight * lowerScale)
    frame.interruptMarker:SetSize(frame.rawWidth * lowerScale, frame.rawHeight * lowerScale)
    frame.interruptPositioner:SetSize(frame.rawWidth * lowerScale, frame.rawHeight * lowerScale)
    if details.interruptMarker.asset ~= "none" then
      local markerDetails = addonTable.Assets.BarPositionHighlights[details.interruptMarker.asset]
      PixelUtil.SetSize(frame.interruptMarkerPoint, markerDetails.width * details.scale * lowerScale, frame.rawHeight * lowerScale)
    end
  end

  return frame
end

function addonTable.Display.GetPower(frame, parent)
  frame = frame or CreateFrame("Frame", nil, parent or UIParent)

  frame.background = CreateFrame("StatusBar", nil, frame)
  frame.background:SetAllPoints()
  if addonTable.Constants.IsRetail then
    frame.background:SetFillStyle(Enum.StatusBarFillStyle.Center)
  else
    frame.background:SetFillStyle("CENTER")
  end
  frame.background:SetMinMaxValues(0, 7)

  frame.main = CreateFrame("StatusBar", nil, frame)
  frame.main:SetMinMaxValues(0, 7)

  frame:SetScript("OnSizeChanged", function()
    PixelUtil.SetSize(frame.main, frame:GetSize())
  end)

  function frame:Init(details)
    if frame.Strip then
      frame:Strip()
    end

    frame.details = details

    local blankDetails = addonTable.Assets.PowerBars[details.blank]
    self.background:SetStatusBarTexture(blankDetails.file)
    self.main:SetStatusBarTexture(addonTable.Assets.PowerBars[details.filled].file)
    self.main:SetPoint("LEFT", frame.background:GetStatusBarTexture())

    Mixin(frame, addonTable.Display.PowerBarMixin)

    frame:SetScript("OnEvent", frame.OnEvent)

    if frame.PostInit then
      frame:PostInit()
    end
  end

  function frame:ApplyAnchor()
    ApplyAnchor(frame, frame.details.anchor)
  end

  function frame:ApplySize()
    local details = frame.details
    local blankDetails = addonTable.Assets.PowerBars[frame.details.blank]
    PixelUtil.SetSize(frame, blankDetails.width * details.scale, blankDetails.height * details.scale)
    PixelUtil.SetSize(self.main, self.background:GetSize())
  end
end

function addonTable.Display.GetHighlight(frame, parent)
  frame = frame or CreateFrame("Frame", nil, parent or UIParent)

  frame.highlight = frame:CreateTexture()
  frame.highlight:SetAllPoints()

  function frame:Init(details)
    local highlightDetails = (details.sliced and (LSM:Fetch("nineslice", details.asset, true) or LSM:Fetch("nineslice", "Platy: 7px"))) or (LSM:Fetch("platynator/sizedtexture", details.asset, true) or LSM:Fetch("platynator/sizedtexture", "Platy: Glow"))
    frame.details = details

    frame.highlight:SetTexture(highlightDetails.file)
    frame.highlight:SetVertexColor(details.color.r, details.color.g, details.color.b, details.color.a)
    frame.highlight:SetScale(details.scale)

    if details.sliced then
      frame.highlight:SetScale(highlightDetails.scaleModifier * details.scale)
      frame.highlight:SetTextureSliceMargins(highlightDetails.margins.left, highlightDetails.margins.top, highlightDetails.margins.right, highlightDetails.margins.bottom)
    else
      frame.highlight:ClearTextureSlice()
    end

    if details.kind == "target" then
      Mixin(frame, addonTable.Display.TargetHighlightMixin)
    elseif details.kind == "softTarget" then
      Mixin(frame, addonTable.Display.SoftTargetHighlightMixin)
    elseif details.kind == "focus" then
      Mixin(frame, addonTable.Display.FocusHighlightMixin)
    elseif details.kind == "mouseover" then
      Mixin(frame, addonTable.Display.MouseoverHighlightMixin)
    elseif details.kind == "automatic" then
      Mixin(frame, addonTable.Display.AutomaticHighlightMixin)
    elseif details.kind == "fixed" then
      Mixin(frame, addonTable.Display.FixedHighlightMixin)
    else
      assert(false)
    end

    frame:SetScript("OnEvent", frame.OnEvent)

    if frame.PostInit then
      frame:PostInit()
    end
  end

  function frame:ApplyAnchor()
    ApplyAnchor(frame, frame.details.anchor)
  end

  function frame:ApplySize()
    local details = frame.details
    local highlightDetails = (details.sliced and (LSM:Fetch("nineslice", details.asset, true) or LSM:Fetch("nineslice", "Platy: 7px"))) or (LSM:Fetch("platynator/sizedtexture", details.asset, true) or LSM:Fetch("platynator/sizedtexture", "Platy: Glow"))
    if details.sliced then
      local width, height = details.width * addonTable.Assets.BarBordersSize.width, details.height * addonTable.Assets.BarBordersSize.height
      PixelUtil.SetSize(frame, width * details.scale, height * details.scale)
      PixelUtil.SetSize(frame.highlight, (width + (highlightDetails.padding.left + highlightDetails.padding.right) / 2) / highlightDetails.scaleModifier, (height + (highlightDetails.padding.top + highlightDetails.padding.bottom) / 2) / highlightDetails.scaleModifier)
    else
      PixelUtil.SetSize(frame, highlightDetails.width * details.width * details.scale, highlightDetails.height * details.height * details.scale)
      PixelUtil.SetSize(frame.highlight, highlightDetails.width * details.width, highlightDetails.height * details.height)
    end
  end

  return frame
end

function addonTable.Display.GetAnimatedBorderHighlight(frame, parent)
  frame = frame or CreateFrame("Frame", nil, parent or UIParent)

  frame.Animation = frame:CreateAnimationGroup()
  do
    frame.Top = frame:CreateTexture()
    frame.Top:SetPoint("TOPLEFT")
    frame.Top:SetPoint("TOPRIGHT")
    frame.Top:SetTexture("Interface/AddOns/Platynator/Assets/Special/pandemic.png")
    frame.Bottom = frame:CreateTexture()
    frame.Bottom:SetPoint("BOTTOMLEFT")
    frame.Bottom:SetPoint("BOTTOMRIGHT")
    frame.Bottom:SetTexture("Interface/AddOns/Platynator/Assets/Special/pandemic.png")
    frame.Bottom:SetRotation(math.pi)
    frame.Left = frame:CreateTexture()
    frame.Left:SetPoint("TOPLEFT")
    frame.Left:SetPoint("BOTTOMLEFT")
    frame.Left:SetTexture("Interface/AddOns/Platynator/Assets/Special/pandemic-90.png")
    frame.Right = frame:CreateTexture()
    frame.Right:SetPoint("TOPRIGHT")
    frame.Right:SetPoint("BOTTOMRIGHT")
    frame.Right:SetTexture("Interface/AddOns/Platynator/Assets/Special/pandemic-90.png")
    frame.Right:SetRotation(math.pi)
    frame.TopFlipBook = frame.Animation:CreateAnimation("Flipbook")
    frame.TopFlipBook:SetTarget(frame.Top)
    frame.BottomFlipBook = frame.Animation:CreateAnimation("Flipbook")
    frame.BottomFlipBook:SetTarget(frame.Bottom)
    frame.LeftFlipBook = frame.Animation:CreateAnimation("Flipbook")
    frame.LeftFlipBook:SetTarget(frame.Left)
    frame.RightFlipBook = frame.Animation:CreateAnimation("Flipbook")
    frame.RightFlipBook:SetTarget(frame.Right)
    frame.Animation:SetLooping("REPEAT")
    frame.Animation:Play()
  end

  frame.currentOffset = 0

  function frame:Init(details)
    local highlightDetails = addonTable.Assets.Highlights[details.asset]
    frame.defaultBorderDim = highlightDetails.defaultWidth
    frame.details = details

    frame.Top:SetTexture(highlightDetails.horizontal)
    frame.Bottom:SetTexture(highlightDetails.horizontal)
    frame.Right:SetTexture(highlightDetails.vertical)
    frame.Left:SetTexture(highlightDetails.vertical)
    frame.Top:SetVertexColor(details.color.r, details.color.g, details.color.b, details.color.a)
    frame.Bottom:SetVertexColor(details.color.r, details.color.g, details.color.b, details.color.a)
    frame.Right:SetVertexColor(details.color.r, details.color.g, details.color.b, details.color.a)
    frame.Left:SetVertexColor(details.color.r, details.color.g, details.color.b, details.color.a)

    frame.TopFlipBook:SetFlipBookColumns(highlightDetails.columns)
    frame.TopFlipBook:SetFlipBookRows(highlightDetails.rows)
    frame.BottomFlipBook:SetFlipBookColumns(highlightDetails.columns)
    frame.BottomFlipBook:SetFlipBookRows(highlightDetails.rows)
    frame.RightFlipBook:SetFlipBookColumns(highlightDetails.rows)
    frame.RightFlipBook:SetFlipBookRows(highlightDetails.columns)
    frame.LeftFlipBook:SetFlipBookColumns(highlightDetails.rows)
    frame.LeftFlipBook:SetFlipBookRows(highlightDetails.columns)

    frame.TopFlipBook:SetDuration(highlightDetails.duration)
    frame.BottomFlipBook:SetDuration(highlightDetails.duration)
    frame.LeftFlipBook:SetDuration(highlightDetails.duration)
    frame.RightFlipBook:SetDuration(highlightDetails.duration)

    if details.kind == "animatedBorder" then
      Mixin(frame, addonTable.Display.AnimatedBorderHighlightMixin)
    else
      assert(false)
    end

    frame:SetScript("OnEvent", frame.OnEvent)

    if frame.PostInit then
      frame:PostInit()
    end
  end

  function frame:ApplyAnchor()
    local details = frame.details
    ApplyAnchor(frame, frame.details.anchor)

    frame.currentOffset = offset
  end

  function frame:ApplySize()
    local details = frame.details
    PixelUtil.SetSize(frame, addonTable.Assets.BarBordersSize.width * details.width * details.scale, addonTable.Assets.BarBordersSize.height * details.height * details.scale)

    local dim = PixelUtil.ConvertPixelsToUIForRegion(details.borderWidth * frame.defaultBorderDim, frame)
    frame.Top:SetHeight(dim)
    frame.Bottom:SetHeight(dim)
    frame.Left:SetWidth(dim)
    frame.Right:SetWidth(dim)
  end

  return frame
end

function addonTable.Display.GetMarker(frame, parent)
  frame = frame or CreateFrame("Frame", nil, parent or UIParent)

  frame.marker = frame:CreateTexture()

  frame.marker:SetAllPoints()

  function frame:Init(details)
    frame.details = details

    local markerDetails = addonTable.Assets.Markers[details.asset]

    frame.marker:SetTexture(markerDetails.file)
    if details.color then
      frame.marker:SetVertexColor(details.color.r, details.color.g, details.color.b)
    else
      frame.marker:SetVertexColor(1, 1, 1)
    end

    if details.kind == "quest" then
      Mixin(frame, addonTable.Display.QuestMarkerMixin)
    elseif details.kind == "cannotInterrupt" then
      Mixin(frame, addonTable.Display.CannotInterruptMarkerMixin)
    elseif details.kind == "elite" then
      Mixin(frame, addonTable.Display.EliteMarkerMixin)
    elseif details.kind == "rare" then
      Mixin(frame, addonTable.Display.RareMarkerMixin)
    elseif details.kind == "raid" then
      Mixin(frame, addonTable.Display.RaidMarkerMixin)
    elseif details.kind == "castIcon" then
      Mixin(frame, addonTable.Display.CastIconMarkerMixin)
    elseif details.kind == "pvp" then
      Mixin(frame, addonTable.Display.PvPMarkerMixin)
    elseif details.kind == "class" then
      Mixin(frame, addonTable.Display.ClassMarkerMixin)
    else
      assert(false)
    end

    frame:SetScript("OnEvent", frame.OnEvent)

    if frame.PostInit then
      frame:PostInit()
    end
  end

  function frame:ApplyAnchor()
    ApplyAnchor(frame, frame.details.anchor)
    if frame.PostApplyAnchor then
      frame:PostApplyAnchor()
    end
  end

  function frame:ApplySize()
    local details = frame.details
    local markerDetails = addonTable.Assets.Markers[details.asset]
    PixelUtil.SetSize(frame, markerDetails.width * details.scale, markerDetails.height * details.scale)
  end

  return frame
end

function addonTable.Display.GetText(frame, parent)
  frame = frame or CreateFrame("Frame", nil, parent or UIParent)
  -- This Wrapper workaround is so that the `frame` always has the same size as the text
  frame.Wrapper = CreateFrame("Frame", nil, parent or UIParent)
  frame.Wrapper:SetSize(1, 1)

  frame.text = frame.Wrapper:CreateFontString(nil, nil, "GameFontNormal")
  frame.text:SetPoint("CENTER", frame.Wrapper)
  frame.text:SetText(" ")

  frame:SetAllPoints(frame.text)

  function frame:Init(details)
    if frame.Strip then
      frame:Strip()
    end

    frame.details = details

    frame.text:SetFontObject(addonTable.CurrentFont)
    frame.text:SetParent(frame)
    frame.text:ClearAllPoints()
    frame.text:SetPoint(details.anchor[1] or "CENTER", frame.Wrapper)
    frame.text:SetTextColor(details.color.r, details.color.g, details.color.b)
    frame.text:SetWordWrap(not details.truncate)
    frame.text:SetNonSpaceWrap(false)
    frame.text:SetSpacing(0)

    frame:SetAllPoints(frame.text)

    frame.text:SetWidth(details.maxWidth * addonTable.Assets.BarBordersSize.width)

    frame.text:SetJustifyV("BOTTOM")
    if details.align ~= frame.text:GetJustifyH() then
      frame.text:SetText(" ")
    end
    frame.text:SetJustifyH(details.align)
    frame.text:SetTextScale(details.scale * 0.85)

    if details.kind == "health" then
      Mixin(frame, addonTable.Display.HealthTextMixin)
    elseif details.kind == "damageAbsorb" then
      Mixin(frame, addonTable.Display.AbsorbTextMixin)
    elseif details.kind == "creatureName" then
      Mixin(frame, addonTable.Display.CreatureTextMSPMixin or addonTable.Display.CreatureTextMixin)
    elseif details.kind == "guild" then
      Mixin(frame, addonTable.Display.GuildTextMixin)
    elseif details.kind == "castSpellName" then
      Mixin(frame, addonTable.Display.CastTextMixin)
    elseif details.kind == "level" then
      Mixin(frame, addonTable.Display.LevelTextMixin)
    elseif details.kind == "target" then
      Mixin(frame, addonTable.Display.UnitTargetTextMixin)
    elseif details.kind == "castTarget" then
      Mixin(frame, addonTable.Display.CastTargetTextMixin)
    elseif details.kind == "castInterrupter" then
      Mixin(frame, addonTable.Display.CastInterrupterTextMixin)
    elseif details.kind == "castTimeLeft" then
      Mixin(frame, addonTable.Display.CastTimeLeftTextMixin)
    elseif details.kind == "quest" then
      Mixin(frame, addonTable.Display.QuestTextMixin)
    else
      assert(false)
    end

    frame:SetScript("OnEvent", frame.OnEvent)

    frame:SetScript("OnShow", function()
      frame.Wrapper:Show()
    end)

    frame:SetScript("OnHide", function()
      frame.Wrapper:Hide()
    end)

    if frame.PostInit then
      frame:PostInit()
    end
  end

  function frame:ApplyAnchor()
    ApplyAnchor(frame.Wrapper, frame.details.anchor)
  end

  function frame:ApplySize()
  end

  return frame
end

local livePools = {
  healthBars = CreateFramePool("Frame", UIParent, nil, nil, false, addonTable.Display.GetHealthBar),
  castBars = CreateFramePool("Frame", UIParent, nil, nil, false, addonTable.Display.GetCastBar),
  texts = CreateFramePool("Frame", UIParent, nil, nil, false, addonTable.Display.GetText),
  powers = CreateFramePool("Frame", UIParent, nil, nil, false, addonTable.Display.GetPower),
  highlights = CreateFramePool("Frame", UIParent, nil, nil, false, addonTable.Display.GetHighlight),
  animatedBorderHighlights = CreateFramePool("Frame", UIParent, nil, nil, false, addonTable.Display.GetAnimatedBorderHighlight),
  markers = CreateFramePool("Frame", UIParent, nil, nil, false, addonTable.Display.GetMarker),
}

local editorPools = {
  healthBars = CreateFramePool("Frame", UIParent, "PlatynatorPropagateMouseTemplate", nil, false, addonTable.Display.GetHealthBar),
  castBars = CreateFramePool("Frame", UIParent, "PlatynatorPropagateMouseTemplate", nil, false, addonTable.Display.GetCastBar),
  texts = CreateFramePool("Frame", UIParent, "PlatynatorPropagateMouseTemplate", nil, false, addonTable.Display.GetText),
  powers = CreateFramePool("Frame", UIParent, "PlatynatorPropagateMouseTemplate", nil, false, addonTable.Display.GetPower),
  highlights = CreateFramePool("Frame", UIParent, "PlatynatorPropagateMouseTemplate", nil, false, addonTable.Display.GetHighlight),
  animatedBorderHighlights = CreateFramePool("Frame", UIParent, "PlatynatorPropagateMouseTemplate", nil, false, addonTable.Display.GetAnimatedBorderHighlight),
  markers = CreateFramePool("Frame", UIParent, "PlatynatorPropagateMouseTemplate", nil, false, addonTable.Display.GetMarker),
}

local poolType = {}
local layerStep = 500

function addonTable.Display.GetWidgets(design, parent, isEditor)
  local widgets = {}

  local pools = isEditor and editorPools or livePools

  for index, barDetails in ipairs(design.bars) do
    local w = pools[barDetails.kind .. "Bars"]:Acquire()
    poolType[w] = barDetails.kind .. "Bars"
    w:SetParent(parent)
    w:Show()
    w:SetFrameStrata("MEDIUM")
    w:SetFrameLevel(layerStep * barDetails.layer + index * 10)
    w:Init(barDetails)
    w.kind = "bars"
    w.kindIndex = index
    table.insert(widgets, w)
  end

  for index, textDetails in ipairs(design.texts) do
    local w = pools.texts:Acquire()
    poolType[w] = "texts"
    w:SetParent(parent)
    w.Wrapper:SetParent(parent)
    w:Show()
    w.Wrapper:SetFrameStrata("MEDIUM")
    w:SetFrameStrata("MEDIUM")
    w.Wrapper:SetFrameLevel(layerStep * textDetails.layer + index * 10)
    w:SetFrameLevel(layerStep * textDetails.layer + index * 10)
    w:Init(textDetails)
    w.kind = "texts"
    w.kindIndex = index
    table.insert(widgets, w)
  end

  for index, highlightDetails in ipairs(design.highlights) do
    local w
    if pools[highlightDetails.kind .. "Highlights"] then
      w = pools[highlightDetails.kind .. "Highlights"]:Acquire()
      poolType[w] = highlightDetails.kind .. "Highlights"
    else
      w = pools.highlights:Acquire()
      poolType[w] = "highlights"
    end
    w:SetParent(parent)
    w:Show()
    w:SetFrameStrata("MEDIUM")
    w:SetFrameLevel(layerStep * highlightDetails.layer + index * 10)
    w:Init(highlightDetails)
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
    w:SetFrameStrata("MEDIUM")
    w:SetFrameLevel(layerStep * specialDetails.layer + index * 10)
    w:Init(specialDetails)
    w.kind = "specialBars"
    w.kindIndex = index
    table.insert(widgets, w)
  end

  for index, markerDetails in ipairs(design.markers) do
    local w = pools.markers:Acquire()
    poolType[w] = "markers"
    w:SetParent(parent)
    w:Show()
    w:SetFrameStrata("MEDIUM")
    w:SetFrameLevel(layerStep * markerDetails.layer + index * 10)
    w:Init(markerDetails)
    w.kind = "markers"
    w.kindIndex = index
    table.insert(widgets, w)
  end

  for _, w in ipairs(widgets) do
    w:ApplyAnchor()
    w:ApplySize()
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
