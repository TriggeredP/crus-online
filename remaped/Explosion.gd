extends Area

export  var damage = 50
export  var gas = false
export  var sleep = false
export  var piercing = true
var c_shape
var particle

var gas_timer = 0

puppet func delete():
	queue_free()

func _ready():
	particle = $Particle
	c_shape = $CollisionShape
	particle.emitting = true
	
func _physics_process(delta):
	if is_network_master():
		if particle.emitting == false:
			if not gas:
				c_shape.disabled = true
				c_shape.visible = false
			else :
				gas_timer += delta
				if gas_timer >= 3:
					rpc("delete")
					queue_free()
		if gas and not sleep:
			for overlap_body in get_overlapping_bodies():
				if overlap_body.has_method("player_damage"):
					overlap_body.player_damage(damage, Vector3.ZERO, overlap_body.global_transform.origin, global_transform.origin, "gas")
				elif overlap_body.has_method("damage"):
					overlap_body.damage(damage, Vector3.ZERO, overlap_body.global_transform.origin, global_transform.origin)

func _on_Explosion_area_entered(area):
	if is_network_master():
		do_damage(area)

func _on_Explosion_body_entered(body):
	if is_network_master():
		do_damage(body)
		if sleep and body.has_method("tranquilize"):
			body.tranquilize(true)

func do_damage(body):
	if gas:
		return 
	var state = get_world().direct_space_state
	var result = state.intersect_ray(global_transform.origin, body.global_transform.origin, [self])
	if result:
		if result.collider.get_class() == "StaticBody":
			if result.collider.has_method("damage"):
				return 
	if body.has_method("damage"):
		if body == Global.player and Global.implants.torso_implant.explosive_shield:
			Global.player.player_velocity -= (global_transform.origin - body.global_transform.origin).normalized() * damage * 0.05
			return 
		body.damage(damage, (global_transform.origin - body.global_transform.origin).normalized(), body.global_transform.origin, global_transform.origin)
	if body.has_method("piercing_damage") and piercing:
		body.piercing_damage(damage, (global_transform.origin - body.global_transform.origin).normalized(), body.global_transform.origin, global_transform.origin)
