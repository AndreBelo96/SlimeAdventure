extends Node

# Riferimenti a player e player_interaction
@export var player: Node2D
@export var tile_layer: Node2D

func _ready():
	call_deferred("_connect_all_tiles")

func _connect_all_tiles() -> void:
	for child in tile_layer.get_children():
		if child is TileBase:
			if not child.is_connected("tile_triggered", Callable(self, "_on_tile_triggered")):
				child.connect("tile_triggered", Callable(self, "_on_tile_triggered"))

func _on_tile_triggered(tile: TileBase, action: String, data: Dictionary) -> void:
	print("[PlayerInteraction] Segnale ricevuto da", tile.name, "azione:", action, "dati:", data)
	match action:
		"death":
			player.on_player_died(data.get("death_type", 0))
		"activate":
			tile.is_active = data.get("is_active", true)
			print("[PlayerInteraction] Tile attivata:", tile.name, "stato:", tile.is_active)
			check_victory()
		_:
			pass

func check_victory():
	for child in tile_layer.get_children():
		if child.has_method("is_activated") and not child.is_activated():
			return
	player.on_player_won()
