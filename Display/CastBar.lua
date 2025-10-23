---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.CastBarMixin = {}

function addonTable.Display.CastBarMixin:SetUnit(unit)
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
    self:Strip()
  end
end

function addonTable.Display.CastBarMixin:Strip()
  self:SetReverseFill(false)

  self:UnregisterAllEvents()
  self:SetScript("OnUpdate", nil)
end

function addonTable.Display.CastBarMixin:OnEvent(eventName, ...)
  if eventName == "UNIT_SPELLCAST_INTERRUPTED" then
  else
    self:ApplyCasting()
  end
end

function addonTable.Display.CastBarMixin:ApplyColor(notInterruptible)
  local color = self.details.colors.normal
  local nameplate = C_NamePlate.GetNamePlateForUnit(self.unit, issecure())
  if nameplate and nameplate.UnitFrame and nameplate.UnitFrame.castBar then
    if nameplate.UnitFrame.castBar.barType == "uninterruptable" then
      color = self.details.colors.uninterruptable
    end
  elseif notInterruptible then
    color = self.details.colors.uninterruptable
  end
  self.statusBar:GetStatusBarTexture():SetVertexColor(color.r, color.g, color.b)
  self.reverseStatusTexture:SetVertexColor(color.r, color.g, color.b)
  self.marker:SetVertexColor(color.r, color.g, color.b)
  if self.details.background.applyColor then
    self.background:SetVertexColor(color.r, color.g, color.b)
  end
end

function addonTable.Display.CastBarMixin:ApplyCasting()
  local name, text, texture, startTime, endTime, _, _, notInterruptible, _ = UnitCastingInfo(self.unit)
  local isChanneled = false

  if type(name) == "nil" then
    name, text, texture, startTime, endTime, _, notInterruptible, _ = UnitChannelInfo(self.unit)
    isChanneled = true
  end
  self:SetReverseFill(isChanneled)

  if type(startTime) ~= "nil" and type(endTime) ~= "nil" then
    self:Show()
    if issecretvalue and issecretvalue(startTime) then
      self.statusBar:SetMinMaxValues(startTime, endTime)
      self:SetScript("OnUpdate", function()
        self.statusBar:SetValue(GetTime() * 1000)
      end)
      self.statusBar:SetValue(GetTime() * 1000)
    else
      self.statusBar:SetMinMaxValues(0, (endTime - startTime) / 1000)
      self:SetScript("OnUpdate", function()
        self.statusBar:SetValue(GetTime() - startTime / 1000)
      end)
      self.statusBar:SetValue(GetTime())
    end
    self:ApplyColor(notInterruptible)
    C_Timer.After(0, function()
      if self.unit then
        self:ApplyColor(notInterruptible)
      end
    end)
    self.statusBar:SetValue(GetTime() * 1000)
  else
    self:SetScript("OnUpdate", nil)
    self:Hide()
  end
end
