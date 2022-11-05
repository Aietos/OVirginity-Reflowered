ScriptName OVirginityScript Extends OStimAddon

string IsVirginKey = "IsVirgin"
string HymenKey = "HasHymen"

bool domVirgin
bool subVirgin
bool thirdVirgin

OCumScript OCum

AssociationType property Spouse Auto
race property OldPeopleRace auto

spell property virginityLossBloodSpell auto

sound property hymenBreak auto

faction property jobInnServer auto
faction property favorJobsBeggarFaction auto
faction property markarthTempleofDibellaFaction auto
faction property ovProstitute auto

bool property disableBloodTextures auto
bool property disableBloodDripping auto
bool property disableBloodierTextures auto

int property virginityChance auto
int property marriedVirginityChance auto
int property prostituteVirginityChance auto
int property elderRaceVirginityChance auto
int property checkVirginityKey auto
int property toggleVirginityKey auto
int property bloodDrippingTimer auto


;  ██████╗ ██╗   ██╗██╗██████╗  ██████╗ ██╗███╗   ██╗██╗████████╗██╗   ██╗
; ██╔═══██╗██║   ██║██║██╔══██╗██╔════╝ ██║████╗  ██║██║╚══██╔══╝╚██╗ ██╔╝
; ██║   ██║██║   ██║██║██████╔╝██║  ███╗██║██╔██╗ ██║██║   ██║    ╚████╔╝ 
; ██║   ██║╚██╗ ██╔╝██║██╔══██╗██║   ██║██║██║╚██╗██║██║   ██║     ╚██╔╝  
; ╚██████╔╝ ╚████╔╝ ██║██║  ██║╚██████╔╝██║██║ ╚████║██║   ██║      ██║   
;  ╚═════╝   ╚═══╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝      ╚═╝   

; ------------------------ Main OVirginity logic functions ------------------------ ;

bool Function isVirgin(actor npc)
	if !isActorValid(npc)
		return false
	endif

	int lookup = OUtils.GetNPCDataInt(npc, IsVirginKey)
	;1 Yes, virgin
	;0 No, not virgin
	;-1 Not yet calculated

	if lookup == 1
		return true
	elseif lookup == 0
		return false
	elseif lookup == -1
		return calculateVirginity(npc)
	endif
EndFunction


Function setVirginity(actor npc, bool virgin, bool fx = false)
	if !isActorValid(npc)
		return
	endif

	int virginnum

	if virgin
		virginnum = 1
		if OStim.isFemale(npc)
			OUtils.StoreNPCDataBool(npc, HymenKey, true)
		endif 
	else
		virginnum = 0
	endif

	OUtils.StoreNPCDataInt(npc, IsVirginKey, virginnum)

	if fx && OStim.IsFemale(npc)
		BreakHymen(npc)
	endif

EndFunction


Function BreakHymen(actor npc)
	if !isActorValid(npc)
		return
	endif

	if !OUtils.GetNPCDataBool(npc, HymenKey)
		writeLog("Hymen already broken")
		return 
	endif

	ApplyBlood(npc)
	ostim.PlaySound(npc, hymenbreak)
EndFunction


Function ApplyBlood(actor act)
	if !isActorValid(act)
		return
	endif

	if (!disableBloodTextures)
		if (disableBloodierTextures)
			OCum.CumOntoArea(act, "VagBlood" + OSANative.RandomInt(1, 2))
		else
			OCum.CumOntoArea(act, "VagBlood" + OSANative.RandomInt(1, 5))
		endif
	endif

	if (!disableBloodDripping)
		virginityLossBloodSpell.cast(act, act)
	endif
EndFunction


bool function calculateVirginity(actor npc)
	if !isActorValid(npc)
		return false
	endif

	if checkAlwaysVirgin(npc)
		setVirginity(npc, true)

		return true
	endif

	if checkNeverVirgin(npc)
		setVirginity(npc, false)

		return false
	endif

	int chance = virginityChance

	if isProstitute(npc)
		chance = prostituteVirginityChance
	endif

	if isMarried(npc)
		chance = marriedVirginityChance
	endif

	if npc.GetRace() == OldPeopleRace
		chance = elderRaceVirginityChance
	endif

	bool virgin = OUtils.ChanceRoll(chance)

	setVirginity(npc, virgin)

	return virgin
EndFunction


; ███████╗██╗   ██╗███████╗███╗   ██╗████████╗███████╗
; ██╔════╝██║   ██║██╔════╝████╗  ██║╚══██╔══╝██╔════╝
; █████╗  ██║   ██║█████╗  ██╔██╗ ██║   ██║   ███████╗
; ██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║╚██╗██║   ██║   ╚════██║
; ███████╗ ╚████╔╝ ███████╗██║ ╚████║   ██║   ███████║
; ╚══════╝  ╚═══╝  ╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝

; Events that add more features to OVirginity based on OStim scenes stages and player actions

Event OnInit()
	PlayerRef = Game.GetPlayer()

	OCum = game.GetFormFromFile(0x000800, "OCum.esp") as OCumScript

	if OUtils.GetNPCDataInt(PlayerRef, IsVirginKey) == -1
		int playerVirginityValue = JsonUtil.GetIntValue("ovirginity_config", "playervirginityvalue")

		if playerVirginityValue == 1
			setVirginity(PlayerRef, true)
		elseif playerVirginityValue == 0
			setVirginity(PlayerRef, false)
		else
			setVirginity(PlayerRef, OUtils.ChanceRoll(50))
		endif
	endif

	OnLoad()

	LoadGameEvents = false
	InstallAddon("OVirginity")
EndEvent


Function OnLoad()
	ostim = OUtils.GetOStim()
	PlayerRef = Game.GetPlayer()

	RegisterForModEvent("ostim_start", "OstimStart")
	RegisterForModEvent("ostim_scenechanged_Sx", "OStimSceneChanged")
	RegisterForModEvent("ostim_scenechanged_Pf1", "OStimSceneChanged")
	RegisterForModEvent("ostim_scenechanged_Pf2", "OStimSceneChanged")

	RegisterForKey(checkVirginityKey)
	RegisterForKey(toggleVirginityKey)

	virginityLossBloodSpell.SetNthEffectDuration(0, bloodDrippingTimer)

	if (JsonUtil.isGood("ovirginity_config"))
		writeLog("OVirginity JSON configuration file is properly formatted!")
	else
		; write to console and message box notification
		; be as invasive as possible because are dumb and/or don't read, and are careless
		writeLog("You have made an error writing the OVirginity JSON configuration file! Please validate your JSON file through an online JSON Validator! Exit the game now or OVirginity won't work properly.")
		Debug.MessageBox("You have made an error writing the OVirginity JSON configuration file! Please validate your JSON file through an online JSON Validator! Exit the game now or OVirginity won't work properly.")
	endif
EndFunction


Event OstimStart(string eventName, string strArg, float numArg, Form sender)
	actor[] acts = ostim.GetActors()

	domVirgin = isVirgin(acts[0])
	subvirgin = false

	if acts.length > 1
		subvirgin = isVirgin(acts[1])
	endif

	thirdVirgin = false

	if acts.length > 2
		thirdVirgin = isVirgin(acts[2])
	endif	

	writeLog(osanative.getdisplayname(acts[0]) + " virginity: " + domVirgin)

	if acts.length > 1
		writeLog(osanative.getdisplayname(acts[1]) + " virginity: " + subVirgin)
	endif

	if acts.length > 2
		writeLog(osanative.getdisplayname(acts[2]) + " virginity: " + thirdVirgin)
	endif	

	if !domVirgin && !subVirgin && !thirdVirgin
		writeLog("OVirginity leaving thread early, no virgins found")
		return
	endif	

	ostim.AddSceneMetadata("hasvirgin")
EndEvent


Event OStimSceneChanged(String EventName, String StrArg, Float NumArg, Form Sender)
	if ostim.HasSceneMetadata("hasvirgin")
		string cclass = ostim.GetCurrentAnimationClass() 

		if cclass == "Sx"
			if domVirgin
				actor domActor = ostim.GetDomActor()

				if ostim.IsSoloScene() && ostim.IsFemale(domActor)
					writeLog("Dom actor hymen broke!")
					domVirgin = false
					BreakHymen(domActor)
					addActorToVirginitiesTakenList(domActor)
				else 
					writeLog("Dom actor virginity lost!")
					domVirgin = false
					setVirginity(domActor, false, true)
					SendModEvent("ovirginity_lost_dom")
					addActorToVirginitiesTakenList(domActor)
				endif 
			endif
			if subVirgin
				writeLog("Sub actor virginity lost!")
				subVirgin = false
				actor subActor = ostim.GetSubActor()
				setVirginity(subActor, false, true)
				SendModEvent("ovirginity_lost_sub")
				addActorToVirginitiesTakenList(subActor)
			EndIf
			if thirdVirgin
				writeLog("third actor virginity lost!")
				thirdVirgin = false
				actor thirdActor = ostim.GetThirdActor()
				setVirginity(thirdActor, false, true)
				SendModEvent("ovirginity_lost_third")
				addActorToVirginitiesTakenList(thirdActor)
			endif
		endif
	endif
EndEvent


Event OnKeyDown(Int keyPress)
	if (keyPress != 1)
		Actor act
		bool actorVirginity
		string actorName

		if (keyPress == checkVirginityKey)
			act = Game.GetCurrentCrosshairRef() as Actor

			if (!act)
				act = PlayerRef
			endif

			if !isActorValid(act)
				return
			endif

			actorName = act.GetActorBase().GetName()
			actorVirginity = isVirgin(act)

			if (actorVirginity == 1)
				Debug.Notification(actorName + " is virgin.")
			else
				Debug.Notification(actorName + " is not virgin.")
			endif
		elseif (keyPress == toggleVirginityKey)
			act = Game.GetCurrentCrosshairRef() as Actor

			if (!act)
				act = PlayerRef
			endif

			if !isActorValid(act)
				return
			endif

			actorName = act.GetActorBase().GetName()
			actorVirginity = isVirgin(act)

			if (actorVirginity == 1)
				setVirginity(act, false)
				Debug.Notification(actorName + " lost their virginity.")
			else
				setVirginity(act, true)
				Debug.Notification(actorName + " is now virgin.")
			endIf
		endif
	endif
EndEvent


; ██╗   ██╗████████╗██╗██╗     ███████╗
; ██║   ██║╚══██╔══╝██║██║     ██╔════╝
; ██║   ██║   ██║   ██║██║     ███████╗
; ██║   ██║   ██║   ██║██║     ╚════██║
; ╚██████╔╝   ██║   ██║███████╗███████║
;  ╚═════╝    ╚═╝   ╚═╝╚══════╝╚══════╝

; ------------------------ Utility functions ------------------------ ;

function writeLog(string logMessage)
	ConsoleUtil.PrintMessage("OVirginity: " + logMessage)
endFunction


Function updateCheckVirginityKey(int oldKey, int newKey)
	checkVirginityKey = newKey

	UnregisterForKey(oldKey)
	RegisterForKey(newKey)
EndFunction


Function updateToggleVirginityKey(int oldKey, int newKey)
	toggleVirginityKey = newKey

	UnregisterForKey(oldKey)
	RegisterForKey(newKey)
EndFunction


function addActorToVirginitiesTakenList(actor act)
	if (isActorValid(act) && act != PlayerRef && ostim.IsActorActive(PlayerRef))
		StorageUtil.StringListAdd(none, "ovirginity_virginities_taken_list", act.GetActorBase().GetName(), false)
	endif
endfunction


bool function isActorValid(actor npc)
	; actor is only valid if it is the Player Character or is NOT a child and if it has the keyword ActorTypeNPC
	return npc == PlayerRef || (!npc.IsChild() && npc.HasKeywordString("ActorTypeNPC"))
endfunction


bool function isProstitute(actor npc)
	return isActorValid(npc) && npc.IsInFaction(jobInnServer) || npc.IsInFaction(FavorJobsBeggarFaction) || npc.IsInFaction(MarkarthTempleofDibellaFaction) || npc.IsInFaction(ovProstitute)
EndFunction


bool function isMarried(actor npc)
	return isActorValid(npc) && npc.HasAssociation(Spouse)
endfunction


bool function checkAlwaysVirgin(actor npc)
	return JsonUtil.StringListHas("ovirginity_config", "alwaysvirgin", npc.GetActorBase().GetName())
endFunction


bool function checkNeverVirgin(actor npc)
	return JsonUtil.StringListHas("ovirginity_config", "nevervirgin", npc.GetActorBase().GetName())
endFunction
