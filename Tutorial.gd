extends AnimationPlayer

var animList = ["MoveLabel", "JumpLabel", "DashLabel", "AttackLabel", "FarmLabel", "SeedLabel"]
var counter = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	if (Settings.tutorial):
		play(animList[0])
		Settings.tutorial = false

func _on_AnimationPlayer_animation_finished(anim_name):
	if (counter < len(animList)):
		play(animList[counter]) 
		counter += 1
