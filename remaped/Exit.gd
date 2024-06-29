extends Area

var playersCount = 0

func _ready():
	playersCount = 0
	
	connect("body_entered", self, "_on_Body_entered")
	connect("body_exited", self, "_on_Body_exited")

func _on_Body_exited(body):
	if body.name == "Player":
		if is_network_master():
			check_exit(-1)
		else:
			rpc("change_player_count", -1)

func _on_Body_entered(body):
	#if body.name == "Player" and $"/root/Global".objective_complete:
		#Global.level_finished()
	
	if body.name == "Player":
		if is_network_master():
			check_exit()
		else:
			rpc("change_player_count")

master func change_player_count(count = 1):
	playersCount += count
	
	if Global.objective_complete:
		rpc_id(get_tree().get_rpc_sender_id(),"send_player_count",playersCount,len(get_tree().get_nodes_in_group("Multiplayer")[0].player_info))

puppet func send_player_count(exitCount, hostCount):
	Global.UI.notify(str(exitCount) + "/" + str(hostCount) + " need to exit", Color(1, 0, 0))

func check_exit(count = 1):
	playersCount += count
	
	if Global.objective_complete:
		var players = len(get_tree().get_nodes_in_group("Multiplayer")[0].player_info)
		if playersCount >= players:
			get_tree().get_nodes_in_group("Multiplayer")[0].goto_menu_host()
		else:
			Global.UI.notify(str(playersCount) + "/" + str(players) + " need to exit", Color(1, 0, 0))
