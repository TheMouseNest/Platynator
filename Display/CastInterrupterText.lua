---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.CastInterrupterTextMixin = {}

function addonTable.Display.CastInterrupterTextMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    addonTable.Cache:RegisterCallback(self.unit, "cast", function(state)
      if state.interrupted and state.interrupted.guid then
        self:UpdateFromGUID(state.interrupted.guid)
      else
        self:Hide()
      end
    end)
    self:Hide()

    local state = addonTable.Cache:Get(self.unit, "cast")
    if state.interrupted and state.interrupted.guid then
      self:UpdateFromGUID(state.interrupted.guid)
    end
  else
    self:Strip()
  end
end

function addonTable.Display.CastInterrupterTextMixin:Strip()
  self.interrupter = nil
  self.interrupterClass = nil
end

function addonTable.Display.CastInterrupterTextMixin:UpdateFromGUID(guid)
  local name, class, _
  if UnitNameFromGUID then
    name = UnitNameFromGUID(guid)
    _, class = GetPlayerInfoByGUID(guid)
  else
    local unit = UnitTokenFromGUID(guid)
    if not unit then
      return
    end
    name = UnitName(unit)
    class = UnitClassBase(unit)
  end
  self.interrupter = name
  self.interrupterClass = class

  self:UpdateText()
  self:Show()
end

function addonTable.Display.CastInterrupterTextMixin:UpdateText()
  if self.interrupter ~= nil then
    self.text:SetText(self.interrupter)
    if self.interrupterClass ~= nil and self.details.applyClassColors then
      if C_ClassColor then
        self.text:SetTextColor(C_ClassColor.GetClassColor(self.interrupterClass):GetRGB())
      else
        self.text:SetTextColor(RAID_CLASS_COLORS[self.interrupterClass]:GetRGB())
      end
    end
  else
    self.text:SetText("")
  end
end
