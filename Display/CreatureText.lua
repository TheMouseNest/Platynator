---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.CreatureTextMixin = {}

function addonTable.Display.CreatureTextMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self:RegisterUnitEvent("UNIT_NAME_UPDATE", self.unit)
    self.defaultText = UnitName(self.unit)
    self.text:SetText(self.defaultText)

    addonTable.Display.RegisterForColorEvents(self, self.details.autoColors, self.details.color)
    self:SetColor(addonTable.Display.GetColor(self.details.autoColors, self.colorState, self.unit))

    if self.details.showWhenWowDoes then
      self:RegisterUnitEvent("UNIT_HEALTH", self.unit)
      self:SetShown(UnitShouldDisplayName(self.unit))
    end
  else
    addonTable.Display.UnregisterForColorEvents(self)
    self:UnregisterAllEvents()
    self.defaultText = nil
  end
end

function addonTable.Display.CreatureTextMixin:Strip()
  local c = self.details.color
  self.text:SetTextColor(c.r, c.g, c.b)
  self.ApplyTarget = nil
  self.ApplyTextOverride = nil
  self.defaultText = nil

  addonTable.Display.UnregisterForColorEvents(self)
  self:UnregisterAllEvents()
end

function addonTable.Display.CreatureTextMixin:SetColor(r, g, b)
  if not r then
    local c =  self.details.color
    r, g, b = c.r, c.g, c.b
  end
  self.text:SetTextColor(r, g, b)
end

function addonTable.Display.CreatureTextMixin:OnEvent(eventName, ...)
  if eventName == "UNIT_HEALTH" then
    if self.details.showWhenWowDoes then
      self:SetShown(UnitShouldDisplayName(self.unit))
    end
  elseif eventName == "UNIT_NAME_UPDATE" then
    self.defaultText = UnitName(self.unit)
    self.text:SetText(self.defaultText)
  end

  self:ColorEventHandler(eventName)
end

function addonTable.Display.CreatureTextMixin:ApplyTarget()
  if self.details.showWhenWowDoes then
    self:SetShown(UnitIsUnit(self.unit, "target") or UnitShouldDisplayName(self.unit))
  end
end

function addonTable.Display.CreatureTextMixin:ApplyTextOverride()
  local override = addonTable.API.TextOverrides.name[self.unit]
  self.text:SetText(override or self.defaultText)
end
