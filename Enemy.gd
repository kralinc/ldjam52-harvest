class_name Ghost
extends KinematicBody2D

export var speed = 5000
var target = Vector2()
var tilemap

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var goto = (target - position).normalized()
	move_and_slide(goto * speed * delta)
	var distance = position.distance_to(target)
	if (distance < 100):
		tilemap.destroy_crop(tilemap.world_to_map(target))
	
func set_tilemap(tm):
	tilemap = tm

func set_enemy_target():
	var crops = tilemap.get_used_cells()
	var thisTile = tilemap.world_to_map(position)
	var min_distance = 9999999
	var closest_crop
	for crop in crops:
		var distance = crop.distance_to(thisTile)
		if (distance < min_distance):
			closest_crop = crop
			min_distance = distance
	target = tilemap.map_to_world(closest_crop)


func _on_Timer_timeout():
	set_enemy_target()
