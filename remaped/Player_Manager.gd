extends Spatial

onready var player = $Player
onready var cam_pos = $Position3D

func _ready():
	if Global.implants.head_implant.shrink:
		scale = Vector3(0.1, 0.1, 0.1)
	
	var respawnPoint = load("res://MOD_CONTENT/CruS Online/respawn_point.tscn").instance()
	get_node("..").call_deferred("add_child",respawnPoint)
	respawnPoint.global_transform.origin = self.global_transform.origin

func _process(delta):
	if Input.is_action_just_pressed("Stocks"):
		$Stock_Menu.visible = not $Stock_Menu.visible
		if $Stock_Menu.visible:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			$Position3D / Rotation_Helper / Weapon.disabled = true
		else :
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			$Position3D / Rotation_Helper / Weapon.disabled = false
	var offset = Vector3(0, 1.481, 0)
	if Global.implants.head_implant.shrink:
		offset *= 0.1
	if player.max_gravity < 0:
		offset = Vector3(0, 0, 0)
	if Engine.get_frames_per_second() <= 30:
		cam_pos.global_transform.origin = player.global_transform.origin + offset
	else :
		cam_pos.global_transform.origin = lerp(cam_pos.global_transform.origin, player.global_transform.origin + offset, clamp(delta * 30, 0, 1))
		
	cam_pos.rotation.y = player.rotation.y
