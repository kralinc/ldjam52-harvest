extends KinematicBody2D

signal crop_harvested(location)

export var speed = 100
export var jump_height = 100
export var dash_power = 3
export var gravity = 100
export var friction = 0.5
var vel = Vector2(0, 0)
var jumped = false
var dashed = false
var air_time = 0

var AIR_TIME_GRACE_PERIOD = 0.2
var FLOOR_DETECT_DISTANCE = 20.0
onready var SPRITE = $AnimatedSprite
onready var WEAPON = $Weapon

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var dir = Vector2(0, 0)
	if (Input.is_action_pressed("left")):
		vel.x -= speed
		SPRITE.flip_h = false
		SPRITE.offset.x = 0
		WEAPON.position.x = 0
	if(Input.is_action_pressed("right")):
		vel.x += speed
		SPRITE.flip_h = true
		SPRITE.offset.x = 200
		WEAPON.position.x = 300
		
	if(Input.is_action_just_pressed("attack")):
		SPRITE.animation = "Attack"
		
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


func _on_Weapon_area_entered(area):
	if(SPRITE.animation == "Attack"):
		emit_signal("crop_harvested", area.crop)
