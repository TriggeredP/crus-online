extends Area

onready var NetworkBridge = Global.get_node("Multiplayer/NetworkBridge")

enum {SPEED, FLOATY, TOXIC, PSYCHOSIS, CANCER, GRAVITY}

export  var pills = false
export  var toxic = false
export  var healing = false
export  var healing_amount = 25
export  var kinematic = false

func _ready():
	NetworkBridge.register_rpcs(self, [
		["check_food", NetworkBridge.PERMISSION.ALL],
		["delete", NetworkBridge.PERMISSION.ALL],
		["kinematic_delete", NetworkBridge.PERMISSION.ALL]
	])
	
	if not NetworkBridge.check_connection() and NetworkBridge.n_is_network_master(self):
		NetworkBridge.n_rpc(self, "check_food")

master func check_food(id):
	if $CollisionShape.disabled:
		if kinematic:
			NetworkBridge.n_rpc_id(self, id, "kinematic_delete")
		else:
			NetworkBridge.n_rpc_id(self, id, "delete")

remote func delete(id):
	$CollisionShape.disabled = true
	hide()

remote func kinematic_delete(id):
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
		delete(null)
		NetworkBridge.n_rpc(self, "delete")
	if healing:
		Global.player.add_health(healing_amount)
		if kinematic:
			kinematic_delete(null)
			NetworkBridge.n_rpc(self, "kinematic_delete")
		delete(null)
		NetworkBridge.n_rpc(self, "delete")
	if toxic:
		Global.player.set_toxic()
		delete(null)
		NetworkBridge.n_rpc(self, "delete")
	else :
		Global.player.detox()
		delete(null)
		NetworkBridge.n_rpc(self, "delete")
