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
    addonTable.Cache:RegisterCallback(self.unit, "cast", function(state)
      if state.interrupted then
        self:ApplyInterrupt()
      elseif state.cast[3] or state.channel[3] then
        self:ApplyCasting(state.cast[3] or state.channel[3])
      else
        self:ClearCast()
      end
    end)

    local state = addonTable.Cache:Get(self.unit, "cast")
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
  self:Show()
end

function addonTable.Display.CastIconMarkerMixin:ClearCast()
  self:Hide()
end

function addonTable.Display.CastIconMarkerMixin:ApplyCasting(texture)
  self.marker:SetTexture(texture)
  self:Show()
end
