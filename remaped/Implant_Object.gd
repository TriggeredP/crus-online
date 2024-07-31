extends Area

export  var implant_name = "Hazmat Suit"

func _ready():
	if Global.implants.purchased_implants.find(implant_name) == - 1:
		for i in Global.implants.IMPLANTS:
			if i.i_name == implant_name:
				
				var new_mat = $implant_object / Cube.mesh.surface_get_material(1).duplicate()
				new_mat.albedo_texture = i.texture
				$implant_object / Cube.set_surface_material(1, new_mat)
	else :
		get_parent().hide()
		$CollisionShape.disabled = true

func player_use():
		Global.implants.purchased_implants.append(implant_name)
		Global.player.UI.notify(implant_name + " acquired.", Color(0.2, 1, 0))
		Global.save_game()
		get_parent().hide()
		$CollisionShape.disabled = true
