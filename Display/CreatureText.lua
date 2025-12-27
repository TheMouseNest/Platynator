---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.CreatureTextMixin = {}

function addonTable.Display.CreatureTextMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self:RegisterUnitEvent("UNIT_NAME_UPDATE", self.unit)
    self.text:SetText(addonTable.Config.Get(addonTable.Config.Options.SHOW_TITLES) and UnitPVPName(self.unit) or UnitName(self.unit))

    self:SetColor(addonTable.Display.GetColor(self.details.autoColors, self.unit))
    addonTable.Display.RegisterForColorEvents(self, self.details.autoColors)

    if self.details.showWhenWowDoes then
      self:RegisterUnitEvent("UNIT_HEALTH", self.unit)
      self:SetShown(UnitShouldDisplayName(self.unit))
    end
  else
    addonTable.Display.UnregisterForColorEvents(self)
    self:UnregisterAllEvents()
  end
end

function addonTable.Display.CreatureTextMixin:Strip()
  local c = self.details.color
  self.text:SetTextColor(c.r, c.g, c.b)
  self.ApplyTarget = nil

  addonTable.Display.UnregisterForColorEvents(self)
  self:UnregisterAllEvents()
end

function addonTable.Display.CreatureTextMixin:SetColor(c)
  if not c then
    c = self.details.color
  end
  self.text:SetTextColor(c.r, c.g, c.b)
end

function addonTable.Display.CreatureTextMixin:OnEvent(eventName, ...)
  if eventName == "UNIT_HEALTH" then
    if self.details.showWhenWowDoes then
      self:SetShown(UnitShouldDisplayName(self.unit))
    end
  elseif eventName == "UNIT_NAME_UPDATE" then
    self.text:SetText(addonTable.Config.Get(addonTable.Config.Options.SHOW_TITLES) and UnitPVPName(self.unit) or UnitName(self.unit))
  end

  self:ColorEventHandler(eventName)
end

function addonTable.Display.CreatureTextMixin:ApplyTarget()
  if self.details.showWhenWowDoes then
    self:SetShown(UnitShouldDisplayName(self.unit))
  end
end
