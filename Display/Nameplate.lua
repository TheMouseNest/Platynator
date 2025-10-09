---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.NameplateMixin = {}
function addonTable.Display.NameplateMixin:OnLoad()
  self:SetScript("OnEvent", self.OnEvent)

  self.health = addonTable.Utilities.InitFrameWithMixin(self, addonTable.Display.HealthBarMixin)
  self.health:SetPoint("CENTER")
  self.cast = addonTable.Utilities.InitFrameWithMixin(self, addonTable.Display.CastBarMixin)
  self.cast:SetPoint("TOP", self.health, "BOTTOM")
  self.power = addonTable.Utilities.InitFrameWithMixin(self, addonTable.Display.PowerBarMixin)
  self.power:SetPoint("TOP", self.health, "BOTTOM", addonTable.style.power.offset.x, addonTable.style.power.offset.y)
  self.power:SetFrameLevel(math.max(self.health:GetFrameLevel(), self.cast:GetFrameLevel()) + 1)

  self.nameFrame = CreateFrame("Frame", nil, self)
  self.name = self.nameFrame:CreateFontString(nil, nil, "PlatynatorNameplateFont")
  self.name:SetShadowOffset(1, -1)
  self.name:SetWidth(self.health:GetWidth())
  self.name:SetJustifyH("CENTER")
  self.name:SetPoint("BOTTOMLEFT", self.health, "TOPLEFT", 2, 2)

  self.questMarker = self.nameFrame:CreateTexture()
  self.questMarker:SetTexture("Interface/AddOns/Platynator/Assets/quest-marker.png")
  self.questMarker:SetSize(addonTable.style.healthBar.scale * 48 * 0.9, addonTable.style.healthBar.scale * 170 * 0.9)
  self.questMarker:SetPoint("RIGHT", self.health, "LEFT", -2, 0)
  self.questMarker:Hide()

  self.AurasFrame = nil
  self.OldUnitFrame = nil
end

function addonTable.Display.NameplateMixin:Install(nameplate)
  self:SetParent(nameplate)
  self:SetAllPoints()
  nameplate.UnitFrame:SetParent(addonTable.hiddenFrame)
  if addonTable.Constants.IsMidnight then
    nameplate.UnitFrame.HitTestFrame:SetParent(nameplate)
    nameplate.UnitFrame.HitTestFrame:ClearAllPoints()
    nameplate.UnitFrame.HitTestFrame:SetPoint("TOPLEFT", self.name)
    nameplate.UnitFrame.HitTestFrame:SetPoint("BOTTOMRIGHT", self.cast)
    if self.AurasFrame and self.AurasFrame:GetParent() == self then
      self.AurasFrame:SetParent(self.OldUnitFrame)
    end
    nameplate.UnitFrame.AurasFrame:SetParent(self)
    self.AurasFrame = nameplate.UnitFrame.AurasFrame
    self.OldUnitFrame = nameplate.UnitFrame
    nameplate.UnitFrame.AurasFrame:ClearAllPoints()
    nameplate.UnitFrame.AurasFrame:SetPoint("BOTTOMLEFT", self.name, "TOPLEFT")
  else
    -- NYI
  end
end

function addonTable.Display.NameplateMixin:SetUnit(unit)
  self.unit = unit
  self.health:SetUnit(self.unit)
  self.cast:SetUnit(self.unit)
  self.power:SetUnit(self.unit)
  if self.unit then
    self:Show()
    self:RegisterUnitEvent("UNIT_NAME_UPDATE", self.unit)
    self.name:SetText(UnitName(self.unit))
    self.questMarker:SetShown(UnitIsQuestBoss(self.unit))
    if addonTable.Constants.IsMidnight then
      C_NamePlateManager.SetNamePlateSimplified(self.unit, false)
    end
  else
    self:Hide()
    self:UnregisterAllEvents()
  end
end

function addonTable.Display.NameplateMixin:UpdateForTarget()
  if self.unit then
    self.power:ApplyPower()
    self.health:ApplyTarget()
  end

  if not addonTable.Constants.IsMidnight then
    if UnitIsUnit("target", self.unit) then
      self:SetScale(1.2)
    else
      self:SetScale(1)
    end
  end
end

function addonTable.Display.NameplateMixin:OnEvent(eventName)
  if eventName == "UNIT_NAME_UPDATE" then
    self.name:SetText(UnitName(self.unit))
  end
end
