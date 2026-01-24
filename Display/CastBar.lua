---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.CastBarMixin = {}

local ConvertColor = addonTable.Display.Utilities.ConvertColor

function addonTable.Display.CastBarMixin:PostInit()
  if self.details.background.applyColor then -- Apply tint to colours
    local mod = self.details.background.color
    if mod.r ~= 1 or mod.g ~= 1 or mod.b ~= 1 then
      self.modColors = CopyTable(self.details.autoColors)
      for _, s in ipairs(self.modColors) do
        for l, c in pairs(s.colors) do
          s.colors[l] = {r = mod.r * c.r, g = mod.g * c.g, b = mod.b * c.b, a = mod.a}
        end
      end
    end
  end

  self.showInterruptMarker = self.details.interruptMarker.asset ~= "none"
end

function addonTable.Display.CastBarMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self.interrupted = nil
    self:RegisterUnitEvent("UNIT_SPELLCAST_START", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", self.unit)

    self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", self.unit)

    self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", self.unit)

    self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTIBLE", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", self.unit)

    self:ApplyCasting()

    addonTable.Display.RegisterForColorEvents(self, self.details.autoColors)
    self:SetColor(addonTable.Display.GetColor(self.details.autoColors, self.colorState, self.unit))
  else
    self:StripInternal()
  end
end

function addonTable.Display.CastBarMixin:StripInternal()
  self:SetReverseFill(false)
  if self.timer then
    self.timer:Cancel()
    self.timer = nil
  end
  self.interrupted = nil

  self:UnregisterAllEvents()
  addonTable.Display.UnregisterForColorEvents(self)
  self:SetScript("OnUpdate", nil)
end

function addonTable.Display.CastBarMixin:Strip()
  self:StripInternal()
  self.modColors = nil
end

function addonTable.Display.CastBarMixin:OnEvent(eventName, ...)
  if eventName == "UNIT_SPELLCAST_INTERRUPTED" or eventName == "UNIT_SPELLCAST_CHANNEL_STOP" and select(4, ...) ~= nil then
    self.interrupted = true
    self:Show()
    self:SetReverseFill(false)
    self.statusBar:SetMinMaxValues(0, 1)
    self.statusBar:SetValue(1)
    self.timer = C_Timer.NewTimer(0.8, function()
      if self.interrupted then
        self.interrupted = nil
        self:Hide()
      end
    end)
    self:SetScript("OnUpdate", nil)
    self.interruptMarker:Hide()
  elseif eventName == "UNIT_SPELLCAST_DELAYED" or eventName == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
    if self:IsShown() then
      self:ApplyCasting()
    end
  elseif eventName:match("^UNIT_SPELL") then
    self:ApplyCasting()
  end

  self:ColorEventHandler(eventName)
end

function addonTable.Display.CastBarMixin:SetColor(...)
  self.statusBar:GetStatusBarTexture():SetVertexColor(...)
  self.reverseStatusTexture:SetVertexColor(...)
  self.marker:SetVertexColor(...)
  if self.details.background.applyColor then
    local mod = self.details.background.color
    if self.modColors then
      self.background:SetVertexColor(addonTable.Display.GetColor(self.modColors, self.colorState, self.unit))
    else
      local r, g, b = ...
      self.background:SetVertexColor(r, g, b, mod.a)
    end
  end
end

local GetInterruptSpell = addonTable.Display.Utilities.GetInterruptSpell

function addonTable.Display.CastBarMixin:ApplyCasting()
  local name, text, texture, startTime, endTime, _, _, notInterruptible, spellID = UnitCastingInfo(self.unit)
  local isChanneled = false

  if name == nil then
    name, text, texture, startTime, endTime, _, notInterruptible, spellID = UnitChannelInfo(self.unit)
    isChanneled = true
  end

  if name ~= nil then
    self.interrupted = nil

    self:SetReverseFill(isChanneled)
    self:Show()

    if C_Secrets then
      local duration
      if isChanneled then
        duration = UnitChannelDuration(self.unit)
      else
        duration = UnitCastingDuration(self.unit)
      end
      self.statusBar:SetTimerDuration(duration)
      self.interruptMarker:SetMinMaxValues(0, duration:GetTotalDuration())
      local spellID
      if self.showInterruptMarker then
        spellID = GetInterruptSpell()
      end
      self.interruptMarker:SetShown(spellID ~= nil)
      if spellID then
        self:SetScript("OnUpdate", function()
          local duration = C_Spell.GetSpellCooldownDuration(spellID)
          self.interruptMarker:SetValue(duration:GetRemainingDuration())
          self.interruptMarker:SetAlphaFromBoolean(duration:IsZero(), 0, C_CurveUtil.EvaluateColorValueFromBoolean(notInterruptible, 0, 1))
        end)
      end
    else
      self.statusBar:SetMinMaxValues(0, (endTime - startTime) / 1000)
      self.interruptMarker:SetMinMaxValues(self.statusBar:GetMinMaxValues())
      local spellID
      if self.showInterruptMarker and not notInterruptible then
        spellID = GetInterruptSpell()
      end
      self.interruptMarker:SetShown(spellID ~= nil)
      self:SetScript("OnUpdate", function()
        self.statusBar:SetValue(GetTime() - startTime / 1000)
        if spellID then
          local info = C_Spell.GetSpellCooldown(spellID)
          self.interruptMarker:SetValue(info.duration - (GetTime() - info.startTime))
          if info.startTime == 0 then
            self.interruptMarker:Hide()
          end
        end
      end)
      self.statusBar:SetValue(GetTime() - startTime / 1000)
    end
  else
    self:SetScript("OnUpdate", nil)
    if not self.interrupted then
      self:Hide()
    end
  end
end
