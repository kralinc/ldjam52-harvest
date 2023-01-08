extends Node2D

onready var Ghost = preload("res://Ghost.tscn")

onready var Enemies = $Enemies
onready var CropTileMap = $CropTileMap
onready var FloorTileMap = $Floor

export var spawn_interval = 6.0
var timer = 0.0
var gametime = 360
var empty_farms = Dictionary()

var DESTROY_FARM_TIME = 15
var HARVEST_GOAL = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer += delta
	if (timer > spawn_interval):
		spawn_new_enemy()
		timer = 0.0
		spawn_interval -= 0.01
		
	update_timer(delta)
	update_hud()
	
	for farm in empty_farms.keys():
		empty_farms[farm] += delta
		if (empty_farms[farm] > DESTROY_FARM_TIME):
			FloorTileMap.set_cellv(farm, 1)
			empty_farms.erase(farm)

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

func update_timer(delta):
	gametime -= delta
	var minutes = int(gametime / 60)
	var seconds = int(gametime - minutes * 60)
	$Canvas/HUD/GameTime.text = str(minutes) + ":" + str(seconds)
	
func update_hud():
	$Canvas/HUD/HarvestedText.text = str($Friend.harvested)


func _on_CropTileMap_crop_destroyed(location):
	location.y += 1
	empty_farms[location] = 0.0


func _on_CropTileMap_seed_planted(location):
	location.y += 1
	empty_farms.erase(location)


func _on_Pauser_paused():
	$Canvas/HUD/PausedLabel.visible = !$Canvas/HUD/PausedLabel.visible
