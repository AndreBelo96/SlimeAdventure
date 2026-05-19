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
	GridUtils.snap_to_tile_center(self, tilemap, posizione_tile, $Center.position)


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
	return GridUtils.is_adjacent_4(posizione_tile, slime.movement_handler.grid_position)
