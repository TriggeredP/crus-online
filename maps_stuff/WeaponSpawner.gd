extends Spatial

onready var NetworkBridge = Global.get_node("Multiplayer/NetworkBridge")

var activeWeapon = null
onready var weaponModels = get_node("Weapons").get_children()

const maxAmmo = [24, 60, 5, 0, 25, 5, 6, 90, 50, 20, 0, 0, 20, 9, 0, 100, 0, 0, 200, 90, 72, 72, 18, 0, 0, 30, 200, 20, 90]

export var rotateSpeed = 0.1
export var respawnWeaponIds = [0]
export var respawnTime = 5

remotesync func _disable(id, disable):
	$Collect/CollisionShape.disabled = disable

remotesync func _set_weapon(id, weaponId):
	if activeWeapon != null:
		weaponModels[activeWeapon].hide()
		
	activeWeapon = weaponId
	
	if activeWeapon != null:
		weaponModels[activeWeapon].show()

mastersync func _enable_timer(id):
	$Timer.start()

func _ready():
	NetworkBridge.register_rpcs(self,[
		["_set_weapon", NetworkBridge.PERMISSION.ALL],
		["_disable", NetworkBridge.PERMISSION.ALL],
		["_enable_timer", NetworkBridge.PERMISSION.ALL]
	])
	
	$Timer.wait_time = respawnTime
	$Timer.connect("timeout", self, "_selectWeapon")

func _physics_process(delta):
	$Weapons.rotate_y(rotateSpeed)

func collected():
	if activeWeapon != null:
		if (activeWeapon != Global.player.weapon.weapon1 and activeWeapon != Global.player.weapon.weapon2) or Global.player.weapon.current_weapon == activeWeapon:
			Global.player.weapon.magazine_ammo[activeWeapon] = Global.player.weapon.MAX_MAG_AMMO[activeWeapon]
			if Global.player.weapon.ammo[activeWeapon] < maxAmmo[activeWeapon]:
				Global.player.weapon.ammo[activeWeapon] = maxAmmo[activeWeapon]
			Global.player.weapon.set_weapon(activeWeapon)
			NetworkBridge.n_rpc(self, "_set_weapon", [null])
			NetworkBridge.n_rpc(self, "_disable", [true])
			NetworkBridge.n_rpc(self, "_enable_timer")

func _selectWeapon():
	respawnWeaponIds.shuffle()
	NetworkBridge.n_rpc(self, "_set_weapon", [respawnWeaponIds[0]])
	NetworkBridge.n_rpc(self, "_disable", [false])
