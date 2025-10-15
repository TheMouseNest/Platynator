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
  self.displayPool = CreateFramePool("Frame", UIParent, nil, nil, false, function(frame)
    Mixin(frame, addonTable.Display.NameplateMixin)
    frame:OnLoad()
  end)
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

  self.HitRegions = {}
  hooksecurefunc(NamePlateDriverFrame, "OnNamePlateAdded", function(_, unit)
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit, issecure())
    if nameplate then
      if addonTable.Constants.IsMidnight then
        nameplate.UnitFrame:SetAlpha(0) --- XXX: Remove when unit health formatting available
        nameplate.UnitFrame.HitTestFrame:SetParent(nameplate)
        nameplate.UnitFrame.HitTestFrame:ClearAllPoints()
        nameplate.UnitFrame.HitTestFrame:SetPoint("BOTTOMLEFT", self, "CENTER", addonTable.Rect.left, addonTable.Rect.bottom)
        nameplate.UnitFrame.HitTestFrame:SetSize(addonTable.Rect.width, addonTable.Rect.height)
        self.HitRegions[unit] = nameplate.UnitFrame

        nameplate.UnitFrame.AurasFrame:SetIgnoreParentAlpha(true)
      else
        nameplate.UnitFrame:SetParent(addonTable.hiddenFrame)
        nameplate.UnitFrame:UnregisterAllEvents()
      end
    end
  end)
  hooksecurefunc(NamePlateDriverFrame, "OnNamePlateRemoved", function(_, unit)
    if self.HitRegions[unit] then
      local UF = self.HitRegions[unit]
      UF.HitTestFrame:SetParent(UF)
      UF.HitTestFrame:SetPoint("TOPLEFT", UF.HealthBarsContainer.healthBar)
      UF.HitTestFrame:SetPoint("BOTTOMRIGHT", UF.HealthBarsContainer.healthBar)
      self.HitRegions[unit] = nil
    end
  end)

  addonTable.CallbackRegistry:RegisterCallback("RefreshStateChange", function(_, state)
    if state[addonTable.Constants.RefreshReason.Design] then
      self:SetScript("OnUpdate", function()
        self:SetScript("OnUpdate", nil)
        for _, display in pairs(self.nameplateDisplays) do
          display:InitializeWidgets()
          local unit = display.unit
          if unit then
            local nameplate = C_NamePlate.GetNamePlateForUnit(display.unit)
            if nameplate then
              display:Install(nameplate)
            end
          end
          display:SetUnit(unit)
        end
      end)
    elseif state[addonTable.Constants.RefreshReason.Scale] then
      for _, display in pairs(self.nameplateDisplays) do
        display:UpdateScale()
      end
    end
  end)

  NamePlateDriverFrame:UnregisterEvent("DISPLAY_SIZE_CHANGED")
end

function addonTable.Display.ManagerMixin:OnEvent(eventName, ...)
  if eventName == "NAME_PLATE_UNIT_ADDED" then
    local unit = ...
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit, issecure())
    -- NOTE: the nameplate _name_ does not correspond to the unit
    if nameplate and nameplate.UnitFrame then
      self.nameplateDisplays[unit] = self.displayPool:Acquire()
      self.nameplateDisplays[unit]:Install(nameplate)
      self.nameplateDisplays[unit]:SetUnit(unit)
    end
  elseif  eventName == "NAME_PLATE_UNIT_REMOVED" then
    local unit = ...
    if self.nameplateDisplays[unit] then
      self.nameplateDisplays[unit]:SetUnit(nil)
      self.displayPool:Release(self.nameplateDisplays[unit])
      self.nameplateDisplays[unit] = nil
    end
  elseif eventName == "PLAYER_TARGET_CHANGED" then
    local start = debugprofilestop()
    if self.lastTarget and (not self.lastTarget.unit or UnitExists(self.lastTarget.unit)) then
      self.lastTarget:UpdateForTarget()
    end
    local unit
    for i = 1, 40 do
      unit = "nameplate" .. i
      if UnitIsUnit(unit, "target") then
        break
      end
    end
    if self.nameplateDisplays[unit] then
      self.lastTarget = self.nameplateDisplays[unit]
      self.lastTarget:UpdateForTarget()
    else
      self.lastTarget = nil
    end
  elseif eventName == "UNIT_POWER_UPDATE" or eventName == "RUNE_POWER_UPDATE" then
    if self.lastTarget then
      self.lastTarget:UpdateForTarget()
    end
  end
end
