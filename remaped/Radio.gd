extends Area

onready var NetworkBridge = Global.get_node("Multiplayer/NetworkBridge")

var static_noise = 0
var current_track = 0

func _ready():
	if NetworkBridge.n_is_network_master(self):
		current_track = randi() % Global.LEVEL_SONGS.size()
		$Radio.stream = Global.LEVEL_SONGS[current_track]
		$Radio.play()
	else:
		NetworkBridge.n_rpc(self, "get_track")

master func player_use(id):
	if NetworkBridge.n_is_network_master(self):
		current_track += 1
		current_track = wrapi(current_track, 0, Global.LEVEL_SONGS.size())
		$Radio.stream = Global.LEVEL_SONGS[current_track]
		$Radio.play()
		
		NetworkBridge.n_rpc(self, "change_track", [current_track])
	else:
		NetworkBridge.n_rpc(self, "player_use")

master func get_track(id):
	NetworkBridge.n_rpc(self, "change_track", [current_track])

puppet func change_track(id, recivedTrack):
	$Radio.stream = Global.LEVEL_SONGS[recivedTrack]
	$Radio.play()
