---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Display.CreatureTextMixin = {}

local ArenaPlatesCreature = {}

local function RefreshArenaPlatesCreature()
    wipe(ArenaPlatesCreature)
    for i = 1, 5 do
        ArenaPlatesCreature[i] = C_NamePlate.GetNamePlateForUnit("arena"..i)
    end
end

local arenaFrameCreature = CreateFrame("Frame")
arenaFrameCreature:RegisterEvent("PLAYER_ENTERING_WORLD")
arenaFrameCreature:RegisterEvent("ARENA_OPPONENT_UPDATE")
arenaFrameCreature:RegisterEvent("NAME_PLATE_UNIT_ADDED")
arenaFrameCreature:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
arenaFrameCreature:SetScript("OnEvent", function()
    RefreshArenaPlatesCreature()
end)

local function GetArenaIndexByUnitCreature(unit)
    local plate = C_NamePlate.GetNamePlateForUnit(unit)
    if not plate then return nil end
    for i = 1, 5 do
        if ArenaPlatesCreature[i] and ArenaPlatesCreature[i] == plate then
            return i
        end
    end
    return nil
end

local specIDToNameCreature = {
    [250] = "Blood", [251] = "Frost", [252] = "Unholy",
    [577] = "Havoc", [581] = "Vengeance",
    [102] = "Balance", [103] = "Feral", [104] = "Guardian", [105] = "Restoration",
    [1467] = "Devastation", [1468] = "Preservation", [1473] = "Augmentation",
    [253] = "Beast Mastery", [254] = "Marksmanship", [255] = "Survival",
    [62] = "Arcane", [63] = "Fire", [64] = "Frost",
    [268] = "Brewmaster", [270] = "Mistweaver", [269] = "Windwalker",
    [65] = "Holy", [66] = "Protection", [70] = "Retribution",
    [256] = "Discipline", [257] = "Holy", [258] = "Shadow",
    [259] = "Assassination", [260] = "Outlaw", [261] = "Subtlety",
    [262] = "Elemental", [263] = "Enhancement", [264] = "Restoration",
    [265] = "Affliction", [266] = "Demonology", [267] = "Destruction",
    [71] = "Arms", [72] = "Fury", [73] = "Protection",
}

local function GetSpecNameCreature(unit)
    local idx = GetArenaIndexByUnitCreature(unit)
    if idx and GetArenaOpponentSpec then
        local specID = GetArenaOpponentSpec(idx)
        if specID then
            return specIDToNameCreature[specID]
        end
    end
    return nil
end

function addonTable.Display.CreatureTextMixin:SetUnit(unit)
  self.unit = unit
  if self.unit then
    self:RegisterUnitEvent("UNIT_NAME_UPDATE", self.unit)
    self:RegisterEvent("ARENA_OPPONENT_UPDATE")
    self.defaultText = UnitName(self.unit)
    self:UpdateText()

    addonTable.Display.RegisterForColorEvents(self, self.details.autoColors)
    self:SetColor(addonTable.Display.GetColor(self.details.autoColors, self.colorState, self.unit))

    if self.details.showWhenWowDoes then
      self:RegisterUnitEvent("UNIT_HEALTH", self.unit)
      self:SetShown(UnitShouldDisplayName(self.unit))
    end
  else
    addonTable.Display.UnregisterForColorEvents(self)
    self:UnregisterAllEvents()
    self.defaultText = nil
  end
end

function addonTable.Display.CreatureTextMixin:UpdateText()
  local isArena = IsActiveBattlefieldArena and IsActiveBattlefieldArena()
  local mode = self.details.arenaDisplayMode or "name"
  
  if isArena and self.unit and mode ~= "name" then
    local idx = GetArenaIndexByUnitCreature(self.unit)
    local specName = GetSpecNameCreature(self.unit)
    
    if mode == "arenaID" and idx then
      self.text:SetText(tostring(idx))
      return
    elseif mode == "specName" and specName then
      self.text:SetText(specName)
      return
    elseif mode == "specNameCaps" and specName then
      self.text:SetText(string.upper(specName))
      return
    elseif mode == "arenaIDSpec" and idx and specName then
      self.text:SetText(idx .. " - " .. specName)
      return
    elseif mode == "arenaIDSpecCaps" and idx and specName then
      self.text:SetText(idx .. " - " .. string.upper(specName))
      return
    end
  end
  self.text:SetText(self.defaultText)
end

function addonTable.Display.CreatureTextMixin:Strip()
  local c = self.details.color
  self.text:SetTextColor(c.r, c.g, c.b)
  self.ApplyTarget = nil
  self.ApplyTextOverride = nil
  self.defaultText = nil

  addonTable.Display.UnregisterForColorEvents(self)
  self:UnregisterAllEvents()
end

function addonTable.Display.CreatureTextMixin:SetColor(r, g, b)
  if not r then
    local c =  self.details.color
    r, g, b = c.r, c.g, c.b
  end
  self.text:SetTextColor(r, g, b)
end

function addonTable.Display.CreatureTextMixin:OnEvent(eventName, ...)
  if eventName == "UNIT_HEALTH" then
    if self.details.showWhenWowDoes then
      self:SetShown(UnitShouldDisplayName(self.unit))
    end
  elseif eventName == "UNIT_NAME_UPDATE" then
    self.defaultText = UnitName(self.unit)
    self:UpdateText()
  elseif eventName == "ARENA_OPPONENT_UPDATE" then
    RefreshArenaPlatesCreature()
    self:UpdateText()
  end

  self:ColorEventHandler(eventName)
end

function addonTable.Display.CreatureTextMixin:ApplyTarget()
  if self.details.showWhenWowDoes then
    self:SetShown(UnitShouldDisplayName(self.unit))
  end
end

function addonTable.Display.CreatureTextMixin:ApplyTextOverride()
  local override = addonTable.API.TextOverrides.name[self.unit]
  if override then
    self.text:SetText(override)
  else
    self:UpdateText()
  end
end