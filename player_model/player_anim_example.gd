extends Spatial

onready var anim_tree = $"../anim_tree"

func _ready():
	### UPPER BODY
	#set look direction. -1 = straight up, 0 = forward, 1 = straight down
	anim_tree.set("parameters/LOOK_DIRECTION/blend_amount", 0.0)
	#set arm animation. -1 = Phone, 0 = None, 1 = Aiming Gun
	anim_tree.set("parameters/ARMS_BLEND/blend_amount", 1.0)

	### LOWER BODY
	#set leg movement type. 0 = Standing, 1 = Crouching
	anim_tree.set("parameters/MOVE_BLEND/blend_amount", 0.0)
	#set crouch speed. 0 = Not moving, 1 = max speed
	anim_tree.set("parameters/CROUCHMOVE_AMOUNT/blend_amount", 1.0)
	#set run speed. 0 = Not moving, 1 = max speed
	anim_tree.set("parameters/STANDMOVE_AMOUNT/blend_amount", 1.0)
	#set run direction (optional). -1 = running left, 0 = running forward, 1 = running right
	anim_tree.set("parameters/RUN_DIRECTION/blend_amount", 0.0)
	#special legs animation. 0 = None, -1 = Sitting, 1 = Jumping
	anim_tree.set("parameters/LEGS_BLEND/blend_amount", 0.0)
	
	### ONE SHOT ANIMATIONS
	#trigger death 1
	anim_tree.set("parameters/DEATH1/active", false)
	#trigger death 2
	anim_tree.set("parameters/DEATH2/active", false)
	#trigger kick
	anim_tree.set("parameters/KICK/active", false)
	
