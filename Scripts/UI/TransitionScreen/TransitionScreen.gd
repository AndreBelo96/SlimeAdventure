extends Control

@export var scene_to_load: String
@export var transition_text: String = "Loading..."
@export var location_id: int = 0

@export var dungeon_frames: SpriteFrames
@export var forest_frames: SpriteFrames

@onready var animation_player = $AnimationPlayer
@onready var enter_label = $MarginContainer/VBoxContainer/Enter
@onready var title_label = $MarginContainer/VBoxContainer/Titolo
@onready var loading_label = $MarginContainer/VBoxContainer/Caricamento

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	
	_apply_location_theme()
	
	_setup_languages()
	
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	match location_id:
		LocationManager.Location.TUTORIAL:
			pass
		LocationManager.Location.DUNGEON:
			var chain_manager = DungeonManager.new()
			chain_manager.chain_frames = dungeon_frames
			$MarginContainer.add_child(chain_manager)
			chain_manager.spawn_chains($MarginContainer)
			chain_manager.spawn_sprites($MarginContainer)
		LocationManager.Location.FOREST:
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

func _setup_languages():
	enter_label.text = tr("TRANSATION_ENTER")
	title_label.text = tr(LocationManager.location_translation_keys[LocationManager.get_location_for_level(LevelStateManager.current_level)])
	loading_label.text = tr("LOADING_LABEL")

func _input(_event: InputEvent) -> void:
	get_viewport().set_input_as_handled()

func _unhandled_input(_event: InputEvent) -> void:
	get_viewport().set_input_as_handled()

func _apply_location_theme():
	var theme_data := ThemeManager.get_accent_colors_for_level(LevelStateManager.current_level)
	if theme_data.is_empty():
		return
	enter_label.add_theme_color_override("font_color", theme_data["name"])
	title_label.add_theme_color_override("font_color", theme_data["name"])
	loading_label.add_theme_color_override("font_color", theme_data["name"])
