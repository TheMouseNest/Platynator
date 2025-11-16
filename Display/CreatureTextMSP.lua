---@class addonTablePlatynator
local addonTable = select(2, ...)

local callbacks = {}
function MSPCallback(name, field, value, ...)
  if callbacks[name] and field == "NA" then
    for _, cb in ipairs(callbacks[name]) do
      cb()
    end
  end
end
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function()
  if msp and msp_RPAddOn then
    table.insert(msp.callback.updated, MSPCallback)

    msp_RPNameplatesAddOn = "Platynator"
  else
    addonTable.Display.CreatureTextMSPMixin = nil
  end
end)

addonTable.Display.CreatureTextMSPMixin = {}

function addonTable.Display.CreatureTextMSPMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self:UnregisterCallback()
    self:RegisterUnitEvent("UNIT_NAME_UPDATE", self.unit)
    self:UpdateName()
    if self.details.applyClassColors and UnitIsPlayer(self.unit) then
      local c = RAID_CLASS_COLORS[UnitClassBase(self.unit)]
      self.text:SetTextColor(c.r, c.g, c.b)
    end
  else
    self:Strip()
  end
end

function addonTable.Display.CreatureTextMSPMixin:UpdateName()
  local originalName, realm = UnitName(self.unit)
  if UnitIsPlayer(self.unit) and (not issecretvalue or not issecretvalue(originalName)) then
    if realm == nil then
      realm = GetNormalizedRealmName()
    end
    if not self.fullName then
      self.fullName = originalName .. "-" .. realm
      self.callback = function()
        self:UpdateName()
      end
      callbacks[self.fullName] = callbacks[self.fullName] or {}
      table.insert(callbacks[self.fullName], self.callback)
    end
    local rpDetails = msp.char[self.fullName]
    local name = rpDetails and rpDetails ~= "" and rpDetails.field.NA
    if name and name ~= "" then
      self.text:SetText(name)
    else
      self.text:SetText(originalName)
    end
  else
    self.text:SetText(originalName)
  end
end

function addonTable.Display.CreatureTextMSPMixin:UnregisterCallback()
  if self.fullName then
    table.remove(callbacks[self.fullName], tIndexOf(callbacks[self.fullName], self.callback))
    self.callback = nil
    self.fullName = nil
  end
end

function addonTable.Display.CreatureTextMSPMixin:Strip()
  local c = self.details.color
  self.text:SetTextColor(c.r, c.g, c.b)
  self:UnregisterCallback()
  self:UnregisterAllEvents()
end

function addonTable.Display.CreatureTextMSPMixin:OnEvent(eventName, ...)
  self:UpdateName()
end
