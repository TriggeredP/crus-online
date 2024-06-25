extends Area





var particle_node
var particle = false


func _ready():
	connect("body_entered", self, "_on_body_entered")
	particle_node = get_node_or_null("Particles")
	if is_instance_valid(particle_node):
		particle = true



func _on_body_entered(body):
	if body == get_parent() or body.get_collision_layer_bit(0) or "sound" in body:
		return 
	if particle:
		particle_node.emitting = true
	if "soul" in body:
		body.soul.hide()
		body.soul.global_transform.origin = Vector3(-1000,-1000,-1000)
	else :
		body.hide()
		body.global_transform.origin = Vector3(-1000,-1000,-1000)
