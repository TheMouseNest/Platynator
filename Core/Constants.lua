---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Constants = {
  IsRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE,
  IsMists = WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC,
  --IsCata = WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC,
  IsWrath = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC,
  IsBC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC,
  IsEra = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC,
  IsClassic = WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE,

  IsMidnightNext = select(4, GetBuildInfo()) >= 120007,
  IsHitTestPointsAvailable = C_NamePlate.SetNamePlateSize ~= nil,
  IsSimplifiedAvailable = C_NamePlateManager and C_NamePlateManager.SetNamePlateSimplified ~= nil,
  IsCooldownFormattingAvailable = CreateFrame("Cooldown").SetCountdownFormatter ~= nil,

  DeathKnightMaxRunes = 6,

  ButtonFrameOffset = 5,

  CustomName = "_custom",

  DefaultFont = "Roboto Condensed Bold",
  FontFamilies = {"roman", "korean", "simplifiedchinese", "traditionalchinese", "russian"},

  LayerFrameLevelStep = 500,

  CastInterruptedDelay = 0.3,

  ClickRegionColor = CreateColor(5/255, 38/255, 223/255, 0.3),
  ClickRegionBorderColor = CreateColor(3/255, 21/255, 124/255),
  StackRegionColor = CreateColor(198/255, 0/255, 0/255, 0.3),
  StackRegionBorderColor = CreateColor(104/255, 0/255, 0/255),
}
addonTable.Constants.Events = {
  "SettingChanged",
  "RefreshStateChange",

  "SkinLoaded",

  "TextOverrideUpdated",

  "LegacyInterrupter",
  "QuestInfoUpdate",
  "CombatStatusChange",
  "MouseoverUpdate",

  "RoleChange",
  "EncounterUpdate",

  "CustomiseDesignsAssigned",
  "UnitDesignChange",
  "ShowRegion",
}

addonTable.Constants.RefreshReason = {
  Design = 1,
  Scale = 2,
  TargetBehaviour = 3,
  StackingBehaviour = 4,
  ShowBehaviour = 5,
  Simplified = 6,
  SimplifiedScale = 7,
  Clickable = 8,
  BlizzardWidgetScale = 9,
  DesignSelection = 10,
}

addonTable.Constants.OldFontMapping = {
  ["ArialNarrow"] = "Arial Narrow",
  ["FritzQuadrata"] = "Friz Quadrata TT",
  ["2002"] = "2002",
  ["RobotoCondensed-Bold"] = addonTable.Constants.DefaultFont,
  ["Lato-Regular"] = "Lato",
  ["Poppins-SemiBold"] = "Poppins SemiBold",
  ["DiabloHeavy"] = "Diablo Heavy",
  ["AtkinsonHyperlegible-Regular"] = "Atkinson Hyperlegible Next",
}

addonTable.Constants.PowerMap = {
  [Enum.PowerType.Mana] = "mana",
  [Enum.PowerType.Rage] = "rage",
  [Enum.PowerType.Energy] = "energy",
}

addonTable.Constants.DefaultRange = {
  -- Death Knight
  ["DEATHKNIGHT"] = 30, -- (death's reach (40))
  [250] = 30, -- Blood
  [251] = 30, -- Frost
  [252] = 30, -- Unholy
  [1455] = 30,
  -- Demon Hunter
  ["DEMONHUNTER"] = 30, -- (champion of the glaive (40))
  [577] = 30, -- Havoc,
  [581] = 30, -- Vengeance
  [1480] = 30, -- Devourer
  [1456] = 30,
  -- Druid
  ["DRUID"] = 30, -- (astral influence (45))
  [102] = 40, -- Balance
  [103] = 40, -- Feral (8)
  [104] = 40, -- Guardian
  [105] = 40, -- Resto
  [1447] = 40,
  -- Evoker
  ["EVOKER"] = 25,
  [1467] = 25, -- Devastation
  [1468] = 25, -- Preservation
  [1473] = 25, -- Augmentation
  [1465] = 25,
  -- Hunter
  ["HUNTER"] = 40,
  [253] = 40, -- Beast Mastery
  [254] = 40, -- Marksmanship
  [255] = 40, -- Survival
  [1448] = 40,
  -- Mage
  ["MAGE"] = 30,
  [62] = 40, -- Arcane
  [63] = 40, -- Fire
  [64] = 40, -- Frost
  [1449] = 40,
  -- Monk
  ["MONK"] = 30,
  [268] = 40, -- Brewmaster
  [270] = 40, -- Mistweaver
  [269] = 40, -- Windwalker
  [1450] = 30,
  -- Paladin
  ["PALADIN"] = 30,
  [65] = 40, -- Holy
  [66] = 30, -- Protection
  [70] = 30, -- Retribution
  [1451] = 30,
  -- Priest
  ["PRIEST"] = 30, -- (Phantom Reach (46))
  [256] = 40, -- Discipline
  [257] = 40, -- Holy
  [258] = 40, -- Shadow
  [1452] = 40,
  -- Rogue
  ["ROGUE"] = 30,
  [259] = 30, -- Assassination (8)
  [260] = 20, -- Outlaw (Precision shot (30))
  [261] = 30, -- Subtlety
  [1453] = 30,
  -- Shaman
  ["SHAMAN"] = 30,
  [262] = 40, -- Elemental
  [263] = 40, -- Enhancement
  [264] = 40, -- Restoration
  [1444] = 40,
  -- Warlock
  ["WARLOCK"] = 30,
  [265] = 40, -- Affliction
  [266] = 40, -- Demonology
  [267] = 40, -- Destruction
  [1454] = 40,
  ["WARRIOR"] = 20, -- (Javelineer (35))
  [71] = 30, -- Arms
  [72] = 30, -- Fury
  [73] = 30, -- Protection
  [1446] = 30,
}
addonTable.Constants.RangeModifier = {
  [276079] = 40, -- Death Knight, Death's Reach
  [429211] = 40, -- Demon Hunter, Champion of the Glaive
  [197524] = 45, -- Druid, Astral Influence
  [459559] = 46, -- Priest, Phantom Reach
  [428377] = 46, -- Rogue - Outlaw, Precision Shot
  [1271948] = 35, -- Warrior, Javelineer
}
