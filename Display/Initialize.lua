---@class addonTablePlatynator
local addonTable = select(2, ...)

local ConvertSecret
if issecretvalue then
  ConvertSecret = function(state)
    return not issecretvalue(state) and state or false
  end
else
  ConvertSecret = function(state)
    return state
  end
end

function addonTable.Display.Initialize()
  local design = addonTable.Core.GetDesign("enemy")

  addonTable.CurrentFont = addonTable.Core.GetFontByDesign(design)
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
  self.friendDisplayPool = CreateFramePool("Frame", UIParent, nil, nil, false, function(frame)
    Mixin(frame, addonTable.Display.NameplateMixin)
    frame.kind = "friend"
    frame:OnLoad()
  end)
  self.enemyDisplayPool = CreateFramePool("Frame", UIParent, nil, nil, false, function(frame)
    Mixin(frame, addonTable.Display.NameplateMixin)
    frame.kind = "enemy"
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
  self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")

  self:RegisterEvent("PLAYER_SOFT_INTERACT_CHANGED")

  self:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
  self:RegisterEvent("RUNE_POWER_UPDATE")
  self:RegisterEvent("UNIT_THREAT_LIST_UPDATE")

  NamePlateDriverFrame:UnregisterEvent("DISPLAY_SIZE_CHANGED")
  if not addonTable.Constants.IsMidnight then
    C_NamePlate.SetNamePlateFriendlyClickThrough(true)
    NamePlateDriverFrame:UnregisterEvent("CVAR_UPDATE")
  end

  self:RegisterEvent("VARIABLES_LOADED")

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
      child.Cooldown:SetCountdownFont("PlatynatorNameplateCooldownFont")
    end
  end
  self.RelayoutAuras = RelayoutAuras
  hooksecurefunc(NamePlateDriverFrame, "OnNamePlateAdded", function(_, unit)
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit, issecure())
    if nameplate and unit and unit ~= "preview" and (addonTable.Constants.IsMidnight or not UnitIsUnit("player", unit)) then
      nameplate.UnitFrame:SetParent(addonTable.hiddenFrame)
      nameplate.UnitFrame:UnregisterAllEvents()
      if addonTable.Constants.IsMidnight then

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
        UF.HitTestFrame:ClearAllPoints()
        UF.HitTestFrame:SetPoint("TOPLEFT", UF.HealthBarsContainer.healthBar)
        UF.HitTestFrame:SetPoint("BOTTOMRIGHT", UF.HealthBarsContainer.healthBar)
        UF.AurasFrame:SetParent(UF)
        UF.AurasFrame:SetIgnoreParentAlpha(false)
        UF.AurasFrame:SetIgnoreParentScale(false)
        local debuffPadding = CVarCallbackRegistry:GetCVarNumberOrDefault(NamePlateConstants.DEBUFF_PADDING_CVAR);
        local namePlateStyle = GetCVar(NamePlateConstants.STYLE_CVAR)
        local unitNameInsideHealthBar = namePlateStyle == Enum.NamePlateStyle.Default or namePlateStyle == Enum.NamePlateStyle.Block
        UF.AurasFrame.DebuffListFrame:ClearAllPoints()
        if unitNameInsideHealthBar then
          UF.AurasFrame.DebuffListFrame:SetPoint("BOTTOM", UF.HealthBarsContainer.healthBar, "TOP", 0, debuffPadding);
        else
          UF.AurasFrame.DebuffListFrame:SetPoint("BOTTOM", UF.name, "TOP", 0, debuffPadding);
        end
        UF.AurasFrame.DebuffListFrame:SetPoint("LEFT", UF.HealthBarsContainer)
        UF.AurasFrame.DebuffListFrame:SetParent(UF.AurasFrame)
        UF.AurasFrame.DebuffListFrame:SetScale(1)
        UF.AurasFrame.BuffListFrame:ClearAllPoints()
        UF.AurasFrame.BuffListFrame:SetPoint("RIGHT", UF.ClassificationFrame, "LEFT", -5, 0);
        UF.AurasFrame.BuffListFrame:SetParent(UF.AurasFrame)
        UF.AurasFrame.BuffListFrame:SetScale(1)
        UF.AurasFrame.CrowdControlListFrame:ClearAllPoints()
        UF.AurasFrame.CrowdControlListFrame:SetPoint("LEFT", UF.HealthBarsContainer.healthBar, "RIGHT", 5, 0);
        UF.AurasFrame.CrowdControlListFrame:SetParent(UF.AurasFrame)
        UF.AurasFrame.CrowdControlListFrame:SetScale(1)
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
        local design = addonTable.Core.GetDesign("enemy")
        addonTable.CurrentFont = addonTable.Core.GetFontByDesign(design)
        PlatynatorNameplateCooldownFont:SetFont(design.font.asset, 13, design.font.outline and "OUTLINE" or "")
        if design.font.shadow then
          PlatynatorNameplateCooldownFont:SetShadowOffset(1, -1)
        else
          PlatynatorNameplateCooldownFont:SetShadowOffset(0, 0)
        end
        self.styleIndex = self.styleIndex + 1
        self:SetScript("OnUpdate", nil)
        for unit, display in pairs(self.nameplateDisplays) do
          display.styleIndex = self.styleIndex
          local nameplate = C_NamePlate.GetNamePlateForUnit(display.unit)
          if nameplate then
            display:Install(nameplate)
          end
          local UF = self.ModifiedUFs[unit]
          if UF and UF.HitTestFrame then
            UF.HitTestFrame:ClearAllPoints()
            UF.HitTestFrame:SetPoint("BOTTOMLEFT", display, "CENTER", addonTable.Rect.left, addonTable.Rect.bottom)
            UF.HitTestFrame:SetSize(addonTable.Rect.width, addonTable.Rect.height)
          end
          display:InitializeWidgets(addonTable.Core.GetDesign(display.kind))
          self:PositionBuffs(display)
          display:SetUnit(unit)
        end
        if self.lastInteract and self.lastInteract.interactUnit then
          self.lastInteract:UpdateSoftInteract()
        end
      end)
    elseif state[addonTable.Constants.RefreshReason.Scale] or state[addonTable.Constants.RefreshReason.TargetBehaviour] then
      for _, display in pairs(self.nameplateDisplays) do
        display:UpdateVisual()
      end
    elseif state[addonTable.Constants.RefreshReason.StackingBehaviour] then
      self:UpdateStacking()
    elseif state[addonTable.Constants.RefreshReason.ShowBehaviour] then
      self:UpdateShowState()
    end
  end)
end

function addonTable.Display.ManagerMixin:UpdateStacking()
  if InCombatLockdown() then
    self:RegisterCallback("PLAYER_REGEN_ENABLED")
  end
  --[[if addonTable.Config.Get(addonTable.Config.Options.CLOSER_NAMEPLATES) then
    C_NamePlate.SetNamePlateSize(30, 20)
  else
    C_NamePlate.SetNamePlateSize(175, 50)
  end]]
  if addonTable.Constants.IsMidnight then
    if addonTable.Config.Get(addonTable.Config.Options.CLOSER_NAMEPLATES) then
      C_CVar.SetCVarBitfield("nameplateStackingTypes", Enum.NamePlateStackType.Enemy, false)
      C_CVar.SetCVarBitfield("nameplateStackingTypes", Enum.NamePlateStackType.Friendly, false)
    elseif C_CVar.GetCVarBitfield("nameplateStackingTypes", Enum.NamePlateStackType.Enemy) == C_CVar.GetCVarBitfield("nameplateStackingTypes", Enum.NamePlateStackType.Friendly) then
      C_CVar.SetCVarBitfield("nameplateStackingTypes", Enum.NamePlateStackType.Enemy, true)
      C_CVar.SetCVarBitfield("nameplateStackingTypes", Enum.NamePlateStackType.Friendly, true)
    end
  else
    if addonTable.Config.Get(addonTable.Config.Options.CLOSER_NAMEPLATES) then
      C_CVar.SetCVar("nameplateOverlapV", "0.6")
      C_CVar.SetCVar("nameplateOverlapH", "0.5")
      C_CVar.SetCVar("nameplateOtherTopInset", "0.05")
      C_CVar.SetCVar("nameplateLargeTopInset", "0.07")
    elseif C_CVar.GetCVar("nameplateOverlapV") == "0.6" and C_CVar.GetCVar("nameplateOverlapH") == "0.5" and C_CVar.GetCVar("nameplateOtherTopInset") == "0.05" and C_CVar.GetCVar("nameplateLargeTopInset") == "0.07" then
      C_CVar.SetCVar("nameplateOverlapV", "1.1")
      C_CVar.SetCVar("nameplateOverlapH", "0.8")
      C_CVar.SetCVar("nameplateOtherTopInset", "0.1")
      C_CVar.SetCVar("nameplateLargeTopInset", "0.15")
    end

    C_CVar.SetCVar("nameplateMotion", addonTable.Config.Get(addonTable.Config.Options.STACKING_NAMEPLATES) and "1" or "0")
  end
end

function addonTable.Display.ManagerMixin:UpdateShowState()
  if InCombatLockdown() then
    self:RegisterCallback("PLAYER_REGEN_ENABLED")
  end

  local currentShow = addonTable.Config.Get(addonTable.Config.Options.SHOW_NAMEPLATES)

  local values
  if C_CVar.GetCVarInfo("nameplateShowFriendlyPlayers") ~= nil then
    values = {
      player = "nameplateShowFriendlyPlayers",
      npc = "nameplateShowFriendlyNpcs",
      enemy = "nameplateShowEnemies",
    }
  else
    values = {
      player = "nameplateShowFriends",
      npc = "nameplateShowFriendlyNPCs",
      enemy = "nameplateShowEnemies",
    }

    if self.oldShowState then
      if currentShow.npc and not currentShow.player and not self.oldShowState.player then
        currentShow.player = true
      end
      if not currentShow.player and self.oldShowState.player then
        currentShow.npc = false
      end
    end

    self.oldShowState = CopyTable(currentShow)
  end

  for key, state in pairs(currentShow) do
    local newValue = state and "1" or "0"
    C_CVar.SetCVar(values[key], newValue)
  end
end

function addonTable.Display.ManagerMixin:PositionBuffs(display)
  if addonTable.Constants.IsMidnight and self.ModifiedUFs[display.unit] then
    local unit = display.unit
    local auras = addonTable.Core.GetDesign(display.kind).auras
    local designInfo = {}
    for _, a in ipairs(auras) do
      designInfo[a.kind] = a
    end
    local DebuffListFrame = self.ModifiedUFs[unit].AurasFrame.DebuffListFrame
    DebuffListFrame:SetParent(display.DebuffDisplay)
    if designInfo.debuffs then
      DebuffListFrame:SetScale(designInfo.debuffs.scale * 4/5)
      self.RelayoutAuras(DebuffListFrame)
    end
    local BuffListFrame = self.ModifiedUFs[unit].AurasFrame.BuffListFrame
    BuffListFrame:SetParent(display.BuffDisplay)
    if designInfo.buffs then
      BuffListFrame:SetScale(designInfo.buffs.scale * 4/5)
      self.RelayoutAuras(BuffListFrame)
    end
    local CrowdControlListFrame = self.ModifiedUFs[unit].AurasFrame.CrowdControlListFrame
    CrowdControlListFrame:SetParent(display.CrowdControlDisplay)
    if designInfo.crowdControl then
      CrowdControlListFrame:SetScale(designInfo.crowdControl.scale * 4/5)
      self.RelayoutAuras(CrowdControlListFrame)
    end
  end
end

function addonTable.Display.ManagerMixin:Install(unit, nameplate)
  local nameplate = C_NamePlate.GetNamePlateForUnit(unit, issecure())
  -- NOTE: the nameplate _name_ does not correspond to the unit
  if nameplate and unit and unit ~= "preview" and (addonTable.Constants.IsMidnight or not UnitIsUnit("player", unit)) then
    local newDisplay
    -- Necesary check on friends in case its a player being mind controlled
    if (UnitIsFriend("player", unit) and not UnitCanAttack("player", unit)) or not UnitCanAttack("player", unit) then
      newDisplay = self.friendDisplayPool:Acquire()
    else
      newDisplay = self.enemyDisplayPool:Acquire()
    end
    local UF = self.ModifiedUFs[unit]
    if UF and UF.HitTestFrame then
      UF.HitTestFrame:SetParent(newDisplay)
      UF.HitTestFrame:ClearAllPoints()
      UF.HitTestFrame:SetPoint("BOTTOMLEFT", newDisplay, "CENTER", addonTable.Rect.left, addonTable.Rect.bottom)
      UF.HitTestFrame:SetSize(addonTable.Rect.width, addonTable.Rect.height)
    end
    self.nameplateDisplays[unit] = newDisplay
    newDisplay:Install(nameplate)
    if newDisplay.styleIndex ~= self.styleIndex then
      newDisplay:InitializeWidgets(addonTable.Core.GetDesign(newDisplay.kind))
      newDisplay.styleIndex = self.styleIndex
    end
    newDisplay:SetUnit(unit)
    self:PositionBuffs(newDisplay)
  end
end

function addonTable.Display.ManagerMixin:Uninstall(unit)
  local display = self.nameplateDisplays[unit]
  if display then
    display:SetUnit(nil)
    if display.kind == "friend" then
      self.friendDisplayPool:Release(display)
    else
      self.enemyDisplayPool:Release(display)
    end
    self.nameplateDisplays[unit] = nil
  end
end

function addonTable.Display.ManagerMixin:OnEvent(eventName, ...)
  if eventName == "NAME_PLATE_UNIT_ADDED" then
    local unit = ...
    self:Install(unit)
  elseif  eventName == "NAME_PLATE_UNIT_REMOVED" then
    local unit = ...
    self:Uninstall(unit)
  elseif eventName == "PLAYER_TARGET_CHANGED" then
    if addonTable.Constants.IsMidnight and IsInInstance() then
      for _, display in pairs(self.nameplateDisplays) do
        display:UpdateForTarget()
      end
    else
      if self.lastTarget and (not self.lastTarget.unit or UnitExists(self.lastTarget.unit)) then
        self.lastTarget:UpdateForTarget()
      end
      local unit
      for i = 1, 40 do
        unit = "nameplate" .. i
        if ConvertSecret(UnitIsUnit(unit, "target")) then
          break
        else
          unit = nil
        end
      end
      if self.nameplateDisplays[unit] then
        self.lastTarget = self.nameplateDisplays[unit]
        self.lastTarget:UpdateForTarget()
      else
        self.lastTarget = nil
      end
    end
  elseif eventName == "PLAYER_SOFT_INTERACT_CHANGED" then
    if self.lastInteract and self.lastInteract.interactUnit then
      self.lastInteract:UpdateSoftInteract()
    end
    local unit
    for i = 1, 40 do
      unit = "nameplate" .. i
      if ConvertSecret(UnitIsUnit(unit, "softinteract")) or ConvertSecret(UnitIsUnit(unit, "softenemy")) or ConvertSecret(UnitIsUnit(unit, "softfriend")) then
        break
      else
        unit = nil
      end
    end
    if self.nameplateDisplays[unit] then
      self.lastInteract = self.nameplateDisplays[unit]
      self.lastInteract:UpdateSoftInteract()
    else
      self.lastInteract = nil
    end
  elseif eventName == "UNIT_POWER_UPDATE" or eventName == "RUNE_POWER_UPDATE" then
    local unit
    for i = 1, 40 do
      unit = "nameplate" .. i
      if ConvertSecret(UnitIsUnit(unit, "target")) then
        break
      else
        unit = nil
      end
    end
    if self.nameplateDisplays[unit] then
      self.lastTarget = self.nameplateDisplays[unit]
      self.lastTarget:UpdateForTarget()
    else
      self.lastTarget = nil
    end
  elseif eventName == "UNIT_THREAT_LIST_UPDATE" then
    local unit = ...
    local display = self.nameplateDisplays[unit]
    if display and ((display.kind == "friend" and UnitCanAttack("player", unit)) or (display.kind == "enemy" and not UnitCanAttack("player", unit))) then
      self:Uninstall(unit)
      self:Install(unit, nameplate)
    end
  elseif eventName == "VARIABLES_LOADED" then
    if addonTable.Constants.IsMidnight then
      C_CVar.SetCVarBitfield(NamePlateConstants.ENEMY_NPC_AURA_DISPLAY_CVAR, Enum.NamePlateEnemyNpcAuraDisplay.Buffs, true)
      C_CVar.SetCVarBitfield(NamePlateConstants.ENEMY_NPC_AURA_DISPLAY_CVAR, Enum.NamePlateEnemyNpcAuraDisplay.Debuffs, true)
      C_CVar.SetCVarBitfield(NamePlateConstants.ENEMY_NPC_AURA_DISPLAY_CVAR, Enum.NamePlateEnemyNpcAuraDisplay.CrowdControl, true)

      C_CVar.SetCVarBitfield(NamePlateConstants.ENEMY_PLAYER_AURA_DISPLAY_CVAR, Enum.NamePlateEnemyPlayerAuraDisplay.Buffs, true)
      C_CVar.SetCVarBitfield(NamePlateConstants.ENEMY_PLAYER_AURA_DISPLAY_CVAR, Enum.NamePlateEnemyPlayerAuraDisplay.Debuffs, true)

      --SetCVarBitfield(NamePlateConstants.ENEMY_PLAYER_AURA_DISPLAY_CVAR, Enum.NamePlateEnemyPlayerAuraDisplay.LossOfControl, true);
      C_CVar.SetCVar("nameplateMinScale", 1)
    end

    self:UpdateStacking()
    self:UpdateShowState()
  elseif eventName == "PLAYER_REGEN_ENABLED" then
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    self:UpdateStacking()
    self:UpdateShowState()
  end
end
