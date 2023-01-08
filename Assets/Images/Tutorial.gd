extends Node2D


var Ghost = preload("res://Ghost.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_FightStartArea_body_entered(body):
	var g = Ghost.instance()
	add_child(g)
	g.position = $FightLocation.position
	g.set_tilemap($CropTileMap)
	$FightStartArea/CollisionShape2D.set_deferred("disabled", true)


func _on_StartArea_body_entered(body):
	get_tree().change_scene("res://Root.tscn")
