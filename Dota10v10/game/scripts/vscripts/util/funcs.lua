function DebugPrint(...)
  local spew = Convars:GetInt('barebones_spew') or -1
  if spew == -1 and BAREBONES_DEBUG_SPEW then
    spew = 1
  end

  if spew == 1 then
    print(...)
  end
end

function GetTrueInfoByName(name)
	local unit = CreateUnitByName(name, Vector(0,0,0), true, nil, nil, DOTA_TEAM_NEUTRALS)
	local infoTable = {
		attribute_primary = unit:GetPrimaryAttribute(),
		attribute_base_0 = unit:GetBaseStrength(),
		attribute_base_1 = unit:GetBaseAgility(),
		attribute_base_2 = unit:GetBaseIntellect(),
		attribute_gain_0 = unit:GetStrengthGain(),
		attribute_gain_1 = unit:GetAgilityGain(),
		attribute_gain_2 = unit:GetIntellectGain(),
		damage_min = tonumber(unit:GetBaseDamageMin()),
		damage_max = tonumber(unit:GetBaseDamageMax()),
		movespeed = unit:GetBaseMoveSpeed(),
		attackrate = unit:GetBaseAttackTime(),
		attackRange = unit:GetBaseAttackRange(),
		ProjectileSpeed = unit:GetProjectileSpeed(),
		armor = unit:GetPhysicalArmorBaseValue(),
		resistance = unit:GetBaseMagicalResistanceValue(),
		SightDay = unit:GetBaseDayTimeVisionRange(),
		SightNight = unit:GetBaseNightTimeVisionRange(),
		health = unit:GetBaseMaxHealth(),
		mana = unit:GetMana(),
		manaRegen = unit:GetManaRegen(),
		healthRegen = unit:GetBaseHealthRegen(),
	}
	UTIL_Remove(unit)
	return infoTable
end 
--[[
	Ability
	modifier
	duration
	count
]]
function CDOTA_BaseNPC:AddStackModifier(data)
		if self:HasModifier(data.modifier) then
			local current_stack = self:GetModifierStackCount( data.modifier, data.ability )
			if data.updateStack then
				self:AddNewModifier(self, data.ability,data.modifier,{duration = (data.duration or -1)})
			end
			self:SetModifierStackCount( data.modifier, data.ability, current_stack + (data.count or 1) )
		else
			self:AddNewModifier(self, data.ability,data.modifier,{duration = (data.duration or -1)})
			self:SetModifierStackCount( data.modifier, data.ability, (data.count or 1) )
		end
end
-- Ark120202
function GetTrueItemCost(name)
	local cost = GetItemCost(name)
	if cost <= 0 then
		local tempItem = CreateItem(name, nil, nil)
		if not tempItem then
			print("[GetTrueItemCost] Warning: " .. name)
		else
			cost = tempItem:GetCost()
			UTIL_Remove(tempItem)
		end
	end
	return cost
end
function IsDev(playerId)
	return PlayerResource:GetSteamAccountID(playerId) == 311310226
end

function RemoveAllUnitsByName(name)
	local units = FindUnitsInRadius(DOTA_TEAM_BADGUYS, Vector(0, 0, 0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
	for _,v in ipairs(units) do
		if v:GetUnitName():match(name) then
			v:ForceKill(true)
			UTIL_Remove(v)
		end
	end
end

function TooltipMessage(number,victim,types)
	if number > 0 then
		local vector2 = types == "BLOOD" and Vector( 108, 211, 246 )
		local vector1 = string.len( math.floor( number ) ) + 1
		local particle = ParticleManager:CreateParticle( "particles/msg_fx/msg_goldbounty.vpcf", PATTACH_POINT_FOLLOW, victim)
		ParticleManager:SetParticleControl( particle, 0, Vector( 40, 0, 75 ) )
		ParticleManager:SetParticleControl( particle, 1, Vector( 0, number, 4 ) )
		ParticleManager:SetParticleControl( particle, 2, Vector( 1, vector1, 1 ) )
		ParticleManager:SetParticleControl( particle, 3, vector2 )
	end		
end

function GetAccesCheatsPlayer(playerId)
	if IsDev(playerId) then
		return DEV_ACCESS
	elseif GameRules:IsCheatMode() then
		return	CHEAT_LOBBY_ACCESS
	end
	return USUAL_ACCESS
end

function FindAllOwnedUnits(player)
	local summons = {}
	local pid = type(player) == "number" and player or player:GetPlayerID()
	local units = FindUnitsInRadius(PlayerResource:GetTeam(pid), Vector(0, 0, 0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED, FIND_ANY_ORDER, false)
	for _,v in ipairs(units) do
		if type(player) == "number" and ((v.GetPlayerID ~= nil and v:GetPlayerID() or v:GetPlayerOwnerID()) == pid) or v:GetPlayerOwner() == player then
			if not (v:HasModifier("modifier_dummy_unit") or v:HasModifier("modifier_containers_shopkeeper_unit") or v:HasModifier("modifier_teleport_passive")) and v ~= hero then
				table.insert(summons, v)
			end
		end
	end
	return summons
end

function DebugPrintTable(...)
  local spew = Convars:GetInt('barebones_spew') or -1
  if spew == -1 and BAREBONES_DEBUG_SPEW then
    spew = 1
  end

  if spew == 1 then
    PrintTable(...)
  end
end

function PrintTable(t, indent, done)
  --print ( string.format ('PrintTable type %s', type(keys)) )
  if type(t) ~= "table" then return end

  done = done or {}
  done[t] = true
  indent = indent or 0

  local l = {}
  for k, v in pairs(t) do
    table.insert(l, k)
  end

  table.sort(l)
  for k, v in ipairs(l) do
    -- Ignore FDesc
    if v ~= 'FDesc' then
      local value = t[v]

      if type(value) == "table" and not done[value] then
        done [value] = true
        print(string.rep ("\t", indent)..tostring(v)..":")
        PrintTable (value, indent + 2, done)
      elseif type(value) == "userdata" and not done[value] then
        done [value] = true
        print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
        PrintTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
      else
        if t.FDesc and t.FDesc[v] then
          print(string.rep ("\t", indent)..tostring(t.FDesc[v]))
        else
          print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
        end
      end
    end
  end
end

-- Colors
COLOR_NONE = '\x06'
COLOR_GRAY = '\x06'
COLOR_GREY = '\x06'
COLOR_GREEN = '\x0C'
COLOR_DPURPLE = '\x0D'
COLOR_SPINK = '\x0E'
COLOR_DYELLOW = '\x10'
COLOR_PINK = '\x11'
COLOR_RED = '\x12'
COLOR_LGREEN = '\x15'
COLOR_BLUE = '\x16'
COLOR_DGREEN = '\x18'
COLOR_SBLUE = '\x19'
COLOR_PURPLE = '\x1A'
COLOR_ORANGE = '\x1B'
COLOR_LRED = '\x1C'
COLOR_GOLD = '\x1D'


function DebugAllCalls()
    if not GameRules.DebugCalls then
        print("Starting DebugCalls")
        GameRules.DebugCalls = true

        debug.sethook(function(...)
            local info = debug.getinfo(2)
            local src = tostring(info.short_src)
            local name = tostring(info.name)
            if name ~= "__index" then
                print("Call: ".. src .. " -- " .. name .. " -- " .. info.currentline)
            end
        end, "c")
    else
        print("Stopped DebugCalls")
        GameRules.DebugCalls = false
        debug.sethook(nil, "c")
    end
end

function HideWearables( unit )
  unit.hiddenWearables = {} -- Keep every wearable handle in a table to show them later
    local model = unit:FirstMoveChild()
    while model ~= nil do
        if model:GetClassname() == "dota_item_wearable" then
            model:AddEffects(EF_NODRAW) -- Set model hidden
            table.insert(unit.hiddenWearables, model)
        end
        model = model:NextMovePeer()
    end
end

function ShowWearables( unit )

  for i,v in pairs(unit.hiddenWearables) do
    v:RemoveEffects(EF_NODRAW)
  end
end

function GetDirectoryFromPath(path)
	return path:match("(.*[/\\])")
end

function ModuleRequire(path,file)
	return require(GetDirectoryFromPath(path) .. file)
end

function LinkLuaModifierByDirectory(path,modifier)
	LinkLuaModifier(modifier, GetDirectoryFromPath(path), LUA_MODIFIER_MOTION_NONE)
end

function UnitVarToPlayerID(unitvar)
  if unitvar then
    if type(unitvar) == "number" then
      return unitvar
    elseif type(unitvar) == "table" and not unitvar:IsNull() and unitvar.entindex and unitvar:entindex() then
      if unitvar.GetPlayerID and unitvar:GetPlayerID() > -1 then
        return unitvar:GetPlayerID()
      elseif unitvar.GetPlayerOwnerID then
        return unitvar:GetPlayerOwnerID()
      end
    end
  end
  return -1
end

function CDOTA_BaseNPC_Hero:CalculateRespawnTime()
	if self.OnDuel then return 1 end
	local time = (5 + 3.8*self:GetLevel()) + (self.RespawnTimeModifierBloodstone or 0) + (self.RespawnTimeModifierSaiReleaseOfForge or 0)
	return math.max(time, 3)
end
 
function CDOTA_BaseNPC:SetRespawnTime()
local respawn = self:CalculateRespawnTime()
	if respawn > 25 then respawn = 25 end
	self:SetTimeUntilRespawn( math.max(respawn,1) )
end

function PickRandomShuffle( reference_list, bucket )
    if ( #reference_list == 0 ) then
        return nil
    end
    
    if ( #bucket == 0 ) then
        for k, v in pairs(reference_list) do
            bucket[k] = v
        end
    end
    local pick_index = RandomInt( 1, #bucket )
    local result = bucket[ pick_index ]
    table.remove( bucket, pick_index )
    return result
end

function PickRandomValueTable(table)
	 return table[RandomInt( 1, #table )]
end 

function CDOTA_BaseNPC:Healing(healing)
	self:Heal(healing, self)
	local player = PlayerResource:GetPlayer(UnitVarToPlayerID(self))
	SendOverheadEventMessage(player, OVERHEAD_ALERT_HEAL, player, math.round(healing), player)
	local lifesteal_pfx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self)
	ParticleManager:SetParticleControl(lifesteal_pfx, 0, self:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(lifesteal_pfx)
end

function CDOTA_BaseNPC:GetCountItem()
local k = 0
	for i=0, 5 do
		if self:GetItemInSlot(i) then
			k = k + 1
		end 
	end
	return k
end
--[[
	DATA:
	caster 
	IsStun
	duration
	height
	ability
	target
]]
function CDOTA_BaseNPC:AddKnockBackHero(data)
		self:AddNewModifier(data.caster,data.ability,'modifier_knockback',{
			should_stun = data.IsStun and 1 or 0,
			knockback_duration = data.duration or 0.5,
			duration = data.duration or 0.5,
			knockback_distance = data.distance or 0,
			knockback_height = data.height or 300,
			center_x = data.caster:GetAbsOrigin().x,
			center_y = data.caster:GetAbsOrigin().y,
			center_z = data.caster:GetAbsOrigin().z
		})
end

function CalculateBaseArmor(arg)
	local agility = arg.agility
	local isPrimary = arg.isPrimary
	if IsValidEntity(arg) then
		agility = arg:GetAgility()
		isPrimary = arg:GetPrimaryAttribute() == DOTA_ATTRIBUTE_AGILITY
	end

	return agility * (isPrimary and 0.20 or 0.16)
end
function CDOTA_Buff:SetSharedKey(key, value)
	local t = CustomNetTables:GetTableValue("modifiers_value", self:GetParent():GetEntityIndex() .. "_" .. self:GetName()) or {}
	t[key] = value
	CustomNetTables:SetTableValue("modifiers_value", self:GetParent():GetEntityIndex() .. "_" .. self:GetName(), t)
end

function CDOTA_Buff:GetSharedKey(key)
	local t = CustomNetTables:GetTableValue("modifiers_value", self:GetParent():GetEntityIndex() .. "_" .. self:GetName()) or {}
	return t[key]
end

function CDOTA_BaseNPC:GetBonusTakeDamage()
	local get = 0
	for _, modifier in pairs(self:FindAllModifiers()) do
		if modifier.GetBonusTakeDamage then
			get = get + modifier:GetBonusTakeDamage()
		end
	end
	return get
end

function CDOTA_BaseNPC:IsWukongsSummon()
	return self:IsHero() and (
		self:HasModifier("modifier_monkey_king_fur_army_soldier") or
		self:HasModifier("modifier_monkey_king_fur_army_soldier_inactive") or
		self:HasModifier("modifier_monkey_king_fur_army_soldier_hidden")
	)
end

function CDOTA_BaseNPC:IsTrueHero()
	return self:IsRealHero() and not self:IsTempestDouble() and not self:IsWukongsSummon()
end

function CDOTA_BaseNPC:HasTalent(talentName)
	return self:HasAbility(talentName) and self:FindAbilityByName(talentName):GetLevel() > 0
end

function CDOTA_BaseNPC:FindTalentValue(talentName, value)
	if self:HasAbility(talentName) then
		local value_name = value or "value"
		return self:FindAbilityByName(talentName):GetSpecialValueFor(value_name)
	end
	return 0
end