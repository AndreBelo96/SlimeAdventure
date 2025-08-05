extends Control


@onready var animation: AnimatedSprite2D = $CanvasLayer/HBoxContainer/ExampleAnimation
@onready var sprite: Sprite2D = $CanvasLayer/HBoxContainer/Arrow

# Called when the node enters the scene tree for the first time.
func _ready():
	animation.sprite_frames.set_animation_loop("UP", false)
	animation.sprite_frames.set_animation_loop("DOWN", false)
	print("GameManager valid:", is_instance_valid(GameManager))
	print("GameManager type:", typeof(GameManager))
	# Avvia la sequenza in loop
	play_sequence()

func play_sequence() -> void:
	while true:
		sprite.region_rect = Rect2(0, 0, 16, 16)
		await play_animation("UP", false, false)
		sprite.region_rect = Rect2(16, 0, 16, 16)
		await play_animation("DOWN", false, false)
		sprite.region_rect = Rect2(48, 0, 16, 16)
		await play_animation("UP", true, false)
		sprite.region_rect = Rect2(32, 0, 16, 16)
		await play_animation("DOWN", true, false)


func play_animation(animation_name: String, flip_h: bool, flip_v: bool) -> void:
	animation.flip_h = flip_h
	animation.flip_v = flip_v
	animation.play(animation_name)
	
	await animation.animation_finished
	await get_tree().create_timer(1.0).timeout


func _on_button_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	var loader = preload("res://Scenes/UI/TransitionScreen.tscn").instantiate()
	loader.scene_to_load = "res://Scenes/Levels/Level1.tscn"
	loader.transition_text = "Tutorial"
	get_tree().root.add_child(loader)
