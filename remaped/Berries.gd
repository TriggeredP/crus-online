extends Area

enum {SPEED, FLOATY, TOXIC, PSYCHOSIS, CANCER, GRAVITY}

export  var pills = false
export  var toxic = false
export  var healing = false
export  var healing_amount = 25
export  var kinematic = false

func _ready():
	if not get_tree().network_peer != null and is_network_master():
		rpc("check_food")

master func check_food():
	if $CollisionShape.disabled:
		if kinematic:
			rpc_id(get_tree().get_rpc_sender_id(),"kinematic_delete")
		else:
			rpc_id(get_tree().get_rpc_sender_id(),"delete")

remote func delete():
	$CollisionShape.disabled = true
	hide()

remote func kinematic_delete():
	$CollisionShape.disabled = true
	get_parent().hide()

func player_use():
	if pills:
		match randi() % 6:
			SPEED:
				Global.player.drug_speed = 50
			FLOATY:
				Global.player.drug_slowfall = 150
			TOXIC:
				Global.player.set_toxic()
			PSYCHOSIS:
				Global.player.psychocounter = 200
			CANCER:
				Global.player.cancer_count = 9
				Global.player.cancer()
			GRAVITY:
				Global.player.drug_gravity_flag = true
		get_parent().get_node("AudioStreamPlayer3D").play()
		get_parent().hide()
		Global.player.UI.notify("You ate pills.", Color(1, 0.0, 1.0))
		delete()
		rpc("delete")
	if healing:
		Global.player.add_health(healing_amount)
		if kinematic:
			kinematic_delete()
			rpc("kinematic_delete")
		delete()
		rpc("delete")
	if toxic:
		Global.player.set_toxic()
		delete()
		rpc("delete")
	else :
		Global.player.detox()
		delete()
		rpc("delete")
