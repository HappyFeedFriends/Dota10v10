var _ = GameUI.CustomUIConfig()._;
var DOTA_TEAM_SPECTATOR = 1;
var PlayerTables = GameUI.CustomUIConfig().PlayerTables;
var RegisterKeyBind = GameUI.CustomUIConfig().RegisterKeyBind;
var dataInfo = GameUI.CustomUIConfig().dataInfo;   

function GetDotaHud() {
	var rootUI = $.GetContextPanel();
	while (rootUI.id != "Hud" && rootUI.GetParent() != null) {
		rootUI = rootUI.GetParent();
	}
	return rootUI;
}

function GetNumberOfDecimal(n) {
    n = (typeof n == 'string') ? n : n.toString();
    if (n.indexOf('e') !== -1) return parseInt(n.split('e')[1]) * -1;
    var separator = (1.1).toString().split('1')[1];
    var parts = n.split(separator);
    return parts.length > 1 ? parts[parts.length - 1].length : 0;
}

function FindDotaHudElement(id){
  return GetDotaHud().FindChildTraverse(id);
}
function GetPlayerID(){
	return Game.GetLocalPlayerInfo().player_id;
}
function LengthTable(table){
	var k = 0;
	for (i in table)
		k++
	return k
} 

function SearchValueByTable(value,table){
	for (i in table){
		if (table[i] == value)
			return true
	}
	return false
}

function IsAllChildrenHide(Parent){
	var t = {}
	$.Each(Parent.Children(),function(child) {	
		t[child.id] = IsHiddenPanel(child);
	}); 
	for (var id in t){
		if (t[id] === false){
			return false
		}
	}
	return true
}

function GetRandomInt(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function HidePanelClass(panel){
	panel.SetHasClass("hidden",true);
}
function UnHidePanelClass(panel){
	panel.SetHasClass("hidden",false);
}

function HidePanel(panel) {
	if (!panel) return
	panel.style.visibility = "collapse;";
	panel.hittest = false;
	panel.enabled = false;
	panel.hidden_custom = true;
}

function UnHiddenPanel(panel) {
	if (!panel) return
	panel.style.visibility = "visible;";
	panel.hittest = true;
	panel.enabled = true;
	panel.hidden_custom = false;
}

function IsHiddenPanel(panel){
	return panel.hidden_custom
}
function GetInfoTableVampires(){
	return PlayerTables.GetAllTableValues('DataPlayer') && PlayerTables.GetAllTableValues('DataPlayer')["info"]
}
function IsVampire(pID){
	return GetInfoTableVampires() && GetInfoTableVampires()[pID].vampire == 1
}

function GetBlood(pID){
	return GetInfoTableVampires() && GetInfoTableVampires()[pID].blood || 0
}

function GetGold(pID){
	return GetInfoTableVampires() && GetInfoTableVampires()[pID].gold || 0
}

function GetClassHero(pID){
	return GetInfoTableVampires() && GetInfoTableVampires()[pID].classHero || -1
}

function IsHeroName(str) {
	return IsDotaHeroName(str);
}

function IsDotaHeroName(str) {
	return str.lastIndexOf('npc_dota_hero_') === 0;
}

function GetHeroName(unit) {
	return Entities.GetUnitName(unit);
}

function SortDec(a, b) {
  if (a > b) return -1;
  if (a < b) return 1;
}
function ShowAbilityTooltip( ability )
{
	return function()
	{
		$.DispatchEvent( "DOTAShowAbilityTooltip", ability, ability.abilityname ); 
	}
};

function HideAbilityTooltip ( ability )
{
	return function()
	{
		$.DispatchEvent( "DOTAHideAbilityTooltip", ability );
	}
};

function ShowText(panel,description,title)
{
	return function(){
		if (title) 
		{
			$.DispatchEvent("DOTAShowTitleTextTooltip",panel, title, description);
		} 
		else
		{
			$.DispatchEvent("DOTAShowTextTooltip", panel, description);
		}
	}
};

function HideText(title) 
{
	return function (){
		if (title) {
			$.DispatchEvent("DOTAHideTitleTextTooltip");
		} 
		else 
		{
			$.DispatchEvent("DOTAHideTextTooltip");
		}
	}
}
function SelectionTeam(args){
	args = args == "Human" && DOTATeam_t.DOTA_TEAM_GOODGUYS || DOTATeam_t.DOTA_TEAM_BADGUYS;
	GameEvents.SendCustomGameEventToServer( "PickedTeamHero", {PlayerID: GetPlayerID(), Team:args} );
}
function PrefixPlayer(id) {
	return IsVampire(id) && ("[" + $.Localize("vampire") + "] ") || ("[" + $.Localize("man") + "] ");
}

function BuyItem(Panel){
	return function()
	{
		GameEvents.SendCustomGameEventToServer('BuyItem', Panel.data );
	}
}

function OpenShop(){
	var shop = FindDotaHudElement('CustomShopList');
	if (IsHiddenPanel(shop))
		UnHiddenPanel(shop);
	else
		HidePanel(shop);
}

function UpdateButtonShopLabel(pID){
	 var GoldLabel = FindDotaHudElement('CustomShopButton').FindChildTraverse('CustomShopButtonLabel');
	GoldLabel.text = " <font color='"+ (IsVampire(pID) && 'red' || 'gold') +"'>" + FormatGold((IsVampire(pID) && GetBlood(pID) || GetGold(pID))) + "</font> <img class='" + (IsVampire(pID) && 'BloodIcons' || 'GoldIcons') +"' /> ";
	var CostLabel = FindDotaHudElement("BuyCostLabel");
	var ItemCostIcon = FindDotaHudElement("ItemCostIcon"); 
	if (ItemCostIcon)
		ItemCostIcon.style.backgroundImage =  IsVampire(pID) && "url('file://{images}/custom_game/custom_icon/blood.png')" || "url('s2r://panorama/images/hud/icon_gold_psd.vtex')";
	if (CostLabel)
		CostLabel.style.color = IsVampire(pID) && "#FF0000" || "#FFCC33";
  }
function TogglePanel(Panel){
	if (IsHiddenPanel(Panel))
		UnHiddenPanel(Panel)
	else
		HidePanel(Panel)
}
function HiddenButtonShop(){
	HidePanel(FindDotaHudElement("quickbuy"))
	HidePanel(FindDotaHudElement("shop_launcher_bg"))	
	//HidePanel(FindDotaHudElement("shop"))	
	HidePanel(FindDotaHudElement("stash_bg"))
	HidePanel(FindDotaHudElement("StatBranch")); 
	HidePanel(FindDotaHudElement("statbranchdialog")); 
	HidePanel(FindDotaHudElement("level_stats_frame")); 
}

//======================================================
//	Author: Ark120202
//	Custom Game: Angel Arena Black Start
//====================================================== 

function TransformTextureToPath(texture, optPanelImageStyle) {
	if (IsHeroName(texture)) {
		return optPanelImageStyle === 'portrait' ?
			'file://{images}/heroes/selection/' + texture + '.png' :
			optPanelImageStyle === 'icon' ?
				'file://{images}/heroes/icons/' + texture + '.png' :
				'file://{images}/heroes/' + texture + '.png';
	} else if (texture.lastIndexOf('npc_') === 0) {
		return optPanelImageStyle === 'portrait' ?
			'file://{images}/custom_game/units/portraits/' + texture + '.png' :
			'file://{images}/custom_game/units/' + texture + '.png';
	} else if (optPanelImageStyle === 'Ability') {
		return 'file://{images}/spellicons/' + texture + '.png'
	} else if (optPanelImageStyle === 'Rune'){
			return 'file://{images}/rune/rune_' + texture + '.png'
	}else if (optPanelImageStyle === 'custom_icon') {
		return 'file://{images}/custom_game/custom_icon/' + texture + '.png' 
	}
	else{
		return optPanelImageStyle === 'item' ?
			'raw://resource/flash3/images/items/' + texture + '.png' :
			'raw://resource/flash3/images/spellicons/' + texture + '.png';
	}
}

function SafeGetPlayerHeroEntityIndex(playerId) {
	var clientEnt = Players.GetPlayerHeroEntityIndex(playerId);
	return clientEnt === -1 ? (Number(PlayerTables.GetTableValue('player_hero_indexes', playerId)) || -1) : clientEnt;
}

function GetPlayerHeroName(playerId) {
	if (Players.IsValidPlayerID(playerId)) {
		return GetHeroName(SafeGetPlayerHeroEntityIndex(playerId));
	}
	return '';
}

function GetTeamInfo(team) {
	var t = PlayerTables.GetTableValue('teams', team) || {};
	return {
		score: t.score || 0,
	};
}

function GetHEXPlayerColor(playerId) {
	var playerColor = Players.GetPlayerColor(playerId).toString(16);;
	return playerColor == null ? '#000000' : ('#' + playerColor.substring(6, 8) + playerColor.substring(4, 6) + playerColor.substring(2, 4) + playerColor.substring(0, 2));
}

function secondsToMS(seconds, bTwoChars) {
	var sec_num = parseInt(seconds, 10);
	var minutes = Math.floor(sec_num / 60);
	var seconds = Math.floor(sec_num - minutes * 60);

	if (bTwoChars && minutes < 10)
		minutes = '0' + minutes;
	if (seconds < 10)
		seconds = '0' + seconds;
	return minutes + ':' + seconds;
}

function SortPanelChildren(panel, sortFunc, compareFunc) {
	var tlc = panel.Children().sort(sortFunc);
	$.Each(tlc, function(child) {
		for (var k in tlc) {
			var child2 = tlc[k];
			if (child !== child2 && compareFunc(child, child2)) {
				panel.MoveChildBefore(child, child2);
				break;
			} 
		}
	});
};

function dynamicSort(property) {
	var sortOrder = 1;
	if (property[0] === '-') {
		sortOrder = -1;
		property = property.substr(1);
	}
	return function(a, b) {
		var result = (a[property] < b[property]) ? -1 : (a[property] > b[property]) ? 1 : 0;
		return result * sortOrder;
	};
}

function FormatComma (value) {
  try {
    return value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
  } catch (e) {}
}

function FormatGold (gold) {
  var formatted = FormatComma(gold);
  if (gold.toString().length > 7) {
    return FormatGold(gold.toString().substring(0, gold.toString().length - 5) / 10) + 'M';
  } else if (gold.toString().length > 6) { 
    return FormatGold(gold.toString().substring(0, gold.toString().length - 3)) + 'k';
  } else {
    return formatted;
  }
}


function IsDotaHeroName(str) {
	return str.lastIndexOf('npc_dota_hero_') === 0;
}

//======================================================