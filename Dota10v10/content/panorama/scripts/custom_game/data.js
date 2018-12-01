
var dataInfo = {}
dataInfo.DATA_PLAYER =
{
	DEVS: {
		"76561198271575954":true,
	},
}

dataInfo.HeroSelection = {};
dataInfo.HeroSelection.PickedHeroName;
dataInfo.HeroSelection.HideAbility = {
	"shredder_return_chakram_2" : true,
	"nyx_assassin_burrow" : true,
	"wisp_tether_break" : true,
	"treant_eyes_in_the_forest" : true,
	"alchemist_unstable_concoction_throw" : true,
	"rubick_hidden1": true,
	"rubick_hidden2": true,
	"rubick_hidden3": true,
	"rubick_telekinesis_land": true,
	"phoenix_sun_ray_stop" : true,
	"wisp_spirits_in" : true, 
	"tiny_toss_tree" : true,
	"shredder_chakram_2" : true,
	"shredder_return_chakram" : true,
	"kunkka_return" : true,
	"abyssal_underlord_cancel_dark_rift" : true,
	"life_stealer_assimilate_eject" : true,
	"life_stealer_control" : true,
	"life_stealer_consume" : true,
	"life_stealer_assimilate" : true,
	"tusk_walrus_kick" : true,
	"tusk_launch_snowball" : true,
	"doom_bringer_empty1" : true,
	"doom_bringer_empty2" : true,
	"earth_spirit_petrify" : true,
	"lone_druid_true_form_druid" : true,
	"lone_druid_true_form_battle_cry" : true,
	"templar_assassin_trap" : true,
	"pangolier_gyroshell_stop" : true,
	"nyx_assassin_unburrow" : true,
	"elder_titan_return_spirit" : true,
	"ogre_magi_unrefined_fireblast" : true,
	"keeper_of_the_light_spirit_form_illuminate" : true,
	"keeper_of_the_light_spirit_form_illuminate_end" : true,
	"phoenix_icarus_dive_stop" : true,
	"phoenix_launch_fire_spirit" : true,
	"phoenix_sun_ray_toggle_move" : true,
	"naga_siren_song_of_the_siren_cancel" : true,
	"spectre_reality" : true,
	"keeper_of_the_light_illuminate_end" : true,
	"bane_nightmare_end" : true,
	"ancient_apparition_ice_blast_release" : true,
	"visage_stone_form_self_cast" : true,
	"puck_ethereal_jaunt" : true,
	"invoker_cold_snap" : true,
	"invoker_ghost_walk" : true,
	"invoker_tornado" : true,
	"invoker_emp" : true,
	"invoker_alacrity" : true,
	"invoker_chaos_meteor" : true,
	"invoker_sun_strike" : true,
	"invoker_forge_spirit" : true,
	"invoker_ice_wall" : true,
	"invoker_deafening_blast" : true,
	"techies_focused_detonate" : true,	
}

dataInfo.HeroSelection.types = {			
	1:"DOTA_ATTRIBUTE_STRENGTH",
	2:"DOTA_ATTRIBUTE_AGILITY",
	3:"DOTA_ATTRIBUTE_INTELLECT",
};
dataInfo.HeroSelection.KeyTable = "HeroSelection";
dataInfo.HeroSelection.prefixEffect = " > ";
dataInfo.HeroSelection.StagePick = {
	1:"picking_hero",
	2:"selection_hero",
};

dataInfo.HeroSelection.textColor = {
	PositivityText:"lime;", 
	NegativityText:"red;", 
	NotEffect:"yellow",
};
GameUI.CustomUIConfig().dataInfo = dataInfo;