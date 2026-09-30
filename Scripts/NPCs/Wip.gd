extends Node2D

var grid_position: Vector2i
var shown: bool = false

@export var dialog_interface: DialogueInterface
@export var tilemap: TileMapLayer

func _ready():
	if LevelStateManager.current_level == 6:
		grid_position = Vector2i(-1, -6)
	else:
		grid_position = Vector2i(-2, -9)
	GridUtils.snap_to_tile_center(self, tilemap, grid_position, $Center.position)


func _process(_delta):
	if is_adjacent_to_slime() and not shown:
		shown = true
		set_process(false)
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
	return PlayerRef.player != null and GridUtils.is_adjacent_4(grid_position, PlayerRef.player.movement_handler.grid_position)
