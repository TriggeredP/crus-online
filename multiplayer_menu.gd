extends Control

var ip = "127.0.0.1"
var port = 8080

onready var IpEdit = $CenterContainer/TabContainer/Main/VBoxContainer/IpPort/IpEdit
onready var PortEdit = $CenterContainer/TabContainer/Main/VBoxContainer/IpPort/PortEdit

onready var NicknameEdit = $CenterContainer/TabContainer/Player/VBoxContainer/Nickname/NicknameEdit
onready var NicknameColor = $CenterContainer/TabContainer/Player/VBoxContainer/Color/ColorRect

onready var Multiplayer = Global.get_node("Multiplayer")

func _ready():
	var loadedPlayerData = load_data("player.save")
	if loadedPlayerData == null:
		save_data("player.save", Multiplayer.playerInfo)
	else:
		Multiplayer.playerInfo = loadedPlayerData
	
	var loadedConfigData = load_data("config.save")
	if loadedConfigData == null:
		save_data("config.save", Multiplayer.config)
	else:
		Multiplayer.config = loadedConfigData
	
	var modloaderVersion = Global.get_node_or_null("Menu/ModLoaderVersion")
	
	if modloaderVersion != null:
		modloaderVersion.hide()
	
	data_init()
	$CenterContainer.hide()
	$CenterContainer/TabContainer.set_tab_hidden(4, true)
	
	Multiplayer.connect("connected_to_server", self, "_on_connected")

func data_init():
	NicknameEdit.text = Multiplayer.playerInfo.nickname
	NicknameColor.color = Multiplayer.playerInfo.color
	
	$CenterContainer/TabContainer/Player/VBoxContainer/Image.set_texture(Multiplayer.playerInfo.image)
	$CenterContainer/TabContainer/Player/VBoxContainer/Skin.set_texture(Multiplayer.playerInfo.skinPath)
	
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
	
	Multiplayer.playerInfo.color = NicknameColor.color.to_html(false)
	
	if NicknameEdit.text == "":
		Multiplayer.playerInfo.nickname = "Mt Foxtrot"
	else:
		Multiplayer.playerInfo.nickname = NicknameEdit.text

func host():
	Multiplayer.hostSettings.bannedImplants = []

	for implant in $CenterContainer/TabContainer/Implants.bannedImplants:
		Multiplayer.hostSettings.bannedImplants.append(implant)

	Multiplayer.host_server(port)
	
	disable_buttons()
	disable_tabs()
	$CenterContainer/TabContainer.current_tab = 0

func join():
	Multiplayer.join_to_server(ip, port)
	
	disable_tabs()
	disable_buttons()
	$CenterContainer/TabContainer.current_tab = 0

func leave():
	Multiplayer.leave_server()
	
	enable_tabs()
	enable_buttons()
	$CenterContainer/TabContainer.current_tab = 0
	
	$CenterContainer/TabContainer/Main/VBoxContainer/PlayersList/PlayersListLabel.text = ""

func disable_buttons():
	$CenterContainer/TabContainer/Main/VBoxContainer/IpPort/Buttons/Join.hide()
	$CenterContainer/TabContainer/Main/VBoxContainer/IpPort/Buttons/Host.hide()
	$CenterContainer/TabContainer/Main/VBoxContainer/IpPort/Buttons/Leave.show()

func enable_buttons():
	$CenterContainer/TabContainer/Main/VBoxContainer/IpPort/Buttons/Join.show()
	$CenterContainer/TabContainer/Main/VBoxContainer/IpPort/Buttons/Host.show()
	$CenterContainer/TabContainer/Main/VBoxContainer/IpPort/Buttons/Leave.hide()

func disable_tabs():
	$CenterContainer/TabContainer.set_tab_hidden(1, true)
	$CenterContainer/TabContainer.set_tab_hidden(2, true)

func enable_tabs():
	$CenterContainer/TabContainer.set_tab_hidden(1, false)
	$CenterContainer/TabContainer.set_tab_hidden(2, false)

func _on_connected():
	$CenterContainer/TabContainer/Main/VBoxContainer/IpPort/Buttons.current_tab = 1

func enable_menu():
	if not $CenterContainer/TabContainer/Implants.updated:
		$CenterContainer/TabContainer/Implants.update()
		
	$CenterContainer.visible = true

func disable_menu():
	$CenterContainer.visible = false

func save_data(fileName, data):
	var dir = Directory.new()
	if not dir.dir_exists("user://mod_config/crus_online/"):
		dir.make_dir("user://mod_config/crus_online/")
	
	var mod_config = File.new()
	mod_config.open("user://mod_config/crus_online/" + fileName, File.WRITE)
	mod_config.store_line(to_json(data))
	mod_config.close()
	
	print("[CruS Online]: Saved")

func load_data(fileName):
	var dir = Directory.new()
	if not dir.dir_exists("user://mod_config/crus_online/"):
		dir.make_dir("user://mod_config/crus_online/")

	var file = File.new()
	if file.file_exists("user://mod_config/crus_online/" + fileName):
		file.open("user://mod_config/crus_online/" + fileName, File.READ)
		var data = parse_json(file.get_as_text())
		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			print("[CruS Online]: Loaded")
			return data
		else:
			printerr("[CruS Online]: Corrupted data!")
			return null
	else:
		printerr("[CruS Online]: No saved data!")
		return null
