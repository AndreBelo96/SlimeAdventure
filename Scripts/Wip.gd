extends Node2D

var posizione_tile: Vector2i
var shown: bool = false

@onready var slime := get_tree().get_first_node_in_group("player")
@export var dialog_interface: DialogueInterface
@export var tilemap: TileMapLayer

func _ready():
	if GameManager.current_level == 6:
		posizione_tile = Vector2i(-1, -6)
	else:
		posizione_tile = Vector2i(-2, -9)
	snap_to_tile_center(posizione_tile)


func _process(_delta):
	if is_adjacent_to_slime() and not shown:
		shown = true
		#show_dialogue()

func show_dialogue():
	var intro_dialogue = [
		{
			"name": "The Dev",
			"text": "Work In Progress",
			"portrait": PortraitManager.get_portrait("Wip"),
			"voice": "res://Assets/Audio/Sound/Voice/AcuteVoice.wav",
			"voice_speed": VoiceManager.get_speed(VoiceManager.DEFAULT)
		}
	]

	dialog_interface.show_dialogue(intro_dialogue)
	await dialog_interface.dialogue_finished

func is_adjacent_to_slime() -> bool:
	if not slime:
		return false
	
	var dx = abs(slime.movement_handler.grid_position.x - posizione_tile.x)
	var dy = abs(slime.movement_handler.grid_position.y - posizione_tile.y)
	
	return dx + dy == 1

func snap_to_tile_center(coords: Vector2i):
	var tile_pos = tilemap.map_to_local(coords)
	global_position = tile_pos - $Center.position
