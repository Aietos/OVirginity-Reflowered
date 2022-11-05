Scriptname OVirginityMCMScript extends SKI_ConfigBase

; Settings
int setDisableBloodTextures
int setDisableBloodDripping
int setDisableBloodierTextures
int setVirginityChance
int setProstituteVirginityChance
int setMarriedVirginityChance
int setElderVirginityChance
int setBloodDrippingTimer
int setCheckVirginityKey
int setToggleVirginityKey
int setResetDefaults

int setPageVirginitiesList
int setvirginitiesTakenAmount

int virginitiesPageIndex

string[] numberPagesArray

OVirginityScript property OVirginity auto


event OnInit()
	parent.OnInit()

	Modname = "OVirginity Reflowered"
endEvent


event OnConfigInit()
	string[] pagearr = PapyrusUtil.StringArray(0)
	pagearr = PapyrusUtil.PushString(pagearr, "$ovirginity_page_configuration")
	pagearr = PapyrusUtil.PushString(pagearr, "$ovirginity_page_virginities_list")

	Pages = pagearr
endEvent


event OnGameReload()
	parent.onGameReload()
endevent


event OnPageReset(string page)
	if (page == "$ovirginity_page_configuration")
		SetCursorFillMode(TOP_TO_BOTTOM)

		AddColoredHeader("$ovirginity_header_main_settings")
		setDisableBloodTextures = AddToggleOption("$ovirginity_option_disable_blood_textures", OVirginity.disableBloodTextures)
		setDisableBloodDripping = AddToggleOption("$ovirginity_option_disable_blood_dripping", OVirginity.disableBloodDripping)
		setDisableBloodierTextures = AddToggleOption("$ovirginity_option_disable_bloodier_textures", OVirginity.disableBloodierTextures)
		setCheckVirginityKey = AddKeyMapOption("$ovirginity_option_check_virginity_key", OVirginity.checkVirginityKey)
		setToggleVirginityKey = AddKeyMapOption("$ovirginity_option_toggle_virginity_key", OVirginity.toggleVirginityKey)
		AddEmptyOption()

		AddColoredHeader("$ovirginity_header_reset")
		setResetDefaults = AddToggleOption("$ovirginity_option_reset_defaults", false)

		SetCursorPosition(1)

		AddColoredHeader("$ovirginity_header_adjustments")
		setVirginityChance = AddSliderOption("$ovirginity_option_virginity_chance", OVirginity.virginityChance, "{0}")
		setProstituteVirginityChance = AddSliderOption("$ovirginity_option_prostitute_virginity_chance", OVirginity.prostituteVirginityChance, "{0}")
		setMarriedVirginityChance = AddSliderOption("$ovirginity_option_married_virginity_chance", OVirginity.marriedVirginityChance, "{0}")
		setElderVirginityChance = AddSliderOption("$ovirginity_option_elder_virginity_chance", OVirginity.elderRaceVirginityChance, "{0}")
		setBloodDrippingTimer = AddSliderOption("$ovirginity_option_blood_dripping_timer", OVirginity.bloodDrippingTimer, "{0}")
		AddEmptyOption()
	elseif (page == "$ovirginity_page_virginities_list")
		SetCursorFillMode(TOP_TO_BOTTOM)

		int virginitiesTakenListSize = StorageUtil.StringListCount(none, "ovirginity_virginities_taken_list")
		int numberPages = Math.Ceiling(virginitiesTakenListSize as float / 100.0)

		if numberPages == 0
			numberPages = 1
		endif

		int i = 0

		numberPagesArray = PapyrusUtil.StringArray(0)

		while (i < numberPages)
			numberPagesArray = PapyrusUtil.PushString(numberPagesArray, "Page " + (i + 1))
			i += 1
		endWhile

		i = virginitiesPageIndex * 100

		setPageVirginitiesList = AddMenuOption("$ovirginity_option_virginity_list_page", numberPagesArray[virginitiesPageIndex])

		SetCursorPosition(1)

		setvirginitiesTakenAmount = AddTextOption("$ovirginity_option_virginities_taken_amount", virginitiesTakenListSize)

		SetCursorPosition(2)

		int currentCursorPosition = 2

		int namesShown = 1

		while (i < virginitiesTakenListSize)
			AddTextOption(StorageUtil.StringListGet(none, "ovirginity_virginities_taken_list", i), "")

			currentCursorPosition = currentCursorPosition + 1

			SetCursorPosition(currentCursorPosition)

			if (namesShown == 100)
				i = virginitiesTakenListSize
			endif

			i += 1
			namesShown += 1
		endWhile
	endif
endEvent


event OnOptionSelect(int option)
	if (option == setDisableBloodTextures)
		OVirginity.disableBloodTextures = !OVirginity.disableBloodTextures
		SetToggleOptionValue(setDisableBloodTextures, OVirginity.disableBloodTextures)
	elseif (option == setDisableBloodDripping)
		OVirginity.disableBloodDripping = !OVirginity.disableBloodDripping
		SetToggleOptionValue(setDisableBloodDripping, OVirginity.disableBloodDripping)
	elseif (option == setDisableBloodierTextures)
		OVirginity.disableBloodierTextures = !OVirginity.disableBloodierTextures
		SetToggleOptionValue(setDisableBloodierTextures, OVirginity.disableBloodierTextures)
	elseif (option == setResetDefaults)
		ResetDefaults()
		ShowMessage("$ovirginity_message_defaults_reset", false)
	endIf
endEvent


event OnOptionMenuOpen(int option)
	if (option == setPageVirginitiesList)
		SetMenuDialogOptions(numberPagesArray)
		SetMenuDialogStartIndex(0)
		SetMenuDialogDefaultIndex(0)
	endIf
endEvent


event OnOptionMenuAccept(int option, int index)
	if (option == setPageVirginitiesList)
		virginitiesPageIndex = index
		SetMenuOptionValue(setPageVirginitiesList, numberPagesArray[index])
		ForcePageReset()
	endIf
endEvent


event OnOptionKeyMapChange(int option, int keyCode, string conflictControl, string conflictName)
	bool continue = true

	if (keyCode != 1 && conflictControl != "")
		string msg

		if (conflictName != "")
			msg = "This key is already mapped to:\n\"" + conflictControl + "\"\n(" + conflictName + ")\n\nAre you sure you want to continue?"
		else
			msg = "This key is already mapped to:\n\"" + conflictControl + "\"\n\nAre you sure you want to continue?"
		endIf

		continue = ShowMessage(msg, true, "$ovirginity_message_box_option_yes", "$ovirginity_message_box_option_no")
	endIf

	if (option == setToggleVirginityKey)
		if (continue)
			OVirginity.updateToggleVirginityKey(OVirginity.toggleVirginityKey, keyCode)
			SetKeymapOptionValue(setToggleVirginityKey, keyCode)
		endIf
	elseif (option == setCheckVirginityKey)
		if (continue)
			OVirginity.updateCheckVirginityKey(OVirginity.checkVirginityKey, keyCode)
			SetKeymapOptionValue(setCheckVirginityKey, keyCode)
		endIf
	endIf
endEvent


event OnOptionSliderOpen(int option)
	If (option == setVirginityChance)
		SetSliderDialogStartValue(OVirginity.virginityChance)
		SetSliderDialogDefaultValue(30.0)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	elseif (option == setProstituteVirginityChance)
		SetSliderDialogStartValue(OVirginity.prostituteVirginityChance)
		SetSliderDialogDefaultValue(5.0)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	elseif (option == setMarriedVirginityChance)
		SetSliderDialogStartValue(OVirginity.marriedVirginityChance)
		SetSliderDialogDefaultValue(10.0)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	elseif (option == setElderVirginityChance)
		SetSliderDialogStartValue(OVirginity.elderRaceVirginityChance)
		SetSliderDialogDefaultValue(10.0)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	elseif (option == setBloodDrippingTimer)
		SetSliderDialogStartValue(OVirginity.bloodDrippingTimer)
		SetSliderDialogDefaultValue(10.0)
		SetSliderDialogRange(5, 180)
		SetSliderDialogInterval(5)
	EndIf
endEvent


event OnOptionSliderAccept(int option, float value)
	If (option == setVirginityChance)
		OVirginity.virginityChance = value as int
		SetSliderOptionValue(setVirginityChance, value, "{0}")
	elseif (option == setProstituteVirginityChance)
		OVirginity.prostituteVirginityChance = value as int
		SetSliderOptionValue(setProstituteVirginityChance, value, "{0}")
	elseif (option == setMarriedVirginityChance)
		OVirginity.marriedVirginityChance = value as int
		SetSliderOptionValue(setMarriedVirginityChance, value, "{0}")
	elseif (option == setElderVirginityChance)
		OVirginity.elderRaceVirginityChance = value as int
		SetSliderOptionValue(setElderVirginityChance, value, "{0}")
	elseif (option == setBloodDrippingTimer)
		OVirginity.bloodDrippingTimer = value as int
		OVirginity.virginityLossBloodSpell.SetNthEffectDuration(0, OVirginity.bloodDrippingTimer)
		SetSliderOptionValue(setBloodDrippingTimer, value, "{0}")
	EndIf
endEvent


event OnOptionHighlight(int option)
	if (option == setDisableBloodTextures)
		SetInfoText("$ovirginity_highlight_disable_blood_textures")
	elseif (option == setDisableBloodDripping)
		SetInfoText("$ovirginity_highlight_disable_blood_dripping")
	elseif (option == setDisableBloodierTextures)
		SetInfoText("$ovirginity_highlight_disable_bloodier_textures")
	elseif (option == setCheckVirginityKey)
		SetInfoText("$ovirginity_highlight_check_virginity_key")
	elseif (option == setToggleVirginityKey)
		SetInfoText("$ovirginity_highlight_toggle_virginity_key")
	elseif (option == setVirginityChance)
		SetInfoText("$ovirginity_highlight_virginity_chance")
	elseif (option == setProstituteVirginityChance)
		SetInfoText("$ovirginity_highlight_prostitute_virginity_chance")
	elseif (option == setMarriedVirginityChance)
		SetInfoText("$ovirginity_highlight_married_virginity_chance")
	elseif (option == setElderVirginityChance)
		SetInfoText("$ovirginity_highlight_elder_virginity_chance")
	elseif (option == setBloodDrippingTimer)
		SetInfoText("$ovirginity_highlight_blood_dripping_timer")
	endif
endEvent


; Shamelessly copied from OStim's OSexIntegrationMCM.psc
bool Color1
function AddColoredHeader(String In)
	string Blue = "#6699ff"
	string Pink = "#ff3389"
	string Color

	If Color1
		Color = Pink
		Color1 = False
	Else
		Color = Blue
		Color1 = True
	EndIf

	AddHeaderOption("<font color='" + Color +"'>" + In)
endFunction


function ResetDefaults()
	OVirginity.disableBloodTextures = false
	SetToggleOptionValue(setDisableBloodTextures, OVirginity.disableBloodTextures)

	OVirginity.disableBloodDripping = true
	SetToggleOptionValue(setDisableBloodDripping, OVirginity.disableBloodDripping)

	OVirginity.disableBloodierTextures = true
	SetToggleOptionValue(setDisableBloodierTextures, OVirginity.disableBloodierTextures)

	OVirginity.updateCheckVirginityKey(OVirginity.checkVirginityKey, 52) ; period . key
	SetKeymapOptionValue(setCheckVirginityKey, 52)

	OVirginity.updateToggleVirginityKey(OVirginity.toggleVirginityKey, 51) ; comma , key
	SetKeymapOptionValue(setToggleVirginityKey, 51)

	OVirginity.virginityChance = 30
	SetSliderOptionValue(setVirginityChance, 30.0, "{0}")
	
	OVirginity.prostituteVirginityChance = 5
	SetSliderOptionValue(setProstituteVirginityChance, 5.0, "{0}")

	OVirginity.marriedVirginityChance = 10
	SetSliderOptionValue(setMarriedVirginityChance, 10.0, "{0}")

	OVirginity.elderRaceVirginityChance = 10
	SetSliderOptionValue(setElderVirginityChance, 10.0, "{0}")

	OVirginity.bloodDrippingTimer = 10
	OVirginity.virginityLossBloodSpell.SetNthEffectDuration(0, OVirginity.bloodDrippingTimer)
	SetSliderOptionValue(setBloodDrippingTimer, 10.0, "{0}")
endFunction
