extends TileMap

signal is_farmland(tile, was_grass)

func _on_Friend_ray_find_tile(location, has_seed):
	var tile = world_to_map(location)
	if (get_cellv(tile) == 0):
		emit_signal("is_farmland", tile, false)
	elif (get_cellv(tile) == 1 and has_seed):
		set_cellv(tile, 0)
		emit_signal("is_farmland", tile, true)
