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

var location_colors := {
	GameManager.Location.TUTORIAL: {
		"name": Color("#959595")
	},
	GameManager.Location.DUNGEON: {
		"name": Color("#38477a")
	},
	GameManager.Location.FOREST: {
		"name": Color("#1b5e20"),
	}
}

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	
	_apply_location_theme()
	
	_setup_languages()
	
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	$MarginContainer/VBoxContainer/Titolo.text = transition_text

	match location_id:
		GameManager.Location.TUTORIAL:
			pass
		GameManager.Location.DUNGEON:
			var chain_manager = DungeonManager.new()
			chain_manager.chain_frames = dungeon_frames
			$MarginContainer.add_child(chain_manager)
			chain_manager.spawn_chains($MarginContainer)
			chain_manager.spawn_sprites($MarginContainer)
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


func _setup_languages():
	enter_label.text = tr("TRANSATION_ENTER")
	title_label.text = tr(GameManager.location_translation_keys[GameManager.location_selected])
	loading_label.text = tr("LOADING_LABEL")

func _input(_event: InputEvent) -> void:
	get_viewport().set_input_as_handled()

func _unhandled_input(_event: InputEvent) -> void:
	get_viewport().set_input_as_handled()

func _apply_location_theme():
	var location = GameManager.get_location_for_level(GameManager.current_level)
	var theme_data = location_colors.get(location, null)
	
	if theme_data == null:
		return
	# Cambiare background nome
	enter_label.add_theme_color_override("font_color", theme_data["name"])
	title_label.add_theme_color_override("font_color", theme_data["name"])
	loading_label.add_theme_color_override("font_color", theme_data["name"])
