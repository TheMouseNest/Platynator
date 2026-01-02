---@class addonTablePlatynator
local addonTable = select(2, ...)

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

  local borderDetails = addonTable.Assets.BarBordersSliced[details.border.asset]
  local foregroundDetails = addonTable.Assets.BarBackgrounds[details.foreground.asset]
  frame.statusBar:SetScale(1/borderDetails.lowerScale * details.scale)
  frame.statusBar:SetStatusBarTexture(foregroundDetails.file)
  frame.statusBar:GetStatusBarTexture():SetDrawLayer("ARTWORK")

  local backgroundDetails = addonTable.Assets.BarBackgrounds[details.background.asset]
  frame.background:SetTexture(backgroundDetails.file)
  frame.background:SetAllPoints()
  frame.background:SetScale(1/borderDetails.lowerScale * details.scale)
  frame.background:SetVertexColor(details.background.color.r, details.background.color.g, details.background.color.b, details.background.color.a)
  frame.border:SetTexture(borderDetails.file)
  frame.border:SetScale(1/borderDetails.lowerScale * details.scale)
  frame.border:SetVertexColor(details.border.color.r, details.border.color.g, details.border.color.b, details.border.color.a)
  frame.border:SetTextureSliceMargins(borderDetails.width * borderDetails.margin, borderDetails.height * borderDetails.margin, borderDetails.width * borderDetails.margin, borderDetails.height * borderDetails.margin)
  if details.marker.asset ~= "none" then
    frame.marker:Show()
    local markerDetails = addonTable.Assets.BarPositionHighlights[details.marker.asset]
    frame.marker:SetTexture(markerDetails.file)
    frame.marker:SetPoint("CENTER", frame.statusBar:GetStatusBarTexture(), "RIGHT")
  else
    frame.marker:Hide()
  end

  frame.statusBar:GetStatusBarTexture():RemoveMaskTexture(frame.mask)
  frame.background:RemoveMaskTexture(frame.mask)
  frame.marker:RemoveMaskTexture(frame.mask)

  local maskDetails = addonTable.Assets.BarMasks[details.border.asset]
  if maskDetails then
    frame.mask:SetBlockingLoadsRequested(true)
    frame.mask:SetTexture(maskDetails.file, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    frame.mask:SetTextureSliceMargins(maskDetails.width * maskDetails.margin, maskDetails.height * maskDetails.margin, maskDetails.width * maskDetails.margin, maskDetails.height * maskDetails.margin)
  else
    frame.mask:SetTexture("Interface/AddOns/Platynator/Assets/Special/white.png", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    frame.mask:SetTextureSliceMargins(1, 1, 1, 1)
  end
  frame.mask:SetScale(details.scale)

  frame.statusBar:GetStatusBarTexture():AddMaskTexture(frame.mask)
  frame.background:AddMaskTexture(frame.mask)
  frame.marker:AddMaskTexture(frame.mask)

  frame.details = details

  frame.marker:SetDrawLayer("ARTWORK", 2)
end

local function SizeBar(frame, details)
  local width, height = details.border.width * addonTable.Assets.BarBordersSize.width, details.border.height * addonTable.Assets.BarBordersSize.height
  local borderDetails = addonTable.Assets.BarBordersSliced[details.border.asset]
  PixelUtil.SetSize(frame, width * details.scale, height * details.scale)
  frame.rawWidth = width
  frame.rawHeight = height

  PixelUtil.SetSize(frame.statusBar, width * borderDetails.lowerScale, height * borderDetails.lowerScale)
  PixelUtil.SetSize(frame.border, (width + borderDetails.extra / 2) * borderDetails.lowerScale, (height + borderDetails.extra / 2) * borderDetails.lowerScale)
  if details.marker.asset ~= "none" then
    local markerDetails = addonTable.Assets.BarPositionHighlights[details.marker.asset]
    PixelUtil.SetSize(frame.marker, markerDetails.width * details.scale * borderDetails.lowerScale, height * borderDetails.lowerScale)
  end

  PixelUtil.SetSize(frame.mask, width, height)
end

function addonTable.Display.GetHealthBar(frame, parent)
  frame = frame or CreateFrame("Frame", nil, parent or UIParent)

  frame.statusBarAbsorb = CreateFrame("StatusBar", nil, frame)
  frame.statusBarAbsorb:SetClipsChildren(true)

  frame.statusBar = CreateFrame("StatusBar", nil, frame)
  frame.statusBar:SetPoint("CENTER")
  frame.statusBar:SetClipsChildren(true)

  frame.marker = frame.statusBar:CreateTexture()
  frame.marker:SetSnapToPixelGrid(false)

  local borderHolder = CreateFrame("Frame", nil, frame)
  borderHolder:SetFlattensRenderLayers(true)
  frame.border = borderHolder:CreateTexture()
  frame.border:SetDrawLayer("OVERLAY")
  frame.border:SetPoint("CENTER", frame)

  frame.mask = frame:CreateMaskTexture()
  frame.mask:SetPoint("CENTER")

  frame.background = frame:CreateTexture()
  frame.background:SetPoint("CENTER")
  frame.background:SetDrawLayer("BACKGROUND")

  function frame:Init(details)
    InitBar(frame, details)

    local borderDetails = addonTable.Assets.BarBordersSliced[details.border.asset]

    frame.statusBarAbsorb:SetFrameLevel(frame:GetFrameLevel() + 1)
    frame.statusBar:SetFrameLevel(frame:GetFrameLevel() + 2)
    borderHolder:SetFrameLevel(frame:GetFrameLevel() + 4)

    frame.statusBarAbsorb:SetStatusBarTexture(addonTable.Assets.BarBackgrounds[details.absorb.asset].file)
    frame.statusBarAbsorb:GetStatusBarTexture():SetVertexColor(details.absorb.color.r, details.absorb.color.g, details.absorb.color.b, details.absorb.color.a)
    frame.statusBarAbsorb:SetPoint("LEFT", frame.statusBar:GetStatusBarTexture(), "RIGHT")
    frame.statusBarAbsorb:SetScale(1/borderDetails.lowerScale * details.scale)
    frame.statusBarAbsorb:GetStatusBarTexture():RemoveMaskTexture(frame.mask)

    frame.statusBarAbsorb:GetStatusBarTexture():AddMaskTexture(frame.mask)

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
    ApplyAnchor(frame, frame.details.anchor)
  end

  function frame:ApplySize()
    SizeBar(frame, frame.details)
    local borderDetails = addonTable.Assets.BarBordersSliced[frame.details.border.asset]
    frame.statusBarAbsorb:SetSize(frame.rawWidth * borderDetails.lowerScale, frame.rawHeight * borderDetails.lowerScale)
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

  frame.cannotInterruptStatusTexture = frame.statusBar:CreateTexture()
  frame.cannotInterruptStatusTexture:SetDrawLayer("ARTWORK")
  frame.cannotInterruptReverseStatusTexture = frame.statusBar:CreateTexture()
  frame.cannotInterruptReverseStatusTexture:SetPoint("LEFT", frame)
  frame.cannotInterruptReverseStatusTexture:SetDrawLayer("ARTWORK")

  frame.marker = frame.statusBar:CreateTexture()
  frame.marker:SetSnapToPixelGrid(false)

  frame.cannotInterruptMarker = frame.statusBar:CreateTexture()
  frame.cannotInterruptMarker:SetSnapToPixelGrid(false)

  local borderHolder = CreateFrame("Frame", nil, frame)
  borderHolder:SetFlattensRenderLayers(true)
  frame.border = borderHolder:CreateTexture()
  frame.border:SetDrawLayer("OVERLAY")
  frame.border:SetPoint("CENTER", frame)

  function frame:SetReverseFill(value)
    if value then
      if addonTable.Constants.IsMidnight then
        frame.statusBar:SetFillStyle(Enum.StatusBarFillStyle.Reverse)
      else
        frame.statusBar:SetFillStyle("REVERSE")
      end
      frame.marker:SetPoint("CENTER", frame.reverseStatusTexture, "RIGHT")
      frame.cannotInterruptMarker:SetPoint("CENTER", frame.cannotInterruptReverseStatusTexture, "RIGHT")
      self.statusBar:GetStatusBarTexture():SetColorTexture(1, 1, 1, 0)
      self.cannotInterruptStatusTexture:Hide()
      self.reverseStatusTexture:Show()
      self.cannotInterruptReverseStatusTexture:Show()
    else
      if addonTable.Constants.IsMidnight then
        frame.statusBar:SetFillStyle(Enum.StatusBarFillStyle.Standard)
      else
        frame.statusBar:SetFillStyle("STANDARD")
      end
      frame.marker:SetPoint("CENTER", frame.statusBar:GetStatusBarTexture(), "RIGHT")
      frame.cannotInterruptMarker:SetPoint("CENTER", frame.statusBar:GetStatusBarTexture(), "RIGHT")
      self.statusBar:SetStatusBarTexture(addonTable.Assets.BarBackgrounds[frame.details.foreground.asset].file)
      self.cannotInterruptStatusTexture:Show()
      self.reverseStatusTexture:Hide()
      self.cannotInterruptReverseStatusTexture:Hide()
    end
  end

  function frame:SetCannotInterrupt(notInterruptible)
    if self.SetAlphaFromBoolean then
      self.background:SetAlphaFromBoolean(notInterruptible, 0, 1)
      self.marker:SetAlphaFromBoolean(notInterruptible, 0, 1)
      self.statusBar:GetStatusBarTexture():SetAlphaFromBoolean(notInterruptible, 0, 1)
      self.reverseStatusTexture:SetAlphaFromBoolean(notInterruptible, 0, 1)
      self.cannotInterruptStatusTexture:SetAlphaFromBoolean(notInterruptible)
      self.cannotInterruptReverseStatusTexture:SetAlphaFromBoolean(notInterruptible)
      self.cannotInterruptMarker:SetAlphaFromBoolean(notInterruptible)
      self.cannotInterruptBackground:SetAlphaFromBoolean(notInterruptible)
    else
      self.background:SetAlpha(notInterruptible and 0 or 1)
      self.statusBar:GetStatusBarTexture():SetAlpha(notInterruptible and 0 or 1)
      self.marker:SetAlpha(notInterruptible and 0 or 1)
      self.reverseStatusTexture:SetAlpha(notInterruptible and 0 or 1)
      self.cannotInterruptStatusTexture:SetAlpha(notInterruptible and 1 or 0)
      self.cannotInterruptReverseStatusTexture:SetAlpha(notInterruptible and 1 or 0)
      self.cannotInterruptMarker:SetAlpha(notInterruptible and 1 or 0)
      self.cannotInterruptBackground:SetAlpha(notInterruptible and 1 or 0)
    end
  end

  frame.mask = frame:CreateMaskTexture()
  frame.mask:SetPoint("CENTER")

  frame.background = frame:CreateTexture()
  frame.background:SetPoint("CENTER")
  frame.background:SetDrawLayer("BACKGROUND")

  frame.cannotInterruptBackground = frame:CreateTexture()
  frame.cannotInterruptBackground:SetPoint("CENTER")
  frame.cannotInterruptBackground:SetDrawLayer("BACKGROUND")

  function frame:Init(details)
    InitBar(frame, details)

    local borderDetails = addonTable.Assets.BarBordersSliced[details.border.asset]

    frame.statusBar:SetFrameLevel(frame:GetFrameLevel() + 2)
    borderHolder:SetFrameLevel(frame:GetFrameLevel() + 4)

    local foregroundDetails = addonTable.Assets.BarBackgrounds[details.foreground.asset]
    frame.reverseStatusTexture:Hide()
    frame.reverseStatusTexture:SetTexture(foregroundDetails.file)
    frame.reverseStatusTexture:SetPoint("RIGHT", frame.statusBar:GetStatusBarTexture(), "LEFT")
    frame.reverseStatusTexture:SetHorizTile(true)

    frame.cannotInterruptStatusTexture:SetTexture(foregroundDetails.file)
    frame.cannotInterruptStatusTexture:SetAllPoints(frame.statusBar:GetStatusBarTexture())
    frame.cannotInterruptStatusTexture:SetHorizTile(true)
    frame.cannotInterruptStatusTexture:SetVertexColor(details.colors.uninterruptable.r, details.colors.uninterruptable.g, details.colors.uninterruptable.b)

    frame.cannotInterruptReverseStatusTexture:SetTexture(foregroundDetails.file)
    frame.cannotInterruptReverseStatusTexture:SetPoint("RIGHT", frame.statusBar:GetStatusBarTexture(), "LEFT")
    frame.cannotInterruptReverseStatusTexture:SetHorizTile(true)
    frame.cannotInterruptReverseStatusTexture:SetVertexColor(details.colors.uninterruptable.r, details.colors.uninterruptable.g, details.colors.uninterruptable.b)

    if details.marker.asset ~= "none" then
      frame.cannotInterruptMarker:Show()
      local markerDetails = addonTable.Assets.BarPositionHighlights[details.marker.asset]
      frame.cannotInterruptMarker:SetTexture(markerDetails.file)
      frame.cannotInterruptMarker:SetPoint("CENTER", frame.statusBar:GetStatusBarTexture(), "RIGHT")
      frame.cannotInterruptMarker:SetVertexColor(details.colors.uninterruptable.r, details.colors.uninterruptable.g, details.colors.uninterruptable.b)
    else
      frame.cannotInterruptMarker:Hide()
    end

    local backgroundDetails = addonTable.Assets.BarBackgrounds[details.background.asset]
    frame.cannotInterruptBackground:SetTexture(backgroundDetails.file)
    frame.cannotInterruptBackground:SetAllPoints(frame.statusBar)
    local mod = details.background.color
    if details.background.applyColor then
      frame.cannotInterruptBackground:SetVertexColor(mod.r * details.colors.uninterruptable.r, mod.g * details.colors.uninterruptable.g, mod.b * details.colors.uninterruptable.b, mod.a)
    else
      frame.cannotInterruptBackground:SetVertexColor(mod.r, mod.g, mod.b, mod.a)
    end

    frame.reverseStatusTexture:RemoveMaskTexture(frame.mask)
    frame.cannotInterruptStatusTexture:RemoveMaskTexture(frame.mask)
    frame.cannotInterruptReverseStatusTexture:RemoveMaskTexture(frame.mask)
    frame.cannotInterruptMarker:RemoveMaskTexture(frame.mask)
    frame.cannotInterruptBackground:RemoveMaskTexture(frame.mask)

    local maskInfo = addonTable.Assets.BarMasks[details.border.asset]
    if maskInfo then
      frame.reverseStatusTexture:AddMaskTexture(frame.mask)
      frame.cannotInterruptStatusTexture:AddMaskTexture(frame.mask)
      frame.cannotInterruptReverseStatusTexture:AddMaskTexture(frame.mask)
      frame.cannotInterruptMarker:AddMaskTexture(frame.mask)
      frame.cannotInterruptBackground:AddMaskTexture(frame.mask)
    end

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
    ApplyAnchor(frame, frame.details.anchor)
  end

  function frame:ApplySize()
    local details = frame.details
    SizeBar(frame, details)
    local borderDetails = addonTable.Assets.BarBordersSliced[details.border.asset]
    frame.reverseStatusTexture:SetHeight(frame.rawHeight * borderDetails.lowerScale)
    frame.cannotInterruptReverseStatusTexture:SetHeight(frame.rawHeight * borderDetails.lowerScale)

    if details.marker.asset ~= "none" then
      local markerDetails = addonTable.Assets.BarPositionHighlights[details.marker.asset]
      PixelUtil.SetSize(frame.cannotInterruptMarker, markerDetails.width * details.scale, frame.rawHeight * borderDetails.lowerScale)
    end
  end

  return frame
end

function addonTable.Display.GetPower(frame, parent)
  frame = frame or CreateFrame("Frame", nil, parent or UIParent)

  frame.background = CreateFrame("StatusBar", nil, frame)
  frame.background:SetAllPoints()
  if addonTable.Constants.IsMidnight then
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
    local highlightDetails = addonTable.Assets.Highlights[details.asset]
    frame.details = details

    frame.highlight:SetTexture(highlightDetails.file)
    frame.highlight:SetVertexColor(details.color.r, details.color.g, details.color.b, details.color.a)
    frame.highlight:SetScale(details.scale)

    if highlightDetails.mode == addonTable.Assets.RenderMode.Sliced then
      frame.highlight:SetScale(1/highlightDetails.lowerScale * details.scale)
      frame.highlight:SetTextureSliceMargins(highlightDetails.width * highlightDetails.margin, highlightDetails.height * highlightDetails.margin, highlightDetails.width * highlightDetails.margin, highlightDetails.height * highlightDetails.margin)
    elseif highlightDetails.mode == addonTable.Assets.RenderMode.Fixed then
      frame.highlight:ClearTextureSlice()
    elseif highlightDetails.mode == addonTable.Assets.RenderMode.Stretch then
      frame.highlight:ClearTextureSlice()
    end

    if details.kind == "target" then
      Mixin(frame, addonTable.Display.TargetHighlightMixin)
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
    local highlightDetails = addonTable.Assets.Highlights[details.asset]
    if highlightDetails.mode == addonTable.Assets.RenderMode.Sliced then
      local width, height = details.width * addonTable.Assets.BarBordersSize.width, details.height * addonTable.Assets.BarBordersSize.height
      PixelUtil.SetSize(frame, width * details.scale, height * details.scale)
      PixelUtil.SetSize(frame.highlight, (width + highlightDetails.extra / 2) * highlightDetails.lowerScale, (height + highlightDetails.extra / 2) * highlightDetails.lowerScale)
    elseif highlightDetails.mode == addonTable.Assets.RenderMode.Fixed then
      PixelUtil.SetSize(frame, highlightDetails.width * details.scale, highlightDetails.height * details.scale)
      PixelUtil.SetSize(frame.highlight, highlightDetails.width, highlightDetails.height)
    elseif highlightDetails.mode == addonTable.Assets.RenderMode.Stretch then
      PixelUtil.SetSize(frame, highlightDetails.width * details.width * details.scale, highlightDetails.height * details.height * details.scale)
      PixelUtil.SetSize(frame.highlight, highlightDetails.width * details.width, highlightDetails.height * details.height)
    end
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

    if details.widthLimit then
      frame.text:SetWidth(details.widthLimit)
    else
      frame.text:SetWidth(0)
    end

    frame.text:SetJustifyV("BOTTOM")
    if details.align ~= frame.text:GetJustifyH() then
      frame.text:SetText(" ")
    end
    frame.text:SetJustifyH(details.align)
    frame.text:SetTextScale(details.scale * 0.85)

    if details.kind == "health" then
      Mixin(frame, addonTable.Display.HealthTextMixin)
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
    elseif details.kind == "castTimeLeft" then
      Mixin(frame, addonTable.Display.CastTimeLeftTextMixin)
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
  markers = CreateFramePool("Frame", UIParent, nil, nil, false, addonTable.Display.GetMarker),
}

local editorPools = {
  healthBars = CreateFramePool("Frame", UIParent, "PlatynatorPropagateMouseTemplate", nil, false, addonTable.Display.GetHealthBar),
  castBars = CreateFramePool("Frame", UIParent, "PlatynatorPropagateMouseTemplate", nil, false, addonTable.Display.GetCastBar),
  texts = CreateFramePool("Frame", UIParent, "PlatynatorPropagateMouseTemplate", nil, false, addonTable.Display.GetText),
  powers = CreateFramePool("Frame", UIParent, "PlatynatorPropagateMouseTemplate", nil, false, addonTable.Display.GetPower),
  highlights = CreateFramePool("Frame", UIParent, "PlatynatorPropagateMouseTemplate", nil, false, addonTable.Display.GetHighlight),
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
    local w = pools.highlights:Acquire()
    poolType[w] = "highlights"
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
