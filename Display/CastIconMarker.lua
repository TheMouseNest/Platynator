---@class addonTablePlatynator
local addonTable = select(2, ...)

local borderPool = CreateTexturePool(UIParent, "BACKGROUND", 0, nil, function(_, tex)
  tex:SetColorTexture(0, 0, 0)
end)

addonTable.Display.CastIconMarkerMixin = {}

function addonTable.Display.CastIconMarkerMixin:PostInit()
  if self.details.square then
    self.background = borderPool:Acquire()
    self.background:SetParent(self)
    self.background:ClearAllPoints()
    self.marker:SetTexCoord(0.1, 0.9, 0.1, 0.9)

    self.PostApplyAnchor = function()
      PixelUtil.SetPoint(self.background, "TOPLEFT", self, "TOPLEFT", -1, 1)
      PixelUtil.SetPoint(self.background, "BOTTOMRIGHT", self, "BOTTOMRIGHT", 1, -1)
    end
  end
end

function addonTable.Display.CastIconMarkerMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self:RegisterUnitEvent("UNIT_SPELLCAST_START", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", self.unit)

    self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", self.unit)

    self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", self.unit)

    self:ApplyCasting()
  else
    self:StripInternal()
  end
end

function addonTable.Display.CastIconMarkerMixin:StripInternal()
  self:UnregisterAllEvents()
  if self.timer then
    self.timer:Cancel()
    self.timer = nil
  end
  self.interrupted = nil
end

function addonTable.Display.CastIconMarkerMixin:Strip()
  self:StripInternal()
  self.marker:SetTexCoord(0, 1, 0, 1)
  if self.background then
    self.background:Hide()
    borderPool:Release(self.background)
    self.background = nil
  end
  self.PostApplyAnchor = nil
  self.PostInit = nil
end

function addonTable.Display.CastIconMarkerMixin:OnEvent(eventName, ...)
  if eventName == "UNIT_SPELLCAST_INTERRUPTED" or eventName == "UNIT_SPELLCAST_CHANNEL_STOP" and select(4, ...) ~= nil then
    self.interrupted = true
    self.marker:Show()
    if self.background then
      self.background:Show()
    end
    self.timer = C_Timer.NewTimer(0.8, function()
      if self.interrupted then
        self.interrupted = nil
        self.marker:Hide()
        if self.background then
          self.background:Hide()
        end
      end
      self.timer = nil
    end)
  else
    self:ApplyCasting()
  end
end

function addonTable.Display.CastIconMarkerMixin:ApplyCasting()
  local _, _, texture = UnitCastingInfo(self.unit)
  if type(texture) == "nil" then
    _, _, texture = UnitChannelInfo(self.unit)
  end

  if type(texture) ~= "nil" then
    if self.timer then
      self.timer:Cancel()
      self.interrupted = nil
      self.timer = nil
    end

    self.marker:SetTexture(texture)
    self.marker:Show()
    if self.background then
      self.background:Show()
    end
  elseif not self.interrupted then
    self.marker:Hide()
    if self.background then
      self.background:Hide()
    end
  end
end
