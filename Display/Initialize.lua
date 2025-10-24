---@class addonTablePlatynator
local addonTable = select(2, ...)

function addonTable.Display.Initialize()
  local design = addonTable.Config.Get(addonTable.Config.Options.DESIGN)

  addonTable.CurrentFont = addonTable.Core.GetFontByID(design.font.asset)
  CreateFont("PlatynatorNameplateCooldownFont")
  PlatynatorNameplateCooldownFont:SetFont(addonTable.Assets.Fonts[design.font.asset].file, 13, design.font.outline and "OUTLINE" or "")
  if design.font.shadow then
    PlatynatorNameplateCooldownFont:SetShadowOffset(1, -1)
  else
    PlatynatorNameplateCooldownFont:SetShadowOffset(0, 0)
  end

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
  self.HookedUFs = {}
  -- Apply Platynator settings to aura layout
  local function RelayoutAuras(list)
    if list:IsForbidden() then
      return
    end
    local details = list:GetParent().details
    if not details then
      return
    end
    local dir = -1
    if details.direction == "RIGHT" then
      dir = 1
    end
    local padding = 2
    local children = list:GetLayoutChildren()
    if #children == 0 then
      return
    end
    list:ClearAllPoints()
    local anchor = details.direction == "LEFT" and "RIGHT" or "LEFT"
    list:SetPoint(anchor)
    for index, child in ipairs(children) do
      child:ClearAllPoints()
      child:SetPoint(anchor, (index - 1) * (child:GetWidth() + padding) * dir, 0)
    end
  end
  hooksecurefunc(NamePlateDriverFrame, "OnNamePlateAdded", function(_, unit)
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit, issecure())
    if nameplate and unit and not UnitIsUnit("player", unit) then
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
        if not self.HookedUFs[nameplate.UnitFrame] then
          self.HookedUFs[nameplate.UnitFrame] = true
          local af = nameplate.UnitFrame.AurasFrame
          hooksecurefunc(af.BuffListFrame, "Layout", RelayoutAuras)
          hooksecurefunc(af.DebuffListFrame, "Layout", RelayoutAuras)
          hooksecurefunc(af.CrowdControlListFrame, "Layout", RelayoutAuras)
        end
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
        UF.AurasFrame.DebuffListFrame:SetParent(UF.AurasFrame)
        UF.AurasFrame.BuffListFrame:ClearAllPoints()
        UF.AurasFrame.BuffListFrame:SetPoint("RIGHT", UF.HealthBarsContainer.healthBar, "LEFT", -5, 0);
        UF.AurasFrame.BuffListFrame:SetParent(UF.AurasFrame)
        UF.AurasFrame.CrowdControlListFrame:ClearAllPoints()
        UF.AurasFrame.CrowdControlListFrame:SetPoint("LEFT", UF.HealthBarsContainer.healthBar, "RIGHT", 5, 0);
        UF.AurasFrame.CrowdControlListFrame:SetParent(UF.AurasFrame)
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
        if design.font.shadow then
          PlatynatorNameplateCooldownFont:SetShadowOffset(1, -1)
        else
          PlatynatorNameplateCooldownFont:SetShadowOffset(0, 0)
        end
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
    elseif state[addonTable.Constants.RefreshReason.Scale] or state[addonTable.Constants.RefreshReason.TargetBehaviour] then
      for _, display in pairs(self.nameplateDisplays) do
        display:UpdateVisual()
      end
    end
  end)
end

function addonTable.Display.ManagerMixin:PositionBuffs(display)
  if addonTable.Constants.IsMidnight and self.ModifiedUFs[display.unit] then
    local unit = display.unit
    local auras = addonTable.Config.Get(addonTable.Config.Options.DESIGN).auras
    local designInfo = {}
    for _, a in ipairs(auras) do
      designInfo[a.kind] = a
    end
    if designInfo.debuffs then
      self.ModifiedUFs[unit].AurasFrame.DebuffListFrame:SetParent(display.DebuffDisplay)
      self.ModifiedUFs[unit].AurasFrame.DebuffListFrame:SetScale(designInfo.debuffs.scale * 4/5)
    end
    if designInfo.buffs then
      self.ModifiedUFs[unit].AurasFrame.BuffListFrame:SetParent(display.BuffDisplay)
      self.ModifiedUFs[unit].AurasFrame.BuffListFrame:SetScale(designInfo.buffs.scale * 4/5)
    end
    if designInfo.crowdControl then
      self.ModifiedUFs[unit].AurasFrame.CrowdControlListFrame:SetParent(display.CrowdControlDisplay)
      self.ModifiedUFs[unit].AurasFrame.CrowdControlListFrame:SetScale(designInfo.crowdControl.scale * 4/5)
    end
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
