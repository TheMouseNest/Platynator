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

    self:ApplyCasting()
  else
    self:Strip()
  end
end

function addonTable.Display.CastBarMixin:Strip()
  self:UnregisterAllEvents()
  self:SetScript("OnUpdate", nil)
end

function addonTable.Display.CastBarMixin:OnEvent(eventName, ...)
  self:ApplyCasting()
end

function addonTable.Display.CastBarMixin:ApplyColor()
  local color = self.details.colors.normal
  local nameplate = C_NamePlate.GetNamePlateForUnit(self.unit, issecure())
  if nameplate and nameplate.UnitFrame then
    if nameplate.UnitFrame.castBar.barType == "uninterruptable" then
      color = self.details.colors.uninterruptable
    end
  end
  self.statusBar:GetStatusBarTexture():SetVertexColor(color.r, color.g, color.b)
  if self.marker then
    self.marker:SetVertexColor(color.r, color.g, color.b)
  end
  if self.details.colorBackground then
    self.background:SetVertexColor(color.r, color.g, color.b)
  end
end

function addonTable.Display.CastBarMixin:ApplyCasting()
  local name, text, texture, startTime, endTime, _, _, _, _ = UnitCastingInfo(self.unit)

  if type(startTime) ~= "nil" and type(endTime) ~= "nil" then
    self:Show()
    self.statusBar:SetMinMaxValues(startTime, endTime)
    self:SetScript("OnUpdate", function()
      self.statusBar:SetValue(GetTimePreciseSec() * 1000)
    end)
    self:ApplyColor()
    C_Timer.After(0, function()
      if self.unit then
        self:ApplyColor()
      end
    end)
    self.statusBar:SetValue(GetTimePreciseSec())
  else
    self:SetScript("OnUpdate", nil)
    self:Hide()
  end
end
