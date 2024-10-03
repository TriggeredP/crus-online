extends Node

export var enabled = true

export var virtual_server_port  = 25568
export var true_server_port  = 25567

export var fake_latency_ms = 0
export var fake_loss = 0.0

# Mental picture :
#
# (True) Server  <-->  Virtual Client -[Laggy bridge]- Virtual Server  <-->  (True) Client
#

var vserver_peer
var vserver_has_dest_address = false
var vserver_first_client_port = -1
var vclient_peer

class QueEntry:
	var byte_array
	var qued_at
	
	func _init(packet, time_now):
		self.byte_array = packet
		self.qued_at = time_now

var client_to_server_que = []
var server_to_client_que = []

func _ready():
	set_process(false)

func setup():
	if enabled:
		print("[CRUS ONLINE / DEBUG / UDP LAGGER]: Setting up")
		
		vserver_peer = PacketPeerUDP.new()
		vserver_peer.listen(virtual_server_port, "127.0.0.1")
		
		vclient_peer = PacketPeerUDP.new()
		vclient_peer.set_dest_address("127.0.0.1", true_server_port)
		
		set_process(true)

func _process(delta):
	var now = Time.get_ticks_msec()
	var send_at_ms = now - fake_latency_ms
	
	# Handle packets Client -> Server
	while vserver_peer.get_available_packet_count() > 0:
		var packet = vserver_peer.get_packet()
		var err = vserver_peer.get_packet_error()
		if err != OK :
			push_error("[CRUS ONLINE / DEBUG / UDP LAGGER]: Incoming packet error : " + str(err))
			continue
			
		var from_port = vserver_peer.get_packet_port()
		
		if not vserver_has_dest_address:
			vserver_peer.set_dest_address("127.0.0.1", from_port)
			vserver_first_client_port = from_port
			vserver_has_dest_address = true
		elif vserver_first_client_port != from_port :
			push_warning("[CRUS ONLINE / DEBUG / UDP LAGGER]: VServer got packet from unknown port, ignored.")
			continue
		
		client_to_server_que.push_back(QueEntry.new(packet, now))
	_process_que(client_to_server_que, vclient_peer, send_at_ms)
	
	if not vserver_has_dest_address:
		return
	
	# Handle packets Server -> Client
	while vclient_peer.get_available_packet_count() > 0:
		var packet = vclient_peer.get_packet()
		var err = vclient_peer.get_packet_error()
		if err != OK :
			push_error("[CRUS ONLINE / DEBUG / UDP LAGGER]: Incoming packet error: " + str(err))
			continue
		
		var from_port = vclient_peer.get_packet_port()
		if from_port != true_server_port :
			push_warning("[CRUS ONLINE / DEBUG / UDP LAGGER]: VClient got packet from unknown port, ignored.")
			continue
		
		server_to_client_que.push_back(QueEntry.new(packet, now))
	_process_que(server_to_client_que, vserver_peer, send_at_ms)

func _process_que(que, to_peer, send_at_ms):
	while not que.empty():
		var front = que.front()
		if send_at_ms >= front.qued_at :
			if fake_loss <= 0 or randf() >= fake_loss:
				to_peer.put_packet(front.byte_array)
			que.pop_front()
		else:
			break
