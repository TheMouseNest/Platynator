---@class addonTablePlatynator
local addonTable = select(2, ...)

function addonTable.Display.Initialize()
  addonTable.style = addonTable.Display.Styles[addonTable.Config.Get("style")]

  do
    local members = {
      {alphabet = "roman", file = addonTable.style.font.file, height = addonTable.style.font.size, flags = ""},
    }
    for _, alphabet in ipairs({"simplifiedchinese", "traditionalchinese", "korean", "russian"}) do
      local fontObject = ChatFontNormal:GetFontObjectForAlphabet(alphabet)
      local file = fontObject:GetFont()
      table.insert(members, {alphabet = alphabet, file = file, height = addonTable.style.font.size, flags = ""})
    end
    CreateFontFamily("PlatynatorNameplateFont", members)
  end

  local manager = CreateFrame("Frame")
  Mixin(manager, addonTable.Display.ManagerMixin)
  manager:OnLoad()
end

addonTable.Display.ManagerMixin = {}
function addonTable.Display.ManagerMixin:OnLoad()
  self.activeNameplates = {}
  self.nameplateDisplays = {}
  self.lastTarget = nil
  self:SetScript("OnEvent", self.OnEvent)

  self:RegisterEvent("NAME_PLATE_CREATED")
  self:RegisterEvent("NAME_PLATE_UNIT_ADDED");
  self:RegisterEvent("NAME_PLATE_UNIT_REMOVED");
  self:RegisterEvent("PLAYER_TARGET_CHANGED");
  self:RegisterEvent("PLAYER_SOFT_INTERACT_CHANGED");
  self:RegisterEvent("PLAYER_SOFT_FRIEND_CHANGED");
  self:RegisterEvent("PLAYER_SOFT_ENEMY_CHANGED");
  self:RegisterEvent("UNIT_THREAT_LIST_UPDATE");
  self:RegisterEvent("UNIT_HEALTH");

  self:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
  self:RegisterEvent("RUNE_POWER_UPDATE")

  hooksecurefunc(NamePlateDriverFrame, "OnNamePlateAdded", function(_, unit)
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit, issecure())
    if self.nameplateDisplays[nameplate] then
      self.nameplateDisplays[nameplate]:Install(nameplate)
    end
  end)

  hooksecurefunc(NamePlateDriverFrame, "OnNamePlateRemoved", function(_, unit)
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit, issecure())
    if self.nameplateDisplays[nameplate] then
      self.nameplateDisplays[nameplate]:SetUnit(nil)
    end
  end)
end

function addonTable.Display.ManagerMixin:OnEvent(eventName, ...)
  if eventName == "NAME_PLATE_UNIT_ADDED" then
    local unit = ...
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit, issecure())
    if self.nameplateDisplays[nameplate] then
      self.nameplateDisplays[nameplate]:SetUnit(unit)
    end
    self.activeNameplates[unit] = nameplate
  elseif eventName == "NAME_PLATE_UNIT_REMOVED" then
    self.activeNameplates[...] = nil
  elseif eventName == "NAME_PLATE_CREATED" then
    local nameplate = ...
    self.nameplateDisplays[nameplate] = CreateFrame("Frame", nil, nameplate)
    Mixin(self.nameplateDisplays[nameplate], addonTable.Display.NameplateMixin)
    self.nameplateDisplays[nameplate]:OnLoad()
  elseif eventName == "PLAYER_TARGET_CHANGED" then
    if self.lastTarget and self.lastTarget.unit and UnitExists(self.lastTarget.unit) then
      self.lastTarget:UpdateForTarget()
    end
    local new = C_NamePlate.GetNamePlateForUnit("target")
    if new then
      self.lastTarget = self.nameplateDisplays[new]
      self.nameplateDisplays[new]:UpdateForTarget()
    else
      self.lastTarget = nil
    end
  elseif eventName == "UNIT_POWER_UPDATE" or eventName == "RUNE_POWER_UPDATE" then
    local new = C_NamePlate.GetNamePlateForUnit("target")
    if new then
      self.lastTarget = self.nameplateDisplays[new]
      self.nameplateDisplays[new]:UpdateForTarget()
    else
      self.lastTarget = nil
    end
  end
end
