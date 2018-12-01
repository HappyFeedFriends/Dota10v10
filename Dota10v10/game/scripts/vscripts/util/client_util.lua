
function CDOTA_Buff:GetSharedKey(key)
	local t = CustomNetTables:GetTableValue("modifiers_value", self:GetParent():GetEntityIndex() .. "_" .. self:GetName()) or {}
	return t[key]
end

function C_DOTA_BaseNPC:HasTalent(talentName)
	if self:HasModifier("modifier_"..talentName) then
		return true 
	end
	return false
end

function C_DOTA_BaseNPC:FindTalentValue(talentName, key)
	if self:HasModifier("modifier_"..talentName) then  
		local value_name = key or "value"
		CUSTOM_ABILITIES = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
		local specialVal = CUSTOM_ABILITIES[talentName]["AbilitySpecial"]
		for l,m in pairs(specialVal) do
			if m[value_name] then
				return m[value_name]
			end
		end
	end    
	return 0
end