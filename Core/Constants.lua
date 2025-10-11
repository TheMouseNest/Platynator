---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Constants = {
  IsRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE,
  --IsMists = WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC,
  --IsCata = WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC,
  --IsWrath = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC,
  --IsEra = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC,
  IsClassic = WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE,

  IsMidnight = select(4, GetBuildInfo()) >= 120000,

  DeathKnightMaxRunes = 6,

  ButtonFrameOffset = 5,
}
addonTable.Constants.Events = {
  "SettingChanged",
  "RefreshStateChange",

  "SkinLoaded",
}

addonTable.Constants.RefreshReason = {
  Design = 1,
}
