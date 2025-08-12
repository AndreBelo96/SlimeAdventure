extends Control


@export var scene_to_load: String
@export var transition_text: String = "Caricamento..."
@export var location_id: int = 0

@onready var animation_player = $CanvasLayer/AnimationPlayer
@onready var animated_sprite =$CanvasLayer/AnimatedSprite2D
@onready var sprite =$CanvasLayer/Sprite

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	$CanvasLayer/Titolo.text = transition_text

	match location_id:
		GameManager.Location.TUTORIAL:
			animated_sprite.visible = false
			sprite.visible = false
		GameManager.Location.DUNGEON:
			animated_sprite.visible = true
			var second_sprite: AnimatedSprite2D = animated_sprite.duplicate()
			second_sprite.position = Vector2(350, 300)
			second_sprite.scale = Vector2(0.8, 0.8)
			second_sprite.animation = animated_sprite.animation
			second_sprite.play()
			$CanvasLayer.add_child(second_sprite)
			sprite.visible = false
		GameManager.Location.FOREST:
			animated_sprite.visible = false # <-- inserisci altro
			sprite.visible = false

	# Fade in
	animation_player.play("FadeIn")
	await animation_player.animation_finished
	
	await get_tree().create_timer(2).timeout

	# Fade out
	animation_player.play("FadeOut")
	await animation_player.animation_finished

	# Carica la scena e sostituisci l'attuale
	var packed_scene = load(scene_to_load)
	get_tree().change_scene_to_packed(packed_scene)
	
	# Questo nodo non serve più
	queue_free()
