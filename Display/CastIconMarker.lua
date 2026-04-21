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
    self.background:Show()
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
    addonTable.Display.Cache:RegisterCallback(self.unit, "cast", function(state)
      if state.interrupterGUID then
        self:ApplyInterrupt()
      elseif state.cast[3] or state.channel[3] then
        self:ApplyCasting(state.cast[3] or state.channel[3])
      else
        self:ClearCast()
      end
    end)

    local state = addonTable.Display.Cache:Get(self.unit, "cast")
    if state.cast[3] or state.channel[3] then
      self:ApplyCasting(state.cast[3] or state.channel[3])
    else
      self:ClearCast()
    end
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

function addonTable.Display.CastIconMarkerMixin:ApplyInterrupt()
  self.interrupted = true
  self:Show()
  self.timer = C_Timer.NewTimer(addonTable.Constants.CastInterruptedDelay, function()
    if self.interrupted then
      self.interrupted = nil
      self:Hide()
    end
    self.timer = nil
  end)
end

function addonTable.Display.CastIconMarkerMixin:ClearCast()
  if not self.interrupted then
    self:Hide()
  end
end

function addonTable.Display.CastIconMarkerMixin:ApplyCasting(texture)
  if self.timer then
    self.timer:Cancel()
    self.interrupted = nil
    self.timer = nil
  end

  self.marker:SetTexture(texture)
  self:Show()
end
