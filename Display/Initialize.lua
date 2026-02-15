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
  self.enemySimplifiedDisplayPool = CreateFramePool("Frame", UIParent, nil, nil, false, function(frame)
    Mixin(frame, addonTable.Display.NameplateMixin)
    frame.kind = "enemySimplified"
    frame:OnLoad()
  end)
  self.nameplateDisplays = {}

  self.MouseoverMonitor = nil

  self.overrideScaleModifier = 1

  self:SetScript("OnEvent", self.OnEvent)

  self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
  self:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
  self:RegisterEvent("PLAYER_TARGET_CHANGED")
  self:RegisterEvent("PLAYER_SOFT_ENEMY_CHANGED")
  self:RegisterEvent("PLAYER_SOFT_FRIEND_CHANGED")
  self:RegisterEvent("PLAYER_SOFT_INTERACT_CHANGED")
  self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
  self:RegisterEvent("PLAYER_FOCUS_CHANGED")
  self:RegisterEvent("PLAYER_LOGIN")
  self:RegisterEvent("PLAYER_ENTERING_WORLD")
  if C_EventUtils.IsEventValid("GARRISON_UPDATE") then
    self:RegisterEvent("GARRISON_UPDATE")
  end
  self:RegisterEvent("UI_SCALE_CHANGED")

  self:RegisterEvent("PLAYER_SOFT_INTERACT_CHANGED")

  self:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
  self:RegisterEvent("RUNE_POWER_UPDATE")
  self:RegisterEvent("UNIT_FACTION")

  C_Timer.NewTicker(0.1, function() -- Used for transitioning mobs to attackable
    for unit, display in pairs(self.nameplateDisplays) do
      local display = self.nameplateDisplays[unit]
      if display and ((display.kind == "friend" and UnitCanAttack("player", unit)) or (display.kind == "enemy" and not UnitCanAttack("player", unit))) then
        self:Uninstall(unit)
        self:Install(unit, nameplate)
      end
      display:UpdateAurasForPandemic()
    end
  end)

  NamePlateDriverFrame:UnregisterEvent("DISPLAY_SIZE_CHANGED")
  if not addonTable.Constants.IsRetail then
    NamePlateDriverFrame:UnregisterEvent("CVAR_UPDATE")
  end

  self:RegisterEvent("VARIABLES_LOADED")

  self.ModifiedUFs = {}
  self.HookedUFs = {}
  self.unitToNameplate = {}
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

  local reparentedKeys = {
    "HealthBarsContainer",
    "castBar",
    "RaidTargetFrame",
    "ClassificationFrame",
    "PlayerLevelDiffFrame",
    "SoftTargetFrame",
    "name",
    "aggroHighlight",
    "aggroHighlightBase",
    "aggroHighlightAdditive",
  }
  hooksecurefunc(NamePlateDriverFrame, "OnNamePlateAdded", function(_, unit)
    if unit == "preview" then
      return
    end
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit, issecure())
    if nameplate and unit and (addonTable.Constants.IsRetail or not UnitIsUnit("player", unit)) then
      if addonTable.Constants.IsRetail then
        nameplate.UnitFrame:SetAlpha(0)
        nameplate.UnitFrame.AurasFrame.DebuffListFrame:SetParent(addonTable.hiddenFrame)
        nameplate.UnitFrame.AurasFrame.BuffListFrame:SetParent(addonTable.hiddenFrame)
        nameplate.UnitFrame.AurasFrame.CrowdControlListFrame:SetParent(addonTable.hiddenFrame)
        nameplate.UnitFrame.AurasFrame.LossOfControlFrame:SetParent(addonTable.hiddenFrame)
        for _, key in ipairs(reparentedKeys) do
          nameplate.UnitFrame[key]:SetParent(addonTable.hiddenFrame)
        end
        if not self.HookedUFs[nameplate.UnitFrame] then
          self.HookedUFs[nameplate.UnitFrame] = true
          local locked = false
          hooksecurefunc(nameplate.UnitFrame, "SetAlpha", function(UF)
            if locked or UF:IsForbidden() then
              return
            end
            locked = true
            UF:SetAlpha(0)
            locked = false
          end)
          hooksecurefunc(nameplate.UnitFrame.AurasFrame, "RefreshAuras", function(af, data)
            if not af:IsForbidden() then
              local display = self.nameplateDisplays[af:GetParent().unit]
              if display and display.unit then
                display.AurasManager:OnEvent("", "", data or {isFullUpdate = true})
              end
            end
          end)
        end
      else
        nameplate.UnitFrame:SetParent(addonTable.hiddenFrame)
      end
      nameplate.UnitFrame:UnregisterAllEvents()
      if nameplate.UnitFrame.castBar then
        nameplate.UnitFrame.castBar:UnregisterAllEvents()
      end
      if nameplate.UnitFrame.WidgetContainer then
        nameplate.UnitFrame.WidgetContainer:SetParent(nameplate)
        nameplate.UnitFrame.WidgetContainer:SetScale(addonTable.Config.Get(addonTable.Config.Options.BLIZZARD_WIDGET_SCALE))
      end
      self.ModifiedUFs[unit] = nameplate.UnitFrame
    end
  end)
  hooksecurefunc(NamePlateDriverFrame, "OnNamePlateRemoved", function(_, unit)
    if self.ModifiedUFs[unit] then
      local UF = self.ModifiedUFs[unit]
      -- Restore original anchors and parents to various things we changed
      if addonTable.Constants.IsRetail then
        for _, key in ipairs(reparentedKeys) do
          UF[key]:SetParent(UF)
        end
        UF.AurasFrame.DebuffListFrame:SetParent(UF.AurasFrame)
        UF.AurasFrame.BuffListFrame:SetParent(UF.AurasFrame)
        UF.AurasFrame.CrowdControlListFrame:SetParent(UF.AurasFrame)
        UF.AurasFrame.LossOfControlFrame:SetParent(UF.AurasFrame)
        UF:UnregisterEvent("UNIT_AURA")
      end
      if UF.WidgetContainer then
        UF.WidgetContainer:SetParent(UF)
        UF.WidgetContainer:SetScale(1)
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
            self:UpdateStackingRegion(unit)
          end
          display:InitializeWidgets(addonTable.Core.GetDesign(display.kind), addonTable.Core.GetDesignScale(display.kind))
          self:ListenToBuffs(display, unit)
          display:SetUnit(unit)
        end
        if self.lastInteract and self.lastInteract.interactUnit then
          self.lastInteract:UpdateSoftInteract()
        end
        self:UpdateFriendlyFont()
        self:UpdateNamePlateSize()
        self:UpdateStacking()
        self:UpdateTargetScale()
      end)
    end
    if state[addonTable.Constants.RefreshReason.SimplifiedScale] then
      self:UpdateSimplifiedScale()
    end
    if state[addonTable.Constants.RefreshReason.Scale] or state[addonTable.Constants.RefreshReason.TargetBehaviour] then
      for unit, display in pairs(self.nameplateDisplays) do
        display.offsetScale = addonTable.Core.GetDesignScale(display.kind) * UIParent:GetEffectiveScale() * addonTable.Config.Get(addonTable.Config.Options.GLOBAL_SCALE)
        display:UpdateVisual()
        if display.stackRegion then
          self:UpdateStackingRegion(unit)
        end
      end
      self:UpdateFriendlyFont()
      self:UpdateNamePlateSize()
      self:UpdateTargetScale()
    end
    if state[addonTable.Constants.RefreshReason.StackingBehaviour] then
      self:UpdateStacking()
      self:UpdateNamePlateSize()
      for unit, display in pairs(self.nameplateDisplays) do
        if display.stackRegion then
          self:UpdateStackingRegion(unit)
        end
      end
    end
    if state[addonTable.Constants.RefreshReason.ShowBehaviour] then
      self:UpdateFriendlyFont()
      self:UpdateNamePlateSize()
      self:UpdateShowState()
    end
    if state[addonTable.Constants.RefreshReason.Simplified] then
      local allUnits = GetKeysArray(self.nameplateDisplays)
      for _, unit in ipairs(allUnits) do
        self:Uninstall(unit)
        local nameplate = C_NamePlate.GetNamePlateForUnit(unit, issecure())
        if nameplate then
          self:Install(unit, nameplate)
        end
      end
    end
    if state[addonTable.Constants.RefreshReason.Clickable] then
      self:UpdateClickable()
      self:UpdateNamePlateSize()
    end
  end)

  addonTable.CallbackRegistry:RegisterCallback("SettingChanged", function(_, settingName)
    if settingName == addonTable.Config.Options.CLICK_REGION_SCALE_X or settingName == addonTable.Config.Options.CLICK_REGION_SCALE_Y then
      for unit, UF in pairs(self.ModifiedUFs) do
        if UF.HitTestFrame then
          self:UpdateStackingRegion(unit)
        end
      end
      self:UpdateNamePlateSize()
      self:UpdateStacking()
    elseif settingName == addonTable.Config.Options.APPLY_CVARS then
      addonTable.Display.SetCVars()
    elseif settingName == addonTable.Config.Options.OBSCURED_ALPHA then
      self:UpdateObscuredAlpha()
    elseif settingName == addonTable.Config.Options.BLIZZARD_WIDGET_SCALE then
      for unit, _ in pairs(self.nameplateDisplays) do
        self.ModifiedUFs[unit].WidgetContainer:SetScale(addonTable.Config.Get(addonTable.Config.Options.BLIZZARD_WIDGET_SCALE))
      end
    end
  end)
end

function addonTable.Display.ManagerMixin:UpdateStacking()
  if InCombatLockdown() then
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    return
  end
  if addonTable.Constants.IsRetail then
    local state = addonTable.Config.Get(addonTable.Config.Options.STACKING_NAMEPLATES)
    C_CVar.SetCVarBitfield("nameplateStackingTypes", Enum.NamePlateStackType.Enemy, state.enemy)
    C_CVar.SetCVarBitfield("nameplateStackingTypes", Enum.NamePlateStackType.Friendly, state.friend)
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

    local state = addonTable.Config.Get(addonTable.Config.Options.STACKING_NAMEPLATES)
    C_CVar.SetCVar("nameplateMotion", (state.enemy or state.friend) and "1" or "0")
  end
end

function addonTable.Display.ManagerMixin:UpdateTargetScale()
  if InCombatLockdown() then
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    return
  end

  C_CVar.SetCVar("nameplateSelectedScale", addonTable.Config.Get(addonTable.Config.Options.TARGET_SCALE))
end

local function GetCVarsForNameplates()
  if C_CVar.GetCVarInfo("nameplateShowFriendlyPlayers") ~= nil then
    return {
      friendlyPlayer = "nameplateShowFriendlyPlayers",
      friendlyNPC = "nameplateShowFriendlyNpcs",
      friendlyMinion = "nameplateShowFriendlyPlayerMinions",
      enemy = "nameplateShowEnemies",
      enemyMinion = "nameplateShowEnemyMinions",
      enemyMinor = "nameplateShowEnemyMinus",
    }
  else
    return {
      friendlyPlayer = "nameplateShowFriends",
      friendlyNPC = "nameplateShowFriendlyNPCs",
      friendlyMinion = "nameplateShowFriendlyMinions",
      enemy = "nameplateShowEnemies",
      enemyMinion = "nameplateShowEnemyMinions",
      enemyMinor = "nameplateShowEnemyMinus",
    }
  end
end

function addonTable.Display.ManagerMixin:UpdateShowState()
  if InCombatLockdown() then
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    return
  end

  C_CVar.SetCVar("nameplateShowAll", addonTable.Config.Get(addonTable.Config.Options.SHOW_NAMEPLATES_ONLY_NEEDED) and "0" or "1")

  local currentShow = addonTable.Config.Get(addonTable.Config.Options.SHOW_NAMEPLATES)

  local values = GetCVarsForNameplates()
  if C_CVar.GetCVarInfo("nameplateShowOnlyNameForFriendlyPlayerUnits") then
    C_CVar.SetCVar("nameplateShowOnlyNameForFriendlyPlayerUnits", "0")
  end
  if C_CVar.GetCVarInfo("nameplateUseClassColorForFriendlyPlayerUnitNames") then
    C_CVar.SetCVar("nameplateUseClassColorForFriendlyPlayerUnitNames", "0")
  end

  for key, state in pairs(currentShow) do
    local newValue = state and "1" or "0"
    C_CVar.SetCVar(values[key], newValue)
  end
  self.toggledFriendly = false

  self:UpdateInstanceShowState()
end

function addonTable.Display.ManagerMixin:UpdateInstanceShowState()
  local state = addonTable.Config.Get(addonTable.Config.Options.SHOW_FRIENDLY_IN_INSTANCES)

  if InCombatLockdown() then
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    return
  end

  local relevantInstance = addonTable.Display.Utilities.IsInRelevantInstance()

  if state == "name_only" and C_CVar.GetCVarInfo("nameplateShowOnlyNameForFriendlyPlayerUnits") then
    C_CVar.SetCVar("nameplateShowOnlyNameForFriendlyPlayerUnits", relevantInstance and "1" or "0")
    C_CVar.SetCVar("nameplateUseClassColorForFriendlyPlayerUnitNames", relevantInstance and self.friendlyNameOnlyClassColors and "1" or "0")
  end

  local values = GetCVarsForNameplates()
  local currentShow = addonTable.Config.Get(addonTable.Config.Options.SHOW_NAMEPLATES)

  if relevantInstance then
    if not self.toggledFriendly and
      (state == "name_only" and not currentShow.friendlyPlayer
      or state == "never" and (currentShow.friendlyPlayer or currentShow.friendlyNPC)
      or state == "name_only" and currentShow.friendlyNPC)
      or state == "always" and (not currentShow.friendlyPlayer or not currentShow.friendlyNPC) then
      C_CVar.SetCVar(values.friendlyPlayer, state == "never" and "0" or "1")
      if currentShow.friendlyNPC then
        C_CVar.SetCVar(values.friendlyNPC, state ~= "always" and "0" or "1")
      end
      self.toggledFriendly = true
    end
  elseif self.toggledFriendly then
    if currentShow.friendlyPlayer then
      C_CVar.SetCVar(values.friendlyPlayer, "1")
    elseif state ~= "never" then
      C_CVar.SetCVar(values.friendlyPlayer, "0")
    end
    if currentShow.friendlyNPC then
      C_CVar.SetCVar(values.friendlyNPC, "1")
    elseif state == "always" then
      C_CVar.SetCVar(values.friendlyNPC, "0")
    end
    self.toggledFriendly = false
  end
end

function addonTable.Display.ManagerMixin:ListenToBuffs(display, unit)
  if addonTable.Constants.IsRetail and self.ModifiedUFs[unit] then
    local UF = self.ModifiedUFs[unit]
    if display.DebuffDisplay.details and display.DebuffDisplay.details.filters.important or display.BuffDisplay.details and display.BuffDisplay.details.filters.important then
      UF:RegisterUnitEvent("UNIT_AURA", unit)

      local DebuffListFrame = UF.AurasFrame.DebuffListFrame
      local BuffListFrame = UF.AurasFrame.BuffListFrame

      display.AurasManager:SetGetImportantAuras(function()
        local important = {}

        UF.AurasFrame.buffList:Iterate(function(auraInstanceID)
          important[auraInstanceID] = true
        end)
        UF.AurasFrame.debuffList:Iterate(function(auraInstanceID)
          important[auraInstanceID] = true
        end)

        return important
      end)
    else
      UF:UnregisterEvent("UNIT_AURA")
    end
  end
end

function addonTable.Display.ManagerMixin:UpdateStackingRegion(unit)
  local stackRegion = self.nameplateDisplays[unit].stackRegion
  local globalScale = addonTable.Config.Get(addonTable.Config.Options.GLOBAL_SCALE)
  local newWidth = addonTable.StackRect.width * addonTable.Config.Get(addonTable.Config.Options.STACK_REGION_SCALE_X) * globalScale
  local newHeight = addonTable.StackRect.height * addonTable.Config.Get(addonTable.Config.Options.STACK_REGION_SCALE_Y) * globalScale
  stackRegion:SetPoint("BOTTOMLEFT", stackRegion:GetParent(), "CENTER", addonTable.StackRect.left - (newWidth - addonTable.StackRect.width)/2, addonTable.StackRect.bottom - (newHeight - addonTable.StackRect.height)/2)
  stackRegion:SetSize(newWidth, newHeight)
end

function addonTable.Display.ManagerMixin:Install(unit, nameplate)
  if unit == "preview" then
    return
  end
  local nameplate = C_NamePlate.GetNamePlateForUnit(unit, issecure())
  -- NOTE: the nameplate _name_ does not correspond to the unit
  if nameplate and unit and (addonTable.Constants.IsRetail or not UnitIsUnit("player", unit)) then
    local shouldSimplify = false
    local newDisplay
    if not UnitCanAttack("player", unit) then
      newDisplay = self.friendDisplayPool:Acquire()
    else
      local simplifiedSettings = addonTable.Config.Get(addonTable.Config.Options.SIMPLIFIED_NAMEPLATES)
      local classification = UnitClassification(unit)
      shouldSimplify = C_NamePlateManager and C_NamePlateManager.SetNamePlateSimplified and (
        simplifiedSettings.instancesNormal and classification == "normal" and addonTable.Display.Utilities.IsInRelevantInstance() or
        simplifiedSettings.minor and classification == "minus" or
        simplifiedSettings.minion and UnitIsMinion and UnitIsMinion(unit)
      )
      if shouldSimplify then
        newDisplay = self.enemySimplifiedDisplayPool:Acquire()
      else
        newDisplay = self.enemyDisplayPool:Acquire()
      end
    end
    if C_NamePlateManager and C_NamePlateManager.SetNamePlateSimplified then
      C_NamePlateManager.SetNamePlateSimplified(unit, shouldSimplify)
    end
    self.nameplateDisplays[unit] = newDisplay
    self.unitToNameplate[unit] = nameplate
    local UF = self.ModifiedUFs[unit]
    if nameplate.SetStackingBoundsFrame then
      newDisplay:SetParent(nameplate)
      if not newDisplay.stackRegion then
        newDisplay.stackRegion = CreateFrame("Frame", nil, newDisplay)
        local tex = newDisplay.stackRegion:CreateTexture()
        tex:SetColorTexture(1, 0, 0, 0)
        tex:SetAllPoints(newDisplay.stackRegion)
      end
      newDisplay.stackRegion:SetParent(nameplate)
      nameplate:SetStackingBoundsFrame(newDisplay.stackRegion)
      self:UpdateStackingRegion(unit)
    elseif UF and UF.HitTestFrame then
      if not newDisplay.stackRegion then
        newDisplay.stackRegion = nameplate:CreateTexture()
        newDisplay.stackRegion:SetIgnoreParentScale(true)
        newDisplay.stackRegion:SetColorTexture(1, 0, 0, 0)
      end
      newDisplay.stackRegion:SetIgnoreParentScale(true)
      newDisplay.stackRegion:SetParent(nameplate)
      self:UpdateStackingRegion(unit)
    else
      newDisplay:SetParent(nameplate)
    end

    newDisplay:Install(nameplate)
    if newDisplay.styleIndex ~= self.styleIndex then
      newDisplay:InitializeWidgets(addonTable.Core.GetDesign(newDisplay.kind), addonTable.Core.GetDesignScale(newDisplay.kind))
      newDisplay.styleIndex = self.styleIndex
    end
    self:ListenToBuffs(newDisplay, unit)
    newDisplay:SetUnit(unit)
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
    elseif display.kind == "enemySimplified" then
      self.enemySimplifiedDisplayPool:Release(display)
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
  if InCombatLockdown() then
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    return
  end

  local globalScale = addonTable.Config.Get(addonTable.Config.Options.GLOBAL_SCALE)
  local width = addonTable.Rect.width * globalScale
  local height = addonTable.Rect.height * globalScale

  if C_NamePlate.SetNamePlateEnemySize and not addonTable.Constants.IsRetail then
    width = width * addonTable.Config.Get(addonTable.Config.Options.CLICK_REGION_SCALE_X) * UIParent:GetScale()
    height = height * addonTable.Config.Get(addonTable.Config.Options.CLICK_REGION_SCALE_Y) * UIParent:GetScale()
    local stackState = addonTable.Config.Get(addonTable.Config.Options.STACKING_NAMEPLATES)
    local anyStack = stackState.enemy or stackState.friend
    if stackState.enemy or not anyStack then
      C_NamePlate.SetNamePlateEnemySize(width, height)
    else
      C_NamePlate.SetNamePlateEnemySize(1, 1)
    end
    if stackState.friend or not anyStack then
      C_NamePlate.SetNamePlateFriendlySize(width, height)
    else
      C_NamePlate.SetNamePlateFriendlySize(1, 1)
    end
    if IsInInstance() then
      if addonTable.Display.Utilities.IsInRelevantInstance() then
        if addonTable.Constants.IsClassic then
          C_NamePlate.SetNamePlateFriendlySize(128, 16)
        else
          C_NamePlate.SetNamePlateFriendlySize(width, height)
        end
      end
    end
  elseif C_NamePlate.SetNamePlateSize then
    width = width * addonTable.Config.Get(addonTable.Config.Options.CLICK_REGION_SCALE_X)
    height = height * addonTable.Config.Get(addonTable.Config.Options.CLICK_REGION_SCALE_Y)
    C_NamePlate.SetNamePlateSize(width, height)
  end
end

function addonTable.Display.ManagerMixin:UpdateClickable()
  if InCombatLockdown() then
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    return
  end

  local state = addonTable.Config.Get(addonTable.Config.Options.CLICKABLE_NAMEPLATES)
  if C_NamePlateManager and C_NamePlateManager.SetNamePlateHitTestInsets then
    local value = 10000

    if state.enemy then
      C_NamePlateManager.SetNamePlateHitTestInsets(Enum.NamePlateType.Enemy, -value, -value, -value, -value)
    else
      C_NamePlateManager.SetNamePlateHitTestInsets(Enum.NamePlateType.Enemy, value, value, value, value)
    end

    if state.friend then
      C_NamePlateManager.SetNamePlateHitTestInsets(Enum.NamePlateType.Friendly, -value, -value, -value, -value)
    else
      C_NamePlateManager.SetNamePlateHitTestInsets(Enum.NamePlateType.Friendly, value, value, value, value)
    end
  else
    C_NamePlate.SetNamePlateFriendlyClickThrough(not state.friend)
    C_NamePlate.SetNamePlateEnemyClickThrough(not state.enemy)
  end
end

function addonTable.Display.ManagerMixin:UpdateSimplifiedScale()
  if InCombatLockdown() then
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    return
  end

  if not C_CVar.GetCVarInfo("nameplateSimplifiedScale") then
    return
  end

  for unit, display in pairs(self.nameplateDisplays) do
    display.offsetScale = addonTable.Core.GetDesignScale(display.kind) * UIParent:GetEffectiveScale() * addonTable.Config.Get(addonTable.Config.Options.GLOBAL_SCALE)
  end

  C_CVar.SetCVar("nameplateSimplifiedScale", addonTable.Config.Get(addonTable.Config.Options.SIMPLIFIED_SCALE))
end

function addonTable.Display.ManagerMixin:UpdateObscuredAlpha()
  if InCombatLockdown() then
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    return
  end

  C_CVar.SetCVar("nameplateOccludedAlphaMult", addonTable.Config.Get(addonTable.Config.Options.OBSCURED_ALPHA))
end

local systemFontSizes = {}
if SystemFont_NamePlate_Outlined then
  local members = {
    {
      alphabet = "roman",
      file ="Fonts/FRIZQT__.TTF",
      height = 9,
      flags = "SLUG",
    },
    {
      alphabet = "korean",
      file ="Fonts/2002.TTF",
      height = 9,
      flags = "SLUG",
    },
    {
      alphabet = "simplifiedchinese",
      file ="Fonts/ARKai_T.ttf",
      height = 9,
      flags = "SLUG",
    },
    {
      alphabet = "traditionalchinese",
      file ="Fonts/blei00d.TTF",
      height = 9,
      flags = "SLUG",
    },
    {
      alphabet = "russian",
      file ="Fonts/FRIZQT___CYR.TTF",
      height = 9,
      flags = "SLUG",
    },
  }
  CreateFontFamily("PlatynatorOriginalSystemFont", members)
  for _, m in ipairs(members) do
    m.flags = m.flags .. " OUTLINE"
  end
  CreateFontFamily("PlatynatorOriginalSystemFontOutlined", members)

  for i = 1, 5 do
    local details = NamePlateConstants.NAME_PLATE_SCALES[i]
    local size = details.vertical * NamePlateConstants.HEALTH_BAR_FONT_HEIGHT
    table.insert(systemFontSizes, size)
  end
end

local function ChangeFont(base, new, overrideHeight)
  for _, a in ipairs(addonTable.Constants.FontFamilies) do
    local baseObj = base:GetFontObjectForAlphabet(a)
    local newObj = new:GetFontObjectForAlphabet(a)
    local font, height, flags = newObj:GetFont()
    baseObj:SetFont(font, 9, flags)
  end
  base:SetShadowColor(new:GetShadowColor())
  base:SetShadowOffset(new:GetShadowOffset())
end

function addonTable.Display.ManagerMixin:UpdateFriendlyFont()
  if not addonTable.CurrentFont or not C_CVar.GetCVarInfo("nameplateShowOnlyNameForFriendlyPlayerUnits") then
    return
  end

  if InCombatLockdown() then
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    return
  end

  local state = addonTable.Config.Get(addonTable.Config.Options.SHOW_FRIENDLY_IN_INSTANCES)
  if state == "name_only" then
    local design = addonTable.Core.GetDesign("friend")
    local scale
    self.friendlyNameOnlyClassColors = false
    for _, t in ipairs(design.texts) do
      if t.kind == "creatureName" then
        for _, c in ipairs(t.autoColors) do
          if c.kind == "classColors" then
            self.friendlyNameOnlyClassColors = true
          end
        end
        scale = t.scale
        break
      end
    end
    C_CVar.SetCVar("nameplateUseClassColorForFriendlyPlayerUnitNames", addonTable.Display.Utilities.IsInRelevantInstance() and self.friendlyNameOnlyClassColors and "1" or "0")
    if scale then
      ChangeFont(SystemFont_NamePlate_Outlined, _G[addonTable.CurrentFont])
      ChangeFont(SystemFont_NamePlate, _G[addonTable.CurrentFont])

      scale = scale * addonTable.Config.Get(addonTable.Config.Options.GLOBAL_SCALE) * design.scale
      local friendlyFontSize = _G[addonTable.CurrentFont]:GetFontHeight() * scale
      for index, size in ipairs(systemFontSizes) do
        if size >= friendlyFontSize or index == 5 then
          if systemFontSizes[index - 1] and math.abs(systemFontSizes[index - 1] - friendlyFontSize) < math.abs(size - friendlyFontSize) then
            index = index - 1
          end
          C_CVar.SetCVar("nameplateSize", tostring(index))
          break
        end
      end
    end
  else
    ChangeFont(SystemFont_NamePlate_Outlined, PlatynatorOriginalSystemFontOutlined)
    ChangeFont(SystemFont_NamePlate, PlatynatorOriginalSystemFont)
  end
end

function addonTable.Display.ManagerMixin:OnEvent(eventName, ...)
  if eventName == "NAME_PLATE_UNIT_ADDED" then
    local unit = ...
    self:Install(unit)
  elseif  eventName == "NAME_PLATE_UNIT_REMOVED" then
    local unit = ...
    self:Uninstall(unit)
  elseif eventName == "PLAYER_TARGET_CHANGED" or eventName == "PLAYER_SOFT_ENEMY_CHANGED" or eventName == "PLAYER_SOFT_FRIEND_CHANGED" then
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
    for _, display in pairs(self.nameplateDisplays) do
      display:UpdateForTarget()
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
    self:UpdateTargetScale()
    self:UpdateSimplifiedScale()
    self:UpdateObscuredAlpha()
    self:UpdateClickable()
  elseif eventName == "UI_SCALE_CHANGED" then
    for unit, display in pairs(self.nameplateDisplays) do
      display.offsetScale = addonTable.Core.GetDesignScale(display.kind) * UIParent:GetEffectiveScale() * addonTable.Config.Get(addonTable.Config.Options.GLOBAL_SCALE)
      if display.stackRegion then
        self:UpdateStackingRegion(unit)
      end
    end
    self:UpdateNamePlateSize()
  elseif eventName == "PLAYER_ENTERING_WORLD" then
    self:UpdateInstanceShowState()
    self:UpdateNamePlateSize()
    self:UpdateClickable()
  elseif eventName == "GARRISON_UPDATE" then
    self:UpdateInstanceShowState()
  elseif eventName == "PLAYER_LOGIN" then
    local design = addonTable.Core.GetDesign("enemy")

    addonTable.CurrentFont = addonTable.Core.GetFontByDesign(design)
    CreateFont("PlatynatorNameplateCooldownFont")
    local file, size, flags = _G[addonTable.CurrentFont]:GetFont()
    PlatynatorNameplateCooldownFont:SetFont(file, 14, flags)
    self:UpdateFriendlyFont()
  elseif eventName == "VARIABLES_LOADED" then
    if addonTable.Constants.IsRetail then
      C_CVar.SetCVarBitfield(NamePlateConstants.ENEMY_NPC_AURA_DISPLAY_CVAR, Enum.NamePlateEnemyNpcAuraDisplay.Debuffs, true)
      C_CVar.SetCVarBitfield(NamePlateConstants.ENEMY_NPC_AURA_DISPLAY_CVAR, Enum.NamePlateEnemyNpcAuraDisplay.Buffs, true)
      C_CVar.SetCVarBitfield(NamePlateConstants.ENEMY_PLAYER_AURA_DISPLAY_CVAR, Enum.NamePlateEnemyPlayerAuraDisplay.Debuffs, true)
      C_CVar.SetCVarBitfield(NamePlateConstants.ENEMY_PLAYER_AURA_DISPLAY_CVAR, Enum.NamePlateEnemyPlayerAuraDisplay.Buffs, true)

      --C_CVar.SetCVarBitfield(NamePlateConstants.FRIENDLY_PLAYER_AURA_DISPLAY_CVAR, Enum.NamePlateFriendlyPlayerAuraDisplay.Debuffs, true)
    end
    addonTable.Display.SetCVars()

    self:UpdateInstanceShowState()
    self:UpdateFriendlyFont()
    self:UpdateStacking()
    self:UpdateShowState()
    self:UpdateTargetScale()
    self:UpdateNamePlateSize()
    self:UpdateSimplifiedScale()
    self:UpdateObscuredAlpha()
  end
end
