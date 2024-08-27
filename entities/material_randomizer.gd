extends Spatial

export (Array, String) var materials
export  var head_only = false
export  var cutscene = false
onready var anim = $AnimationPlayer

var materialId = 0

puppet func set_material(materialId,headOnlyRecived):
	print("NPC material changed")
	var material = load(materials[materialId])
	$Armature / Skeleton / Head_Mesh.material_override = material
	if not headOnlyRecived:
		$Armature / Skeleton / Torso_Mesh.material_override = material

master func get_material():
	rpc_id(get_tree().get_rpc_sender_id(),"set_material",materialId,head_only)

func _ready():
	if get_tree().network_peer != null and is_network_master():
		materialId = randi() % materials.size()
		var material = load(materials[materialId])
		$Armature / Skeleton / Head_Mesh.material_override = material
		if not head_only:
			$Armature / Skeleton / Torso_Mesh.material_override = material
	else:
		rpc_id(0,"get_material")

func _process(delta):
	if not cutscene:
		return
		set_process(false)
	translate(Vector3.FORWARD * delta)
	anim.play("Walk")
