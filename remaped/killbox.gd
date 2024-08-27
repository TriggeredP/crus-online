extends Area

func _ready():
	set_collision_mask_bit(0, 0)
	set_collision_mask_bit(1, 1)
	
	connect("body_entered", self, "_on_Body_Entered")

func _on_Body_Entered(body):
	if body.has_method("damage"):
		body.damage(1000, Vector3.ZERO, global_transform.origin, global_transform.origin)
