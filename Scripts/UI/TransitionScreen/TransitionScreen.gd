extends Control

@export var scene_to_load: String
@export var transition_text: String = "Loading..."
@export var location_id: int = 0

@export var dungeon_frames: SpriteFrames
@export var forest_frames: SpriteFrames

@onready var animation_player = $CanvasLayer/AnimationPlayer


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	$CanvasLayer/Titolo.text = transition_text

	match location_id:
		GameManager.Location.TUTORIAL:
			pass
		GameManager.Location.DUNGEON:
			var chain_manager = DungeonManager.new()
			chain_manager.chain_frames = dungeon_frames
			$CanvasLayer.add_child(chain_manager)
			chain_manager.spawn_chains($CanvasLayer)
			chain_manager.spawn_sprites($CanvasLayer)
		GameManager.Location.FOREST:
			pass
	
	animation_player.play("FadeIn")
	await animation_player.animation_finished
	
	await get_tree().create_timer(2).timeout
	
	animation_player.play("FadeOut")
	await animation_player.animation_finished

	get_tree().paused = false
	var packed_scene := load(scene_to_load)
	get_tree().change_scene_to_packed(packed_scene)

	queue_free()

func _input(_event: InputEvent) -> void:
	get_viewport().set_input_as_handled()

func _unhandled_input(_event: InputEvent) -> void:
	get_viewport().set_input_as_handled()
