---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.CastTimeLeftTextMixin = {}

local formatter

local exceedsLimit = ">30"

if C_StringUtil and C_StringUtil.CreateSecondsFormatter then
  formatter = C_StringUtil.CreateNumericRuleFormatter()
  formatter:SetBreakpoints({
    {
      threshold = 0,
      step = 0.1,
      format = "%.1f",
    },
    {
      threshold = 10,
      step = 1,
      format = "%d",
    },
    {
      threshold = 30,
      step = 1,
      format = exceedsLimit,
    },
  })
end

local function ClassicFormatter(duration)
  if duration < 10 then
    return string.format("%.1f", duration)
  elseif duration < 30 then
    return string.format("%d", duration)
  else
    return exceedsLimit
  end
end

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
      self.text:SetText(self.duration:FormatRemainingDuration(formatter))
      self.timer = C_Timer.NewTicker(0.005, function()
        self.text:SetText(self.duration:FormatRemainingDuration(formatter))
      end)
    else
      self.endTime = endTime / 1000
      self.text:SetText(ClassicFormatter(self.endTime - GetTime()))
      self.timer = C_Timer.NewTicker(0.005, function()
        self.text:SetText(ClassicFormatter(self.endTime - GetTime()))
      end)
    end
  else
    self:Hide()
  end
end
