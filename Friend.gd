extends KinematicBody2D

signal crop_harvested(location)
signal ray_find_tile(location)
signal is_crop_here(location)

export var speed = 100
export var jump_height = 100
export var dash_power = 3.0
export var gravity = 100
export var friction = 0.5
var vel = Vector2(0, 0)
var jumped = false
var dashed = false
var air_time = 0
var crop_just_harvested = false

var AIR_TIME_GRACE_PERIOD = 0.2
var FLOOR_DETECT_DISTANCE = 20.0

onready var SPRITE = $AnimatedSprite
onready var WEAPON = $Weapon
onready var WEAPON_COL = $Weapon/CollisionShape2D
onready var LABEL = $Label
onready var LABEL_ANIM = $Label/AnimationPlayer
onready var HITBOX = $Hitbox
onready var SEED = $Seed
onready var FIND_FLOOR = $FindFloor

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var dir = Vector2(0, 0)
	if (Input.is_action_pressed("left")):
		vel.x -= speed
		SPRITE.flip_h = false
		SPRITE.offset.x = 0
		WEAPON.position.x = 0
		FIND_FLOOR.position.x = 120
	if(Input.is_action_pressed("right")):
		vel.x += speed
		SPRITE.flip_h = true
		SPRITE.offset.x = 200
		WEAPON.position.x = 300
		FIND_FLOOR.position.x = 90
		
	if(Input.is_action_just_pressed("attack")):
		SPRITE.animation = "Attack"
		
	if (SPRITE.animation == "Attack"):
		for area in WEAPON.get_overlapping_areas():
			if (area.get_collision_layer_bit(2) == true):
				emit_signal("crop_harvested", area.crop)
		if (crop_just_harvested):
			set_label_animation()
			crop_just_harvested = false
				
	if(Input.is_action_just_pressed("seed")):
		if (SEED.visible == false):
			for area in HITBOX.get_overlapping_areas():
				if (area.get_collision_layer_bit(3) == true):
					SEED.visible = true
		else:
			FIND_FLOOR.enabled = true
			FIND_FLOOR.force_raycast_update()
			if (FIND_FLOOR.is_colliding()):
				print("ray is colliding with something")
				emit_signal("ray_find_tile", FIND_FLOOR.get_collision_point())
			FIND_FLOOR.enabled = false
		
	if (is_on_floor()):
		dir.y = 0
		dashed = false
		air_time = 0
	else:
		air_time += delta
	
	if (dir.x == 0):
		vel.x *= friction
			
	dir.y += gravity * delta
	if (dir.y > 0 and not is_on_floor()):
		dir.y += gravity * delta
		
	if(Input.is_action_just_pressed("jump")):
		if (is_on_floor() or (air_time < AIR_TIME_GRACE_PERIOD and not jumped)):
			vel.y = -jump_height
			jumped = true
		elif(jumped and not dashed):
			vel.y = -jump_height
			vel.x *= dash_power
			dashed = true
	
	vel.y += dir.y
	
	var snap_vector = Vector2.ZERO
	if dir.y == 0.0:
		snap_vector = Vector2.DOWN * FLOOR_DETECT_DISTANCE
	vel = move_and_slide_with_snap(
		vel, snap_vector, Vector2.UP, true, 4, 0.9, false
	)


func _on_AnimatedSprite_animation_finished():
	SPRITE.animation = "default"


func _on_CropTileMap_upgrade():
	crop_just_harvested = true
	var upgrade_type = randi() % 5
	var upgrade_amount = randi() % 10 + 1
	LABEL.text = "UPGRADE!\n+" + str(upgrade_amount) + "% "
	if (upgrade_type == 0):
		LABEL.text += "Speed"
		speed += (speed * upgrade_amount / 100)
	elif (upgrade_type == 1):
		LABEL.text += "Jump"
		jump_height += (jump_height * upgrade_amount / 100)
	elif (upgrade_type == 2):
		LABEL.text += "Seed Plant Distance"
		FIND_FLOOR.cast_to.y *= 1 + (upgrade_amount / 100)
	elif (upgrade_type == 3):
		LABEL.text += "Sword Radius"
		WEAPON_COL.scale *= 1 + (upgrade_amount / 100)
	else:
		LABEL.text += "Dash"
		dash_power += (dash_power * upgrade_amount / 100)
			
func set_label_animation():
	if (LABEL_ANIM.is_playing()):
		LABEL_ANIM.stop(true)
		LABEL_ANIM.play("FadeOut")
	else:
		LABEL_ANIM.play("FadeInOut")

func _on_Floor_is_farmland(tile):
	print(tile)
	tile.y -= 1
	print(tile)
	emit_signal("is_crop_here", tile)


func _on_CropTileMap_seed_planted():
	SEED.visible = false
