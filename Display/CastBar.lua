---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.CastBarMixin = {}

function addonTable.Display.CastBarMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self.interrupted = nil
    self:RegisterUnitEvent("UNIT_SPELLCAST_START", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", self.unit)

    self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", self.unit)

    self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", self.unit)

    self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTIBLE", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", self.unit)

    self:ApplyCasting()
  else
    self:Strip()
  end
end

function addonTable.Display.CastBarMixin:Strip()
  self:SetReverseFill(false)
  if self.timer then
    self.timer:Cancel()
    self.timer = nil
  end
  self.interrupted = nil

  self:UnregisterAllEvents()
  self:SetScript("OnUpdate", nil)
end

function addonTable.Display.CastBarMixin:OnEvent(eventName, ...)
  if eventName == "UNIT_SPELLCAST_INTERRUPTED" then
    self.interrupted = true
    self:Show()
    self:SetCannotInterrupt(false)
    self:ApplyColor(self.details.colors.interrupted)
    self.statusBar:SetMinMaxValues(0, 1)
    self.timer = C_Timer.NewTimer(0.8, function()
      if self.interrupted then
        self.interrupted = nil
        self:Hide()
      end
    end)
  elseif eventName == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" or eventName == "UNIT_SPELLCAST_INTERRUPTIBLE" then
    local name, text, texture, startTime, endTime, _, _, notInterruptible, _ = UnitCastingInfo(self.unit)
    local isChanneled = false

    if type(name) == "nil" then
      name, text, texture, startTime, endTime, _, notInterruptible, _ = UnitChannelInfo(self.unit)
      isChanneled = true
    end

    self:SetCannotInterrupt(notInterruptible)
  else
    self:ApplyCasting()
  end
end

function addonTable.Display.CastBarMixin:ApplyColor(color)
  self.statusBar:GetStatusBarTexture():SetVertexColor(color.r, color.g, color.b)
  self.reverseStatusTexture:SetVertexColor(color.r, color.g, color.b)
  self.marker:SetVertexColor(color.r, color.g, color.b)
  if self.details.background.applyColor then
    local mod = self.details.background.color
    self.background:SetVertexColor(mod.r * color.r, mod.r * color.g, mod.r * color.b, mod.a)
  end
end

function addonTable.Display.CastBarMixin:ApplyCasting()
  local name, text, texture, startTime, endTime, _, _, notInterruptible, _ = UnitCastingInfo(self.unit)
  local isChanneled = false

  if type(name) == "nil" then
    name, text, texture, startTime, endTime, _, notInterruptible, _ = UnitChannelInfo(self.unit)
    isChanneled = true
  end

  if type(startTime) ~= "nil" and type(endTime) ~= "nil" then
    self.interrupted = nil

    self:SetReverseFill(isChanneled)
    self:Show()

    if issecretvalue and issecretvalue(startTime) then
      local duration
      if isChanneled then
        duration = UnitChannelDuration(self.unit)
      else
        duration = UnitCastingDuration(self.unit)
      end
      self.statusBar:SetTimerDuration(duration)
    else
      self.statusBar:SetMinMaxValues(0, (endTime - startTime) / 1000)
      self:SetScript("OnUpdate", function()
        self.statusBar:SetValue(GetTime() - startTime / 1000)
      end)
      self.statusBar:SetValue(GetTime() - startTime / 1000)
    end

    if isChanneled then
      self:ApplyColor(self.details.colors.normalChannel)
    else
      self:ApplyColor(self.details.colors.normal)
    end
    self:SetCannotInterrupt(notInterruptible)
  else
    self:SetScript("OnUpdate", nil)
    if not self.interrupted then
      self:Hide()
    end
  end
end
