extends TileMap

onready var CropArea = preload("res://CropArea.tscn")

var crop_lifetimes  = Dictionary()

# Called when the node enters the scene tree for the first time.
func _ready():
	var crops = get_used_cells()
	for crop in crops:
		crop_lifetimes[crop] = 0.0
		var ca = CropArea.instance()
		add_child(ca)
		ca.position = map_to_world(crop)
		ca.crop = crop

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for crop in crop_lifetimes.keys():
		crop_lifetimes[crop] += delta
		set_crop_level(crop)

func set_crop_level(crop):
	var life = crop_lifetimes[crop]
	var tile = 0
	if life > 4:
		tile = 4
	elif life > 30:
		tile = 3
	elif life > 20:
		tile = 2
	elif life > 10:
		tile = 1
		
	set_cell(crop.x, crop.y, tile)


func _on_Friend_crop_harvested(location):
	print(get_cellv(location))
	if (get_cellv(location) == 4):
		set_cell(location.x, location.y, -1)
		crop_lifetimes.erase(location)
