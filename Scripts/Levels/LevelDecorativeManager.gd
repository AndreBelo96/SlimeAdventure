extends Node2D

var texture_atlas = preload("res://Assets/Sprites/Decorations/set_decorazioni.png")
enum OggettiDecorativi { PORTA_CELLA, GABBIA }

func spawn(tipo: OggettiDecorativi, tile_pos: Vector2i, offset := Vector2.ZERO):
	match tipo:
		OggettiDecorativi.PORTA_CELLA:
			var porta = preload("res://Scenes/Decorations/PortaCella.tscn").instantiate()
			porta.position = tile_to_world(tile_pos) + offset
			add_child(porta)
		_:
			var sprite = Sprite2D.new()
			sprite.texture = AtlasTexture.new()
			sprite.texture.atlas = texture_atlas
			sprite.position = tile_to_world(tile_pos) + offset
			add_child(sprite)

func tile_to_world(tile_pos: Vector2i) -> Vector2:
	var tile_width := 64.0
	var tile_height := 24.0
	return Vector2((tile_pos.x - tile_pos.y)*(tile_width/2),
				   (tile_pos.x + tile_pos.y)*(tile_height/2))
