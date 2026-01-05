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
L["POSITIONING"] = "Positioning"
L["STYLE_SELECT"] = "Style Select"
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
L["INTERRUPTED"] = "Interrupted"
L["WIDTH_RESTRICTION"] = "Width restriction"
L["CENTER"] = "Center"
L["LEFT"] = "Left"
L["RIGHT"] = "Right"
L["ALIGNMENT"] = "Alignment"
L["TEXTURES"] = "Textures"
L["COLORS"] = "Colors"
L["SIZE_AND_POSITION"] = "Size and position"
L["SAFE"] = "Safe"
L["TRANSITION"] = "Transition"
L["WARNING"] = "Warning"
L["OFFTANK"] = "Off-tank"
L["FRIENDLY"] = "Friendly"
L["NEUTRAL"] = "Neutral"
L["HOSTILE"] = "Hostile"
L["UNFRIENDLY"] = "Unfriendly"
L["ONLY_APPLY_IN_COMBAT"] = "Only apply in combat"
L["ONLY_APPLY_IN_INSTANCES"] = "Only apply in instances"
L["USE_SAFE_COLOR"] = "Use safe color"
L["MULTIPLE_SELECTED"] = "Multiple Selected"
L["FADE"] = "Fade"
L["DIRECTION"] = "Direction"
L["HEIGHT"] = "Height"
L["WIDTH"] = "Width"
L["CLICK_REGION_WIDTH"] = "Click region width"
L["CLICK_REGION_HEIGHT"] = "Click region height"
L["STACKING_REGION_WIDTH"] = "Stacking region width"
L["STACKING_REGION_HEIGHT"] = "Stacking region height"
L["ABSORB"] = "Absorb"
L["ABSORB_COLOR"] = "Absorb color"
L["HIGHLIGHT_BAR_EDGE"] = "Highlight bar edge"
L["SHOW_COUNTDOWN"] = "Show countdown"
L["FOCUSED"] = "Focused"
L["CLOSER_TO_SCREEN_EDGES"] = "Closer to screen edges"
L["SIMPLIFIED_NAMEPLATES"] = "Simplified nameplates"
L["NORMAL"] = "Normal"
L["MINION"] = "Minion"
L["MINOR"] = "Minor"
L["NORMAL_INSTANCES_ONLY"] = "Normal (instances only)"
L["LAYER"] = "Layer"
L["SQUARE"] = "Square"
L["CLEAR_SELECTION"] = "Clear Selection"
L["TEXT_SCALE"] = "Text scale"
L["SHOW_WHEN_WOW_DOES"] = "Show when WoW does"
L["MOVE"] = "Move"
L["THREAT"] = "Threat"
L["ELITE_TYPE"] = "Elite Type"
L["BOSS"] = "Boss"
L["MINIBOSS"] = "Miniboss"
L["CASTER"] = "Caster"
L["MELEE"] = "Melee"
L["QUEST"] = "Quest"
L["CLASS_COLORS"] = "Class Colors"
L["REACTION"] = "Reaction"
L["ADD_COLORS"] = "Add Colors"
L["DIFFICULTY"] = "Difficulty"
L["AUTOMATIC"] = "Automatic"
L["SHOW_NAMEPLATES_ONLY_IF_NEEDED"] = "Show nameplates only if needed"
L["NEVER"] = "Never"

L["FLIP"] = "Flip"
L["NAME_ONLY_PLAYERS"] = "Name only (players)"
L["ALWAYS_ALL"] = "Always (all)"
L["ON_TARGET_SCALE"] = "On target scale"
L["ON_CAST_SCALE"] = "On cast scale"
L["ON_CAST_TRANSPARENCY"] = "On cast transparency"
L["ON_NOT_TARGET_TRANSPARENCY"] = "On not target transparency"

L["FOREGROUND"] = "Foreground"
L["VISUAL"] = "Visual"
L["BACKGROUND"] = "Background"
L["BACKGROUND_COLOR"] = "Background color"
L["APPLY_MAIN_COLOR_TO_BACKGROUND"] = "Apply main color to background"
L["BORDER"] = "Border"
L["COLOR"] = "Color"
L["CLASS_COLORED"] = "Class colored"

L["ON_TARGET_OR_CASTING"] = "On target (or casting)"
L["ON_NON_TARGET_AND_NON_CASTING"] = "On non-target (and non-casting)"
L["ENLARGE_NAMEPLATE"] = "Enlarge nameplate"
L["DO_NOTHING"] = "Do nothing"
L["SPECIAL_BRACKETS"] = "(Special)"
L["PERCENT_BRACKETS"] = "(%d%%)"
L["NONE"] = "None"
L["USE_NAMEPLATES_FOR"] = "Use nameplates for"
L["PLAYERS"] = "Players"
L["PLAYERS_AND_FRIENDS"] = "Players and friends"
L["FRIENDLY_NPCS"] = "Friendly NPCs"
L["ENEMY_NPCS"] = "Enemy NPCs"
L["STACKING_NAMEPLATES"] = "Stacking nameplates"
L["SHOW_FRIENDLY_IN_INSTANCES"] = "Show friendly in instances"
L["TAPPED"] = "Tapped"
L["FOCUS"] = "Focus"
L["APPLY_OTHER_CVARS"] = "Apply other CVars"

L["ENTER_PROFILE_NAME"] = "Enter Profile Name:"
L["PROFILES"] = "Profiles"
L["NEW_PROFILE_CLONE"] = "New Profile (clone current)"
L["NEW_PROFILE_BLANK"] = "New Profile (blank)"
L["CONFIRM_DELETE_PROFILE_X"] = "Are you sure you want to delete profile \"%s\"?"
L["CONFIRM_DELETE_STYLE_X"] = "Are you sure you want to delete style \"%s\"?"
L["IMPORT_DEFAULT_STYLE"] = "Import Default Style"

L["EXPORT"] = "Export"
L["IMPORT"] = "Import"
L["PASTE_YOUR_IMPORT_STRING_HERE"] = "Paste your import string here"

L["SQUIRREL"] = "Squirrel"
L["RABBIT"] = "Rabbit"
L["BEAVER"] = "Beaver"
L["HARE"] = "Hare"
L["HARE_SIMPLIFIED"] = "Hare Simplified"
L["HEDGEHOG"] = "Hedgehog"
L["TYPE_COLORS"] = "Type Colors"
L["BLIZZARD"] = "Blizzard"
L["BLIZZARD_CLASSIC"] = "Blizzard Classic"
L["NAME_ONLY"] = "Name Only"
L["CUSTOM"] = "Custom"
L["SAVE_AS"] = "Save as"

L["FRIENDLY_STYLE"] = "Friendly Style"
L["ENEMY_STYLE"] = "Enemy Style"
L["SIMPLIFIED_STYLE"] = "Simplified Style"
L["DEFAULT_BRACKETS"] = "(Default)"

L["ADD_WIDGET"] = "Add Widget"
L["DELETE_WIDGET"] = "Delete Widget"
L["BARS"] = "Bars"
L["HEALTH"] = "Health"
L["CAST"] = "Cast"
L["POWER"] = "Power"
L["HIGHLIGHTS"] = "Highlights"
L["TARGETED"] = "Targeted"
L["MOUSEOVER"] = "Mouseover"
L["FIXED"] = "Fixed"
L["AURAS"] = "Auras"
L["BUFFS"] = "Buffs"
L["DEBUFFS"] = "Debuffs"
L["CROWD_CONTROL"] = "Crowd Control"
L["TEXTS"] = "Texts"
L["CREATURE_NAME"] = "Creature Name"
L["HEALTH_VALUE"] = "Health Value"
L["CAST_NAME"] = "Cast Name"
L["GUILD"] = "Guild"
L["LEVEL"] = "Level"
L["ICONS"] = "Icons"
L["TARGET"] = "Target"
L["CAST_TARGET"] = "Cast Target"
L["CAST_TIME_LEFT"] = "Cast Time Left"
L["QUEST_OBJECTIVE"] = "Quest Objective"
L["CANNOT_INTERRUPT"] = "Cannot Interrupt"
L["CAST"] = "Cast"
L["ELITE"] = "Elite"
L["RARE"] = "Rare"
L["PVP"] = "PvP"
L["RAID_MARKER"] = "Raid Marker"
L["IMPOSSIBLE"] = "Impossible"
L["VERY_DIFFICULT"] = "Very difficult"
L["DIFFICULT"] = "Difficult"
L["STANDARD"] = "Standard"
L["TRIVIAL"] = "Trivial"
L["DIFFICULTY_COLORED"] = "Difficulty colored"
L["TRUNCATE"] = "Truncate"
L["FILTERS"] = "Filters"
L["IMPORTANT"] = "Important"
L["FROM_YOU"] = "From you"
L["DISPELABLE"] = "Dispelable"
L["SHOW_PANDEMIC"] = "Show pandemic"
L["SORTING"] = "Sorting"
L["METHOD"] = "Method"
L["DURATION"] = "Duration"
L["REVERSED"] = "Reversed"
L["INTERRUPT_READY"] = "Interrupt Ready"
L["READY"] = "Ready"
L["NOT_READY"] = "Not ready"
L["CAST"] = "Cast"
L["CHANNEL"] = "Channel"
L["CASTING"] = "Casting"
L["IMPORTANT_CAST"] = "Important Cast"
L["INTERRUPTED_CAST"] = "Interrupted cast"
L["UNINTERRUPTABLE"] = "Uninterruptable"

L["WHAT_TO_EXPORT"] = "What to export?"
L["STYLE"] = "Style"
L["PROFILE"] = "Profile"

L["THIS_WILL_OVERWRITE_STYLE_CUSTOM"] = "This will overwrite style \"Custom\". Continue?"
L["ENTER_THE_NEW_STYLE_NAME"] = "Enter the new style name"
L["ENTER_THE_NEW_PROFILE_NAME"] = "Enter the new profile name"
L["THAT_STYLE_NAME_ALREADY_EXISTS"] = "That style name already exists"
L["THAT_PROFILE_NAME_ALREADY_EXISTS"] = "That profile name already exists"
L["OVERWRITE_CURRENT_PROFILE"] = "Overwrite current profile?"
L["OVERWRITE"] = "Overwrite"
L["MAKE_NEW"] = "Make new"
L["INVALID_IMPORT"] = "Invalid import"

L["SLASH_RESET"] = "reset"
L["SLASH_RESET_HELP"] = "Reset all Platynator settings, then reload."
L["SLASH_HELP"] = "Open the Platynator settings."
L["SLASH_UNKNOWN_COMMAND"] = "Unknown command '%s'"

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
