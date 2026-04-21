---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.CastTargetTextMixin = {}

function addonTable.Display.CastTargetTextMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    addonTable.Display.Cache:RegisterCallback(self.unit, "cast", function(state)
      self:UpdateTarget(state)
      self:UpdateText()
    end)

    self:UpdateTarget(addonTable.Display.Cache:Get(self.unit, "cast"))
    self:UpdateText()
  else
    self:Strip()
  end
end

function addonTable.Display.CastTargetTextMixin:Strip()
  self.target = nil
  self.targetClass = nil
end

function addonTable.Display.CastTargetTextMixin:UpdateTarget(state)
  self.target = nil
  self.targetClass = nil

  if state.cast[1] or state.channel[1] then
    if UnitSpellTargetName then
      if UnitShouldDisplaySpellTargetName(self.unit) then
        self.target = UnitSpellTargetName(self.unit)
        self.targetClass = UnitSpellTargetClass(self.unit)
      end
    else
      self.target = UnitName(self.unit .. "target")
      self.targetClass = UnitClassBase(self.unit .. "target")
    end
  end
end

function addonTable.Display.CastTargetTextMixin:UpdateText()
  if self.target ~= nil then
    self.text:SetText(self.target)
    if self.targetClass ~= nil and self.details.applyClassColors then
      if C_ClassColor then
        self.text:SetTextColor(C_ClassColor.GetClassColor(self.targetClass):GetRGB())
      else
        self.text:SetTextColor(RAID_CLASS_COLORS[self.targetClass]:GetRGB())
      end
    end
  else
    self.text:SetText("")
  end
end
