extends Area

onready var NetworkBridge = Global.get_node("Multiplayer/NetworkBridge")

var Multiplayer = Global.get_node("Multiplayer")

var exitPlayers = []
var exitTimer

var exiting = false

func _ready():
	connect("body_entered", self, "_on_Body_entered")
	connect("body_exited", self, "_on_Body_exited")
	
	NetworkBridge.register_rpcs(self, [
		["send_player_count", NetworkBridge.PERMISSION.SERVER],
		["send_exit_message", NetworkBridge.PERMISSION.SERVER],
		["player_exited", NetworkBridge.PERMISSION.ALL],
		["player_entered", NetworkBridge.PERMISSION.ALL]
	])
	
	exitTimer = Timer.new()
	add_child(exitTimer)
	exitTimer.wait_time = 5
	exitTimer.connect("timeout", self , "exit_to_menu")

func _on_Body_exited(body):
	if body.name == "Player":
		if NetworkBridge.check_connection() and NetworkBridge.n_is_network_master(self):
			player_exited(NetworkBridge.get_host_id())
		else:
			NetworkBridge.n_rpc(self, "player_exited")

func _on_Body_entered(body):
	if body.name == "Player":
		if NetworkBridge.check_connection() and NetworkBridge.n_is_network_master(self):
			player_entered(NetworkBridge.get_host_id())
		else:
			NetworkBridge.n_rpc(self, "player_entered")

master func player_exited(id):
	if exitPlayers.has(id):
		exitPlayers.erase(id)

master func player_entered(id):
	if not exitPlayers.has(id):
		exitPlayers.append(id)
	
	var all_player_entered = true

	for player in Multiplayer.players:
		if not exitPlayers.has(player):
			all_player_entered = false
	
	if Global.objective_complete:
		if all_player_entered:
			if not exiting:
				exiting = true
				send_exit_message(null)
				NetworkBridge.n_rpc(self, "send_exit_message")
				exitTimer.start()
		else:
			if NetworkBridge.n_is_network_master(self):
				send_player_count(null, len(exitPlayers), len(Multiplayer.players))
			else:
				NetworkBridge.n_rpc_id(self, id, "send_player_count", [len(exitPlayers), len(Multiplayer.players)])

puppet func send_player_count(id, exitCount, hostCount):
	Global.UI.notify(str(exitCount) + "/" + str(hostCount) + " need to exit", Color(1, 0, 0))

puppet func send_exit_message(id):
	Global.UI.notify("Exiting...", Color(1, 0, 0))
	Global.UI.notify("All players are at the exit", Color(1, 0, 0))

func exit_to_menu():
	Multiplayer.goto_menu_host(true)
