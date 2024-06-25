extends Area

var playersCount = 0

func _ready():
	playersCount = 0
	
	connect("body_entered", self, "_on_Body_entered")
	connect("body_exited", self, "_on_Body_exited")

func _on_Body_exited(body):
	if body.name == "Player":
		if not is_network_master():
			rpc("sub_player_count")
			rpc("get_player_count")
			rpc("check_exit")
		else:
			add_player_count()
			check_exit(true)

func _on_Body_entered(body):
	#if body.name == "Player" and $"/root/Global".objective_complete:
		#Global.level_finished()
	
	if body.name == "Player":
		if not is_network_master():
			rpc("add_player_count")
			rpc("get_player_count")
			rpc("check_exit")
		else:
			add_player_count()
			check_exit(true)

master func add_player_count():
	playersCount += 1

master func sub_player_count():
	playersCount -= 1

master func get_player_count():
	if $"/root/Global".objective_complete:
		rpc_id(get_tree().get_rpc_sender_id(),"send_player_count",playersCount,len(get_tree().get_nodes_in_group("Multiplayer")[0].player_info))

puppet func send_player_count(exitCount,hostCount):
	Global.UI.notify(str(exitCount) + "/" + str(hostCount) + " need to exit", Color(1, 0, 0))

master func check_exit(show = false):
	if $"/root/Global".objective_complete:
		var players = len(get_tree().get_nodes_in_group("Multiplayer")[0].player_info)
		if playersCount == players:
			get_tree().get_nodes_in_group("Multiplayer")[0].goto_menu_host()
		elif show:
			Global.UI.notify(str(playersCount) + "/" + str(players) + " need to exit", Color(1, 0, 0))
