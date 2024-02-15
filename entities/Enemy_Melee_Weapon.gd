extends Spatial
export  var damage:float = 75
export  var toxic = false
onready var raycast:RayCast = $RayCast
export  var velocity_booster = false

func AI_shoot()->void :
	if is_network_master():
		if raycast.is_colliding():
			if raycast.get_collider().name == "Player" or raycast.get_collider().has_meta("puppetId"):
				if velocity_booster:
					Global.player.player_velocity -= (global_transform.origin - Vector3.UP * 0.5 - Global.player.global_transform.origin).normalized() * damage
				var collider = raycast.get_collider()
				raycast.force_raycast_update()
				if toxic and collider.has_method("set_toxic"):
					collider.set_toxic()
				if collider.has_method("damage"):
					collider.damage(damage, Vector3(0, 0, 0), Vector3(0, 0, 0), global_transform.origin)
				raycast.enabled = false
				if is_instance_valid($Attack_Sound) and not $Attack_Sound.playing:
					$Attack_Sound.play()
				get_parent().get_parent().anim_player.play("Attack", - 1, 2)
				yield (get_tree().create_timer(0.5), "timeout")
				raycast.enabled = true
