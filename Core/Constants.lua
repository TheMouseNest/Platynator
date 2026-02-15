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

  IsMidnight = select(4, GetBuildInfo()) >= 120001,

  DeathKnightMaxRunes = 6,

  ButtonFrameOffset = 5,

  CustomName = "_custom",

  DefaultFont = "Roboto Condensed Bold",
  FontFamilies = {"roman", "korean", "simplifiedchinese", "traditionalchinese", "russian"},
}
addonTable.Constants.Events = {
  "SettingChanged",
  "RefreshStateChange",

  "SkinLoaded",

  "TextOverrideUpdated",

  "LegacyInterrupter",
  "QuestInfoUpdate",
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
