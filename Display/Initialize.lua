---@class addonTablePlatynator
local addonTable = select(2, ...)

function addonTable.Display.Initialize()
  local design = addonTable.Config.Get(addonTable.Config.Options.DESIGN)

  addonTable.CurrentFont = addonTable.Core.GetFontByID(design.font.asset)
  CreateFont("PlatynatorNameplateCooldownFont")
  PlatynatorNameplateCooldownFont:SetFont(addonTable.Assets.Fonts[design.font.asset].file, 13, design.font.outline and "OUTLINE" or "")

  local manager = CreateFrame("Frame")
  Mixin(manager, addonTable.Display.ManagerMixin)
  manager:OnLoad()
end

addonTable.Display.ManagerMixin = {}
function addonTable.Display.ManagerMixin:OnLoad()
  self.styleIndex = 0
  self.displayPool = CreateFramePool("Frame", UIParent, nil, nil, false, function(frame)
    Mixin(frame, addonTable.Display.NameplateMixin)
    frame:OnLoad()
    frame.styleIndex = self.styleIndex
  end)
  self.nameplateDisplays = {}
  self.lastTarget = nil
  self:SetScript("OnEvent", self.OnEvent)

  self:RegisterEvent("NAME_PLATE_CREATED")
  self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
  self:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
  self:RegisterEvent("PLAYER_TARGET_CHANGED")
  self:RegisterEvent("PLAYER_SOFT_INTERACT_CHANGED")
  self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")

  self:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
  self:RegisterEvent("RUNE_POWER_UPDATE")

  NamePlateDriverFrame:UnregisterEvent("DISPLAY_SIZE_CHANGED")
  if not addonTable.Constants.IsMidnight then
    NamePlateDriverFrame:UnregisterEvent("CVAR_UPDATE")
  end

  self.ModifiedUFs = {}
  hooksecurefunc(NamePlateDriverFrame, "OnNamePlateAdded", function(_, unit)
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit, issecure())
    if nameplate and not UnitIsUnit("player", unit) then
      nameplate.UnitFrame:SetParent(addonTable.hiddenFrame)
      nameplate.UnitFrame:UnregisterAllEvents()
      if addonTable.Constants.IsMidnight then
        nameplate.UnitFrame.HitTestFrame:SetParent(nameplate)
        nameplate.UnitFrame.HitTestFrame:ClearAllPoints()
        nameplate.UnitFrame.HitTestFrame:SetPoint("BOTTOMLEFT", nameplate, "CENTER", addonTable.Rect.left, addonTable.Rect.bottom)
        nameplate.UnitFrame.HitTestFrame:SetSize(addonTable.Rect.width, addonTable.Rect.height)

        nameplate.UnitFrame:RegisterUnitEvent("UNIT_AURA", unit)
        nameplate.UnitFrame.AurasFrame:SetParent(nameplate)
        nameplate.UnitFrame.AurasFrame:SetIgnoreParentScale(true)
      end
      if nameplate.UnitFrame.WidgetContainer then
        nameplate.UnitFrame.WidgetContainer:SetParent(nameplate)
      end
      self.ModifiedUFs[unit] = nameplate.UnitFrame
    end
  end)
  hooksecurefunc(NamePlateDriverFrame, "OnNamePlateRemoved", function(_, unit)
    if self.ModifiedUFs[unit] then
      local UF = self.ModifiedUFs[unit]
      -- Restore original anchors and parents to various things we changed
      if UF.HitTestFrame then
        UF.HitTestFrame:SetParent(UF)
        UF.HitTestFrame:SetPoint("TOPLEFT", UF.HealthBarsContainer.healthBar)
        UF.HitTestFrame:SetPoint("BOTTOMRIGHT", UF.HealthBarsContainer.healthBar)
        UF.AurasFrame:SetParent(UF)
        UF.AurasFrame:SetIgnoreParentAlpha(false)
        local debuffPadding = CVarCallbackRegistry:GetCVarNumberOrDefault(NamePlateConstants.DEBUFF_PADDING_CVAR);
        local namePlateStyle = GetCVar(NamePlateConstants.STYLE_CVAR)
        local unitNameInsideHealthBar = namePlateStyle == Enum.NamePlateStyle.Default or namePlateStyle == Enum.NamePlateStyle.Block
        UF.AurasFrame.DebuffListFrame:ClearAllPoints()
        UF.AurasFrame:SetIgnoreParentScale(false)
        if unitNameInsideHealthBar then
          UF.AurasFrame.DebuffListFrame:SetPoint("BOTTOM", UF.HealthBarsContainer.healthBar, "TOP", 0, debuffPadding);
        else
          UF.AurasFrame.DebuffListFrame:SetPoint("BOTTOM", UF.name, "TOP", 0, debuffPadding);
        end
        UF.AurasFrame.BuffListFrame:ClearAllPoints()
        UF.AurasFrame.BuffListFrame:SetPoint("RIGHT", UF.HealthBarsContainer.healthBar, "LEFT", -5, 0);
        UF.AurasFrame.CrowdControlListFrame:ClearAllPoints()
        UF.AurasFrame.CrowdControlListFrame:SetPoint("LEFT", UF.HealthBarsContainer.healthBar, "RIGHT", 5, 0);
        UF:UnregisterEvent("UNIT_AURA")
      end
      if UF.WidgetContainer then
        UF.WidgetContainer:SetParent(UF)
      end
      self.ModifiedUFs[unit] = nil
    end
  end)

  addonTable.CallbackRegistry:RegisterCallback("RefreshStateChange", function(_, state)
    if state[addonTable.Constants.RefreshReason.Design] then
      self:SetScript("OnUpdate", function()
        local design = addonTable.Config.Get(addonTable.Config.Options.DESIGN)
        addonTable.CurrentFont = addonTable.Core.GetFontByID(design.font.asset)
        PlatynatorNameplateCooldownFont:SetFont(design.font.asset, 13, design.font.outline and "OUTLINE" or "")
        self.styleIndex = self.styleIndex + 1
        self:SetScript("OnUpdate", nil)
        for _, display in pairs(self.nameplateDisplays) do
          display:InitializeWidgets()
          self:PositionBuffs(display)
          display.styleIndex = self.styleIndex
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
end

function addonTable.Display.ManagerMixin:PositionBuffs(display)
  if addonTable.Constants.IsMidnight and self.ModifiedUFs[display.unit] then
    local unit = display.unit
    local auras = addonTable.Config.Get(addonTable.Config.Options.DESIGN).auras
    local debuffs = auras[1]
    self.ModifiedUFs[unit].AurasFrame.DebuffListFrame:ClearAllPoints()
    self.ModifiedUFs[unit].AurasFrame.DebuffListFrame:SetScale(debuffs.scale)
    self.ModifiedUFs[unit].AurasFrame.DebuffListFrame:SetPoint(debuffs.anchor[1] or "CENTER", display.DebuffDisplay)
    local buffs = auras[2]
    self.ModifiedUFs[unit].AurasFrame.BuffListFrame:ClearAllPoints()
    self.ModifiedUFs[unit].AurasFrame.BuffListFrame:SetScale(buffs.scale)
    self.ModifiedUFs[unit].AurasFrame.BuffListFrame:SetPoint(buffs.anchor[1] or "CENTER", display.BuffDisplay)
    local cc = auras[3]
    self.ModifiedUFs[unit].AurasFrame.CrowdControlListFrame:ClearAllPoints()
    self.ModifiedUFs[unit].AurasFrame.CrowdControlListFrame:SetScale(cc.scale)
    self.ModifiedUFs[unit].AurasFrame.CrowdControlListFrame:SetPoint(cc.anchor[1] or "CENTER", display.CrowdControlDisplay)
  end
end

function addonTable.Display.ManagerMixin:OnEvent(eventName, ...)
  if eventName == "NAME_PLATE_UNIT_ADDED" then
    local unit = ...
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit, issecure())
    -- NOTE: the nameplate _name_ does not correspond to the unit
    if nameplate and nameplate.UnitFrame and not UnitIsUnit("player", unit) then
      local newDisplay = self.displayPool:Acquire()
      self.nameplateDisplays[unit] = newDisplay
      newDisplay:Install(nameplate)
      if newDisplay.styleIndex ~= self.styleIndex then
        newDisplay:InitializeWidgets()
      end
      newDisplay:SetUnit(unit)
      self:PositionBuffs(newDisplay)
    end
  elseif  eventName == "NAME_PLATE_UNIT_REMOVED" then
    local unit = ...
    if self.nameplateDisplays[unit] then
      self.nameplateDisplays[unit]:SetUnit(nil)
      self.displayPool:Release(self.nameplateDisplays[unit])
      self.nameplateDisplays[unit] = nil
    end
  elseif eventName == "PLAYER_TARGET_CHANGED" then
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
  end
end
