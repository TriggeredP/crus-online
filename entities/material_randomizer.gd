extends Spatial

onready var NetworkBridge = Global.get_node("Multiplayer/NetworkBridge")

export (Array, String) var materials
export  var head_only = false
export  var cutscene = false
onready var anim = $AnimationPlayer

var materialId = 0

puppet func set_material(id, recived_material_id, head_only_recived):
	var material = load(materials[recived_material_id])
	$Armature / Skeleton / Head_Mesh.material_override = material
	if not head_only_recived:
		$Armature / Skeleton / Torso_Mesh.material_override = material

master func get_material(id):
	NetworkBridge.n_rpc_id(self, id, "set_material", [materialId, head_only])

func _ready():
	NetworkBridge.register_rpcs(self,[
		["get_material", NetworkBridge.PERMISSION.ALL],
		["set_material", NetworkBridge.PERMISSION.SERVER]
	])
	
	if NetworkBridge.check_connection() and NetworkBridge.n_is_network_master(self):
		materialId = randi() % materials.size()
		var material = load(materials[materialId])
		$Armature / Skeleton / Head_Mesh.material_override = material
		if not head_only:
			$Armature / Skeleton / Torso_Mesh.material_override = material
	else:
		NetworkBridge.n_rpc_id(self, 0, "get_material")

func _process(delta):
	if not cutscene:
		return
		set_process(false)
	translate(Vector3.FORWARD * delta)
	anim.play("Walk")
