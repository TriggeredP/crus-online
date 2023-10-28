extends Node

var steam_id
var is_online: bool
var is_game_owned: bool

var Steam

var status

func is_steam_enabled():
	return OS.has_feature("steam") or OS.is_debug_build()

func setup():
	var init = Steam.steamInit()
	print("[CruS Online] Did Steam initialize?: "+str(init))
	
	status = init['status']

	if status != 1:
		print("[CruS Online] Failed to initialize Steam. "+str(init['verbal'])+" Shutting down...")
		$ConfirmationDialog.dialog_text = "Failed to initialize Steam.\n\n" + str(init['verbal'])
		$ConfirmationDialog.popup_centered()
	else:
		steam_id = Steam.getSteamID()
		is_online = Steam.loggedOn()
		is_game_owned = Steam.isSubscribed()
		
		print("[CruS Online] Steam ID: ", steam_id)
		print("[CruS Online] Is online: ", is_online)
		print("[CruS Online] Is game owned: ", is_game_owned)
		
		if is_game_owned == false:
			print("Playing on pirated version of game huh? \nDon't worry i am not gonna tell Ville about that ;)")

func _process(delta):
	Steam.run_callbacks()

func get_profile_name():
	return Steam.getPersonaName()
