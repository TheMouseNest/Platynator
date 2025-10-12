---@class addonTablePlatynator
local addonTable = select(2, ...)

function addonTable.Display.Initialize()
  local style = addonTable.Config.Get(addonTable.Config.Options.DESIGN)

  local flags = style.font.flags
  local file = addonTable.Assets.Fonts[style.font.asset].file
  local size = addonTable.Assets.Fonts[style.font.asset].size
  do
    local members = {
      {alphabet = "roman", file = file, height = size, flags = flags},
    }
    for _, alphabet in ipairs({"simplifiedchinese", "traditionalchinese", "korean", "russian"}) do
      local fontObject = ChatFontNormal:GetFontObjectForAlphabet(alphabet)
      local file = fontObject:GetFont()
      table.insert(members, {alphabet = alphabet, file = file, height = size, flags = flags})
    end
    CreateFontFamily("PlatynatorNameplateFont", members)
  end
  PlatynatorNameplateFont:SetShadowOffset(1, -1)

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
  self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
  self:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
  self:RegisterEvent("PLAYER_TARGET_CHANGED")
  self:RegisterEvent("PLAYER_SOFT_INTERACT_CHANGED")
  self:RegisterEvent("PLAYER_SOFT_FRIEND_CHANGED")
  self:RegisterEvent("PLAYER_SOFT_ENEMY_CHANGED")
  self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")

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

  addonTable.CallbackRegistry:RegisterCallback("RefreshStateChange", function(_, state)
    if state[addonTable.Constants.RefreshReason.Design] then
      self:SetScript("OnUpdate", function()
        self:SetScript("OnUpdate", nil)
        for nameplate, display in pairs(self.nameplateDisplays) do
          local unit = display.unit
          display:InitializeWidgets()
          display:SetUnit(unit)
        end
      end)
    end
  end)

  NamePlateDriverFrame:UnregisterEvent("DISPLAY_SIZE_CHANGED")
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
