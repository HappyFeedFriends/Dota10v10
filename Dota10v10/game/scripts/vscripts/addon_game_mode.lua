-- This is the entry-point to your game mode and should be used primarily to precache models/particles/sounds/etc
require('gamemode')

function Precache( context )
  PrecacheResource("particle", "particles/econ/generic/generic_aoe_explosion_sphere_1/generic_aoe_explosion_sphere_1.vpcf", context)
  PrecacheResource("particle_folder", "particles/test_particle", context)
  PrecacheResource("model_folder", "particles/heroes/antimage", context)
  PrecacheModel("models/heroes/viper/viper.vmdl", context)
  PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_gyrocopter.vsndevts", context)
  PrecacheItemByNameSync("example_ability", context)
  PrecacheItemByNameSync("item_example_item", context)
  PrecacheUnitByNameSync("npc_dota_hero_ancient_apparition", context)
  PrecacheUnitByNameSync("npc_dota_hero_enigma", context)
end

-- Create the game mode when we activate
function Activate()
  GameRules.GameMode = DotaNew()
  GameRules.GameMode:Init()
end
LinkLuaModifier ("modifier_hex_bh", "util/modifiers", LUA_MODIFIER_MOTION_NONE)