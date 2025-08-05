extends Control

@onready var location_container: GridContainer = $CanvasLayer/Menu/CenterContainer/LocationContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	load_level_buttons()

func load_level_buttons():
	for child in location_container.get_children():
		child.queue_free()
		
	for location_name in GameManager.Location.keys():
		create_level_button(location_name)

func create_level_button(label: String):
	var button := Button.new()
	button.text = label
	button.focus_mode = Control.FOCUS_NONE
	button.disabled = is_location_disabled(label)
	button.pressed.connect(_on_level_button_pressed.bind(label))

	# Personalizzazione con match sulla location
	match GameManager.Location[label]:
		GameManager.Location.TUTORIAL:
			button.theme = preload("res://Theme/TutorialButton.tres")
		GameManager.Location.DUNGEON:
			button.theme = preload("res://Theme/DungeonButton.tres")
		_:
			# Default fallback (opzionale)
			button.add_theme_color_override("font_color", Color.WHITE)
	
	# Posizionamento
	button.set_size(Vector2(200, 60))
	button.set_custom_minimum_size(Vector2(200, 60))
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	
	location_container.add_child(button)

func is_location_disabled(label: String) -> bool:
	var target_location = GameManager.Location[label]
	var min_level_location = null
	
	for level in GameManager.level_locations.keys():
		if GameManager.level_locations[level] == target_location:
			if min_level_location == null or level < min_level_location:
				min_level_location = level
	
	return min_level_location > GameManager.max_level_reach

func _on_level_button_pressed(label: String):
	GameManager.location_selected = GameManager.Location[label]
	get_tree().change_scene_to_file("res://Scenes/UI/LevelMenu.tscn")


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")
