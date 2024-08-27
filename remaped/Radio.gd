extends Area

var static_noise = 0
var current_track = 0

func _ready():
	if is_network_master():
		current_track = randi() % Global.LEVEL_SONGS.size()
		$Radio.stream = Global.LEVEL_SONGS[current_track]
		$Radio.play()
	else:
		rpc("get_track")

master func player_use():
	if is_network_master():
		current_track += 1
		current_track = wrapi(current_track, 0, Global.LEVEL_SONGS.size())
		$Radio.stream = Global.LEVEL_SONGS[current_track]
		$Radio.play()
		
		rpc("change_track", current_track)
	else:
		rpc("player_use")

master func get_track():
	rpc("change_track", current_track)

puppet func change_track(recivedTrack):
	$Radio.stream = Global.LEVEL_SONGS[recivedTrack]
	$Radio.play()
