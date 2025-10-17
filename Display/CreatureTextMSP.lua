---@class addonTablePlatynator
local addonTable = select(2, ...)

local callbacks = {}
function MSPCallback(name, field, value, ...)
  if callbacks[name] and field == "name" then
    callbacks[name]()
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
    self:RegisterUnitEvent("UNIT_NAME_UPDATE", self.unit)
    self:UpdateName()
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
      callbacks[self.fullName] = function()
        self:UpdateName()
      end
    end
    local rpDetails = msp.char[self.fullName]
    local name = rpDetails and rpDetails.name
    if rpName and rpName ~= "" then
      self.text:SetText(rpName)
    else
      self.text:SetText(originalName)
    end
  else
    self.text:SetText(originalName)
  end
end

function addonTable.Display.CreatureTextMSPMixin:Strip()
  callbacks[self.fullName] = nil
  self.fullName = nil
  self:UnregisterAllEvents()
end

function addonTable.Display.CreatureTextMSPMixin:OnEvent(eventName, ...)
  self:UpdateName()
end
