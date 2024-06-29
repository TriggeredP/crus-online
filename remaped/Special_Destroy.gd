extends StaticBody

puppet func remove():
	queue_free()

func special_destroy():
	if is_network_master():
		queue_free()
		rpc("remove")
