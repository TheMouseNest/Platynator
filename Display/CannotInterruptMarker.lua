---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.CannotInterruptMarkerMixin = {}

function addonTable.Display.CannotInterruptMarkerMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    addonTable.Display.Cache:RegisterCallback(self.unit, "cast", function(state)
      if state.cast[1] == nil and state.channel[1] == nil then
        self:Hide()
      else
        self:ApplyCasting(state)
      end
    end)

    self:ApplyCasting(addonTable.Display.Cache:Get(self.unit, "cast"))
  else
    self:Strip()
  end
end

function addonTable.Display.CannotInterruptMarkerMixin:Strip()
  self.marker:SetAlpha(1)
end

function addonTable.Display.CannotInterruptMarkerMixin:ApplyCasting(state)
  local notInterruptible = state.cast[8]

  if notInterruptible == nil then
    notInterruptible = state.channel[7]
  end

  if notInterruptible ~= nil then
    if self.marker.SetAlphaFromBoolean then
      self:Show()
      self.marker:SetAlphaFromBoolean(notInterruptible)
    else
      self:SetShown(notInterruptible)
    end
  else
    self:Hide()
  end
end
