extends Node2D

onready var Ghost = preload("res://Ghost.tscn")

onready var Enemies = $Enemies
onready var CropTileMap = $CropTileMap

export var spawn_interval = 4.0
var timer = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer += delta
	if (timer > spawn_interval):
		spawn_new_enemy()
		timer = 0.0
		spawn_interval -= 0.005

func spawn_new_enemy():
	var enemy_type = randi() % 1
	var left_right = randi() % 2
	
	var posx = -300 if left_right == 0 else 3500
	var posy = (randi() % 3000) * -1
	
	if (enemy_type == 0):
		var g = Ghost.instance()
		Enemies.add_child(g)
		g.position = Vector2(posx, posy)
		g.set_tilemap(CropTileMap)
		g.set_enemy_target()
