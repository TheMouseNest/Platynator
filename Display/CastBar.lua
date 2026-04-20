---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.CastBarMixin = {}

local GetInterruptSpell = addonTable.Display.Utilities.GetInterruptSpellPriority

function addonTable.Display.CastBarMixin:PostInit()
  if self.details.background.applyColor then -- Apply tint to colours
    self.modColors = addonTable.Display.Utilities.TintAutoColors(self.details.autoColors, self.details.background.color)
  end

  self.showInterruptMarker = self.details.interruptMarker.asset ~= "none"
end

function addonTable.Display.CastBarMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self.interrupted = nil

    addonTable.Display.Cache:RegisterCallback(self.unit, "cast", function(state)
      if state.interrupterGUID then
        self:ApplyInterrupt()
      elseif state.cast[1] == nil and state.channel[1] == nil then
        self:ClearCast()
      else
        self:ApplyCasting(state)
      end
    end)

    if self.showInterruptMarker then
      self:RegisterEvent("SPELL_UPDATE_USABLE")
    end

    self:ApplyCasting(addonTable.Display.Cache:Get(self.unit, "cast"))

    addonTable.Display.RegisterForColorEvents(self, self.details.autoColors)
    self:SetColor(addonTable.Display.GetColor(self.details.autoColors, self.colorState, self.unit))
  else
    self:StripInternal()
  end
end

function addonTable.Display.CastBarMixin:StripInternal()
  self:RefreshInterruptMarker()
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

function addonTable.Display.CastBarMixin:ApplyInterrupt()
  self.interrupted = true
  self:Show()
  self.statusBar:SetMinMaxValues(0, 1)
  self.statusBar:SetValue(1)
  if self.timer then
    self.timer:Cancel()
    self.timer = nil
  end
  self.timer = C_Timer.NewTimer(addonTable.Constants.CastInterruptedDelay, function()
    if self.interrupted then
      self.interrupted = nil
      self:Hide()
    end
  end)
  self:SetScript("OnUpdate", nil)
  self.interruptMarker:Hide()
end

function addonTable.Display.CastBarMixin:OnEvent(eventName, ...)
  if eventName == "SPELL_UPDATE_USABLE" and self.showInterruptMarker then
    self:RefreshInterruptMarker()
  end

  if self:IsShown() then
    self:ColorEventHandler(eventName)
  end
end

function addonTable.Display.CastBarMixin:SetColor(...)
  self.statusBar:GetStatusBarTexture():SetVertexColor(...)
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
  function addonTable.Display.CastBarMixin:ApplyCasting(state)
    self.isChanneled = state.channel[1] ~= nil
    local isEmpowered = state.channel[9] == true
    local castDuration
    if self.isEmpowered then
      castDuration = UnitEmpoweredChannelDuration(self.unit, true)
    elseif self.isChanneled then
      castDuration = UnitChannelDuration(self.unit)
    else
      castDuration = UnitCastingDuration(self.unit)
    end
    if castDuration ~= nil then
      local notInterruptible
      if self.isChanneled then
        notInterruptible = state.channel[7]
      else
        notInterruptible = state.cast[8]
      end

      self.interrupted = nil

      if self.timer then
        self.timer:Cancel()
        self.timer = nil
      end

      self:Show()

      self.statusBar:SetTimerDuration(castDuration, nil, self.isChanneled and not isEmpowered and Enum.StatusBarTimerDirection.RemainingTime or Enum.StatusBarTimerDirection.ElapsedTime)
      local spellID
      if self.showInterruptMarker then
        spellID = GetInterruptSpell()
      end
      self.interruptMarker:SetShown(spellID ~= nil)
      self.interruptPositioner:SetShown(spellID ~= nil)
      if spellID then
        self:ReverseInterruptMarker(self.isChanneled and not isEmpowered)
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
  function addonTable.Display.CastBarMixin:ApplyCasting(state)
    local name, startTime, endTime, notInterruptible, _
    self.isChanneled = state.channel[1] ~= nil

    if not self.isChanneled then
      name, _, _, startTime, endTime, _, _, notInterruptible = unpack(state.cast)
    else
      name, _, _, startTime, endTime, _, notInterruptible, _ = unpack(state.channel)
    end

    if name ~= nil then
      self.interrupted = nil
      self.notInterruptible = notInterruptible

      self:Show()

      if self.timer then
        self.timer:Cancel()
        self.timer = nil
      end

      local castEnd = (endTime - startTime) / 1000
      self.statusBar:SetMinMaxValues(0, castEnd)
      local castValue = GetTime() - startTime / 1000
      self.statusBar:SetValue(castValue)

      local spellID
      if self.showInterruptMarker and not notInterruptible then
        spellID = GetInterruptSpell()
      end
      self.interruptMarker:SetShown(spellID ~= nil)
      self.interruptPositioner:SetShown(spellID ~= nil)
      if spellID then
        self.interruptPositioner:SetMinMaxValues(0, castEnd)
        self.interruptMarker:SetMinMaxValues(0, castEnd)
        local info = C_Spell.GetSpellCooldown(spellID)
        local interruptEndTime = info.duration + info.startTime
        if interruptEndTime > 0 then
          self:RefreshInterruptMarker()
          self.interruptMarker:Show()
          self.interruptPositioner:SetValue(castValue)
          self.interruptMarker:SetValue(interruptEndTime - GetTime())
          self.timer = C_Timer.NewTicker(0.1, function()
            self:RefreshInterruptMarker()
          end)
        else
          self.interruptMarker:Hide()
        end
      end

      if self.isChanneled then
        self.timer = C_Timer.NewTicker(0.005, function()
          self.statusBar:SetValue(endTime / 1000 - GetTime())
        end)
        self.statusBar:SetValue(endTime / 1000 - GetTime())
      else
        self.timer = C_Timer.NewTicker(0.005, function()
          self.statusBar:SetValue(GetTime() - startTime / 1000)
        end)
        self.statusBar:SetValue(GetTime() - startTime / 1000)
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
    if spellID and not self.notInterruptible and self.interruptMarker:IsShown() then
      local info = C_Spell.GetSpellCooldown(spellID)
      local endTime = info.duration + info.startTime
      self.interruptMarker:SetShown(endTime > 0)
    end
  end
end
