extends TileMap

signal upgrade
signal seed_planted(location)
signal crop_destroyed(location)

onready var CropArea = preload("res://CropArea.tscn")

var crop_lifetimes  = Dictionary()

# Called when the node enters the scene tree for the first time.
func _ready():
	var crops = get_used_cells()
	for crop in crops:
		crop_lifetimes[crop] = float(get_cellv(crop) * 10)
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
	if life > 40:
		tile = 4
	elif life > 30:
		tile = 3
	elif life > 20:
		tile = 2
	elif life > 10:
		tile = 1
		
	set_cell(crop.x, crop.y, tile)
	
func destroy_crop(location):
	set_cell(location.x, location.y, -1)
	crop_lifetimes.erase(location)
	emit_signal("crop_destroyed", location)

func _on_Friend_crop_harvested(location):
	if (get_cellv(location) == 4):
		destroy_crop(location)
		emit_signal("upgrade")

func _on_Friend_is_crop_here(location):
	if(get_cellv(location) == -1):
		set_cellv(location, 0)
		crop_lifetimes[location] = 0.0
		emit_signal("seed_planted", location)
