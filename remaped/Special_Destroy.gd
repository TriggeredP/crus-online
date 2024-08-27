extends StaticBody

puppet func remove():
	queue_free()

func special_destroy():
	if get_tree().network_peer != null and is_network_master():
		queue_free()
		rpc("remove")
