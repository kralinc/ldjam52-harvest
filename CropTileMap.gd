extends TileMap

var crop_lifetimes  = Dictionary()

# Called when the node enters the scene tree for the first time.
func _ready():
	var crops = get_used_cells()
	for crop in crops:
		crop_lifetimes[crop] = 0.0

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
