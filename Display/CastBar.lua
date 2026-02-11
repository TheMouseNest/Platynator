---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.CastBarMixin = {}

local ConvertColor = addonTable.Display.Utilities.ConvertColor

local GetInterruptSpell = addonTable.Display.Utilities.GetInterruptSpell

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

    if self.showInterruptMarker then
      self:RegisterEvent("SPELL_UPDATE_USABLE")
    end

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
    if self.timer then
      self.timer:Cancel()
      self.timer = nil
    end
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
  elseif eventName == "SPELL_UPDATE_USABLE" and self.showInterruptMarker then
    self:RefreshInterruptMarker()
  elseif eventName:match("^UNIT_SPELL") then
    self:ApplyCasting()
  end

  if self:IsShown() then
    self:ColorEventHandler(eventName)
  end
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

function addonTable.Display.CastBarMixin:ClearCast()
  if not self.interrupted then
    if self.timer then
      self.timer:Cancel()
      self.timer = nil
    end
    self:Hide()
  end
  self.isChanneled = nil
  self.notInterruptible = nil
  self.uninterruptibleCheck = nil
end

if UnitCastingDuration then
  function addonTable.Display.CastBarMixin:ApplyCasting()
    self.isChanneled = false
    local castDuration = UnitCastingDuration(self.unit)
    if not castDuration then
      castDuration = UnitChannelDuration(self.unit)
      self.isChanneled = true
    end
    if castDuration ~= nil then
      local notInterruptible, _
      if self.isChanneled then
        _, _, _, _, _, _, notInterruptible, _ = UnitChannelInfo(self.unit)
      else
        _, _, _, _, _, _, _, notInterruptible, _ = UnitCastingInfo(self.unit)
      end

      self.interrupted = nil

      if self.timer then
        self.timer:Cancel()
        self.timer = nil
      end

      self:SetReverseFill(self.isChanneled)
      self:Show()

      self.statusBar:SetTimerDuration(castDuration)
      local spellID
      if self.showInterruptMarker then
        spellID = GetInterruptSpell()
      end
      self.interruptMarker:SetShown(spellID ~= nil)
      self.interruptPositioner:SetShown(spellID ~= nil)
      if spellID then
        local interruptDuration = C_Spell.GetSpellCooldownDuration(spellID)
        self.interruptPositioner:SetMinMaxValues(0, castDuration:GetTotalDuration())
        self.interruptMarker:SetMinMaxValues(0, castDuration:GetTotalDuration())
        self.uninterruptibleCheck = C_CurveUtil.EvaluateColorValueFromBoolean(notInterruptible, 0, 1)
        self.interruptPositioner:SetValue(castDuration:GetElapsedDuration())
        self.interruptMarker:SetValue(interruptDuration:GetRemainingDuration())
        self:RefreshInterruptMarker()
        self.timer = C_Timer.NewTicker(0.1, function()
          self:RefreshInterruptMarker()
        end)
      else
        self.isChanneled = nil
      end
    else
      self:ClearCast()
    end
  end

  function addonTable.Display.CastBarMixin:RefreshInterruptMarker()
    if self.isChanneled == nil then
      return
    end
    local spellID = GetInterruptSpell()
    if spellID then
      local interruptDuration = C_Spell.GetSpellCooldownDuration(spellID)
      self.uninterruptibleCheck = C_CurveUtil.EvaluateColorValueFromBoolean(interruptDuration:IsZero(), 0, self.uninterruptibleCheck)
      self.interruptMarker:SetAlpha(self.uninterruptibleCheck)
    end
  end
else
  function addonTable.Display.CastBarMixin:ApplyCasting()
    local name, text, texture, startTime, endTime, _, _, notInterruptible, spellID = UnitCastingInfo(self.unit)
    self.isChanneled = false

    if name == nil then
      name, text, texture, startTime, endTime, _, notInterruptible, spellID = UnitChannelInfo(self.unit)
      self.isChanneled = true
    end

    if name ~= nil then
      self.interrupted = nil
      self.notInterruptible = notInterruptible

      self:SetReverseFill(self.isChanneled)
      self:Show()

      if self.timer then
        self.timer:Cancel()
        self.timer = nil
      end

      self.statusBar:SetMinMaxValues(0, (endTime - startTime) / 1000)
      self.statusBar:SetValue(GetTime() - startTime / 1000)

      local spellID
      if self.showInterruptMarker and not notInterruptible then
        spellID = GetInterruptSpell()
      end
      self.interruptMarker:SetShown(spellID ~= nil)
      self.interruptPositioner:SetShown(spellID ~= nil)
      local endTime
      if spellID then
        self.interruptPositioner:SetMinMaxValues(self.statusBar:GetMinMaxValues())
        self.interruptMarker:SetMinMaxValues(self.statusBar:GetMinMaxValues())
        local info = C_Spell.GetSpellCooldown(spellID)
        endTime = info.duration + info.startTime
        if endTime > 0 then
          self.interruptMarker:Show()
          self.interruptPositioner:SetValue(self.statusBar:GetValue())
          self.interruptMarker:SetValue(endTime - GetTime())
          self.timer = C_Timer.NewTicker(0.1, function()
            self:RefreshInterruptMarker()
          end)
        else
          endTime = nil
          self.interruptMarker:Hide()
        end
      end

      self.timer = C_Timer.NewTicker(0.005, function()
        self.statusBar:SetValue(GetTime() - startTime / 1000)
      end)
      self.statusBar:SetValue(GetTime() - startTime / 1000)
    else
      self:ClearCast()
    end
  end

  function addonTable.Display.CastBarMixin:RefreshInterruptMarker()
    if self.isChanneled == nil then
      return
    end
    local spellID = GetInterruptSpell()
    if spellID and not self.notInterruptible and self.interruptMarker:IsShown() then
      local info = C_Spell.GetSpellCooldown(spellID)
      endTime = info.duration + info.startTime
      self.interruptMarker:SetShown(endTime > 0)
    end
  end
end
