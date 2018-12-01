function DotaNew:StartGameEvents()
  ListenToGameEvent('entity_killed', Dynamic_Wrap(DotaNew, 'OnEntityKilled'), self)
  ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(DotaNew, 'OnGameRulesStateChange'), self)
  ListenToGameEvent('npc_spawned', Dynamic_Wrap(DotaNew, 'OnNPCSpawned'), self)
  ListenToGameEvent("player_chat", Dynamic_Wrap(DotaNew, 'OnPlayerChat'), self)
  CustomGameEventManager:RegisterListener("PickedHero", Dynamic_Wrap(HeroSelection, 'PickedHero'))
 -- ListenToGameEvent("player_reconnected", Dynamic_Wrap(HeroSelection, 'OnPlayerReconnect'), self)
end

function DotaNew:OnGameRulesStateChange(keys)
	local newState = GameRules:State_Get()
	if newState == DOTA_GAMERULES_STATE_HERO_SELECTION then
		DotaNew:HeroSelection()
	end	
	if newState == DOTA_GAMERULES_STATE_PRE_GAME then
		DotaNew:PreGame()
	end 	
	if newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		DotaNew:OnGameInProgress()
	end 
end

function DotaNew:OnNPCSpawned(keys)
local SpawnedUnit = EntIndexToHScript(keys.entindex)
	if SpawnedUnit:IsRealHero() then
		if  SpawnedUnit.FirstSpawn == nil then
			SpawnedUnit.FirstSpawn = true
		end
	end
end

function DotaNew:OnItemPickedUp(keys)
end

function DotaNew:OnEntityKilled( keys )
local killedUnit = EntIndexToHScript( keys.entindex_killed )
local killerEntity
local killerAbility
local damagebits = keys.damagebits
	if keys.entindex_attacker ~= nil then killerEntity = EntIndexToHScript( keys.entindex_attacker ) end
	if keys.entindex_inflictor ~= nil then killerAbility = EntIndexToHScript( keys.entindex_inflictor ) end
	if killedUnit:IsRealHero() then
		killedUnit:SetRespawnTime()
	end 
end

function DotaNew:OnPlayerChat(keys)
	local text = keys.text
	local ID = keys.userid
	local PlayerId = keys.playerid
	--if PlayerId and PlayerId >= 0 then
		--local teamOnly = keys.teamonly
		--local SteamdID = PlayerResource:GetSteamAccountID(PlayerId)
		--local player = PlayerResource:GetPlayer(PlayerId)
		--local playerName = PlayerResource:GetPlayerName(PlayerId)
		--local hero = player:GetAssignedHero()
		--local team = PlayerResource:GetTeam(PlayerId)
		--local hero_table = PlayerResource:GetSelectedHeroEntity(PlayerId)	
		--local commands = {}
		--for v in string.gmatch(string.sub(text, 2), "%S+") do 
		--	table.insert(commands, v) 
		--end		
		--local command = table.remove(commands, 1)
		--if command == "-" or not command then return end
		--local prob =  text:find(" ") or 0
		--local numbers = string.sub(text, prob+1)
		--local cmd = CHAT_COMMANDS[command:upper()]	
		--if cmd --[[and cmd.ACCESS <= GetAccesCheatsPlayer(PlayerId)]] then
		--	cmd.funcs(numbers,PlayerId)
		--end 
	--end
end