if not Gold then
	Gold = class({})
end 
GOLD_PER_TICK = 4
TICK_TIME = 1
function Gold:Init()
	PlayerTables:CreateTable('Gold', {
	info = PLAYER_DATA}, PLAYER_DATA)
	Timers:CreateTimer(TICK_TIME, Dynamic_Wrap(Gold, 'Think'))
end
function Gold:ModifyGold(pID,modify)
if pID < 0  then return end
	local gold = Gold:GetGold(pID)
	Gold:SetGold(pID,gold + modify)
end
function Gold:GetGold(pID)
	return tonumber(pID) >= 0 and PlayerTables:GetTableValue("Gold", "info") and PlayerTables:GetTableValue("Gold", "info")[pID].gold or -1
end 

function Gold:SetGold(pID,gold)
if pID < 0  then return end
	local t = PlayerTables:GetTableValue("Gold", "info")
	t[pID].gold = gold
	PlayerTables:SetTableValue("Gold", "info", t)
end 

function Gold:Think()
	if GameRules:State_Get() >= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		for i = 0, DOTA_MAX_PLAYERS - 1 do 
			if PlayerResource:IsValidPlayer(i) then
			
				Gold:ModifyGold(PlayerResource:GetPlayer(i):GetPlayerID(), GOLD_PER_TICK)
			end 
		end
	end
end 


