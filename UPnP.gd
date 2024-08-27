extends Node

var thread = null

signal upnp_completed(error)

func _upnp_setup(server_port):
	var upnp = UPNP.new()
	var err = upnp.discover()

	if err != OK:
		push_error("[CRUS ONLINE / UPnP]: ERROR " + str(err))
		emit_signal("upnp_completed", err)
		return

	if upnp.get_gateway() and upnp.get_gateway().is_valid_gateway():
		upnp.add_port_mapping(server_port, server_port, ProjectSettings.get_setting("application/config/name"), "UDP")
		upnp.add_port_mapping(server_port, server_port, ProjectSettings.get_setting("application/config/name"), "TCP")
		print("[CRUS ONLINE / UPnP]: UPnP enabled")
		emit_signal("upnp_completed", OK)

func upnp_setup(server_port):
	thread = Thread.new()
	thread.start(self, "_upnp_setup", server_port)

func _exit_tree():
	thread.wait_to_finish()
