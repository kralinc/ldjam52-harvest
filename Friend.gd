extends KinematicBody2D

export var speed = 1000
export var jump_height = 1000
export var dash_power = 5
export var gravity = 1000
export var friction = 0.4
var vel = Vector2(0, 0)
var dashed = false

var FLOOR_DETECT_DISTANCE = 20.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var dir = Vector2(0, 0)
	if (Input.is_action_pressed("left")):
		dir.x -= 1
	if(Input.is_action_pressed("right")):
		dir.x += 1
		
	if (is_on_floor()):
		dir.y = 0
		dashed = false
		
	dir *= speed * delta
	
	if (dir.x == 0):
		vel.x *= friction
		
	if(Input.is_action_just_pressed("jump")):
		if (is_on_floor()):
			dir.y = -jump_height
		elif(not is_on_floor() and not dashed):
			dir.y = -jump_height
			dir.x *= dash_power
			dashed = true
			
	dir.y += gravity * delta
	if (dir.y > 0 and not is_on_floor()):
		dir.y += gravity * delta / 2
	
	vel += dir
	
	vel.x = speed if vel.x > speed else vel.x
	
	var snap_vector = Vector2.ZERO
	if dir.y == 0.0:
		snap_vector = Vector2.DOWN * FLOOR_DETECT_DISTANCE
	vel = move_and_slide_with_snap(
		vel, snap_vector, Vector2.UP, true, 4, 0.9, false
	)
