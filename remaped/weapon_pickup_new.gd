extends Area
enum WEAPON{W_PISTOL, W_SMG, W_TRANQ, W_BLACKJACK, W_SHOTGUN, W_ROCKET_LAUNCHER, W_SNIPER, W_AR, W_SILENCED_SMG, W_NAMBU, W_GAS, W_MG3, W_AUTOSHOTGUN, W_MAUSER, W_BORE, W_MKR, W_RADIATOR, W_FLASHLIGHT, W_ZIPPY, W_AN94, W_VAG72, W_STEYR, W_DNA, W_ROD, W_FLAMETHROWER, W_SKS, W_NAILER, W_SHOCK, W_LIGHT}
onready var MESH = [$Pistol_Mesh, $SMG_Mesh, $Tranq_Mesh, $Baton_Mesh, $Shotgun_Mesh, $RL_Mesh, $Sniper_Mesh, $AR_Mesh, $S_SMG_Mesh, $Nambu_Mesh, $Gas_Mesh, $MG3_Mesh, $Autoshotgun_Mesh, $Mauser_Mesh, $Bore_Mesh, $MKR_Mesh, $Rad_Mesh, $Flashlight_Mesh, $Zippy_Mesh, $AN94_Mesh, $VAG72_Mesh, $Steyr_Mesh, $DNA_Mesh, $Rod_Mesh, $FT_Mesh, $SKS_Mesh, $Nailer_Mesh, $SHOCK_Mesh, $Light_Mesh]
export (WEAPON) var current_weapon = 0
export  var menu = false
var ammo = 0

################################################################################

remote func _update_vars(recivedWeapon,recivedAmmo):
	current_weapon = recivedWeapon
	ammo = recivedAmmo

remote func _change_visible(mesh,visibility):
	mesh.visible = visibility

################################################################################

func _ready():
	MESH[current_weapon].show()
	if not menu:
		ammo = Global.player.weapon.MAX_MAG_AMMO[current_weapon]

func player_use():
	if not menu:
		var rot = rand_range(0, deg2rad(180))

		get_parent().rotation.y = rot
		get_parent().rot_changed.y = rot
		
		if Global.player.weapon.current_weapon == current_weapon:
			if current_weapon == WEAPON.W_RADIATOR or current_weapon == WEAPON.W_BLACKJACK or current_weapon == WEAPON.W_BORE or current_weapon == WEAPON.W_FLASHLIGHT or current_weapon == WEAPON.W_ROD:
				return 
			Global.player.weapon.add_ammo(ammo, current_weapon, Spatial.new())
			ammo = 0
			rpc("_update_vars",current_weapon,ammo)
			return 
		if Global.player.weapon.weapon1 == current_weapon or Global.player.weapon.weapon2 == current_weapon:
			return 
		var last_weapon
		var last_ammo
		if Global.player.weapon.current_weapon != null:
			last_weapon = Global.player.weapon.current_weapon
			last_ammo = Global.player.weapon.magazine_ammo[last_weapon]
		else :
			last_weapon = null
		var a = ammo
		Global.player.weapon.magazine_ammo[current_weapon] = a
		Global.player.weapon.set_weapon(current_weapon)
		Global.player.weapon.set_UI_ammo()
		Global.player.weapon.player_weapon.show()
		MESH[current_weapon].hide()
		rpc("_change_visible",MESH[current_weapon],false)
		current_weapon = last_weapon
		rpc("_update_vars",current_weapon,ammo)
		if current_weapon == null:
			get_parent().rpc("_remove")
			get_parent().queue_free()
			return 
		ammo = last_ammo
		rpc("_update_vars",current_weapon,ammo)
		MESH[current_weapon].show()
		rpc("_change_visible",MESH[current_weapon],true)
