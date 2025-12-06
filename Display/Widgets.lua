---@class addonTablePlatynator
local addonTable = select(2, ...)

function addonTable.Display.ApplyAnchor(frame, anchor)
  if #anchor == 0 then
    frame:SetPoint("CENTER")
  elseif #anchor == 3 then
    frame:SetPoint(anchor[1], frame:GetParent(), "CENTER", anchor[2], anchor[3])
  elseif #anchor == 2 then
    frame:SetPoint("CENTER", frame:GetParent(), "CENTER", anchor[1], anchor[2])
  elseif #anchor == 1 then
    frame:SetPoint("TOP", frame:GetParent(), "CENTER")
  end
end

local ApplyAnchor = addonTable.Display.ApplyAnchor

local function InitBar(frame, details)
  if frame.Strip then
    frame:Strip()
  end

  ApplyAnchor(frame, details.anchor)

  local foregroundDetails = addonTable.Assets.BarBackgrounds[details.foreground.asset]
  local borderDetails = addonTable.Assets.BarBorders[details.border.asset]
  local borderMaskDetails = addonTable.Assets.BarMasks[details.border.asset]
  local width, height = foregroundDetails.width, foregroundDetails.height
  if borderDetails.mode and borderDetails.mode ~= foregroundDetails.mode then
    if borderMaskDetails and (borderMaskDetails.mode > 0 and borderMaskDetails.mode <= 100) then
      width, height = math.min(borderMaskDetails.width, width), math.min(borderMaskDetails.height, height)
    elseif borderMaskDetails then
      width, height = math.min(borderMaskDetails.width, width), math.max(borderMaskDetails.height, height)
    else
      width, height = math.min(borderDetails.width, width), math.min(borderDetails.height, height)
    end
  end
  frame:SetSize(width * details.scale, height * details.scale)

  frame.statusBar:SetStatusBarTexture(foregroundDetails.file)
  frame.statusBar:GetStatusBarTexture():SetDrawLayer("ARTWORK")
  frame.statusBar:GetStatusBarTexture():SetSnapToPixelGrid(false)
  frame.statusBar:GetStatusBarTexture():SetTexelSnappingBias(0)

  local backgroundDetails = addonTable.Assets.BarBackgrounds[details.background.asset]
  frame.background:SetTexture(backgroundDetails.file)
  frame.background:SetSize(width * details.scale, height * details.scale)
  frame.background:SetVertexColor(details.background.color.r, details.background.color.g, details.background.color.b, details.background.color.a)
  local borderDetails = addonTable.Assets.BarBorders[details.border.asset]
  frame.border:SetTexture(borderDetails.file)
  frame.border:SetSize(borderDetails.width * details.scale, borderDetails.height * details.scale)
  frame.border:SetVertexColor(details.border.color.r, details.border.color.g, details.border.color.b, details.border.color.a)
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
  frame.background:RemoveMaskTexture(frame.mask)
  frame.marker:RemoveMaskTexture(frame.mask)

  local maskInfo = addonTable.Assets.BarMasks[details.border.asset]
  if maskInfo then
    frame.mask:SetBlockingLoadsRequested(true)
    frame.mask:SetTexture(maskInfo.file, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    frame.mask:SetSize(maskInfo.width * details.scale, maskInfo.height * details.scale)
    frame.mask:SetSnapToPixelGrid(false)
    frame.mask:SetTexelSnappingBias(0)

    frame.statusBar:GetStatusBarTexture():AddMaskTexture(frame.mask)
    frame.background:AddMaskTexture(frame.mask)
    frame.marker:AddMaskTexture(frame.mask)
  end

  frame.details = details

  frame.marker:SetTexelSnappingBias(0)
  frame.marker:SetDrawLayer("ARTWORK", 2)
  frame.border:SetSnapToPixelGrid(false)
  frame.border:SetTexelSnappingBias(0)
  frame.background:SetSnapToPixelGrid(false)
  frame.background:SetTexelSnappingBias(0)
end

function addonTable.Display.GetHealthBar(frame, parent)
  frame = frame or CreateFrame("Frame", nil, parent or UIParent)

  frame.statusBarAbsorb = CreateFrame("StatusBar", nil, frame)
  frame.statusBarAbsorb:SetClipsChildren(true)

  frame.statusBar = CreateFrame("StatusBar", nil, frame)
  frame.statusBar:SetAllPoints()
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

    frame.statusBarAbsorb:SetFrameLevel(frame:GetFrameLevel() + 1)
    frame.statusBar:SetFrameLevel(frame:GetFrameLevel() + 2)
    borderHolder:SetFrameLevel(frame:GetFrameLevel() + 4)

    frame.statusBarAbsorb:SetStatusBarTexture(addonTable.Assets.BarBackgrounds[details.absorb.asset].file)
    frame.statusBarAbsorb:GetStatusBarTexture():SetVertexColor(details.absorb.color.r, details.absorb.color.g, details.absorb.color.b, details.absorb.color.a)
    frame.statusBarAbsorb:SetPoint("LEFT", frame.statusBar:GetStatusBarTexture(), "RIGHT")
    frame.statusBarAbsorb:SetHeight(frame:GetHeight())
    frame.statusBarAbsorb:SetWidth(frame:GetWidth())
    frame.statusBarAbsorb:GetStatusBarTexture():RemoveMaskTexture(frame.mask)
    frame.statusBarAbsorb:GetStatusBarTexture():SetSnapToPixelGrid(false)
    frame.statusBarAbsorb:GetStatusBarTexture():SetTexelSnappingBias(0)

    local maskInfo = addonTable.Assets.BarMasks[details.border.asset]
    if maskInfo then
      frame.statusBarAbsorb:GetStatusBarTexture():AddMaskTexture(frame.mask)
    end

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

  return frame
end

function addonTable.Display.GetCastBar(frame, parent)
  frame = frame or CreateFrame("Frame", nil, parent or UIParent)

  frame.statusBar = CreateFrame("StatusBar", nil, frame)
  frame.statusBar:SetAllPoints()
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

    frame.statusBar:SetFrameLevel(frame:GetFrameLevel() + 2)
    borderHolder:SetFrameLevel(frame:GetFrameLevel() + 4)

    local foregroundDetails = addonTable.Assets.BarBackgrounds[details.foreground.asset]
    frame.reverseStatusTexture:Hide()
    frame.reverseStatusTexture:SetTexture(foregroundDetails.file)
    frame.reverseStatusTexture:SetHeight(foregroundDetails.height)
    frame.reverseStatusTexture:SetPoint("RIGHT", frame.statusBar:GetStatusBarTexture(), "LEFT")
    frame.reverseStatusTexture:SetHorizTile(true)

    frame.cannotInterruptStatusTexture:SetTexture(foregroundDetails.file)
    frame.cannotInterruptStatusTexture:SetHeight(foregroundDetails.height)
    frame.cannotInterruptStatusTexture:SetAllPoints(frame.statusBar:GetStatusBarTexture())
    frame.cannotInterruptStatusTexture:SetHorizTile(true)
    frame.cannotInterruptStatusTexture:SetVertexColor(details.colors.uninterruptable.r, details.colors.uninterruptable.g, details.colors.uninterruptable.b)

    frame.cannotInterruptReverseStatusTexture:SetScale(details.scale)
    frame.cannotInterruptReverseStatusTexture:SetTexture(foregroundDetails.file)
    frame.cannotInterruptReverseStatusTexture:SetHeight(foregroundDetails.height)
    frame.cannotInterruptReverseStatusTexture:SetPoint("RIGHT", frame.statusBar:GetStatusBarTexture(), "LEFT")
    frame.cannotInterruptReverseStatusTexture:SetHorizTile(true)
    frame.cannotInterruptReverseStatusTexture:SetVertexColor(details.colors.uninterruptable.r, details.colors.uninterruptable.g, details.colors.uninterruptable.b)

    if details.marker.asset ~= "none" then
      frame.cannotInterruptMarker:Show()
      local markerDetails = addonTable.Assets.BarPositionHighlights[details.marker.asset]
      frame.cannotInterruptMarker:SetTexture(markerDetails.file)
      frame.cannotInterruptMarker:SetSize(markerDetails.width * details.scale, frame:GetHeight())
      frame.cannotInterruptMarker:SetPoint("CENTER", frame.statusBar:GetStatusBarTexture(), "RIGHT")
      frame.cannotInterruptMarker:SetVertexColor(details.colors.uninterruptable.r, details.colors.uninterruptable.g, details.colors.uninterruptable.b)
    else
      frame.cannotInterruptMarker:Hide()
    end

    local backgroundDetails = addonTable.Assets.BarBackgrounds[details.background.asset]
    frame.cannotInterruptBackground:SetTexture(backgroundDetails.file)
    frame.cannotInterruptBackground:SetSize(frame:GetSize())

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

    frame.reverseStatusTexture:SetSnapToPixelGrid(false)
    frame.reverseStatusTexture:SetTexelSnappingBias(0)
    frame.cannotInterruptStatusTexture:SetSnapToPixelGrid(false)
    frame.cannotInterruptStatusTexture:SetTexelSnappingBias(0)
    frame.cannotInterruptReverseStatusTexture:SetSnapToPixelGrid(false)
    frame.cannotInterruptReverseStatusTexture:SetTexelSnappingBias(0)
    frame.cannotInterruptMarker:SetSnapToPixelGrid(false)
    frame.cannotInterruptMarker:SetTexelSnappingBias(0)
    frame.cannotInterruptBackground:SetSnapToPixelGrid(false)
    frame.cannotInterruptBackground:SetTexelSnappingBias(0)

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
    frame.highlight:SetVertexColor(details.color.r, details.color.g, details.color.b, details.color.a)
    frame:SetSize(highlightDetails.width * details.scale, highlightDetails.height * details.scale)

    frame.highlight:SetSnapToPixelGrid(false)
    frame.highlight:SetTexelSnappingBias(0)

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

  return frame
end

function addonTable.Display.GetText(frame, parent)
  frame = frame or CreateFrame("Frame", nil, parent or UIParent)

  frame.text = frame:CreateFontString(nil, nil, "GameFontNormal")
  frame.text:SetPoint("CENTER")
  frame.text:SetText(" ")
  hooksecurefunc(frame.text, "SetText", function(_, value)
    if addonTable.Constants.IsMidnight and issecretvalue(frame.text:GetStringHeight()) then
      frame:SetSize(1, 1)
      return
    end
    frame:SetSize(frame.text:GetSize())
  end)
  frame:SetSize(1, 1)

  function frame:Init(details)
    if frame.Strip then
      frame:Strip()
    end

    frame.details = details

    ApplyAnchor(frame, details.anchor)
    frame.text:SetFontObject(addonTable.CurrentFont)
    frame.text:SetParent(frame)
    frame.text:ClearAllPoints()
    frame.text:SetPoint(details.anchor[1] or "CENTER")
    frame.text:SetTextColor(details.color.r, details.color.g, details.color.b)
    frame.text:SetWordWrap(not details.truncate)
    frame.text:SetNonSpaceWrap(false)
    frame.text:SetSpacing(0)

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
  healthBars = CreateFramePool("Frame", UIParent, nil, nil, false, addonTable.Display.GetHealthBar),
  castBars = CreateFramePool("Frame", UIParent, nil, nil, false, addonTable.Display.GetCastBar),
  texts = CreateFramePool("Frame", UIParent, nil, nil, false, addonTable.Display.GetText),
  powers = CreateFramePool("Frame", UIParent, nil, nil, false, addonTable.Display.GetPower),
  highlights = CreateFramePool("Frame", UIParent, nil, nil, false, addonTable.Display.GetHighlight),
  markers = CreateFramePool("Frame", UIParent, nil, nil, false, addonTable.Display.GetMarker),
}

local editorPools = {
  healthBars = CreateFramePool("Frame", UIParent, nil, nil, false, addonTable.Display.GetHealthBar),
  castBars = CreateFramePool("Frame", UIParent, nil, nil, false, addonTable.Display.GetCastBar),
  texts = CreateFramePool("Frame", UIParent, nil, nil, false, addonTable.Display.GetText),
  powers = CreateFramePool("Frame", UIParent, nil, nil, false, addonTable.Display.GetPower),
  highlights = CreateFramePool("Frame", UIParent, nil, nil, false, addonTable.Display.GetHighlight),
  markers = CreateFramePool("Frame", UIParent, nil, nil, false, addonTable.Display.GetMarker),
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
    w:Show()
    w:SetFrameStrata("MEDIUM")
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
