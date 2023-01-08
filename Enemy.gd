class_name Ghost
extends KinematicBody2D

export var speed = 5000
var target = Vector2()
var tilemap
var health = 100
var knockback = 10
var dead = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if (not dead):
		var goto = (target - position).normalized()
		if (goto.x < 0):
			$AnimatedSprite.flip_h = true
		else:
			$AnimatedSprite.flip_h = false
		if ($iframes.time_left > 0):
			goto.x += knockback
		move_and_slide(goto * speed * delta)
		var distance = position.distance_to(target)
		if (distance < 50 and $CropDestroyTimer.time_left == 0):
			tilemap.destroy_crop(tilemap.world_to_map(target))
			$CropDestroyTimer.start(0)
			set_enemy_target()
	
func set_tilemap(tm):
	tilemap = tm

func set_enemy_target():
	var crops = tilemap.get_used_cells()
	var thisTile = tilemap.world_to_map(position)
	var min_distance = 9999999
	var closest_crop = Vector2(1000, -1000)
	for crop in crops:
		var distance = crop.distance_to(thisTile)
		if (distance < min_distance):
			closest_crop = crop
			min_distance = distance
	target = tilemap.map_to_world(closest_crop)

func harm(right, damage, kb):
	if($iframes.time_left == 0 and not dead):
		health -= damage
		knockback = kb
		$AnimationPlayer.play("Hurt")
		$iframes.start(0)
		if (right):
			knockback *= -1
		$CropDestroyTimer.start(0)
		if (health <= 0):
			dead = true
			$AnimationPlayer.play("Die")

func _on_Timer_timeout():
	if (not dead):
		set_enemy_target()


func _on_AnimationPlayer_animation_finished(anim_name):
	if (anim_name == "Die"):
		queue_free()
