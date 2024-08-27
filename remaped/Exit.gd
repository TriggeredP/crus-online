extends Area

var Multiplayer = Global.get_node("Multiplayer")

var exitPlayers = []
var exitTimer

var exiting = false

func _ready():
	connect("body_entered", self, "_on_Body_entered")
	connect("body_exited", self, "_on_Body_exited")
	
	exitTimer = Timer.new()
	add_child(exitTimer)
	exitTimer.wait_time = 5
	exitTimer.connect("timeout", self , "exit_to_menu")

func _on_Body_exited(body):
	if body.name == "Player":
		if get_tree().network_peer != null and is_network_master():
			player_exited(true)
		else:
			rpc("player_exited")

func _on_Body_entered(body):
	if body.name == "Player":
		if get_tree().network_peer != null and is_network_master():
			player_entered(true)
		else:
			rpc("player_entered")

master func player_exited(host = false):
	if host:
		if exitPlayers.has(1):
			exitPlayers.erase(1)
	else:
		if exitPlayers.has(get_tree().get_rpc_sender_id()):
			exitPlayers.erase(get_tree().get_rpc_sender_id())

master func player_entered(host = false):
	if host:
		if not exitPlayers.has(1):
			exitPlayers.append(1)
	else:
		if not exitPlayers.has(get_tree().get_rpc_sender_id()):
			exitPlayers.append(get_tree().get_rpc_sender_id())
	
	var all_player_entered = true

	for player in Multiplayer.players:
		if not exitPlayers.has(player):
			all_player_entered = false
	
	if Global.objective_complete:
		if all_player_entered:
			if not exiting:
				exiting = true
				send_exit_message()
				rpc("send_exit_message")
				exitTimer.start()
		else:
			if host:
				send_player_count(len(exitPlayers), len(Multiplayer.players))
			else:
				rpc_id(get_tree().get_rpc_sender_id(), "send_player_count", len(exitPlayers), len(Multiplayer.players))

puppet func send_player_count(exitCount, hostCount):
	Global.UI.notify(str(exitCount) + "/" + str(hostCount) + " need to exit", Color(1, 0, 0))

puppet func send_exit_message():
	Global.UI.notify("Exiting...", Color(1, 0, 0))
	Global.UI.notify("All players are at the exit", Color(1, 0, 0))

func exit_to_menu():
	Multiplayer.goto_menu_host(true)
