AllPlayersInterval = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23}
if DotaNew == nil then
    _G.DotaNew = class({})
	PickersHeroes = {}
end
local RequireList = {
	"settings",
	"events",
	"filters",
	["libraries"] = {
		"timers",
		"physics",
		"projectiles",
		"notifications",
		"containers",
		"playertables",
		--"attachments",
		--"modmaker",
		--"pathgraph",
		--"selection",
	},
	["util"] = {
		"funcs",
		"math",
		"PlayerResource",
		"string",
		"table",
		"keyvalues",
	},
}

for k,v in pairs(RequireList) do
	if type(v) == "table" then
		for _,value in pairs(v) do
			require(k .. "/" .. value)
		end 
	else
		require(v)
	end
end
require("modules/index")
function DotaNew:OnHeroInGame(hero)
end

function DotaNew:OnGameInProgress()
end

function DotaNew:PreGame()	
	HeroSelection:Init()
end

function DotaNew:HeroSelection()
end 
function DotaNew:Init()
	DotaNew:SetGlobalSettings()
	DotaNew:StartGameEvents()
	DotaNew:FiltersOn()
	PlayerTables:CreateTable("player_hero_indexes", {}, AllPlayersInterval)
	HeroSelection:PreLoad()
	--Gold:Init()
end

function DotaNew:SetGlobalSettings()
	GameRules:SetHeroRespawnEnabled( ENABLE_HERO_RESPAWN )
	GameRules:SetUseUniversalShopMode( UNIVERSAL_SHOP_MODE )
	GameRules:SetSameHeroSelectionEnabled( ALLOW_SAME_HERO_SELECTION )
	GameRules:SetHeroSelectionTime( HERO_SELECTION_TIME )
	GameRules:SetPreGameTime( HERO_SELECTION_PICKING_TIME + 2 + PRE_GAME_TIME )
	GameRules:SetPostGameTime( POST_GAME_TIME )
	GameRules:SetTreeRegrowTime( TREE_REGROW_TIME )
	GameRules:SetUseCustomHeroXPValues ( USE_CUSTOM_XP_VALUES )
	GameRules:SetGoldPerTick(GOLD_PER_TICK)
	GameRules:SetGoldTickTime(GOLD_TICK_TIME)
	GameRules:SetRuneSpawnTime(RUNE_SPAWN_TIME)
	GameRules:SetUseBaseGoldBountyOnHeroes(USE_STANDARD_HERO_GOLD_BOUNTY)
	GameRules:SetHeroMinimapIconScale( MINIMAP_ICON_SIZE )
	GameRules:SetCreepMinimapIconScale( MINIMAP_CREEP_ICON_SIZE )
	GameRules:SetRuneMinimapIconScale( MINIMAP_RUNE_ICON_SIZE )
	GameRules:SetFirstBloodActive( ENABLE_FIRST_BLOOD )
	GameRules:SetHideKillMessageHeaders( HIDE_KILL_BANNERS )
	GameRules:SetCustomGameEndDelay( GAME_END_DELAY )
	GameRules:SetCustomVictoryMessageDuration( VICTORY_MESSAGE_DURATION )
	GameRules:SetStartingGold( STARTING_GOLD )
	local mode = GameRules:GetGameModeEntity()        
	mode:SetRecommendedItemsDisabled( RECOMMENDED_BUILDS_DISABLED )
	mode:SetCameraDistanceOverride( CAMERA_DISTANCE_OVERRIDE )
	mode:SetCustomBuybackCostEnabled( CUSTOM_BUYBACK_COST_ENABLED )
	mode:SetCustomBuybackCooldownEnabled( CUSTOM_BUYBACK_COOLDOWN_ENABLED )
	mode:SetBuybackEnabled( BUYBACK_ENABLED )
	mode:SetTopBarTeamValuesOverride ( USE_CUSTOM_TOP_BAR_VALUES )
	mode:SetTopBarTeamValuesVisible( TOP_BAR_VISIBLE )
	mode:SetUseCustomHeroLevels ( USE_CUSTOM_HERO_LEVELS )
	mode:SetCustomHeroMaxLevel ( MAX_LEVEL )
	mode:SetCustomXPRequiredToReachNextLevel( XP_PER_LEVEL_TABLE )
	mode:SetBotThinkingEnabled( USE_STANDARD_DOTA_BOT_THINKING )
	mode:SetTowerBackdoorProtectionEnabled( ENABLE_TOWER_BACKDOOR_PROTECTION )
	mode:SetFogOfWarDisabled(DISABLE_FOG_OF_WAR_ENTIRELY)
	mode:SetGoldSoundDisabled( DISABLE_GOLD_SOUNDS )
	mode:SetRemoveIllusionsOnDeath( REMOVE_ILLUSIONS_ON_DEATH )
	mode:SetAlwaysShowPlayerInventory( SHOW_ONLY_PLAYER_INVENTORY )
	mode:SetAnnouncerDisabled( DISABLE_ANNOUNCER )
	if FORCE_PICKED_HERO ~= nil then
		mode:SetCustomGameForceHero( FORCE_PICKED_HERO )
	end
	mode:SetFixedRespawnTime( FIXED_RESPAWN_TIME ) 
	mode:SetFountainConstantManaRegen( FOUNTAIN_CONSTANT_MANA_REGEN )
	mode:SetFountainPercentageHealthRegen( FOUNTAIN_PERCENTAGE_HEALTH_REGEN )
	mode:SetFountainPercentageManaRegen( FOUNTAIN_PERCENTAGE_MANA_REGEN )
	mode:SetLoseGoldOnDeath( LOSE_GOLD_ON_DEATH )
	mode:SetMaximumAttackSpeed( MAXIMUM_ATTACK_SPEED )
	mode:SetMinimumAttackSpeed( MINIMUM_ATTACK_SPEED )
	mode:SetStashPurchasingDisabled ( DISABLE_STASH_PURCHASING )
	for rune, spawn in pairs(ENABLED_RUNES) do
		mode:SetRuneEnabled(rune, spawn)
	end
	mode:SetUnseenFogOfWarEnabled( USE_UNSEEN_FOG_OF_WAR )
	mode:SetDaynightCycleDisabled( DISABLE_DAY_NIGHT_CYCLE )
	mode:SetKillingSpreeAnnouncerDisabled( DISABLE_KILLING_SPREE_ANNOUNCER )
	mode:SetStickyItemDisabled( DISABLE_STICKY_ITEM )
	GameRules:SetCustomGameSetupAutoLaunchDelay( AUTO_LAUNCH_DELAY )
	GameRules:LockCustomGameSetupTeamAssignment( LOCK_TEAM_SETUP )
	GameRules:EnableCustomGameSetupAutoLaunch( ENABLE_AUTO_LAUNCH )
	for k,v in pairs(CUSTOM_TEAM_PLAYER_COUNT) do
		GameRules:SetCustomGameTeamMaxPlayers(k, v)
	end
	if USE_CUSTOM_TEAM_COLORS then
		for team,color in pairs(TEAM_COLORS) do
			SetTeamCustomHealthbarColor(team, color[1], color[2], color[3])
		end
	end
	GameRules:GetGameModeEntity():SetHudCombatEventsDisabled( false )
end 