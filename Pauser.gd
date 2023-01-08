extends Node

signal paused

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS

func _process(delta):
	if (Input.is_action_just_pressed("pause")):
			get_tree().paused = !get_tree().paused
			emit_signal("paused")


func _on_RestartButton_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_MenuButton_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://MainMenu.tscn")
