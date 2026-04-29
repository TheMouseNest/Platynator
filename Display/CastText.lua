---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.CastTextMixin = {}

function addonTable.Display.CastTextMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self.interrupted = nil

    addonTable.Display.Cache:RegisterCallback(self.unit, "cast", function(state)
      if state.interrupted then
        self:ApplyInterrupt()
      elseif state.cast[1] == nil and state.channel[1] == nil then
        self:ClearCast()
      else
        self:ApplyCasting(state)
      end
    end)

    self:ApplyCasting(addonTable.Display.Cache:Get(self.unit, "cast"))
  else
    self:Strip()
  end
end

function addonTable.Display.CastTextMixin:Strip()
  if self.timer then
    self.timer:Cancel()
    self.timer = nil
  end
  self.interrupted = nil
  self:UnregisterAllEvents()
end

function addonTable.Display.CastTextMixin:ApplyInterrupt()
  self.interrupted = true
  self:Show()
  self.text:SetText(addonTable.Locales.INTERRUPTED)
  if self.timer then
    self.timer:Cancel()
  end
  self.timer = C_Timer.NewTimer(addonTable.Constants.CastInterruptedDelay, function()
    if self.interrupted then
      self.interrupted = nil
      self.timer = nil
      self:Hide()
    end
  end)
end

function addonTable.Display.CastTextMixin:ClearCast()
  if not self.interrupted then
    self:Hide()
  end
end

function addonTable.Display.CastTextMixin:ApplyCasting(state)
  local text = state.cast[2]
  if not text then
    text = state.channel[2]
  end

  if text then
    self.interrupted = nil
    self:Show()
    self.text:SetText(text)
  else
    self:ClearCast()
  end
end
