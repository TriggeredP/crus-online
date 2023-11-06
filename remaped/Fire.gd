extends KinematicBody

var velocity = Vector3.ZERO

var f = preload("res://Entities/Bullets/Fire_Child.tscn")
onready var p = $Particles
var wep

################################################################################

remote func _set_transform(recivedTransform):
	global_transform = recivedTransform

remote func _delete():
	queue_free()

################################################################################

func _ready():
	pass

func _physics_process(delta):
	var col = move_and_collide(velocity * delta)
	if col:
		var body = col.collider
		var new_fire_child = f.instance()
		if "soul" in body:
			if body.soul.on_fire:
				pass
			else :
				body.soul.on_fire = true
				body.add_child(new_fire_child)
				new_fire_child.scale.y = 2.0
				new_fire_child.global_transform.origin = body.global_transform.origin - Vector3.UP * 0.5
		elif "random_line" in body:
			if body.get_parent().on_fire:
				pass
			else :
				body.get_parent().on_fire = true
				body.add_child(new_fire_child)
				new_fire_child.scale.y = 2.0
				new_fire_child.global_transform.origin = body.global_transform.origin - Vector3.UP * 0.5
		else :
				body.add_child(new_fire_child)
				new_fire_child.global_transform.origin = global_transform.origin
		queue_free()
	velocity.y -= 4 * delta
	velocity *= 0.98
	p.scale += Vector3(0.1, 0.1, 0.1)
	if velocity.length() < 6:
		queue_free()

func set_water(value):
	queue_free()
