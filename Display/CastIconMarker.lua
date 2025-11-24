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
    self.background:SetPoint("TOPLEFT", -1, 1)
    self.background:SetPoint("BOTTOMRIGHT", 1, -1)
    self.marker:SetTexCoord(0.1, 0.9, 0.1, 0.9)
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
    self:UnregisterAllEvents()
  end
end

function addonTable.Display.CastIconMarkerMixin:Strip()
  self.marker:SetTexCoord(0, 1, 0, 1)
  if self.background then
    self.background:Hide()
    borderPool:Release(self.background)
    self.background = nil
  end
end

function addonTable.Display.CastIconMarkerMixin:OnEvent(eventName, ...)
  self:ApplyCasting()
end

function addonTable.Display.CastIconMarkerMixin:ApplyCasting()
  local _, _, texture = UnitCastingInfo(self.unit)
  if type(texture) == "nil" then
    _, _, texture = UnitChannelInfo(self.unit)
  end

  if type(texture) ~= "nil" then
    self.marker:SetTexture(texture)
    self.marker:Show()
    if self.background then
      self.background:Show()
    end
  else
    self.marker:Hide()
    if self.background then
      self.background:Hide()
    end
  end
end
