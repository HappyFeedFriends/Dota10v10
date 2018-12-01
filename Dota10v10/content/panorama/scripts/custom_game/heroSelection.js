var types = dataInfo.HeroSelection.types;  
var prefixEffect = dataInfo.HeroSelection.prefixEffect
var textColor = dataInfo.HeroSelection.textColor
var settings = {};
var KeyTable = dataInfo.HeroSelection.KeyTable;
var Main = FindDotaHudElement('MainPickHero');
var BG = FindDotaHudElement('BackgroundPanel');
var SelectionHeroMain = FindDotaHudElement('MainSelectionHero');
var TimerTime = FindDotaHudElement('HeroSelectionTimer');
var SearchPanel = Main.GetParent().FindChildTraverse("SearchContainer")
var FORCE_PICKED_HERO = CustomNetTables.GetTableValue(KeyTable,"settings")["Hero"];
var TimeToPick = 0;
var PickHeroes = {};
var h,t;
var SearchingFor = null;
var StagePick = dataInfo.HeroSelection.StagePick;
var PickedHeroName = dataInfo.HeroSelection.PickedHeroName;
if (!AllHero){
	var AllHero = {}
	for (i in types){
		t = CustomNetTables.GetTableValue(KeyTable,types[i]);
		for (j in t){
			h = t[j];
			AllHero[Number(LengthTable(AllHero)) + 1] = h;
		}
	}
}
settings.Decimal = 1;
settings.intellect = $.GetContextPanel().FindChildTraverse("intellectInfo").FindChildTraverse('MonoNumbersFont');
settings.strength = $.GetContextPanel().FindChildTraverse("StrengthtInfo").FindChildTraverse('MonoNumbersFont');
settings.Agility = $.GetContextPanel().FindChildTraverse("AgilityInfo").FindChildTraverse('MonoNumbersFont');
settings.Damage = $.GetContextPanel().FindChildTraverse("DamageInfo").FindChildTraverse('MonoNumbersFont');
settings.AttackRateInfo = $.GetContextPanel().FindChildTraverse("AttackRateInfo").FindChildTraverse('MonoNumbersFont');
settings.AttackRangeInfo = $.GetContextPanel().FindChildTraverse("AttackRangeInfo").FindChildTraverse('MonoNumbersFont');
settings.ProjectileSpeedRow = $.GetContextPanel().FindChildTraverse("ProjectileSpeedRow").FindChildTraverse('MonoNumbersFont');
settings.ArmorInfo = $.GetContextPanel().FindChildTraverse("ArmorInfo").FindChildTraverse('MonoNumbersFont');
settings.MagicInfo = $.GetContextPanel().FindChildTraverse("MagicInfo").FindChildTraverse('MonoNumbersFont');
settings.MoveSpeedInfo = $.GetContextPanel().FindChildTraverse("MoveSpeedInfo").FindChildTraverse('MonoNumbersFont');
settings.TurnRateInfo = $.GetContextPanel().FindChildTraverse("TurnRateInfo").FindChildTraverse('MonoNumbersFont');
settings.SightInfo = $.GetContextPanel().FindChildTraverse("SightInfo").FindChildTraverse('MonoNumbersFont');
settings.HeroOverview = $.GetContextPanel().FindChildTraverse("HeroOverview");
settings.HeroLore = $.GetContextPanel().FindChildTraverse("HeroLore");
function CreateTimer(data){	
	TimeToPick = data.time;
	var Timer = TimerTime.FindChild( "time" );
	if (!Timer){
		Timer = $.CreatePanel( "Label", TimerTime, "time" );   
	}	
	var TimerInfo = TimerTime.FindChild( "time_info" );
	if (!TimerInfo){
		TimerInfo = $.CreatePanel( "Label", TimerTime, "time_info" );   
		TimerInfo.style.fontSize = "20px;";
		TimerInfo.style.marginTop = "-20px";
	}
	if (TimeToPick <= 0){
		PickedRandom();	
		PickingEndAll();
	}
	Timer.text = secondsToMS(GetPickTime(), true);
	TimerInfo.text = IsHiddenPanel(SelectionHeroMain) && $.Localize("stage_" + StagePick[1]) || $.Localize("stage_" + StagePick[2]);
}


function CreateAbilitiesPanelUI(heroDataPanel,abilities){
	var abilityHero = heroDataPanel.FindChild( "abilityHero" );
	if (!abilityHero){
		abilityHero = $.CreatePanel( "Panel", heroDataPanel, "abilityHero" ); 
		abilityHero.SetHasClass( "abilityHero", true );
	}
	var ability,panel;
	var abilityNum = 0;
	for (i in abilities){
		ability = abilities[i];
		if (!dataInfo.HeroSelection.HideAbility[ability]){
			abilityNum++;
			panel = abilityHero.FindChild( "Ability_hero_" + abilityNum );
			if (!panel){
				panel = $.CreatePanel( "DOTAAbilityImage", abilityHero, "Ability_hero_" + abilityNum );
				panel.SetHasClass( "AbilityPanel", true );
			}
				panel.abilityname = ability;
				panel.SetPanelEvent( "onmouseover", ShowAbilityTooltip( panel ) );
				panel.SetPanelEvent( "onmouseout", HideAbilityTooltip( panel ) );
		}
	};
	RefreshAbilityList(abilityNum,abilityHero);
}
function CreateButtonPanelsUI(heroDataPanel,name,data){
	var ButtonPickHero = heroDataPanel.FindChild( "ButtonPickHero" );
	if (!ButtonPickHero){
		ButtonPickHero = $.CreatePanel("Panel", heroDataPanel, "ButtonPickHero"); 
		ButtonPickHero.SetHasClass("ButtonPickHero",true);
	}
	var ButtonLabel = ButtonPickHero.FindChild( "ButtonPickLabel" );
	if (!ButtonLabel){
		ButtonLabel = $.CreatePanel("Label", ButtonPickHero, "ButtonPickLabel"); 
	}  
	var ButtonRepickHero  = heroDataPanel.FindChild( "ButtonRepickHero" );
	if (!ButtonRepickHero){
		ButtonRepickHero = $.CreatePanel("Panel", heroDataPanel, "ButtonRepickHero"); 
		ButtonRepickHero.SetHasClass("ButtonRepickHero",true);
		ButtonRepickHero.SetPanelEvent( "onactivate", RepickHero() );
	}
	var ButtonRepickHeroLabel = ButtonRepickHero.FindChild( "ButtonRepickHeroLabel" );
	if (!ButtonRepickHeroLabel){
		ButtonRepickHeroLabel = $.CreatePanel("Label", ButtonRepickHero, "ButtonRepickHeroLabel");   
	}
	ButtonRepickHeroLabel.text = $.Localize("#repick_hero");
	ButtonLabel.text = $.Localize("#playing_hero") + " " + $.Localize(name);
	ButtonPickHero.SetPanelEvent( "onactivate", PickedHero( data ) );
}

function CreateScenePanelUI(heroDataPanel,name){
	var ScenePanel = heroDataPanel.FindChild( "ScenePanel" );
	if (!ScenePanel){
		ScenePanel = $.CreatePanel("Panel", heroDataPanel, "ScenePanel"); 
		ScenePanel.SetHasClass("ScenePanelHero",true);
		ScenePanel.style.opacityMask = 'url("s2r://panorama/images/masks/hero_model_opacity_mask_png.vtex");';
	}
	var heroImageXML = '<DOTAScenePanel style="width:100%; height:100%;" particleonly="false" ' +
		(!IsDotaHeroName(name)
			? 'map="scenes/heroes" camera="' + name + '" />'
			: 'allowrotation="true" unit="' + name + '" />');
	ScenePanel.RemoveAndDeleteChildren();
	ScenePanel.BCreateChildren(heroImageXML);
}
 
function OpenHero(data){
	var TimerInfo = TimerTime.FindChild( "time_info" );
	if (TimerInfo)
	HidePanel(SearchPanel);
	TimerInfo.text = IsHiddenPanel(SelectionHeroMain) && $.Localize("stage_" + StagePick[1]) || $.Localize("stage_" + StagePick[2]);
	var name = data.heroName;
	UpdateHeroInformation(name);
	var abilities = CustomNetTables.GetTableValue(KeyTable,name);
	var heroDataPanel = SelectionHeroMain.FindChild( "heroDataPanel" );
	if (!heroDataPanel){
		heroDataPanel = $.CreatePanel( "Panel", SelectionHeroMain, "heroDataPanel" );
		heroDataPanel.SetHasClass( "heroDataPanel", true );		
	}	
	CreateAbilitiesPanelUI(heroDataPanel,abilities);
	CreateScenePanelUI(heroDataPanel,name);
	CreateButtonPanelsUI(heroDataPanel,name,data); 
}
 
function UpdateHeroInformation(HeroName){
	var table = PlayerTables.GetTableValue("HeroSelection",HeroName)
	for (var i in table){
		table[i] = GetNumberOfDecimal(table[i]) > 1 && table[i].toFixed(settings.Decimal) || table[i];
	} 
	if (!table.ProjectileSpeed)
		HidePanel(settings.ProjectileSpeedRow.GetParent());
	else
	UnHiddenPanel(settings.ProjectileSpeedRow.GetParent());
	settings.strength.SetDialogVariable("base_str",table.attribute_base_0); 
	settings.strength.SetDialogVariable("str_per_level",table.attribute_gain_0);
	settings.intellect.SetDialogVariable("base_int",table.attribute_base_2); 
	settings.intellect.SetDialogVariable("int_per_level",table.attribute_gain_2 );
	settings.Agility.SetDialogVariable("base_agi",table.attribute_base_0);
	settings.Agility.SetDialogVariable("agi_per_level",table.attribute_gain_0); 
	settings.AttackRateInfo.SetDialogVariable("attack_rate",table.attackrate); 
	settings.ProjectileSpeedRow.text = table.ProjectileSpeed || "";
	settings.AttackRangeInfo.text = table.attackRange || ""; 
	settings.ArmorInfo.SetDialogVariable("armor",table.armor); 
	settings.MagicInfo.text = table.resistance || 25 + "%"; 
	settings.MoveSpeedInfo.text = table.movespeed; 
	settings.TurnRateInfo.text = table.MovementTurnRate; 
	settings.SightInfo.text = (table.SightDay || 1800) + " / " + (table.SightNight || 800); 
	settings.Damage.text = table.damage_min.toFixed(0) + " - " +  table.damage_max.toFixed(0); 
	settings.HeroOverview.SetDialogVariable("hero_hype",$.Localize(HeroName + "_Hype"));
	settings.HeroLore.text = $.Localize(HeroName + "_bio")
}    

function RefreshAbilityList(RefreshMin,abilityHero){
	for (var i = RefreshMin+1;i <= 24;i++){
		if (abilityHero.FindChild( "Ability_hero_" + i ))
		HidePanel(abilityHero.FindChild( "Ability_hero_" + i ));
	}
	for (var i = 1;i < RefreshMin;i++){
		if (abilityHero.FindChild( "Ability_hero_" + i ))
			UnHiddenPanel(abilityHero.FindChild( "Ability_hero_" + i ));
	}
}

function FillHeroSelection(){
	for (i in types){
		Fill(types[i]);
	}
	UnHiddenPanel(Main);
	HidePanel(SelectionHeroMain);  
}

function Fill(type){
	if (!Main) return 
	var heroes = CustomNetTables.GetTableValue(KeyTable,type);
	var sortable = [];
	for (var vehicle in heroes) {
		sortable.push(heroes[vehicle]);
	}
	sortable.sort();
	var IsUpgrade,IsDisabled;
	type = type.replace("DOTA_ATTRIBUTE_","");
	var AttributesPanel = Main.FindChild( type );
	if (!AttributesPanel){
		AttributesPanel = $.CreatePanel( "Panel", Main, type );  
		AttributesPanel.SetHasClass( "AttributesPanel", true );
	};
	var length = LengthTable(heroes)
	sortable.forEach(function(HeroName){
		IsUpgrade = PlayerTables.GetTableValue("HeroSelection",HeroName).IsUpgrade
		IsDisabled = PlayerTables.GetTableValue("HeroSelection",HeroName).IsDisabled
		var PanelHero = $.CreatePanel( "Panel", AttributesPanel, HeroName ); 
		PanelHero.SetHasClass( "HeroPanel", true );  
		PanelHero.data = {
			heroName:HeroName,
			pID:GetPlayerID(),
		};
		var HeroCard = $.CreatePanel('Image', PanelHero, "ImageHero");
		HeroCard.SetImage(TransformTextureToPath(HeroName, 'portrait'));
		var HeroMovie = $.CreatePanel( "DOTAHeroMovie", PanelHero, 'HeroMovie' );
		PanelHero.SetPanelEvent('onmouseover', function() {
			if (IsDotaHeroName(HeroName)){
				HeroMovie.heroname = HeroName;
				HeroMovie.style.opacity = "1"
			}
		});
		PanelHero.SetPanelEvent('onmouseout', function() {
			HeroMovie.heroname = null;
			HeroMovie.style.opacity = "0"
		});
		PanelHero.SetPanelEvent( "onactivate", OpenInfoHero( PanelHero ));			
		PanelHero.heroname = HeroName;
		if (IsUpgrade){ 
			panelUpgrade = $.CreatePanel( "Panel", PanelHero, 'IsUpgrade' );	
			panelUpgrade = $.CreatePanel( "Panel", PanelHero, 'IsUpgrade' );
			panelUpgrade.AddClass('IsUpgrade');
			PanelUpgradeLabel = $.CreatePanel( "Label", panelUpgrade, 'IsUpgradeLabel' );
			PanelUpgradeLabel.text = $.Localize('IsUpgrade'); 
		}
		if (IsDisabled){
			PanelHero.enabled = false;
			PanelHero.hittest = false;
		}
	});	
} 
function PickedRandom(){
	if (Game.GetPlayerInfo(GetPlayerID()).player_selected_hero == FORCE_PICKED_HERO){ 
		var LengthAllTables = 0;
		for (i in types){
			LengthAllTables += LengthTable(CustomNetTables.GetTableValue(KeyTable,types[i]));
		}
		var data = {
			heroName:PickedHeroNotPicked(),
			pID:Game.GetLocalPlayerInfo().player_id,
		};
		PickHero(data);
	}
}    
function PickHero(data,skip){
	for (i in CustomNetTables.GetTableValue("HeroSelection", "picks")){
		if (CustomNetTables.GetTableValue("HeroSelection", "picks")[i] == data.heroName && i != GetPlayerID()){
			if (GetPickTime() > 0){
				RepickHero();
			}else{
				PickedHero({
					pID:data.pID,
					heroName:PickedHeroNotPicked(),
				});
				return
			}
		}
	}
	if (!PickHeroes[data.pID])
		PickHeroes[data.pID] = data.heroName;
	if ($.GetContextPanel().FindChildTraverse('ButtonRepickHero'))
	$.GetContextPanel().FindChildTraverse('ButtonRepickHero').enabled = false;
	if ($.GetContextPanel().FindChildTraverse('ButtonPickHero'))
	$.GetContextPanel().FindChildTraverse('ButtonPickHero').enabled = false;
	GameEvents.SendCustomGameEventToServer( "PickedHero", data );
}
function PickedHero( data,skip ){
	return function(){
		PickHero(data,skip)
	}
} 

function RepickHero(){
	return function(){
		var TimerInfo = TimerTime.FindChild( "time_info" );
		if (TimerInfo)
		TimerInfo.text = IsHiddenPanel(Main) && $.Localize("stage_" + StagePick[1]) || $.Localize("stage_" + StagePick[2]);
		HidePanel(SelectionHeroMain);
		UnHiddenPanel(Main);
		UnHiddenPanel(SearchPanel);
	}
}

function OpenInfoHero(Panel){
	return function(){
		HidePanel(Main);
		UnHiddenPanel(SelectionHeroMain);
		OpenHero(Panel.data);
	}
}

function PickingEnd(){
	var t = CustomNetTables.GetTableValue(KeyTable,"picks")
	for (var i in t){
		if ($.GetContextPanel().FindChildTraverse(i) && $.GetContextPanel().FindChildTraverse(i) !== 0){
			$.GetContextPanel().FindChildTraverse(i).hittest = false;
			$.GetContextPanel().FindChildTraverse(i).enabled = false;
		}
	}
}
function PickingEndAll(){
	HidePanel(Main.GetParent());
	HidePanel(Main);
	HidePanel(BG);
	HidePanel(SelectionHeroMain);
	HidePanel(TimerTime);
	HidePanel(SearchPanel);
}

function GetPickTime(){
	return TimeToPick
}

function PickedHeroNotPicked(){
	var data,RandomHero;
	var LengthAllTables = 0;
	for (i in types){
		LengthAllTables += LengthTable(CustomNetTables.GetTableValue(KeyTable,types[i]));
	} 
	var t = CustomNetTables.GetTableValue(KeyTable, "picks");
	while (true){
		RandomHero = AllHero[String(GetRandomInt(1,LengthAllTables))];
		if (!SearchValueByTable(RandomHero,t))
			return RandomHero;
	}
}   

function SearchHero(){
	var searchStr = SearchPanel.FindChildTraverse('SearchTextEntry').text.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, '\\$&');
	var localize;
	if (searchStr  !== SearchingFor){
		SearchingFor = searchStr; 
		if (SearchingFor.length > 0){
			_.each(Main.Children(),function(child) {
				_.each(child.Children(),function(childs) {
					localize = $.Localize(childs.heroname).toLowerCase();
					searchStr = searchStr.toLowerCase();
					if (childs.enabled){
						childs.SetHasClass('IsSearchHero',localize.match(searchStr) !== null);
						childs.SetHasClass('NoSearchHero',!localize.match(searchStr));
						childs.hittest = localize.match(searchStr) === null;
					}
				});
			}); 
		}else{
			_.each(Main.Children(),function(child) {
				_.each(child.Children(),function(childs) {
					childs.SetHasClass('IsSearchHero',false)
					childs.SetHasClass('NoSearchHero',false)
					childs.hittest = true;
				}); 
			}); 
		}
	}
}
function AutoUpdateSearchHero(){
	SearchHero();
	if (!IsHiddenPanel(BG))
	$.Schedule(0.1,AutoUpdateSearchHero);
}
(function(){ 
	if (Game.GetPlayerInfo(GetPlayerID()).player_selected_hero === FORCE_PICKED_HERO){
		FillHeroSelection(); 
		AutoUpdateSearchHero();
		var tables = CustomNetTables.GetTableValue(KeyTable,"picks"); 
		if (tables && tables[GetPlayerID()] && IsHeroName(tables[GetPlayerID()])){
			var dataInfo = {
				heroName:tables[GetPlayerID()],
				pID:Game.GetLocalPlayerInfo().player_id, 
			}
			OpenHero( dataInfo );
			HidePanel(Main);
			UnHiddenPanel(SelectionHeroMain);
			PickedHero( dataInfo )
		} 
	}else{
		PickingEndAll();
	}
	if (Players.GetTeam(Players.GetLocalPlayer()) == DOTA_TEAM_SPECTATOR)
		PickingEndAll();
	GameEvents.Subscribe('HeroSelection_picked', PickingEnd);
	GameEvents.Subscribe('HeroSelectionTimer', CreateTimer);
})(); 