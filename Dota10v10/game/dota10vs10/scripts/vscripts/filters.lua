function DotaNew:FiltersOn()
	GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(DotaNew, 'ExecuteOrderFilter'), self )
	GameRules:GetGameModeEntity():SetDamageFilter(Dynamic_Wrap(DotaNew, 'DamageFilter'), self)
	GameRules:GetGameModeEntity():SetModifyExperienceFilter(Dynamic_Wrap(DotaNew, 'ExpFilter'), self)
	GameRules:GetGameModeEntity():SetModifyGoldFilter(Dynamic_Wrap(DotaNew, 'ModifyGoldFilter'), self)
	--GameRules:GetGameModeEntity():SetModifierGainedFilter(Dynamic_Wrap(DotaNew, 'ModifyModifierFilter'), self)
end
function DotaNew:ExpFilter(keys)
	keys.experience = keys.experience * 1.7
	return true
end 

function DotaNew:ModifyGoldFilter(filterTable)
	filterTable.gold = filterTable.gold * 1.5
	return true
end

function DotaNew:ExecuteOrderFilter(filterTable)
	local order_type = filterTable.order_type
	local unit = EntIndexToHScript(filterTable.units["0"])
	local playerId = filterTable.issuer_player_id_const
	local target = EntIndexToHScript(filterTable.entindex_target)
	local ability = EntIndexToHScript(filterTable.entindex_ability)
	local abilityname
	if ability and ability.GetAbilityName then
		abilityname = ability:GetAbilityName()
	end
	return true
end

function DotaNew:DamageFilter(filterDamage)
-- Fix Swap Hero
		local attacker = filterDamage.entindex_attacker_const and EntIndexToHScript(filterDamage.entindex_attacker_const) 
		if not attacker then return true end 
		local ability,abilityName
		local victim = EntIndexToHScript(filterDamage.entindex_victim_const)
		if filterDamage.entindex_inflictor_const then
			ability = EntIndexToHScript(filterDamage.entindex_inflictor_const )
			if ability and ability:GetAbilityName() then
				abilityName = ability:GetAbilityName()
			end
		end
		if victim:IsHero() then
			filterDamage.damage = filterDamage.damage + victim:GetBonusTakeDamage()
		end
		local TYPE = filterDamage.damagetype_const
	return true
end