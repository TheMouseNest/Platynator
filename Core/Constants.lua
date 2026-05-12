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

  DeathKnightMaxRunes = 6,

  ButtonFrameOffset = 5,

  CustomName = "_custom",

  DefaultFont = "Roboto Condensed Bold",
  FontFamilies = {"roman", "korean", "simplifiedchinese", "traditionalchinese", "russian"},

  LayerFrameLevelStep = 500,

  CastInterruptedDelay = 0.3,
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
  ["DEATHKNIGHT"] = 30,
  [250] = 30, -- Blood
  [251] = 30, -- Frost
  [252] = 30, -- Unholy
  [1455] = 30,
  -- Demon Hunter
  ["DEMONHUNTER"] = 20,
  [577] = 20, -- Havoc
  [581] = 20, -- Vengeance
  [1480] = 25, -- Devourer
  [1456] = 20,
  -- Druid
  ["DRUID"] = 30,
  [102] = 40, -- Balance
  [103] = 5, -- Feral (8)
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
  ["MONK"] = 20,
  [268] = 25, -- Brewmaster
  [270] = 40, -- Mistweaver
  [269] = 5, -- Windwalker
  [1450] = 30,
  -- Paladin
  ["PALADIN"] = 30,
  [65] = 40, -- Holy
  [66] = 30, -- Protection
  [70] = 20, -- Retribution
  [1451] = 30,
  -- Priest
  ["PRIEST"] = 30,
  [256] = 46, -- Discipline
  [257] = 46, -- Holy
  [258] = 46, -- Shadow
  [1452] = 46,
  -- Rogue
  ["ROGUE"] = 5,
  [259] = 5, -- Assassination (8)
  [260] = 5, -- Outlaw
  [261] = 5, -- Subtlety
  [1453] = 5,
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
  ["WARRIOR"] = 20,
  [71] = 25, -- Arms
  [72] = 25, -- Fury
  [73] = 25, -- Protection
  [1446] = 25,
}
