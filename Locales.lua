---@class addonTableBaganator
local addonTable = select(2, ...)
local Locales = {
  enUS = {},
  frFR = {},
  deDE = {},
  ruRU = {},
  ptBR = {},
  esES = {},
  esMX = {},
  zhTW = {},
  zhCN = {},
  koKR = {},
  itIT = {},
}

PLATYNATOR_LOCALES = Locales

local L = Locales.enUS

L["PLATYNATOR"] = "Platynator"
L["DESIGNER"] = "Designer"
L["BEHAVIOUR"] = "Behaviour"
L["GENERAL"] = "General"
L["FONT"] = "Font"
L["SHOW_OUTLINE"] = "Show outline"
L["SHOW_SHADOW"] = "Show shadow"
L["STYLE"] = "Style"
L["CUSTOMISE_PLATYNATOR"] = "Customise Platynator"
L["CTRL_C_TO_COPY"] = "Ctrl+C to copy"
L["JOIN_THE_DISCORD"] = "Join the Discord"
L["DISCORD_DESCRIPTION"] = "Updates, feature suggestions and support"
L["BY_PLUSMOUSE"] = "by plusmouse"
L["DEVELOPMENT_IS_TIME_CONSUMING"] = "|cff04cca4Development takes a huge amount of time|r"
L["DONATE"] = "Donate"
L["LINK"] = "Link"
L["VERSION_COLON_X"] = "Version: %s"
L["TO_OPEN_OPTIONS_X"] = "Access options with /platy"
L["OPEN_OPTIONS"] = "Open Options"
L["GLOBAL_SCALE"] = "Global scale"
L["SCALE"] = "Scale"
L["FILLED"] = "Filled"
L["EMPTY"] = "Empty"
L["BORDER_COLOR"] = "Border color"
L["ABSOLUTE_VALUE"] = "Absolute value"
L["PERCENTAGE_VALUE"] = "Percentage value"
L["NO_VALUE_UPPER"] = "NO VALUE"
L["ARCANE_FLURRY"] = "Arcane Flurry"
L["NORMAL_CAST_COLOR"] = "Normal cast color"
L["UNINTERRUPTABLE_CAST_COLOR"] = "Uninterruptable cast color"
L["INTERRUPTED_CAST_COLOR"] = "Interrupted cast color"
L["INTERRUPTED"] = "Interrupted"
L["WIDTH_RESTRICTION"] = "Width restriction"
L["CENTER"] = "Center"
L["LEFT"] = "Left"
L["RIGHT"] = "Right"
L["ALIGNMENT"] = "Alignment"
L["TEXTURES"] = "Textures"
L["COLORS"] = "Colors"
L["SIZE_AND_POSITION"] = "Size and position"
L["AGGRO_SAFE"] = "Aggro safe"
L["AGGRO_TRANSITION"] = "Aggro transition"
L["AGGRO_WARNING"] = "Aggro warning"
L["AGGRO_OFFTANK"] = "Aggro off-tank"
L["FRIENDLY"] = "Friendly"
L["NEUTRAL"] = "Neutral"
L["HOSTILE"] = "Hostile"
L["AGGRO_COLORS_ON_HOSTILES"] = "Aggro colors on hostiles"
L["MULTIPLE_SELECTED"] = "Multiple Selected"
L["FADE"] = "Fade"
L["DIRECTION"] = "Direction"
L["SHORTEN"] = "Shorten"
L["SHOW_ALL"] = "Show all"
L["LAST_WORD"] = "Last word"
L["FIRST_WORD"] = "First word"

L["FOREGROUND"] = "Foreground"
L["VISUAL"] = "Visual"
L["BACKGROUND"] = "Background"
L["BACKGROUND_TRANSPARENCY"] = "Background transparency"
L["APPLY_MAIN_COLOR_TO_BACKGROUND"] = "Apply main color to background"
L["BORDER"] = "Border"
L["COLOR"] = "Color"

L["ON_TARGET_OR_CASTING"] = "On target (or casting)"
L["ON_NON_TARGET_AND_NON_CASTING"] = "On non-target (and non-casting)"
L["ENLARGE_NAMEPLATE"] = "Enlarge nameplate"
L["DO_NOTHING"] = "Do nothing"
L["SPECIAL_BRACKETS"] = "(Special)"
L["NARROW_BRACKETS"] = "(Narrow)"
L["NONE"] = "None"

L["ENTER_PROFILE_NAME"] = "Enter Profile Name:"
L["PROFILES"] = "Profiles"
L["NEW_PROFILE_CLONE"] = "New Profile (clone current)"
L["NEW_PROFILE_BLANK"] = "New Profile (blank)"
L["CONFIRM_DELETE_PROFILE_X"] = "Are you sure you want to delete profile \"%s\"?"

L["EXPORT"] = "Export"
L["IMPORT"] = "Import"
L["PASTE_YOUR_IMPORT_STRING_HERE"] = "Paste your import string here"

L["SQUIRREL"] = "Squirrel"
L["RABBIT"] = "Rabbit"
L["BEAVER"] = "Beaver"
L["HARE"] = "Hare"
L["HEDGEHOG"] = "Hedgehog"
L["BLIZZARD"] = "Blizzard"
L["BLIZZARD_CLASSIC"] = "Blizzard Classic"
L["CUSTOM"] = "Custom"

L["ADD_WIDGET"] = "Add Widget"
L["DELETE_WIDGET"] = "Delete Widget"
L["BARS"] = "Bars"
L["HEALTH"] = "Health"
L["CAST"] = "Cast"
L["POWER"] = "Power"
L["HIGHLIGHTS"] = "Highlights"
L["TARGETED"] = "Targeted"
L["AURAS"] = "Auras"
L["BUFFS"] = "Buffs"
L["DEBUFFS"] = "Debuffs"
L["CROWD_CONTROL"] = "Crowd Control"
L["TEXTS"] = "Texts"
L["CREATURE_NAME"] = "Creature Name"
L["HEALTH_VALUE"] = "Health Value"
L["CAST_NAME"] = "Cast Name"
L["LEVEL"] = "Level"
L["ICONS"] = "Icons"
L["TARGET"] = "Target"
L["QUEST_OBJECTIVE"] = "Quest Objective"
L["CANNOT_INTERRUPT"] = "Cannot Interrupt"
L["CAST"] = "Cast"
L["ELITE"] = "Elite"
L["RARE"] = "Rare"
L["RAID_MARKER"] = "Raid Marker"

L["THIS_WILL_OVERWRITE_YOUR_DESIGN"] = "This will overwrite your design. Continue?"

local L = Locales.frFR
--@localization(locale="frFR", format="lua_additive_table")@

local L = Locales.deDE
--@localization(locale="deDE", format="lua_additive_table")@

local L = Locales.ruRU
--@localization(locale="ruRU", format="lua_additive_table")@

local L = Locales.ptBR
--@localization(locale="ptBR", format="lua_additive_table")@

local L = Locales.esES
--@localization(locale="esES", format="lua_additive_table")@

local L = Locales.esMX
--@localization(locale="esMX", format="lua_additive_table")@

local L = Locales.zhTW
--@localization(locale="zhTW", format="lua_additive_table")@

local L = Locales.zhCN
--@localization(locale="zhCN", format="lua_additive_table")@

local L = Locales.koKR
--@localization(locale="koKR", format="lua_additive_table")@

local L = Locales.itIT
--@localization(locale="itIT", format="lua_additive_table")@
