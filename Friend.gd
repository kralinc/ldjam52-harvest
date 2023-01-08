extends KinematicBody2D

signal crop_harvested(location)
signal ray_find_tile(location, has_seed)
signal is_crop_here(location)

export var speed = 750
export var jump_height = 1800
export var dash_power = 1.5
export var gravity = 2150
var friction = 0.5
export var damage = 30.0
export var knockback = -10.0
export var cam_right = 3392

var MAX_SPEED = 1800
var MAX_JUMP_HEIGHT = 2500

var vel = Vector2(0, 0)
var jumped = false
var djumped = false
var dashed = false
var air_time = 0
var crop_just_harvested = false
var tile_was_grass = false
var harvested = 0

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
	$Camera2D.limit_right = cam_right


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var dir = Vector2(0, 0)
	var dash_mod = 1
	if (SPRITE.animation == "Dash"):
		dash_mod = dash_power
	if (Input.is_action_pressed("left")):
		vel.x -= speed * dash_mod
		dir.x = -1
		SPRITE.flip_h = false
		SPRITE.offset.x = 0
		WEAPON.position.x = 0
		FIND_FLOOR.position.x = 120
	if(Input.is_action_pressed("right")):
		vel.x += speed * dash_mod
		dir.x = 1
		SPRITE.flip_h = true
		SPRITE.offset.x = 200
		WEAPON.position.x = 300
		FIND_FLOOR.position.x = 90
		
	if (is_on_floor() and SPRITE.animation != "Attack"):
		if (dir.x == 0):
			SPRITE.animation = "default"
		elif(dir.x != 0):
			SPRITE.animation = "Run"
		
	if(Input.is_action_just_pressed("attack") and SPRITE.animation != "Attack"):
		SPRITE.animation = "Attack"
		$AttackSound.play(0)
				
	if(Input.is_action_just_pressed("dash") and not dashed):
		dashed = true
		SPRITE.animation = "Dash"
		$DashSound.play(0)
		
	if (SEED.visible == false):
		for area in HITBOX.get_overlapping_areas():
			if (area.get_collision_layer_bit(3) == true):
				SEED.visible = true
					
	if (FIND_FLOOR.is_colliding()):
		emit_signal("ray_find_tile", FIND_FLOOR.get_collision_point(), SEED.visible)
		
	if (is_on_floor()):
		dir.y = 0
		dashed = false
		jumped = false
		djumped = false
		air_time = 0
		if (SPRITE.animation == "Jump"):
			if (vel.x == 0):
				SPRITE.animation = "default"
			else:
				SPRITE.animation = "Run"
	else:
		air_time += delta

	vel.x *= friction
			
	dir.y += gravity * delta
	if (dir.y > 0 and not is_on_floor()):
		dir.y += gravity * delta
		
	if(Input.is_action_just_pressed("jump")):
		if (is_on_floor() or (air_time < AIR_TIME_GRACE_PERIOD and not jumped)):
			$JumpSound.play(0)
			vel.y = -jump_height
			jumped = true
			SPRITE.animation = "Jump"
		elif((jumped or air_time >= AIR_TIME_GRACE_PERIOD) and not djumped):
			vel.y = -jump_height
			djumped = true
			SPRITE.animation = "Jump"
			$JumpSound.play(0)
			
	if (SPRITE.animation == "Attack"):
		for area in WEAPON.get_overlapping_areas():
			if (area.get_collision_layer_bit(2) == true):
				emit_signal("crop_harvested", area.crop)
		if (crop_just_harvested):
			set_label_animation()
			crop_just_harvested = false
		for body in WEAPON.get_overlapping_bodies():
			body.harm(SPRITE.flip_h, damage, knockback)
	else:
		for body in HITBOX.get_overlapping_bodies():
			if (SPRITE.animation == "Dash"):
				body.harm(SPRITE.flip_h, damage / 2, knockback * 1.33)
	
	vel.y += dir.y
	
	var snap_vector = Vector2.ZERO
	if dir.y == 0.0:
		snap_vector = Vector2.DOWN * FLOOR_DETECT_DISTANCE
	vel = move_and_slide_with_snap(
		vel, snap_vector, Vector2.UP, true, 4, 0.9, false
	)


func _on_AnimatedSprite_animation_finished():
	if (vel.y == 0):
		if (vel.x == 0):
			SPRITE.animation = "default"
		else:
			SPRITE.animation = "Run"
	elif (SPRITE.animation == "Dash"):
		SPRITE.animation = "Jump"
	else:
		SPRITE.animation = "Jump"


func _on_CropTileMap_upgrade():
	harvested += 1
	crop_just_harvested = true
	var upgrade_type = randi() % 4
	var upgrade_amount = randi() % 10 + 1
	LABEL.text = "UPGRADE!\n+" + str(upgrade_amount) + "% "
	if (upgrade_type == 0):
		if (speed < MAX_SPEED):
			LABEL.text += "Speed"
			speed += (speed * upgrade_amount / 100)
		else:
			_on_CropTileMap_upgrade()
	elif (upgrade_type == 1):
		if (jump_height < MAX_JUMP_HEIGHT):
			LABEL.text += "Jump"
			jump_height += (jump_height * upgrade_amount / 100)
			gravity += (gravity * upgrade_amount / 200)
		else:
			_on_CropTileMap_upgrade()
	elif (upgrade_type == 2):
		LABEL.text += "Knockback"
		knockback += (knockback * upgrade_amount / 100)
	else:
		LABEL.text += "Damage"
		damage += damage * upgrade_amount / 100
			
func set_label_animation():
	if (LABEL_ANIM.is_playing()):
		LABEL_ANIM.stop(true)
		LABEL_ANIM.play("FadeOut")
	else:
		LABEL_ANIM.play("FadeInOut")

func _on_Floor_is_farmland(tile, was_grass):
	tile_was_grass = was_grass
	tile.y -= 1
	emit_signal("is_crop_here", tile)


func _on_CropTileMap_seed_planted(location):
	$PlantSound.play(0)
	if (tile_was_grass):
		SEED.visible = false
		tile_was_grass = false
