extends Node2D

@onready var animation: AnimatedSprite2D = $ExampleAnimation
@onready var sprite: Sprite2D = $Arrow

func _ready():
	animation.sprite_frames.set_animation_loop("UP", false)
	animation.sprite_frames.set_animation_loop("DOWN", false)
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
