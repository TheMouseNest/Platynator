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
    addonTable.Cache:RegisterCallback(self.unit, "cast", function(state)
      self:ApplyCasting(state)
    end)

    self:ApplyCasting(addonTable.Cache:Get(self.unit, "cast"))
  else
    self:Strip()
  end
end

function addonTable.Display.CastTimeLeftTextMixin:Strip()
  if self.timer then
    self.timer:Cancel()
    self.timer = nil
  end
  self:UnregisterAllEvents()
end


if addonTable.Constants.IsSecretsActive then
  function addonTable.Display.CastTimeLeftTextMixin:ApplyCasting(state)
    if self.timer then
      self.timer:Cancel()
      self.timer = nil
    end

    local duration = state.empoweredDuration or state.channelDuration or state.castDuration

    self:SetShown(duration ~= nil)
    if duration then
      self.text:SetText(duration:FormatRemainingDuration(formatter))
      self.timer = C_Timer.NewTicker(0.05, function()
        self.text:SetText(duration:FormatRemainingDuration(formatter))
      end)
    end
  end
else
  function addonTable.Display.CastTimeLeftTextMixin:ApplyCasting(state)
    if self.timer then
      self.timer:Cancel()
      self.timer = nil
    end

    local endTime = state.cast[5]
    local isChanneled = false
    if not endTime then
      endTime = state.channel[5]
      isChanneled = true
    end

    self:SetShown(endTime ~= nil)
    if endTime then
      local endTime = endTime / 1000
      self.text:SetText(ClassicFormatter(endTime - GetTime()))
      self.timer = C_Timer.NewTicker(0.05, function()
        self.text:SetText(ClassicFormatter(endTime - GetTime()))
      end)
    end
  end
end
