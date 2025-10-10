---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.NameplateMixin = {}
function addonTable.Display.NameplateMixin:OnLoad()
  local style = addonTable.Config.Get(addonTable.Config.Options.DESIGN)
  self.widgets = addonTable.Display.GetWidgets(style, self)

  self.questFrame = CreateFrame("Frame", nil, self)
  self.questMarker = self.questFrame:CreateTexture()
  self.questMarker:SetTexture("Interface/AddOns/Platynator/Assets/quest-marker.png")
  self.questMarker:SetSize(style.bars[1].scale * 48 * 0.9, style.bars[1].scale * 170 * 0.9)
  self.questMarker:SetPoint("RIGHT", self.widgets[1], "LEFT", -2, 0)
  self.questMarker:Hide()

  self.AurasFrame = nil
  self.OldUnitFrame = nil
end

function addonTable.Display.NameplateMixin:Install(nameplate)
  self:SetParent(nameplate)
  self:SetAllPoints()
  if addonTable.Constants.IsMidnight then
    nameplate.UnitFrame:SetAlpha(0) --- XXX: Remove when unit health formatting available
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
    self:SetScale(9/10)
    nameplate.UnitFrame:SetParent(addonTable.hiddenFrame)
    nameplate.UnitFrame:UnregisterAllEvents()
    -- NYI
  end
end

function addonTable.Display.NameplateMixin:SetUnit(unit)
  self.unit = unit
  for _, w in ipairs(self.widgets) do
    w:SetUnit(self.unit)
  end
  if self.unit then
    self:Show()
    self:RegisterUnitEvent("UNIT_NAME_UPDATE", self.unit)
    self:UpdateQuestMarker()
    if addonTable.Constants.IsMidnight then
      C_NamePlateManager.SetNamePlateSimplified(self.unit, false)
    end
  else
    self:Hide()
    self:UnregisterAllEvents()
  end
end

function addonTable.Display.NameplateMixin:UpdateQuestMarker()
  if not self.unit then
    return
  end
  self.questMarker:SetShown(UnitIsQuestBoss(self.unit) or C_QuestLog.UnitIsRelatedToActiveQuest(self.unit))
end

function addonTable.Display.NameplateMixin:UpdateForTarget()
  if self.unit then
    for _, w in ipairs(self.widgets) do
      if w.ApplyTarget then
        w:ApplyTarget()
      end
    end
  end

  if not addonTable.Constants.IsMidnight then
    if UnitIsUnit("target", self.unit) then
      self:SetScale(1.2 * 9/10)
    else
      self:SetScale(1 * 9/10)
    end
  end
end
