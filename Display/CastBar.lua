---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.CastBarMixin = {}
function addonTable.Display.CastBarMixin:OnLoad()
  self:SetScript("OnEvent", self.OnEvent)

  local castStyle = addonTable.style.castBar

  self.castBar = CreateFrame("StatusBar", nil, self)
  local castBar = self.castBar
  castBar:SetStatusBarTexture(addonTable.style.castBar.foreground)
  castBar:SetPoint("CENTER")
  castBar:SetSize(castStyle.width*castStyle.scale, castStyle.height*castStyle.scale)
  castBar:SetClipsChildren(true)

  if addonTable.style.castBar.marker and addonTable.style.castBar.marker.texture then
    local castMarker = self.castBar:CreateTexture()
    castMarker:SetTexture(addonTable.style.castBar.marker.texture)
    castMarker:SetPoint("RIGHT", castBar:GetStatusBarTexture(), "RIGHT", addonTable.style.castBar.marker.width * addonTable.style.castBar.scale / 2, 0)
    castMarker:SetSize(addonTable.style.castBar.marker.width * addonTable.style.castBar.scale, castBar:GetHeight())
    castMarker:SetDrawLayer("OVERLAY", 1)
    castBar.marker = castMarker
  end

  self.border = castBar:CreateTexture()
  self.border:SetTexture(addonTable.style.castBar.border)
  self.border:SetSize(addonTable.style.castBar.width*addonTable.style.castBar.scale, addonTable.style.castBar.height*addonTable.style.castBar.scale)
  self.border:SetPoint("CENTER")
  self.border:SetDrawLayer("OVERLAY", 2)
  self.background = castBar:CreateTexture()
  self.background:SetTexture(addonTable.style.castBar.background)
  self.background:SetSize(addonTable.style.castBar.width*addonTable.style.castBar.scale, addonTable.style.castBar.height*addonTable.style.castBar.scale)
  self.background:SetPoint("CENTER")
  self.background:SetDrawLayer("BACKGROUND", -7)
  self.background:SetAlpha(addonTable.style.castBar.backgroundAlpha)

  self:SetSize(addonTable.style.castBar.width*addonTable.style.castBar.scale, addonTable.style.castBar.height*addonTable.style.castBar.scale)
end

function addonTable.Display.CastBarMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self:RegisterUnitEvent("UNIT_SPELLCAST_START", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", self.unit)

    self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", self.unit)

    self:ApplyCasting()
  else
    self:UnregisterAllEvents()
    self:SetScript("OnUpdate", nil)
  end
end

function addonTable.Display.CastBarMixin:OnEvent(eventName, ...)
  self:ApplyCasting()
end

function addonTable.Display.CastBarMixin:ApplyColor()
  local color = addonTable.style.castBar.colors.normal
  local nameplate = C_NamePlate.GetNamePlateForUnit(self.unit, issecure())
  if nameplate and nameplate.UnitFrame then
    if nameplate.UnitFrame.castBar.barType == "uninterruptable" then
      color = addonTable.style.castBar.colors.uninterruptable
    end
  end
  self.castBar:GetStatusBarTexture():SetVertexColor(color.r, color.g, color.b)
  if self.castBar.marker then
    self.castBar.marker:SetVertexColor(color.r, color.g, color.b)
  end
  if addonTable.style.castBar.colorBackground then
    self.background:SetVertexColor(color.r, color.g, color.b)
  end
end

function addonTable.Display.CastBarMixin:ApplyCasting()
  local name, text, texture, startTime, endTime, _, _, _, _ = UnitCastingInfo(self.unit)

  if type(startTime) ~= "nil" and type(endTime) ~= "nil" then
    self:Show()
    self.castBar:SetMinMaxValues(startTime, endTime)
    self:SetScript("OnUpdate", function()
      self.castBar:SetValue(GetTimePreciseSec() * 1000)
    end)
    self:ApplyColor()
    C_Timer.After(0, function()
      if self.unit then
        self:ApplyColor()
      end
    end)
    self.castBar:SetValue(GetTimePreciseSec())
  else
    self:SetScript("OnUpdate", nil)
    self:Hide()
  end
end
