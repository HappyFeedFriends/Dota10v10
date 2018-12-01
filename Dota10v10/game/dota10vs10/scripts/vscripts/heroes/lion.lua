LinkLuaModifier ("modifier_hex_debuff", "heroes/lion", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_lion_mana_drain_new", "heroes/lion", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_lion_mana_drain_new_debuff_new", "heroes/lion", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_lion_fingerOfDeath_hidden", "heroes/lion", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier ("modifier_lion_magic_resistance_reduction", "heroes/lion", LUA_MODIFIER_MOTION_NONE)
if not lion_New_EarthSpike then
	lion_New_EarthSpike = class({})
end
--[[
	Lion: Earth Spike
	Devolopment: DotaNew
]]
function lion_New_EarthSpike:OnSpellStart()
	local caster = self:GetCaster()
	local vDirection = (caster:GetCursorPosition() - caster:GetOrigin()):Normalized()
	self.countHeroes = self:GetSpecialValueFor("count_target")
	self.targets = {}
	self.Projectile = 
	{
		Ability = self,
        EffectName = 'particles/units/heroes/hero_lion/lion_spell_impale.vpcf',
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = self:GetSpecialValueFor("distance"),
        fStartRadius = self:GetSpecialValueFor("width"),
        fEndRadius = self:GetSpecialValueFor("width"),
        Source = caster,
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		bDeleteOnHit = false,
		vVelocity = caster:GetForwardVector() * self:GetSpecialValueFor("speed"),										
	}
	
	ProjectileManager:CreateLinearProjectile(self.Projectile)
	EmitSoundOn('Hero_Lion.Impale',caster)
end

function lion_New_EarthSpike:OnProjectileHit( hTarget, vLocation )
	if hTarget and not hTarget:IsMagicImmune() and not self.targets[hTarget] then
		self.targets[hTarget] = true
		local caster = self:GetCaster()
		EmitSoundOn('Hero_Lion.ImpaleHitTarget',hTarget)
		hTarget:AddKnockBackHero({
			caster = caster,
			IsStun = false,
			ability = self,
			duration = 0.5,
		})
		hTarget:AddNewModifier(caster,self,'modifier_stunned',{
			duration = self:GetSpecialValueFor("duration") + 0.5
		})
		ApplyDamage({	
			victim = hTarget,
			attacker = caster,
			damage = self:GetSpecialValueFor("damage") + (caster:HasTalent('special_bonus_new_lion_3') and caster:FindTalentValue('special_bonus_new_lion_3') or 0),
			damage_type = self:GetAbilityDamageType(),
			damage_flags = self:GetAbilityTargetFlags(),
			ability = self, 
		})
		if self.countHeroes > 0 then
			local units = FindUnitsInRadius(caster:GetTeam(),hTarget:GetAbsOrigin(),nil, self:GetSpecialValueFor("radius"),DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,self:GetAbilityTargetFlags(),FIND_CLOSEST,false)
			for k,v in pairs(units) do
				if hTarget ~= v and v ~= caster and not v:IsCreep() and not hTarget:IsCreep() then
					local vDirection = (v:GetOrigin() - hTarget:GetOrigin())
					vDirection.z = 0
					local vDirection = vDirection:Normalized()
					self.Projectile.vSpawnOrigin = hTarget:GetAbsOrigin()
					self.Projectile.vVelocity = vDirection * self:GetSpecialValueFor("speed")
					self.Projectile.fDistance = (v:GetAbsOrigin() - hTarget:GetAbsOrigin()):Length2D(),
					ProjectileManager:CreateLinearProjectile(self.Projectile)
					self.countHeroes = self.countHeroes -1
					break
				end
			end
		end
	end
end 

--[[
	Lion: Hex 
	Devolopment: DotaNew
]]
if not lion_New_Hex then
	lion_New_Hex = class({})
end
function lion_New_Hex:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	target:AddNewModifier(caster,self,'modifier_hex_bh',{
		duration = self:GetSpecialValueFor("duration"),
		Slow = self:GetSpecialValueFor("SlowMove"),
		Model = 'models/items/hex/fish_hex/fish_hex.vmdl',
	})	
	target:AddNewModifier(caster,self,'modifier_hex_debuff',{duration = self:GetSpecialValueFor("duration")})
	EmitSoundOn('Hero_Lion.Voodoo',caster)
end 
if not modifier_hex_debuff then 
	modifier_hex_debuff = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return true end,
	IsDebuff 				= function(self) return true end,
	IsBuff                  = function(self) return false end,
	RemoveOnDeath 			= function(self) return true end,
})
end

function modifier_hex_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end 
function modifier_hex_debuff:OnAttackLanded(keys)
	if keys.target == self:GetParent() and self:GetCaster():HasTalent('special_bonus_new_lion_1') then
		ApplyDamage({	
			victim = keys.target,
			attacker = self:GetCaster(),
			damage = keys.damage / 100 * self:GetCaster():FindTalentValue('special_bonus_new_lion_1'),
			damage_type = keys.damage_type or 1 ,
			damage_flags = self:GetAbility():GetAbilityTargetFlags(),
			ability = self:GetAbility(), 
		})
	end 
end 
function modifier_hex_debuff:GetBonusTakeDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_hex_debuff:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("reduction_armor")
end 
--[[
	Lion: Mana Drain 
	Devolopment: DotaNew
]]
if not lion_New_ManaDrain then
	lion_New_ManaDrain = class({
		GetIntrinsicModifierName = function(self) return 'modifier_lion_mana_drain_new' end,
	})
end

if not modifier_lion_mana_drain_new then
	modifier_lion_mana_drain_new = class({
	IsHidden 				= function(self) return true end,
	IsPurgable 				= function(self) return true end,
	IsDebuff 				= function(self) return true end,
	IsBuff                  = function(self) return false end,
	RemoveOnDeath 			= function(self) return true end,
	IsAura 					= function(self) return true end,
	GetAuraSearchFlags 		= function(self) return self:GetAbility():GetAbilityTargetFlags() end,
	GetAuraSearchTeam 		= function(self) return self:GetAbility():GetAbilityTargetTeam() end,
	GetAuraSearchType 		= function(self) return self:GetAbility():GetAbilityTargetType() end,
	GetModifierAura 		= function(self) return 'modifier_lion_mana_drain_new_debuff_new' end,
	GetAuraRadius 			= function(self) return self:GetAbility():GetSpecialValueFor("radius") end,
	DeclareFunctions		= function(self) return {MODIFIER_EVENT_ON_ATTACK_LANDED} end
})
end 
function modifier_lion_mana_drain_new:OnAttackLanded(t)
	if t.attacker:IsRealHero() and t.target == self:GetCaster() and self:GetAbility():IsCooldownReady() and t.attacker:GetTeam() ~= self:GetCaster():GetTeam() then
		t.attacker:AddNewModifier(self:GetCaster(),self:GetAbility(),'modifier_stunned',{
			duration = self:GetAbility():GetSpecialValueFor("stunned_duration") + (self:GetCaster():HasTalent('special_bonus_new_lion_5') and self:GetCaster():FindTalentValue('special_bonus_new_lion_5') or 0)
		})
		self:GetAbility():StartCooldown(self:GetAbility():GetSpecialValueFor("stunned_delay"))
	end 
end
function modifier_lion_mana_drain_new:GetAuraEntityReject(hEntity)
	return hEntity == self:GetParent() or not hEntity:IsTrueHero()
end
if not modifier_lion_mana_drain_new_debuff_new then
	modifier_lion_mana_drain_new_debuff_new = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return true end,
	IsBuff                  = function(self) return false end,
	RemoveOnDeath 			= function(self) return true end,
	DeclareFunctions		= function(self) return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
})
end 
function modifier_lion_mana_drain_new_debuff_new:GetModifierMoveSpeedBonus_Percentage() return self:GetSharedKey('MoveSpeedR') end
function modifier_lion_mana_drain_new_debuff_new:OnCreated() self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("tick_interval")) end 

function modifier_lion_mana_drain_new_debuff_new:OnIntervalThink()
	if IsServer() then
		local parent = self:GetParent()
		local caster = self:GetCaster()
		local mp = self:GetAbility():GetSpecialValueFor("mana_per_second") + (caster:HasTalent('special_bonus_new_lion_2') and caster:FindTalentValue('special_bonus_new_lion_2') or 0)
		if parent:GetMana() > mp and parent ~= caster then
			caster:GiveMana(mp)
			parent:ReduceMana(mp)
		end 
		self:SetSharedKey('MoveSpeedR', self:GetAbility():GetSpecialValueFor("movespeed"))
	end
end
--[[
	Lion: Finger Of Death 
	Devolopment: DotaNew
]]
if not lion_New_FingerOfDeath then
	lion_New_FingerOfDeath = class({})
end

if not modifier_lion_fingerOfDeath_hidden then
	modifier_lion_fingerOfDeath_hidden = class({
	IsHidden 				= function(self) return false end,
	IsPurgable 				= function(self) return false end,
	IsDebuff 				= function(self) return false end,
	IsBuff                  = function(self) return true end,
	RemoveOnDeath 			= function(self) return false end,
})
end 

function lion_New_FingerOfDeath:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	EmitSoundOn("Hero_Lion.FingerOfDeath", caster)
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_lion/lion_spell_finger_of_death.vpcf",  PATTACH_POINT, caster)
	ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT, "attach_attack2", caster:GetOrigin(), false)
	ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT, "attach_hitloc", target:GetOrigin(), false)
	ParticleManager:SetParticleControl(particle, 2, target:GetOrigin())
	local CountStack = caster:HasModifier('modifier_lion_fingerOfDeath_hidden') and caster:GetModifierStackCount( 'modifier_lion_fingerOfDeath_hidden', self ) or 0
	local damage = self:GetSpecialValueFor("damage") + (CountStack * (self:GetSpecialValueFor("damage_per_kill") + (caster:HasTalent('special_bonus_new_lion_4') and caster:FindTalentValue('special_bonus_new_lion_4') or 0)))
	local ability = caster:FindAbilityByName('lion_New_Hex')
	if caster:HasScepter() then
		local units =FindUnitsInRadius(caster:GetTeam(),
		target:GetAbsOrigin(),
		nil, 
		self:GetSpecialValueFor("scepter_radius"),
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		self:GetAbilityTargetFlags(),
		FIND_CLOSEST,
		false)
		local count = self:GetSpecialValueFor("scepter_count_hero")
		for k,v in pairs(units) do
			if not v:IsMagicImmune() and v ~= target and v ~= caster and count > 0 then
				local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_lion/lion_spell_finger_of_death.vpcf",  PATTACH_POINT, target)
				ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_POINT, "attach_attack2", target:GetOrigin(), false)
				ParticleManager:SetParticleControlEnt(particle, 1, v, PATTACH_POINT, "attach_hitloc", v:GetOrigin(), false)
				ParticleManager:SetParticleControl(particle, 2, v:GetOrigin())
				count = count -1
				ApplyDamage({	
					victim = v,
					attacker = caster,
					damage = damage / 100 * (self:GetSpecialValueFor("scepter_procentage_damage") + (caster:HasTalent('special_bonus_new_lion_6') and caster:FindTalentValue('special_bonus_new_lion_6') or 0)),
					damage_type = self:GetAbilityDamageType(),
					damage_flags = self:GetAbilityTargetFlags(),
					ability = self, 
				})
				v:AddNewModifier(caster,self,'modifier_lion_magic_resistance_reduction',{duration=0.3})
				if v:HasModifier('modifier_hex_debuff') then
					if ability then
						v:AddNewModifier(caster,ability,'modifier_hex_debuff',{
							duration=v:FindModifierByName('modifier_hex_debuff'):GetRemainingTime() + self:GetSpecialValueFor("bonus_time")
						})
					end 
				end 
				EmitSoundOn("Hero_Lion.FingerOfDeathImpact", v)
			end
		end 
	end 
	target:AddNewModifier(caster,self,'modifier_lion_magic_resistance_reduction',{duration=0.3})
		ApplyDamage({	
			victim = target,
			attacker = caster,
			damage = damage,
			damage_type = self:GetAbilityDamageType(),
			damage_flags = self:GetAbilityTargetFlags(),
			ability = self, 
		})
		if target:HasModifier('modifier_hex_debuff') then
			if ability then
				target:AddNewModifier(caster,ability,'modifier_hex_debuff',{
					duration=target:FindModifierByName('modifier_hex_debuff'):GetRemainingTime() + self:GetSpecialValueFor("bonus_time")
				})
			end 
		end
		EmitSoundOn("Hero_Lion.FingerOfDeathImpact", target)
	if not target:IsAlive() and target:IsTrueHero() then
		caster:AddStackModifier({
			modifier = "modifier_lion_fingerOfDeath_hidden",
			ability = self,
		})
	end 
end 

if not modifier_lion_magic_resistance_reduction then 
	modifier_lion_magic_resistance_reduction = class({
	IsHidden 							= function(self) return true end,
	IsPurgable 							= function(self) return false end,
	IsDebuff 							= function(self) return true end,
	IsBuff                  			= function(self) return false end,
	RemoveOnDeath 						= function(self) return true end,
	DeclareFunctions					= function(self) return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS} end,
	GetModifierMagicalResistanceBonus	= function(self) return self:GetAbility():GetSpecialValueFor("reduction_resistance") end
})
end