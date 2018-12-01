modifier_hex_bh = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return true end,
	IsDebuff 				= function(self) return true end,
	IsBuff                  = function(self) return false end,
	RemoveOnDeath 			= function(self) return true end,
	DeclareFunctions		= function(self) return {MODIFIER_PROPERTY_MODEL_CHANGE,MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end,
})
function modifier_hex_bh:OnCreated(kv)
	if IsServer() then
		self.model = kv.Model
		self:SetSharedKey('MoveSpeed', kv.Slow)
	end
end
function modifier_hex_bh:GetModifierModelChange() return self.model end 
function modifier_hex_bh:GetModifierMoveSpeedBonus_Percentage() return self:GetSharedKey('MoveSpeed') end 
function modifier_hex_bh:CheckState()
	return {
		[MODIFIER_STATE_HEXED] = true,
		[MODIFIER_STATE_MUTED] = true,
		[MODIFIER_STATE_SILENCED] = true,
		[MODIFIER_STATE_DISARMED] = true,
	}
end

modifier_slow_movespeed = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return true end,
	IsDebuff 				= function(self) return true end,
	IsBuff                  = function(self) return false end,
	RemoveOnDeath 			= function(self) return true end,
	DeclareFunctions		= function(self) return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end,
})
function modifier_slow_movespeed:OnCreated(kv)
	if IsServer() then
		self:SetSharedKey('MoveSpeed', kv.Slow)
	end
end
function modifier_hex_bh:GetModifierMoveSpeedBonus_Percentage() return self:GetSharedKey('MoveSpeed') end 

