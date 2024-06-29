extends Control

var ip = "127.0.0.1"
var port = 8080

var playerInfo = {
	"nickname": "MT Foxtrot",
	"color": "ff00ff",
	"image": "null",
	"skinPath": "res://Textures/Misc/mainguy_clothes.png"
}

var hostSettings = {
	"gamemode": "Cruelty",
	"map": "res://MOD_CONTENT/CruS Online/maps/bonesquad_museum.tscn",
	"bannedImplants": []
}

onready var IpEdit = $CenterContainer/TabContainer/Main/VBoxContainer/IpPort/IpEdit
onready var PortEdit = $CenterContainer/TabContainer/Main/VBoxContainer/IpPort/PortEdit

onready var NicknameEdit = $CenterContainer/TabContainer/Player/VBoxContainer/Nickname/NicknameEdit
onready var NicknameColor = $CenterContainer/TabContainer/Player/VBoxContainer/Color/ColorRect

onready var Multiplayer = get_tree().get_nodes_in_group("Multiplayer")[0]

func _ready():
	Multiplayer.connect("connected_to_server", self, "_on_connected")
	
	$CenterContainer.hide()

func data_init():
	playerInfo = Multiplayer.my_info
	
	print(Multiplayer.my_info)
	print(playerInfo)
	
	NicknameEdit.text = playerInfo.nickname
	NicknameColor.color = playerInfo.color
	
	$CenterContainer/TabContainer/Player/VBoxContainer/Image.set_texture(playerInfo.image)
	$CenterContainer/TabContainer/Player/VBoxContainer/Skin.set_texture(playerInfo.skinPath)
	
	$CenterContainer/TabContainer/Player/VBoxContainer/Color.r_change(NicknameColor.color.r8)
	$CenterContainer/TabContainer/Player/VBoxContainer/Color.g_change(NicknameColor.color.g8)
	$CenterContainer/TabContainer/Player/VBoxContainer/Color.b_change(NicknameColor.color.b8)

func _physics_process(delta):
	if Global.menu.in_game:
		hide()
	else:
		show()

func get_data():
	ip = IpEdit.text
	port = int(PortEdit.text)
	
	playerInfo.color = NicknameColor.color.to_html(false)
	
	if NicknameEdit.text == "":
		playerInfo.nickname = "Mt Foxtrot"
	else:
		playerInfo.nickname = NicknameEdit.text

func host():
	get_data()
	
	for implant in $CenterContainer/TabContainer/Implants.bannedImplants:
		hostSettings["bannedImplants"].append(implant)
	
	Multiplayer.my_info = playerInfo
	Multiplayer.save_data()
	
	Multiplayer.host_server(port,hostSettings)
	$CenterContainer/TabContainer/Main/VBoxContainer/IpPort/Buttons.current_tab = 2

func join():
	get_data()
	
	Multiplayer.my_info = playerInfo
	Multiplayer.save_data()
	
	Multiplayer.join_to_server(ip, port)

func _on_connected():
	$CenterContainer/TabContainer/Main/VBoxContainer/IpPort/Buttons.current_tab = 1

func enable_menu():
	if not $CenterContainer/TabContainer/Implants.updated:
		$CenterContainer/TabContainer/Implants.update()
		
	$CenterContainer.visible = true

func disable_menu():
	$CenterContainer.visible = false
