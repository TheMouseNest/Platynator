---@class addonTablePlatynator
local addonTable = select(2, ...)

function addonTable.Display.Initialize()
  local cache = CreateFrame("Frame")
  Mixin(cache, addonTable.Display.CacheMixin)
  cache:OnLoad()
  addonTable.Cache = cache

  local context = CreateFrame("Frame")
  Mixin(context, addonTable.Display.DesignForContextMixin)
  context:OnLoad()
  addonTable.Display.Context = context

  local manager = CreateFrame("Frame")
  Mixin(manager, addonTable.Display.ManagerMixin)
  manager:OnLoad()
end

---@class PlatynatorDisplayManager: Frame
addonTable.Display.ManagerMixin = {}
function addonTable.Display.ManagerMixin:OnLoad()
  self.styleIndex = 0
  self.pools = {}
  self.clickRegionPool = CreateFramePool("Frame")

  self.nameplateDisplays = {}
  self.nameplateClickRegions = {}

  self:SetScript("OnEvent", self.OnEvent)

  self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
  self:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
  self:RegisterEvent("PLAYER_LOGIN")
  self:RegisterEvent("PLAYER_ENTERING_WORLD")
  if C_EventUtils.IsEventValid("GARRISON_UPDATE") then
    self:RegisterEvent("GARRISON_UPDATE")
  end
  self:RegisterEvent("UI_SCALE_CHANGED")

  self:RegisterEvent("PLAYER_SOFT_INTERACT_CHANGED")

  self:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
  self:RegisterEvent("RUNE_POWER_UPDATE")
  if addonTable.Constants.IsRetail then
    self:RegisterEvent("UNIT_POWER_POINT_CHARGE")
  end
  self:RegisterEvent("PLAYER_REGEN_DISABLED")
  self:RegisterEvent("PLAYER_REGEN_ENABLED")

  C_Timer.NewTicker(0.1, function()
    for _, display in pairs(self.nameplateDisplays) do
      display:UpdateAurasForPandemic()
    end
  end)

  addonTable.CallbackRegistry:RegisterCallback("UnitDesignChange", function(_, unit)
    local display = self.nameplateDisplays[unit]
    if display then
      self:Uninstall(unit)
      self:Install(unit)
    end
  end)

  NamePlateDriverFrame:UnregisterEvent("DISPLAY_SIZE_CHANGED")
  if not addonTable.Constants.IsRetail then
    NamePlateDriverFrame:UnregisterEvent("CVAR_UPDATE")
  end

  self:RegisterEvent("VARIABLES_LOADED")

  self.ModifiedUFs = {}
  self.HookedUFs = {}

  hooksecurefunc(NamePlateDriverFrame, "OnNamePlateAdded", function(_, unit)
    if unit == "preview" then
      return
    end
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit, issecure())
    if nameplate and unit and (addonTable.Constants.IsRetail or not UnitIsUnit("player", unit)) then
      if addonTable.Constants.IsRetail then
        if not self.HookedUFs[nameplate.UnitFrame] then
          self.HookedUFs[nameplate.UnitFrame] = true
          hooksecurefunc(nameplate.UnitFrame.AurasFrame, "RefreshAuras", function(af, data)
            if not af:IsForbidden() then
              local display = self.nameplateDisplays[af:GetParent().unit]
              if display and display.unit then
                display.AurasManager:OnEvent("", "", data or {isFullUpdate = true})
              end
            end
          end)
        end
      end

      nameplate.UnitFrame:SetParent(addonTable.hiddenFrame)
      nameplate.UnitFrame:UnregisterAllEvents()

      if nameplate.UnitFrame.castBar then
        nameplate.UnitFrame.castBar:UnregisterAllEvents()
      elseif nameplate.UnitFrame.CastBarContainer then
        nameplate.UnitFrame.CastBarContainer.castBar:UnregisterAllEvents()
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
      if addonTable.Constants.IsRetail then
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
        local defaultEnemyDesign = addonTable.Core.GetDesignByName(addonTable.Display.Context:GetDefaultEnemyNPCDesign())
        addonTable.CurrentFont, addonTable.CurrentFontUsesSmoothing = addonTable.Core.GetFontByDesign(defaultEnemyDesign)
        self.styleIndex = self.styleIndex + 1
        self:UpdateFriendlyFont()
        self:UpdateNamePlateSize()
        self:SetScript("OnUpdate", nil)
        for unit in pairs(self.nameplateDisplays) do
          self:Uninstall(unit)
          self:Install(unit)
        end
        if self.lastInteract and self.lastInteract.interactUnit then
          self.lastInteract:UpdateSoftInteract()
        end
        self:UpdateStacking()
        self:UpdateAllClickRegions()
        self:UpdateTargetScale()
      end)
    end
    if state[addonTable.Constants.RefreshReason.SimplifiedScale] then
      self:UpdateSimplifiedScale()
    end
    if state[addonTable.Constants.RefreshReason.Scale] or state[addonTable.Constants.RefreshReason.TargetBehaviour] then
      self:UpdateFriendlyFont()
      self:UpdateNamePlateSize()

      for unit in pairs(self.nameplateDisplays) do
        self:Uninstall(unit)
        self:Install(unit)
      end
      self:UpdateAllClickRegions()
      self:UpdateTargetScale()
    end
    if state[addonTable.Constants.RefreshReason.StackingBehaviour] then
      self:UpdateNamePlateSize()
      self:UpdateStacking()
      for unit in pairs(self.nameplateDisplays) do
        self:Uninstall(unit)
        self:Install(unit)
      end
    end
    if state[addonTable.Constants.RefreshReason.ShowBehaviour] then
      self:UpdateFriendlyFont()
      self:UpdateNamePlateSize()
      self:RepositionDisplays()
      self:UpdateShowState()
    end
    if state[addonTable.Constants.RefreshReason.Simplified] then
      local allUnits = GetKeysArray(self.nameplateDisplays)
      for _, unit in ipairs(allUnits) do
        self:Uninstall(unit)
        local nameplate = C_NamePlate.GetNamePlateForUnit(unit, issecure())
        if nameplate then
          self:Install(unit)
        end
      end
      self:RepositionDisplays()
    end
    if state[addonTable.Constants.RefreshReason.Clickable] then
      self:UpdateNamePlateSize()
      self:UpdateClickable()
    end
    if state[addonTable.Constants.RefreshReason.DesignSelection] then
      self.styleIndex = self.styleIndex + 1
      local defaultEnemyDesign = addonTable.Core.GetDesignByName(addonTable.Display.Context:GetDefaultEnemyNPCDesign())
      addonTable.CurrentFont, addonTable.CurrentFontUsesSmoothing = addonTable.Core.GetFontByDesign(defaultEnemyDesign)
      self:UpdateFriendlyFont()
      self:UpdateNamePlateSize()
      self:UpdateAllClickRegions()
      self:RepositionDisplays()
    end
  end)

  addonTable.CallbackRegistry:RegisterCallback("SettingChanged", function(_, settingName)
    if settingName == addonTable.Config.Options.CLICK_REGION_SCALE_X
      or settingName == addonTable.Config.Options.CLICK_REGION_SCALE_Y
      or settingName == addonTable.Config.Options.VERTICAL_OFFSET
    then
      self:UpdateNamePlateSize()
      for unit in pairs(self.nameplateDisplays) do
        self:UpdateStackingRegion(unit)
      end
      self:RepositionDisplays()
      self:UpdateAllClickRegions()
      self:UpdateStacking()
    elseif settingName == addonTable.Config.Options.APPLY_CVARS then
      addonTable.Display.SetCVars()
    elseif settingName == addonTable.Config.Options.OBSCURED_ALPHA then
      self:UpdateObscuredAlpha()
    elseif settingName == addonTable.Config.Options.BLIZZARD_WIDGET_SCALE then
      for unit in pairs(self.nameplateDisplays) do
        local WidgetContainer = self.ModifiedUFs[unit].WidgetContainer
        if WidgetContainer then
          WidgetContainer:SetScale(addonTable.Config.Get(addonTable.Config.Options.BLIZZARD_WIDGET_SCALE))
        end
      end
    elseif settingName == addonTable.Config.Options.NAMEPLATE_POSITION then
      self:UpdateNamePlateSize()
      self:RepositionDisplays()
      self:UpdateNamePlatePosition()
    end
  end)

  self.showingRegion = {
    click = false,
    stack = false,
  }
  addonTable.CallbackRegistry:RegisterCallback("ShowRegion", function(_, kind, shouldShow)
    self.showingRegion[kind] = shouldShow
    if kind == "stack" then
      for unit in pairs(self.nameplateDisplays) do
        self:UpdateStackingRegion(unit)
      end
    elseif kind == "click" then
      for unit in pairs(self.nameplateDisplays) do
        self:UpdateClickRegion(unit)
      end
    end
  end)
end

function addonTable.Display.ManagerMixin:GetPool(index)
  if self.pools[index] then
    return self.pools[index]
  end

  self.pools[index] = CreateFramePool("Frame", UIParent, nil, nil, false, function(frame)
    Mixin(frame, addonTable.Display.NameplateMixin)
    frame.kind = index
    frame:OnLoad()
  end)

  return self.pools[index]
end

function addonTable.Display.ManagerMixin:CombatChangesCheck()
  if InCombatLockdown() then
    self.combatChangesPending = true
    return true
  end
  return false
end

function addonTable.Display.ManagerMixin:UpdateStacking()
  if self:CombatChangesCheck() then
    return
  end
  if addonTable.Constants.IsHitTestPointsAvailable then
    local state = addonTable.Config.Get(addonTable.Config.Options.STACKING_NAMEPLATES)
    C_CVar.SetCVarBitfield("nameplateStackingTypes", Enum.NamePlateStackType.Enemy, state.enemy)
    C_CVar.SetCVarBitfield("nameplateStackingTypes", Enum.NamePlateStackType.Friendly, state.friend)
  else
    local enemyDesign = addonTable.Core.GetDesignByName(addonTable.Display.Context:GetDefaultEnemyNPCDesign())
    local click, stack = enemyDesign.regions.click, enemyDesign.regions.stack
    C_CVar.SetCVar("nameplateOverlapH", stack.width / click.width * addonTable.Config.Get(addonTable.Config.Options.STACK_REGION_SCALE_X) / addonTable.Config.Get(addonTable.Config.Options.CLICK_REGION_SCALE_X))
    C_CVar.SetCVar("nameplateOverlapV", stack.height / click.height * addonTable.Config.Get(addonTable.Config.Options.STACK_REGION_SCALE_Y) / addonTable.Config.Get(addonTable.Config.Options.CLICK_REGION_SCALE_Y))
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
  if self:CombatChangesCheck() then
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
    }, {
      friendlyMinionPet = "nameplateShowFriendlyPlayerPets",
      friendlyMinionTotem = "nameplateShowFriendlyPlayerTotems",
      friendlyMinionGuardian = "nameplateShowFriendlyPlayerGuardians",
    }, {
      enemyMinionPet = "nameplateShowEnemyPets",
      enemyMinionTotem = "nameplateShowEnemyTotems",
      enemyMinionGuardian = "nameplateShowEnemyGuardians",
    }
  else
    return {
      friendlyPlayer = "nameplateShowFriends",
      friendlyNPC = "nameplateShowFriendlyNPCs",
      friendlyMinion = "nameplateShowFriendlyMinions",
      enemy = "nameplateShowEnemies",
      enemyMinion = "nameplateShowEnemyMinions",
      enemyMinor = "nameplateShowEnemyMinus",
    }, {
      friendlyMinionPet = "nameplateShowFriendlyPets",
      friendlyMinionTotem = "nameplateShowFriendlyTotems",
      friendlyMinionGuardian = "nameplateShowFriendlyGuardians",
    }, {
      enemyMinionPet = "nameplateShowEnemyPets",
      enemyMinionTotem = "nameplateShowEnemyTotems",
      enemyMinionGuardian = "nameplateShowEnemyGuardians",
    }
  end
end

function addonTable.Display.ManagerMixin:UpdateShowState()
  if self:CombatChangesCheck() then
    return
  end

  C_CVar.SetCVar("nameplateShowAll", addonTable.Config.Get(addonTable.Config.Options.SHOW_NAMEPLATES_ONLY_NEEDED) and "0" or "1")

  local currentShow = addonTable.Config.Get(addonTable.Config.Options.SHOW_NAMEPLATES)

  local baseValues, friendlyMinions, enemyMinions = GetCVarsForNameplates()
  if C_CVar.GetCVarInfo("nameplateShowOnlyNameForFriendlyPlayerUnits") then
    C_CVar.SetCVar("nameplateShowOnlyNameForFriendlyPlayerUnits", "0")
  end
  if C_CVar.GetCVarInfo("nameplateUseClassColorForFriendlyPlayerUnitNames") then
    C_CVar.SetCVar("nameplateUseClassColorForFriendlyPlayerUnitNames", "0")
  end

  for key, cvar in pairs(baseValues) do
    local newValue = currentShow[key] and "1" or "0"
    C_CVar.SetCVar(cvar, newValue)
  end

  if currentShow.friendlyMinion then
    for key, cvar in pairs(friendlyMinions) do
      local newValue = currentShow[key] and "1" or "0"
      C_CVar.SetCVar(cvar, newValue)
    end
  end
  if currentShow.enemyMinion then
    for key, cvar in pairs(enemyMinions) do
      local newValue = currentShow[key] and "1" or "0"
      C_CVar.SetCVar(cvar, newValue)
    end
  end

  self.toggledFriendly = false

  self:UpdateInstanceShowState()
end

function addonTable.Display.ManagerMixin:UpdateInstanceShowState()
  local state = addonTable.Config.Get(addonTable.Config.Options.SHOW_FRIENDLY_IN_INSTANCES)

  if self:CombatChangesCheck() then
    return
  end

  local relevantInstance = addonTable.Display.Utilities.IsInRelevantInstance({dungeon = true, raid = true, delve = true})

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

function addonTable.Display.ManagerMixin:UpdateNamePlatePosition()
  if self:CombatChangesCheck() then
    return
  end

  C_CVar.SetCVar("nameplateOtherAtBase", addonTable.Config.Get(addonTable.Config.Options.NAMEPLATE_POSITION) == "top" and 0 or 1)
end

function addonTable.Display.ManagerMixin:ListenToBuffs(display, unit)
  if addonTable.Constants.IsRetail and self.ModifiedUFs[unit] then
    local UF = self.ModifiedUFs[unit]
    UF:RegisterUnitEvent("UNIT_AURA", unit)

    if display.DebuffDisplay.details and display.DebuffDisplay.details.filters.important or display.BuffDisplay.details and display.BuffDisplay.details.filters.important then
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
    end
  end
end

function addonTable.Display.ManagerMixin:UpdateStackingRegion(unit)
  local stackRegion = self.nameplateDisplays[unit].stackRegion
  if not stackRegion then
    return
  end
  stackRegion.visual:SetSize(stackRegion.rect.width, stackRegion.rect.height)
  -- Avoid UIScale affecting stack regions
  local newHeight
  if addonTable.Constants.IsMidnightNext or addonTable.Constants.IsMists then
    newHeight = stackRegion.rect.height
  else
    local uiParentScale = UIParent:GetScale()
    newHeight = stackRegion.rect.height / uiParentScale - 1 / uiParentScale^2
  end
  stackRegion:SetPoint(
    "BOTTOMLEFT",
    stackRegion:GetParent(),
    "CENTER",
    stackRegion.rect.left,
    stackRegion.rect.bottom - (newHeight - stackRegion.rect.height) / 2 + self:GetBaseOffset(unit)
  )
  stackRegion:SetSize(stackRegion.rect.width, newHeight)

  stackRegion.visual:SetShown(self.showingRegion.stack)
end

function addonTable.Display.ManagerMixin:UpdateClickRegion(unit)
  local nameplate = C_NamePlate.GetNamePlateForUnit(unit, issecure())
  if nameplate and addonTable.Constants.IsHitTestPointsAvailable and nameplate:CanChangeHitTestPoints() then
    local clickRegion = self.nameplateClickRegions[nameplate:GetName()]
    if not clickRegion then
      clickRegion = self.clickRegionPool:Acquire()
      if addonTable.Constants.IsClassic then
        clickRegion:SetScale(UIParent:GetScale())
      end
      clickRegion:SetParent(nameplate)
      clickRegion.visual = clickRegion:CreateTexture()
      clickRegion.visual:SetColorTexture(addonTable.Constants.ClickRegionColor.r, addonTable.Constants.ClickRegionColor.g, addonTable.Constants.ClickRegionColor.b, addonTable.Constants.ClickRegionColor.a)
      clickRegion.visual:SetAllPoints()
      self.nameplateClickRegions[nameplate:GetName()] = clickRegion
    end
    clickRegion:Show()
    clickRegion:ClearAllPoints()
    local globalScale = addonTable.Config.Get(addonTable.Config.Options.GLOBAL_SCALE)
    local region, clickScale, scale = addonTable.Display.Context:GetClickRegion(unit)
    local width = region.width * clickScale * scale * globalScale * addonTable.Assets.BarBordersSize.width
    local height = region.height * clickScale * scale * globalScale * addonTable.Assets.BarBordersSize.height
    clickRegion:SetSize(width, height)
    if region.anchor[2] then
      local rect = addonTable.Utilities.GetRectFromRegion(region, clickScale * scale * globalScale, region.anchor, true)
      local newLeft = rect.left
      local newBottom = rect.bottom
      clickRegion:SetPoint(
        "BOTTOMLEFT",
        nameplate,
        "CENTER",
        newLeft,
        newBottom + self:GetBaseOffset(unit)
      )
    else
      clickRegion:SetPoint("CENTER", nameplate, "CENTER", 0, self:GetBaseOffset(unit))
    end
    nameplate:SetAllHitTestPoints(clickRegion)
    clickRegion.visual:SetShown(self.showingRegion.click)
  end
end

function addonTable.Display.ManagerMixin:UpdateAllClickRegions()
  if self:CombatChangesCheck() then
    return
  end

  for unit in pairs(self.nameplateDisplays) do
    self:UpdateClickRegion(unit)
  end
end

function addonTable.Display.ManagerMixin:Install(unit)
  if unit == "preview" then
    return
  end
  local nameplate = C_NamePlate.GetNamePlateForUnit(unit, issecure())
  -- NOTE: the nameplate _name_ does not correspond to the unit
  if nameplate and unit and (addonTable.Constants.IsRetail or not UnitIsUnit("player", unit)) then
    addonTable.Cache:AddUnit(unit)
    local globalScale = addonTable.Config.Get(addonTable.Config.Options.GLOBAL_SCALE)
    local designName, scale, shouldSimplify, index = addonTable.Display.Context:GetAssignedDesign(unit)
    local design = addonTable.Core.GetDesignByName(designName)
    local newDisplay = self:GetPool(index):Acquire()
    if C_NamePlateManager and C_NamePlateManager.SetNamePlateSimplified then
      C_NamePlateManager.SetNamePlateSimplified(unit, shouldSimplify)
    end
    self.nameplateDisplays[unit] = newDisplay
    newDisplay:SetParent(nameplate)
    if nameplate.SetStackingBoundsFrame then
      if not newDisplay.stackRegion then
        newDisplay.stackRegionWrapper = CreateFrame("Frame", nil, newDisplay)
        newDisplay.stackRegion = CreateFrame("Frame", nil, newDisplay.stackRegionWrapper)
        local tex = newDisplay.stackRegion:CreateTexture()
        tex:SetColorTexture(1, 0, 0, 0)
        tex:SetAllPoints(newDisplay.stackRegion)
        newDisplay.stackRegion.visual = newDisplay.stackRegion:CreateTexture()
        newDisplay.stackRegion.visual:SetColorTexture(addonTable.Constants.StackRegionColor.r, addonTable.Constants.StackRegionColor.g, addonTable.Constants.StackRegionColor.b, addonTable.Constants.StackRegionColor.a)
        newDisplay.stackRegion.visual:SetPoint("CENTER", newDisplay.stackRegion)
        if addonTable.Constants.IsClassic then
          newDisplay.stackRegion:SetScale(UIParent:GetScale())
        end
      end
      newDisplay.stackRegionWrapper:SetParent(nameplate)
      newDisplay.stackRegionWrapper:SetAllPoints()
      newDisplay.stackRegion.rect = addonTable.Utilities.GetRectFromRegion(design.regions.stack, scale * design.scale * globalScale, design.regions.stack.anchor, true)
      nameplate:SetStackingBoundsFrame(newDisplay.stackRegion)
      self:UpdateStackingRegion(unit)
    end

    self:UpdateClickRegion(unit)

    newDisplay:Install(nameplate, self:GetBaseOffset(unit) / scale / design.scale / globalScale)
    if newDisplay.styleIndex ~= self.styleIndex then
      local scaleOffset, scaleMod = addonTable.Core.GetDesignScale(shouldSimplify), scale
      newDisplay:InitializeWidgets(design, scaleOffset, scaleMod)
      newDisplay.styleIndex = self.styleIndex
    end
    self:ListenToBuffs(newDisplay, unit)
    newDisplay:SetUnit(unit)
  end
end

function addonTable.Display.ManagerMixin:Uninstall(unit)
  local display = self.nameplateDisplays[unit]
  if display then
    addonTable.Cache:RemoveUnit(unit)
    addonTable.Display.Context:RevokedUnitListeners(unit)
    display:SetUnit(nil)
    if display.stackRegion then
      display.stackRegionWrapper:SetParent(display)
    end
    self.pools[display.kind]:Release(display)
    self.nameplateDisplays[unit] = nil
  end
end

function addonTable.Display.ManagerMixin:UpdateNamePlateSize()
  if self:CombatChangesCheck() then
    return
  end

  local assignments = addonTable.Config.Get(addonTable.Config.Options.DESIGN_ASSIGNMENTS)
  local left, bottom, top, right

  for _, details in ipairs(assignments) do
    local design = addonTable.Core.GetDesignByName(details.style)
    local click = design.regions.click
    local rect = addonTable.Utilities.GetRectFromRegion(click, details.scale * design.scale, click.anchor, true)
    local newLeft = rect.left
    local newBottom = rect.bottom
    local newRight = newLeft + rect.width
    local newTop = newBottom + rect.height
    if left == nil then
      left = newLeft
      bottom = newBottom
      right = newRight
      top = newTop
    end

    left = math.min(newLeft, left)
    bottom = math.min(newBottom, bottom)
    right = math.max(newRight, right)
    top = math.max(newTop, top)
  end

  local globalScale = addonTable.Config.Get(addonTable.Config.Options.GLOBAL_SCALE)
  local verticalOffset = addonTable.Config.Get(addonTable.Config.Options.VERTICAL_OFFSET) * addonTable.Assets.BarBordersSize.height
  if not addonTable.Constants.IsHitTestPointsAvailable then
    verticalOffset = 0
  end

  local width = math.max(math.abs(right), math.abs(left)) * 2 * globalScale
  local height = (top - bottom) * globalScale
  self.baseOffsetFriendly = - height / 2 - bottom * globalScale + verticalOffset * globalScale / 2
  self.baseOffsetEnemy = self.baseOffsetFriendly
  if addonTable.Config.Get(addonTable.Config.Options.NAMEPLATE_POSITION) == "bottom" then
    self.baseOffsetEnemy = - self.baseOffsetEnemy
  end

  height = height + verticalOffset * globalScale

  if C_NamePlate.SetNamePlateSize then
    width = math.max(math.min(250, 200 * NamePlateConstants.NAME_PLATE_SCALES[tonumber(C_CVar.GetCVar("nameplateSize"))].horizontal), width)
    if self.baseBlizzHeight and self.baseBlizzHeight > height then
      local diff = -(self.baseBlizzHeight - height) / 2
      self.baseOffsetFriendly = self.baseOffsetFriendly + diff
      if addonTable.Config.Get(addonTable.Config.Options.NAMEPLATE_POSITION) == "bottom" then
        diff = -diff
      end
      self.baseOffsetEnemy = self.baseOffsetEnemy + diff
      height = self.baseBlizzHeight
    end
    if addonTable.Constants.IsClassic then
      local uiParentScale = UIParent:GetScale()
      C_NamePlate.SetNamePlateSize(width * uiParentScale, height * uiParentScale)
    else
      C_NamePlate.SetNamePlateSize(width, height)
    end
  elseif C_NamePlate.SetNamePlateEnemySize then
    width = width * UIParent:GetScale() * addonTable.Config.Get(addonTable.Config.Options.CLICK_REGION_SCALE_X)
    height = height * UIParent:GetScale() * addonTable.Config.Get(addonTable.Config.Options.CLICK_REGION_SCALE_Y)
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
      if addonTable.Display.Utilities.IsInRelevantInstance({dungeon = true, raid = true}) then
        if addonTable.Constants.IsClassic then
          C_NamePlate.SetNamePlateFriendlySize(128, 16)
        else
          C_NamePlate.SetNamePlateFriendlySize(width, height)
        end
      end
    end
  end
end

function addonTable.Display.ManagerMixin:GetBaseOffset(unit)
  local offset = self.baseOffsetFriendly
  if not UnitIsFriend("player", unit) and UnitReaction(unit, "player") ~= 4 --[[different neutral check due to np behaviour]] then
    offset = self.baseOffsetEnemy
  end
  return offset
end

function addonTable.Display.ManagerMixin:RepositionDisplays()
  local globalScale = addonTable.Config.Get(addonTable.Config.Options.GLOBAL_SCALE)
  for unit, display in pairs(self.nameplateDisplays) do
    local styleName, scale = addonTable.Display.Context:GetAssignedDesign(unit)
    local design = addonTable.Core.GetDesignByName(styleName)
    display:Install(C_NamePlate.GetNamePlateForUnit(unit), self:GetBaseOffset(unit) / scale / design.scale / globalScale)
  end
end

function addonTable.Display.ManagerMixin:UpdateClickable()
  if self:CombatChangesCheck() then
    return
  end

  local state = addonTable.Config.Get(addonTable.Config.Options.CLICKABLE_NAMEPLATES)
  if C_NamePlateManager and C_NamePlateManager.SetNamePlateHitTestInsets then
    local value = 10000

    if state.enemy then
      C_NamePlateManager.SetNamePlateHitTestInsets(Enum.NamePlateType.Enemy, 0, 0, 0, 0)
    else
      C_NamePlateManager.SetNamePlateHitTestInsets(Enum.NamePlateType.Enemy, value, value, value, value)
    end

    if state.friend then
      C_NamePlateManager.SetNamePlateHitTestInsets(Enum.NamePlateType.Friendly, 0, 0, 0, 0)
    else
      C_NamePlateManager.SetNamePlateHitTestInsets(Enum.NamePlateType.Friendly, value, value, value, value)
    end
  else
    C_NamePlate.SetNamePlateFriendlyClickThrough(not state.friend)
    C_NamePlate.SetNamePlateEnemyClickThrough(not state.enemy)
  end
end

function addonTable.Display.ManagerMixin:UpdateSimplifiedScale()
  if self:CombatChangesCheck() then
    return
  end

  if not C_CVar.GetCVarInfo("nameplateSimplifiedScale") then
    return
  end

  for unit, display in pairs(self.nameplateDisplays) do
    local _, _, shouldSimplify = addonTable.Display.Context:GetAssignedDesign(unit)
    display.offsetScale = addonTable.Core.GetDesignScale(shouldSimplify) * UIParent:GetEffectiveScale() * addonTable.Config.Get(addonTable.Config.Options.GLOBAL_SCALE)
  end

  C_CVar.SetCVar("nameplateSimplifiedScale", addonTable.Config.Get(addonTable.Config.Options.SIMPLIFIED_SCALE))
end

function addonTable.Display.ManagerMixin:UpdateObscuredAlpha()
  if InCombatLockdown() then
    return
  end
  C_CVar.SetCVar("nameplateOccludedAlphaMult", UnitAffectingCombat("player") and addonTable.Config.Get(addonTable.Config.Options.OBSCURED_COMBAT_ALPHA) or addonTable.Config.Get(addonTable.Config.Options.OBSCURED_ALPHA))
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
    local font, _, flags = newObj:GetFont()
    baseObj:SetFont(font, 9, flags)
  end
  base:SetShadowColor(new:GetShadowColor())
  base:SetShadowOffset(new:GetShadowOffset())
end

function addonTable.Display.ManagerMixin:UpdateFriendlyFont()
  if not addonTable.CurrentFont or not C_CVar.GetCVarInfo("nameplateShowOnlyNameForFriendlyPlayerUnits") then
    return
  end

  if self:CombatChangesCheck() then
    return
  end

  local state = addonTable.Config.Get(addonTable.Config.Options.SHOW_FRIENDLY_IN_INSTANCES)
  if state == "name_only" then
    local designName, scaleMult, shouldSimplify = addonTable.Display.Context:GetDefaultFriendlyPlayerDesign()
    local design = addonTable.Core.GetDesignByName(designName)
    local scale
    self.friendlyNameOnlyClassColors = false
    do
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
    end
    if not self.friendlyNameOnlyClassColors then
      for _, t in ipairs(design.specialBars) do
        if t.kind == "healthFillText" then
          for _, c in ipairs(t.autoColors) do
            if c.kind == "classColors" then
              self.friendlyNameOnlyClassColors = true
            end
          end
          scale = t.scale
          break
        end
      end
    end
    C_CVar.SetCVar("nameplateUseClassColorForFriendlyPlayerUnitNames", addonTable.Display.Utilities.IsInRelevantInstance({dungeon = true, raid = true, delve = true}) and self.friendlyNameOnlyClassColors and "1" or "0")
    if scale then
      ChangeFont(SystemFont_NamePlate_Outlined, _G[addonTable.CurrentFont])
      ChangeFont(SystemFont_NamePlate, _G[addonTable.CurrentFont])

      scale = scale * addonTable.Config.Get(addonTable.Config.Options.GLOBAL_SCALE) * design.scale * scaleMult * addonTable.Core.GetDesignScale(shouldSimplify)
      local friendlyFontSize = _G[addonTable.CurrentFont]:GetFontHeight() * scale
      for index, size in ipairs(systemFontSizes) do
        if size >= friendlyFontSize or index == 5 then
          if systemFontSizes[index - 1] and math.abs(systemFontSizes[index - 1] - friendlyFontSize) < math.abs(size - friendlyFontSize) then
            index = index - 1
          end
          local oldSize = C_CVar.GetCVar("nameplateSize")
          C_CVar.SetCVar("nameplateSize", tostring(index))
          if oldSize ~= tostring(index) then
            self:UpdateBaseNamePlateInfo()
          end
          break
        end
      end
    end
  else
    ChangeFont(SystemFont_NamePlate_Outlined, PlatynatorOriginalSystemFontOutlined)
    ChangeFont(SystemFont_NamePlate, PlatynatorOriginalSystemFont)
  end
end

function addonTable.Display.ManagerMixin:UpdateBaseNamePlateInfo()
  if addonTable.Constants.IsRetail then
    local namePlateSize = GetCVarNumberOrDefault(NamePlateConstants.SIZE_CVAR);
    -- Remove aura height
    local namePlateScale = NamePlateConstants.NAME_PLATE_SCALES[namePlateSize] or NamePlateConstants.NAME_PLATE_SCALES[Enum.NamePlateSize.Medium];
    local _
    _, self.baseBlizzHeight = C_NamePlate.GetNamePlateSize()
    local auraScale = GetCVarNumberOrDefault(NamePlateConstants.AURA_SCALE_CVAR)

    self.baseBlizzHeight = self.baseBlizzHeight - NamePlateConstants.AURA_ITEM_HEIGHT * auraScale * namePlateScale.aura - GetCVarNumberOrDefault(NamePlateConstants.DEBUFF_PADDING_CVAR)
  end
end

function addonTable.Display.ManagerMixin:OnEvent(eventName, ...)
  if eventName == "NAME_PLATE_UNIT_ADDED" then
    local unit = ...
    self:Install(unit)
  elseif  eventName == "NAME_PLATE_UNIT_REMOVED" then
    local unit = ...
    self:Uninstall(unit)
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
  elseif eventName == "UNIT_POWER_UPDATE" or eventName == "RUNE_POWER_UPDATE" or eventName == "UNIT_POWER_POINT_CHARGE" then
    for unit, display in pairs(self.nameplateDisplays) do
      if addonTable.Cache:Get(unit, "target") then
        display:UpdateForTarget()
        break
      end
    end
  elseif eventName == "PLAYER_REGEN_DISABLED" then
    self:UpdateObscuredAlpha()
  elseif eventName == "PLAYER_REGEN_ENABLED" then
    if self.combatChangesPending then
      self.combatChangesPending = false
      self:UpdateStacking()
      self:UpdateShowState()
      self:UpdateNamePlateSize()
      self:UpdateTargetScale()
      self:UpdateSimplifiedScale()
      self:UpdateClickable()
      self:UpdateAllClickRegions()
      self:UpdateNamePlatePosition()
      self:RepositionDisplays()
    end
    self:UpdateObscuredAlpha()
  elseif eventName == "UI_SCALE_CHANGED" then
    for unit, display in pairs(self.nameplateDisplays) do
      local _, _, shouldSimplify = addonTable.Display.Context:GetAssignedDesign(unit)
      display.offsetScale = addonTable.Core.GetDesignScale(shouldSimplify) * UIParent:GetEffectiveScale() * addonTable.Config.Get(addonTable.Config.Options.GLOBAL_SCALE)
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
    local defaultEnemyDesign = addonTable.Core.GetDesignByName(addonTable.Display.Context:GetDefaultEnemyNPCDesign())

    addonTable.CurrentFont, addonTable.CurrentFontUsesSmoothing = addonTable.Core.GetFontByDesign(defaultEnemyDesign)
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

    -- Remove realm name from friendly plates in instances
    if not addonTable.Constants.IsMidnightNext and addonTable.Constants.IsRetail then
      addonTable.Utilities.PurgeKey(NamePlateFriendlyFrameOptions, "updateNameUsesGetUnitName")
    end

    self:UpdateInstanceShowState()
    self:UpdateFriendlyFont()
    self:UpdateStacking()
    self:UpdateShowState()
    self:UpdateTargetScale()
    self:UpdateBaseNamePlateInfo()
    self:UpdateNamePlateSize()
    self:UpdateSimplifiedScale()
    self:UpdateObscuredAlpha()
    self:UpdateNamePlatePosition()
  end
end
