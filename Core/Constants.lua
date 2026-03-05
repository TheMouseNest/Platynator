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
  "CombatStatusChange",
  "AttackStatusChange",
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

addonTable.Constants.LegacyDungeons = {
  -- World of Warcraft Classic
  33, -- 	Shadowfang Keep
  34, -- 	The Stockade
  36, -- 	The Deadmines
  43, -- 	Wailing Caverns
  47, -- 	Razorfen Kraul
  48, -- 	Blackfathom Deeps
  70, -- 	Uldaman
  90, -- 	Gnomeregan
  109, -- 	The Temple of Atal'Hakkar
  129, -- 	Razorfen Downs
  209, -- 	Zul'Farrak
  229, -- 	Blackrock Spire
  230, -- 	Blackrock Depths
  329, -- 	Stratholme
  349, -- 	Maraudon
  389, -- 	Ragefire Chasm
  429, -- 	Dire Maul
  1001, -- 	Scarlet Halls
  1004, -- 	Scarlet Monastery
  1007, -- 	Scholomance
  -- Burning Crusade
  269, -- 	The Black Morass
  540, -- 	The Shattered Halls
  542, -- 	The Blood Furnace
  543, -- 	Hellfire Ramparts
  545, -- 	The Steamvault
  546, -- 	The Underbog
  547, -- 	The Slave Pens
  552, -- 	The Arcatraz
  553, -- 	The Botanica
  554, -- 	The Mechanar
  555, -- 	Shadow Labyrinth
  556, -- 	Sethekk Halls
  557, -- 	Mana-Tombs
  558, -- 	Auchenai Crypts
  560, -- 	Old Hillsbrad Foothills
  585, -- 	Magisters' Terrace
  -- Wrath of the Lich King
  574, -- 	Utgarde Keep
  575, -- 	Utgarde Pinnacle
  576, -- 	The Nexus
  578, -- 	The Oculus
  595, -- 	The Culling of Stratholme
  599, -- 	Halls of Stone
  600, -- 	Drak'Tharon Keep
  601, -- 	Azjol-Nerub
  602, -- 	Halls of Lightning
  604, -- 	Gundrak
  608, -- 	The Violet Hold
  619, -- 	Ahn'kahet: The Old Kingdom
  632, -- 	The Forge of Souls
  650, -- 	Trial of the Champion
  658, -- 	Pit of Saron
  668, -- 	Halls of Reflection

  -- Cataclysm
  568, -- 	Zul'Aman
  643, -- 	Throne of the Tides
  644, -- 	Halls of Origination
  645, -- 	Blackrock Caverns
  657, -- 	The Vortex Pinnacle
  670, -- 	Grim Batol
  725, -- 	The Stonecore
  755, -- 	Lost City of the Tol'vir
  859, -- 	Zul'Gurub
  938, -- 	End Time
  939, -- 	Well of Eternity
  940, -- 	Hour of Twilight
  -- Mists of Pandaria
  959, -- 	Shado-pan Monastery
  960, -- 	Temple of the Jade Serpent
  961, -- 	Stormstout Brewery
  962, -- 	Gate of the Setting Sun
  994, -- 	Mogu'Shan Palace
  1011, -- 	Siege of Niuzao Temple
  -- Warlords of Draenor
  1182, -- 	Auchindoun
  1175, -- 	Bloodmaul Slag Mines
  1176, -- 	Shadowmoon Burial Grounds
  1195, -- 	Iron Docks
  1208, -- 	Grimrail Depot
  1209, -- 	Skyreach
  1279, -- 	The Everbloom
  1358, -- 	Upper Blackrock Spire
  -- Legion
  1456, -- 	Eye of Azshara
  1458, -- 	Neltharion's Lair
  1466, -- 	Darkheart Thicket
  1477, -- 	Halls of Valor
  1492, -- 	Maw of Souls
  1493, -- 	Vault of the Wardens
  1501, -- 	Black Rook Hold
  1516, -- 	The Arcway
  1544, -- 	Violet Hold
  1571, -- 	Court of Stars
  1651, -- 	Return to Karazhan
  1677, -- 	Cathedral of Eternal Night
  1753, -- 	Seat of the Triumvirate
  -- Battle for Azeroth
  1594, -- 	The MOTHERLODE!!
  1754, -- 	Freehold
  1762, -- 	Kings' Rest
  1763, -- 	Atal'Dazar
  1771, -- 	Tol Dagor
  1822, -- 	Siege of Boralus
  1841, -- 	The Underrot
  1862, -- 	Waycrest Manor
  1864, -- 	Shrine of the Storm
  1877, -- 	Temple of Sethraliss
  2097, -- 	Operation: Mechagon

  -- Shadowlands
  2284, -- 	Sanguine Depths
  2285, -- 	Spires of Ascension
  2286, -- 	The Necrotic Wake
  2287, -- 	Halls of Atonement
  2289, -- 	Plaguefall
  2290, -- 	Mists of Tirna Scithe
  2291, -- 	De Other Side
  2293, -- 	Theater of Pain
  2441, -- 	Tazavesh, the Veiled Market
  -- Dragonflight
  2451, -- 	Uldaman: Legacy of Tyr
  2515, -- 	The Azure Vault
  2516, -- 	The Nokhud Offensive
  2519, -- 	Neltharus
  2520, -- 	Brackenhide Hollow
  2521, -- 	Ruby Life Pools
  2526, -- 	Algeth'ar Academy
  2527, -- 	Halls of Infusion
  2579, -- 	Dawn of the Infinite
}
