if not HeroSelection then
	HeroSelection = class({})
	PickPrecacheHero = {}
	HeroPick = {}
	STAGE_SELECTION = -1
	STAGE_SELECTION_START = 0
	STAGE_SELECTION_PICKED_HERO = 1
	STAGE_SELECTION_END = 2
	HERO_SELECTION_PICKING_TIME = 30
end

local a_table = a_table or {}
if not a_table[0] then
	for i=0,23 do
		a_table[i] = 0
	end
end
function HeroSelection:Init()
	HeroSelection:StartingTimer()
	STAGE_SELECTION = STAGE_SELECTION_START
end
function HeroSelection:StartingTimer()
	Timers:CreateTimer(1,function()
	CustomGameEventManager:Send_ServerToAllClients("HeroSelectionTimer", {
		time = HERO_SELECTION_PICKING_TIME,
	})
		if HERO_SELECTION_PICKING_TIME > 0 then
			HERO_SELECTION_PICKING_TIME = HERO_SELECTION_PICKING_TIME - 1;
			STAGE_SELECTION = STAGE_SELECTION_PICKED_HERO
			return 1
		else
			STAGE_SELECTION = STAGE_SELECTION_END
			HeroSelection:PickedHeroEnd()
		end 
	end)
end
function HeroSelection:GetSelectionStage()
	return STAGE_SELECTION
end
-- Author:Ark120202
function HeroSelection:ExtractHeroStats(HeroName)
	local heroTable = GetKeyValue(HeroName)
	local attributes = {
		attribute_primary = _G[heroTable.AttributePrimary],
		attribute_base_0 = heroTable.AttributeBaseStrength,
		attribute_base_1 = heroTable.AttributeBaseAgility,
		attribute_base_2 = heroTable.AttributeBaseIntelligence,
		attribute_gain_0 = heroTable.AttributeStrengthGain,
		attribute_gain_1 = heroTable.AttributeAgilityGain,
		attribute_gain_2 = heroTable.AttributeIntelligenceGain,
		damage_min = tonumber(heroTable.AttackDamageMin) or 0,
		damage_max = tonumber(heroTable.AttackDamageMax) or 0,
		movespeed = heroTable.MovementSpeed or 0,
		attackrate = heroTable.AttackRate or 0,
		attackRange = heroTable.AttackRange or 0,
		ProjectileSpeed = heroTable.ProjectileSpeed,
		armor = heroTable.ArmorPhysical or 0,
		resistance = heroTable.MagicalResistance or 25,
		MovementTurnRate = heroTable.MovementTurnRate or 0.5,
		SightDay = heroTable.VisionDaytimeRange or 1800,
		SightNight = heroTable.VisionNighttimeRange or 800,
		IsUpgrade = GetKeyValueByHeroName(HeroName, "IsUpgrade") and GetKeyValueByHeroName(HeroName, "IsUpgrade") == 1
	}

	attributes.damage_min = attributes.damage_min + attributes["attribute_base_" .. attributes.attribute_primary]
	attributes.damage_max = attributes.damage_max + attributes["attribute_base_" .. attributes.attribute_primary]

	local armorForFirstLevel = CalculateBaseArmor({
		agility = heroTable.AttributeBaseAgility,
		isPrimary = heroTable.AttributePrimary == "DOTA_ATTRIBUTE_AGILITY",
	})
	attributes.armor = attributes.armor + armorForFirstLevel
	return attributes
end
--
function HeroSelection:PreLoad()
	local t = {
		agility = {},
		strength = {},
		intellect = {},
		DataHero = {},
	}
	local t_,TableAttributes,IsUpgrade;
	local HeroList = LoadKeyValues('scripts/npc/CustomHeroList.txt')
	for _,HeroName in pairs(GetAllHeroesNames()) do
		HeroList[HeroName] = not HeroList[HeroName] and 1 or HeroList[HeroName]
		if HeroList[HeroName] and HeroList[HeroName] ~= 0 then
			TableAttributes = GetKeyValueByHeroName(HeroName, "AttributePrimary")
			t_ = TableAttributes == "DOTA_ATTRIBUTE_STRENGTH" and t.strength or 
			TableAttributes == "DOTA_ATTRIBUTE_AGILITY" and t.agility or 
			TableAttributes == "DOTA_ATTRIBUTE_INTELLECT" and t.intellect
			table.insert(t_,HeroName)
			t.DataHero[HeroName] = HeroSelection:ExtractHeroStats(HeroName)
			t.DataHero[HeroName].IsDisabled = HeroList[HeroName] == -1
			CustomNetTables:SetTableValue("HeroSelection", HeroName, HeroSelection:HeroAbility(HeroName))
		end
	end 
	PlayerTables:CreateTable("HeroSelection",t.DataHero,true)
	CustomNetTables:SetTableValue("HeroSelection", "DOTA_ATTRIBUTE_AGILITY", t.agility)	
	CustomNetTables:SetTableValue("HeroSelection", "DOTA_ATTRIBUTE_STRENGTH", t.strength)	
	CustomNetTables:SetTableValue("HeroSelection", "DOTA_ATTRIBUTE_INTELLECT", t.intellect)	
	CustomNetTables:SetTableValue("HeroSelection", "picks", a_table)
	CustomNetTables:SetTableValue("HeroSelection", "settings", {
		["Hero"] = FORCE_PICKED_HERO,
	})
end

function HeroSelection:PickedHero(data)

	if not (data.PlayerID or data.heroName) then return end
	if data.heroName == PlayerResource:GetSelectedHeroEntity(data.PlayerID):GetUnitName() or PlayerResource:GetSelectedHeroEntity(data.PlayerID):GetUnitName() ~= FORCE_PICKED_HERO then return end
	local function PickHero() 
		local hero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
		if hero:GetUnitName() == data.heroName or HeroPick[data.PlayerID] then Containers:DisplayError(data.PlayerID,"#hud_error_picking_hero") return end
			HeroPick[data.PlayerID] = true
			PlayerResource:ReplaceHeroWith(data.PlayerID, data.heroName, STARTING_GOLD, 0 )
			UTIL_Remove(hero)
			HeroSelection:SetHeroPicked(data)
			CustomGameEventManager:Send_ServerToAllClients("HeroSelection_picked", {HeroName = data.heroName}) 
	end
	if not PickPrecacheHero[data.heroName] then
		PrecacheUnitByNameAsync(data.heroName, PickHero,data.PlayerID)
		PickPrecacheHero[data.heroName] = true
	else
		 PickHero()
	end
end 

function HeroSelection:SetHeroPicked(data) 
	local t = CustomNetTables:GetTableValue("HeroSelection","picks")
	t[tostring(data.pID)] = data.heroName
	CustomNetTables:SetTableValue("HeroSelection", "picks", t)

end

function HeroSelection:HeroAbility(hero)
local full = KeyValues.UnitKV
local heroes = {}
	for i = 1,24 do
		if full[hero]["Ability" .. i] and	not 
		full[hero]["Ability" .. i]:find("special_bonus_") and 
		full[hero]["Ability" .. i] ~= "generic_hidden" then
			table.insert(heroes, full[hero]["Ability" .. i])
		end
	end
	return heroes
end

function HeroSelection:PickedHeroEnd()
	if HeroSelection:GetSelectionStage() == STAGE_SELECTION_END then	
	end
end 