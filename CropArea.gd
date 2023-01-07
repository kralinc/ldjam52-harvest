class_name CropArea
extends Area2D

var crop = Vector2()

signal attempt_harvest(pos)

func _on_CropArea_area_entered(area):
	emit_signal("attempt_harvest", position)
