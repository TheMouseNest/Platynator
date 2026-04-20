---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.CastTimeLeftTextMixin = {}

function addonTable.Display.CastTimeLeftTextMixin:SetUnit(unit)
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

function addonTable.Display.CastTimeLeftTextMixin:Strip()
  if self.timer then
    self.timer:Cancel()
    self.timer = nil
  end
  self.duration = nil
  self.endTime = nil
  self:UnregisterAllEvents()
end

function addonTable.Display.CastTimeLeftTextMixin:ApplyCasting(state)
  local endTime = state.cast[5]
  local isChanneled = false
  if not endTime then
    endTime = state.channel[5]
    isChanneled = true
  end

  if self.timer then
    self.timer:Cancel()
  end

  if endTime then
    self:Show()
    if UnitChannelDuration then
      if isChanneled then
        self.duration = UnitChannelDuration(self.unit)
      else
        self.duration = UnitCastingDuration(self.unit)
      end
      self.text:SetText(string.format("%.1f", self.duration:GetRemainingDuration()))
      self.timer = C_Timer.NewTicker(0.005, function()
        self.text:SetText(string.format("%.1f", self.duration:GetRemainingDuration()))
      end)
    else
      self.endTime = endTime / 1000
      self.text:SetText(string.format("%.1f", self.endTime - GetTime()))
      self.timer = C_Timer.NewTicker(0.005, function()
        self.text:SetText(string.format("%.1f", self.endTime - GetTime()))
      end)
    end
  else
    self:Hide()
  end
end
