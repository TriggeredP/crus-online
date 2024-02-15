extends KinematicBody

var velocity = Vector3.ZERO
var angular_velocity

var water : bool
var gravity = 22

var impact_sound : Array

func _ready():
	impact_sound = [
		$Sound1,
		$Sound2,
		$Sound3
	]

func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	
	global_rotation += angular_velocity
	
	if water:
		gravity = 2
	else :
		gravity = 22
	
	if collision:
		velocity = velocity.bounce(collision.normal) * 0.6

		if abs(velocity.length()) > 2:
			var current_sound = randi() % 3
			
			impact_sound[current_sound].pitch_scale += rand_range( - 0.1, 0.1)
			impact_sound[current_sound].pitch_scale = clamp(impact_sound[current_sound].pitch_scale, 0.8, 1.2)
			impact_sound[current_sound].unit_db = velocity.length() * 0.1 - 1
			impact_sound[current_sound].play()
	
	velocity.y -= gravity * delta
	angular_velocity = lerp(angular_velocity, Vector3.ZERO, delta * 2)

func damage(damage, collision_n, collision_p, shooter_pos):
	if damage < 3:
		return 
	velocity -= collision_n * damage
	randomize()
	angular_velocity = Vector3(rand_range(1,5),rand_range(1,5),rand_range(1,5))

func remove():
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.tween_property(self,"scale",Vector3.ZERO,1)
	
	yield(tween,"finished")
	queue_free()
