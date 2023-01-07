extends TileMap

signal is_farmland(tile)

func _on_Friend_ray_find_tile(location):
	var tile = world_to_map(location)
	if (get_cellv(tile) == 0):
		emit_signal("is_farmland", tile)
		print("the tile is farmland")
