---@class addonTablePlatynator
local addonTable = select(2, ...)

function addonTable.Display.Initialize()

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

  self.MouseoverMonitor = nil

  self.overrideScaleModifier = 1

  self:SetScript("OnEvent", self.OnEvent)

  self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
  self:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
  self:RegisterEvent("PLAYER_TARGET_CHANGED")
  self:RegisterEvent("PLAYER_SOFT_INTERACT_CHANGED")
  self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
  self:RegisterEvent("PLAYER_FOCUS_CHANGED")
  self:RegisterEvent("PLAYER_LOGIN")
  self:RegisterEvent("PLAYER_ENTERING_WORLD")
  self:RegisterEvent("UI_SCALE_CHANGED")

  self:RegisterEvent("PLAYER_SOFT_INTERACT_CHANGED")

  self:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
  self:RegisterEvent("RUNE_POWER_UPDATE")
  self:RegisterEvent("UNIT_FACTION")

  NamePlateDriverFrame:UnregisterEvent("DISPLAY_SIZE_CHANGED")
  if not addonTable.Constants.IsMidnight then
    C_NamePlate.SetNamePlateFriendlyClickThrough(true)
    NamePlateDriverFrame:UnregisterEvent("CVAR_UPDATE")
  end

  self:RegisterEvent("VARIABLES_LOADED")

  self.ModifiedUFs = {}
  self.HookedUFs = {}
  self.unitToNameplate = {}
  self.AlphaImporter = CreateFrame("Frame", nil, self)
  self.AlphaImporter:SetScript("OnUpdate", function()
    for unit, nameplate in pairs(self.unitToNameplate) do
      local display = self.nameplateDisplays[unit]
      display:SetAlpha(nameplate:GetAlpha() * display.overrideAlpha)
      if display:GetFrameLevel() ~= nameplate:GetFrameLevel() then
        display:SetFrameLevel(nameplate:GetFrameLevel())
      end
    end
  end)
  -- Apply Platynator settings to aura layout
  local function RelayoutAuras(list, filter)
    if list:IsForbidden() then
      return
    end
    local parent = list:GetParent()
    local details = parent.details
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
    local showCountdown = details.showCountdown
    list:SetPoint(anchor)
    local texBase = (1 - details.height) / 2
    for index, child in ipairs(children) do
      child:ClearAllPoints()
      if not filter or filter(child.unitToken, child.auraInstanceID) then
        child:SetScale(0.8)
        child:SetSize(25, 25 * details.height)
        child.Icon:SetTexCoord(0, 1, texBase, 1 - texBase)
        child:SetPoint(anchor, parent, anchor, (index - 1) * (child:GetWidth() + padding) * dir, 0)
        child.Cooldown:SetCountdownFont("PlatynatorNameplateCooldownFont")
        child.Cooldown:SetHideCountdownNumbers(not showCountdown)
        if showCountdown then
          if not child.Cooldown.Text then
            child.Cooldown.Text = child.Cooldown:GetRegions()
          end
          child.Cooldown.Text:SetFontObject(addonTable.CurrentFont)
          child.Cooldown.Text:SetTextScale(14/12 * details.textScale)
        end
        child.CountFrame.Count:SetFontObject(addonTable.CurrentFont)
        child.CountFrame.Count:SetTextScale(11/12 * details.textScale)
      else
        child:Hide()
      end
    end
  end
  self.RelayoutAuras = RelayoutAuras
  self.DebuffFilter = function(unitToken, auraInstanceID)
    return not C_UnitAuras.IsAuraFilteredOutByInstanceID(unitToken, auraInstanceID, "HARMFUL|PLAYER")
  end
  hooksecurefunc(NamePlateDriverFrame, "OnNamePlateAdded", function(_, unit)
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit, issecure())
    if nameplate and unit and unit ~= "preview" and (addonTable.Constants.IsMidnight or not UnitIsUnit("player", unit)) then
      nameplate.UnitFrame:SetParent(addonTable.hiddenFrame)
      nameplate.UnitFrame:UnregisterAllEvents()
      if nameplate.UnitFrame.castBar then
        nameplate.UnitFrame.castBar:UnregisterAllEvents()
      end
      if addonTable.Constants.IsMidnight then

        nameplate.UnitFrame:RegisterUnitEvent("UNIT_AURA", unit)
        nameplate.UnitFrame.AurasFrame:SetParent(nameplate)
        nameplate.UnitFrame.AurasFrame:SetIgnoreParentScale(true)
        if not self.HookedUFs[nameplate.UnitFrame] then
          self.HookedUFs[nameplate.UnitFrame] = true
          local af = nameplate.UnitFrame.AurasFrame
          hooksecurefunc(af.BuffListFrame, "Layout", RelayoutAuras)
          hooksecurefunc(af.DebuffListFrame, "Layout", function(list)
            RelayoutAuras(list, self.DebuffFilter)
          end)
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
        UF.HitTestFrame:SetScale(1)
        UF.AurasFrame:SetParent(UF)
        UF.AurasFrame:SetIgnoreParentAlpha(false)
        UF.AurasFrame:SetIgnoreParentScale(false)
        local debuffPadding = tonumber(GetCVar(NamePlateConstants.DEBUFF_PADDING_CVAR)) or 0
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
        UF.AurasFrame.LossOfControlFrame:ClearAllPoints()
        UF.AurasFrame.LossOfControlFrame:SetPoint("LEFT", UF.HealthBarsContainer.healthBar, "RIGHT", 5, 0);
        UF.AurasFrame.LossOfControlFrame:SetParent(UF.AurasFrame)
        UF.AurasFrame.LossOfControlFrame:SetScale(1)
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
          local nameplate = C_NamePlate.GetNamePlateForUnit(unit, issecure())
          if nameplate then
            display:Install(nameplate)
          end
          local UF = self.ModifiedUFs[unit]
          if UF and UF.HitTestFrame then
            UF.HitTestFrame:ClearAllPoints()
            UF.HitTestFrame:SetPoint("BOTTOMLEFT", display, "CENTER", addonTable.Rect.left * addonTable.Config.Get(addonTable.Config.Options.CLICK_REGION_SCALE_X), addonTable.Rect.bottom * addonTable.Config.Get(addonTable.Config.Options.CLICK_REGION_SCALE_Y))
            UF.HitTestFrame:SetSize(addonTable.Rect.width * addonTable.Config.Get(addonTable.Config.Options.CLICK_REGION_SCALE_X), addonTable.Rect.height * addonTable.Config.Get(addonTable.Config.Options.CLICK_REGION_SCALE_Y))
            self:UpdateStackingRegion(nameplate, unit)
          end
          display:InitializeWidgets(addonTable.Core.GetDesign(display.kind))
          self:PositionBuffs(display)
          display:SetUnit(unit)
        end
        if self.lastInteract and self.lastInteract.interactUnit then
          self.lastInteract:UpdateSoftInteract()
        end
        self:UpdateNamePlateSize()
        self:UpdateStacking()
      end)
    elseif state[addonTable.Constants.RefreshReason.Scale] or state[addonTable.Constants.RefreshReason.TargetBehaviour] then
      for unit, display in pairs(self.nameplateDisplays) do
        display:UpdateVisual()
        if display.stackRegion then
          self:UpdateStackingRegion(nil, unit)
        end
      end
      self:UpdateNamePlateSize()
    elseif state[addonTable.Constants.RefreshReason.StackingBehaviour] then
      self:UpdateStacking()
      for unit, display in pairs(self.nameplateDisplays) do
        if display.stackRegion then
          self:UpdateStackingRegion(nil, unit)
        end
      end
    elseif state[addonTable.Constants.RefreshReason.ShowBehaviour] then
      self:UpdateShowState()
    end
  end)

  addonTable.CallbackRegistry:RegisterCallback("SettingChanged", function(_, settingName)
    if settingName == addonTable.Config.Options.CLICK_REGION_SCALE_X or settingName == addonTable.Config.Options.CLICK_REGION_SCALE_Y then
      for unit, UF in pairs(self.ModifiedUFs) do
        if UF.HitTestFrame then
          UF.HitTestFrame:ClearAllPoints()
          UF.HitTestFrame:SetPoint("BOTTOMLEFT", self.nameplateDisplays[unit], "CENTER", addonTable.Rect.left * addonTable.Config.Get(addonTable.Config.Options.CLICK_REGION_SCALE_X), addonTable.Rect.bottom * addonTable.Config.Get(addonTable.Config.Options.CLICK_REGION_SCALE_Y))
          UF.HitTestFrame:SetSize(addonTable.Rect.width * addonTable.Config.Get(addonTable.Config.Options.CLICK_REGION_SCALE_X), addonTable.Rect.height * addonTable.Config.Get(addonTable.Config.Options.CLICK_REGION_SCALE_Y))
          self:UpdateStackingRegion(nameplate, unit)
        end
      end
      self:UpdateNamePlateSize()
      self:UpdateStacking()
    end
  end)
end

function addonTable.Display.ManagerMixin:UpdateStacking()
  if InCombatLockdown() then
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    return
  end
  if addonTable.Constants.IsMidnight then
    if addonTable.Config.Get(addonTable.Config.Options.STACKING_NAMEPLATES) then
      C_CVar.SetCVarBitfield("nameplateStackingTypes", Enum.NamePlateStackType.Enemy, true)
      C_CVar.SetCVarBitfield("nameplateStackingTypes", Enum.NamePlateStackType.Friendly, false)
    else
      C_CVar.SetCVarBitfield("nameplateStackingTypes", Enum.NamePlateStackType.Enemy, false)
      C_CVar.SetCVarBitfield("nameplateStackingTypes", Enum.NamePlateStackType.Friendly, false)
    end
  else
    C_CVar.SetCVar("nameplateOverlapH", addonTable.StackRect.width / addonTable.Rect.width * addonTable.Config.Get(addonTable.Config.Options.STACK_REGION_SCALE_X) / addonTable.Config.Get(addonTable.Config.Options.CLICK_REGION_SCALE_X))
    C_CVar.SetCVar("nameplateOverlapV", addonTable.StackRect.height / addonTable.Rect.height * addonTable.Config.Get(addonTable.Config.Options.STACK_REGION_SCALE_Y) / addonTable.Config.Get(addonTable.Config.Options.CLICK_REGION_SCALE_Y))
    if addonTable.Config.Get(addonTable.Config.Options.CLOSER_TO_SCREEN_EDGES) then
      C_CVar.SetCVar("nameplateOtherTopInset", "0.05")
      C_CVar.SetCVar("nameplateLargeTopInset", "0.07")
    elseif C_CVar.GetCVar("nameplateOtherTopInset") == "0.05" and C_CVar.GetCVar("nameplateLargeTopInset") == "0.07" then
      C_CVar.SetCVar("nameplateOtherTopInset", "0.08")
      C_CVar.SetCVar("nameplateLargeTopInset", "0.1")
    end

    C_CVar.SetCVar("nameplateMotion", addonTable.Config.Get(addonTable.Config.Options.STACKING_NAMEPLATES) and "1" or "0")
  end
end

local function GetCVarsForNameplates()
  if C_CVar.GetCVarInfo("nameplateShowFriendlyPlayers") ~= nil then
    return {
      player = "nameplateShowFriendlyPlayers",
      npc = "nameplateShowFriendlyNpcs",
      enemy = "nameplateShowEnemies",
    }
  else
    return {
      player = "nameplateShowFriends",
      npc = "nameplateShowFriendlyNPCs",
      enemy = "nameplateShowEnemies",
    }
  end
end

function addonTable.Display.ManagerMixin:UpdateShowState()
  if InCombatLockdown() then
    self:RegisterCallback("PLAYER_REGEN_ENABLED")
    return
  end

  local currentShow = addonTable.Config.Get(addonTable.Config.Options.SHOW_NAMEPLATES)

  local values = GetCVarsForNameplates()
  if C_CVar.GetCVarInfo("nameplateShowFriends") ~= nil then -- Check for the entangled cvars for friendly npcs
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
  self.hiddenFriendly = false

  self:UpdateInstanceShowState()
end

function addonTable.Display.ManagerMixin:UpdateInstanceShowState()
  -- Avoid changing nameplate visibility if we don't need to (so the Blizz hotkeys persist)
  if addonTable.Config.Get(addonTable.Config.Options.SHOW_FRIENDLY_IN_INSTANCES) then
    return
  end

  if InCombatLockdown() then
    self:RegisterCallback("PLAYER_REGEN_ENABLED")
    return
  end

  local values = GetCVarsForNameplates()
  local currentShow = addonTable.Config.Get(addonTable.Config.Options.SHOW_NAMEPLATES)

  local _, instanceType = GetInstanceInfo()
  if not self.hiddenFriendly and (instanceType == "raid" or instanceType == "party" or instanceType == "arenas") then
    if currentShow.player then
      C_CVar.SetCVar(values.player, "0")
    end
    if currentShow.npc then
      C_CVar.SetCVar(values.npc, "0")
    end
    self.hiddenFriendly = true
  elseif self.hiddenFriendly then
    if currentShow.player then
      C_CVar.SetCVar(values.player, "1")
    end
    if currentShow.npc then
      C_CVar.SetCVar(values.npc, "1")
    end
    self.hiddenFriendly = false
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
      DebuffListFrame:SetScale(designInfo.debuffs.scale)
      self.RelayoutAuras(DebuffListFrame, self.DebuffFilter)
    end
    local BuffListFrame = self.ModifiedUFs[unit].AurasFrame.BuffListFrame
    BuffListFrame:SetParent(display.BuffDisplay)
    if designInfo.buffs then
      BuffListFrame:SetScale(designInfo.buffs.scale)
      self.RelayoutAuras(BuffListFrame)
    end
    local CrowdControlListFrame = self.ModifiedUFs[unit].AurasFrame.CrowdControlListFrame
    CrowdControlListFrame:SetParent(display.CrowdControlDisplay)
    if designInfo.crowdControl then
      CrowdControlListFrame:SetScale(designInfo.crowdControl.scale)
      self.RelayoutAuras(CrowdControlListFrame)
    end
    local LossOfControlFrame = self.ModifiedUFs[unit].AurasFrame.LossOfControlFrame
    LossOfControlFrame:SetParent(display.CrowdControlDisplay)
    if designInfo.crowdControl then
      if type(designInfo.crowdControl.anchor[1]) == "string" then
        LossOfControlFrame:SetPoint(designInfo.crowdControl.anchor[1], display.CrowdControlDisplay)
      else
        LossOfControlFrame:SetPoint("CENTER")
      end
      LossOfControlFrame:SetScale(designInfo.crowdControl.scale)
    end
  end
end

function addonTable.Display.ManagerMixin:UpdateStackingRegion(nameplate, unit)
  nameplate = nameplate or C_NamePlate.GetNamePlateForUnit(unit, issecure())
  local stackRegion = self.nameplateDisplays[unit].stackRegion
  stackRegion:SetScale(addonTable.Config.Get(addonTable.Config.Options.GLOBAL_SCALE))
  stackRegion:SetPoint("BOTTOMLEFT", nameplate, "CENTER", addonTable.StackRect.left * addonTable.Config.Get(addonTable.Config.Options.CLICK_REGION_SCALE_X), addonTable.StackRect.bottom * addonTable.Config.Get(addonTable.Config.Options.CLICK_REGION_SCALE_Y))
  stackRegion:SetSize(addonTable.StackRect.width * addonTable.Config.Get(addonTable.Config.Options.STACK_REGION_SCALE_X), addonTable.StackRect.height * 1 * addonTable.Config.Get(addonTable.Config.Options.STACK_REGION_SCALE_Y))

  local stackFor = addonTable.Config.Get(addonTable.Config.Options.STACK_APPLIES_TO)
  local isMinor = UnitClassification(unit) == "minus"
  local isMinion = UnitIsMinion(unit)
  if not isMinor and not isMinion and stackFor.normal then
    stackRegion:Show()
  elseif isMinor and stackFor.minor then
    stackRegion:Show()
  elseif isMinion and stackFor.minion then
    stackRegion:Show()
  else
    stackRegion:Hide()
  end
end

function addonTable.Display.ManagerMixin:Install(unit, nameplate)
  local nameplate = C_NamePlate.GetNamePlateForUnit(unit, issecure())
  -- NOTE: the nameplate _name_ does not correspond to the unit
  if nameplate and unit and unit ~= "preview" and (addonTable.Constants.IsMidnight or not UnitIsUnit("player", unit)) then
    local newDisplay
    if not UnitCanAttack("player", unit) then
      newDisplay = self.friendDisplayPool:Acquire()
    else
      newDisplay = self.enemyDisplayPool:Acquire()
    end
    self.nameplateDisplays[unit] = newDisplay
    self.unitToNameplate[unit] = nameplate
    local UF = self.ModifiedUFs[unit]
    if UF and UF.HitTestFrame then
      if UnitCanAttack("player", unit) then
        UF.HitTestFrame:SetParent(newDisplay)
      else
        UF.HitTestFrame:SetParent(addonTable.hiddenFrame)
      end
      UF.HitTestFrame:ClearAllPoints()
      UF.HitTestFrame:SetPoint("BOTTOMLEFT", newDisplay, "CENTER", addonTable.Rect.left * addonTable.Config.Get(addonTable.Config.Options.CLICK_REGION_SCALE_X), addonTable.Rect.bottom * addonTable.Config.Get(addonTable.Config.Options.CLICK_REGION_SCALE_Y))
      UF.HitTestFrame:SetSize(addonTable.Rect.width * addonTable.Config.Get(addonTable.Config.Options.CLICK_REGION_SCALE_X), addonTable.Rect.height * addonTable.Config.Get(addonTable.Config.Options.CLICK_REGION_SCALE_Y))
      if not newDisplay.stackRegion then
        newDisplay.stackRegion = nameplate:CreateTexture()
        newDisplay.stackRegion:SetIgnoreParentScale(true)
        newDisplay.stackRegion:SetColorTexture(1, 0, 0, 0)
      end
      newDisplay.stackRegion:SetParent(nameplate)
      self:UpdateStackingRegion(nameplate, unit)
    end

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
    if display.stackRegion then
      display.stackRegion:SetParent(display)
    end
    if display.kind == "friend" then
      self.friendDisplayPool:Release(display)
    else
      self.enemyDisplayPool:Release(display)
    end
    self.nameplateDisplays[unit] = nil
    self.unitToNameplate[unit] = nil
  end
end

function addonTable.Display.ManagerMixin:UpdateForMouseover()
  for _, display in pairs(self.nameplateDisplays) do
    display:UpdateForMouseover()
  end

  if UnitExists("mouseover") and not self.MouseoverMonitor then
    self.MouseoverMonitor = C_Timer.NewTicker(0.1, function()
      self:UpdateForMouseoverFrequent()
    end)
  end
end

function addonTable.Display.ManagerMixin:UpdateForMouseoverFrequent()
  if not UnitExists("mouseover") then
    self.MouseoverMonitor:Cancel()
    self.MouseoverMonitor = nil
    self:UpdateForMouseover()
    if IsMouseButtonDown() then -- Holding down the mouse button will remove the mouseover unit temporarily
      self:RegisterEvent("GLOBAL_MOUSE_UP")
    end
  end
end

function addonTable.Display.ManagerMixin:UpdateForTarget()
  for _, display in pairs(self.nameplateDisplays) do
    display:UpdateForTarget()
  end
end

function addonTable.Display.ManagerMixin:UpdateForFocus()
  for _, display in pairs(self.nameplateDisplays) do
    display:UpdateForFocus()
  end
end

function addonTable.Display.ManagerMixin:UpdateNamePlateSize()
  local globalScale = addonTable.Config.Get(addonTable.Config.Options.GLOBAL_SCALE)
  local width = addonTable.Rect.width * globalScale
  local height = addonTable.Rect.height * globalScale

  if C_NamePlate.SetNamePlateEnemySize and not addonTable.Constants.IsMidnight then
    if InCombatLockdown() then
      self:RegisterEvent("PLAYER_REGEN_ENABLED")
      return
    end
    width = width * addonTable.Config.Get(addonTable.Config.Options.CLICK_REGION_SCALE_X) * UIParent:GetScale()
    height = height * addonTable.Config.Get(addonTable.Config.Options.CLICK_REGION_SCALE_Y) * UIParent:GetScale()
    C_NamePlate.SetNamePlateEnemySize(width, height)
    C_NamePlate.SetNamePlateFriendlySize(1, 1)
    if IsInInstance() then
      local _, instanceType = GetInstanceInfo()
      if instanceType == "raid" or instanceType == "party" or instanceType == "arenas" then
        C_NamePlate.SetNamePlateFriendlySize(width, height)
      end
    end
  --Here in case its needed in the future if Midnight's stacking changes
  --elseif C_NamePlate.SetNamePlateSize then
  --  C_NamePlate.SetNamePlateSize(width, height)
  end
end

function addonTable.Display.ManagerMixin:ImportNameplateScaleModifier(force)
  if addonTable.Constants.IsMidnight and (not IsInInstance() or force) then
    local nameplate
    for i = 1, 40 do
      unit = "nameplate" .. i
      if UnitExists(unit) then
        local target, focus = UnitIsUnit(unit, "target"), UnitIsUnit(unit, "focus")
        if force or not target and not focus then
          nameplate = C_NamePlate.GetNamePlateForUnit(unit, issecure())
          if nameplate then
            self.overrideScaleModifier = 1 / nameplate:GetScale()
            break
          end
        end
      end
    end
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
    self:UpdateForTarget()
  elseif eventName == "PLAYER_FOCUS_CHANGED" then
    self:UpdateForFocus()
  elseif eventName == "UPDATE_MOUSEOVER_UNIT" then
    self:UpdateForMouseover()
  elseif eventName == "PLAYER_SOFT_INTERACT_CHANGED" then
    if self.lastInteract and self.lastInteract.interactUnit then
      self.lastInteract:UpdateSoftInteract()
    end
    local unit
    for i = 1, 40 do
      unit = "nameplate" .. i
      if UnitIsUnit(unit, "softinteract") or UnitIsUnit(unit, "softenemy") or UnitIsUnit(unit, "softfriend") then
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
      if UnitIsUnit(unit, "target") then
        break
      else
        unit = nil
      end
    end
    if self.nameplateDisplays[unit] then
      self.nameplateDisplays[unit]:UpdateForTarget()
    end
  elseif eventName == "UNIT_FACTION" then
    local unit = ...
    local display = self.nameplateDisplays[unit]
    if display and ((display.kind == "friend" and UnitCanAttack("player", unit)) or (display.kind == "enemy" and not UnitCanAttack("player", unit))) then
      self:Uninstall(unit)
      self:Install(unit, nameplate)
    end
  elseif eventName == "GLOBAL_MOUSE_UP" then
    self:UpdateForMouseover()
    self:UnregisterEvent("GLOBAL_MOUSE_UP")
  elseif eventName == "PLAYER_REGEN_ENABLED" then
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    self:UpdateStacking()
    self:UpdateShowState()
    self:UpdateNamePlateSize()
  elseif eventName == "UI_SCALE_CHANGED" then
    for unit, display in pairs(self.nameplateDisplays) do
      display:UpdateVisual()
      if display.stackRegion then
        self:UpdateStackingRegion(nil, unit)
      end
    end
    self:UpdateNamePlateSize()
    C_Timer.After(0, function()
      self:ImportNameplateScaleModifier()
    end)
  elseif eventName == "PLAYER_ENTERING_WORLD" then
    self:UpdateInstanceShowState()
    self:UpdateNamePlateSize()
    C_Timer.After(0, function()
      self:ImportNameplateScaleModifier(true)
    end)
  elseif eventName == "PLAYER_LOGIN" then
    local design = addonTable.Core.GetDesign("enemy")

    addonTable.CurrentFont = addonTable.Core.GetFontByDesign(design)
    CreateFont("PlatynatorNameplateCooldownFont")
    local file, size, flags = _G[addonTable.CurrentFont]:GetFont()
    PlatynatorNameplateCooldownFont:SetFont(file, 14, flags)

    if C_NamePlate.SetNamePlateEnemySize then
      self:UpdateNamePlateSize()
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
  end
end
