extends Control


@export var scene_to_load: String
@export var transition_text: String = "Caricamento..."

@onready var animation_player = $CanvasLayer/AnimationPlayer

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	$CanvasLayer/Titolo.text = transition_text

	# Fade in
	animation_player.play("FadeIn")
	await animation_player.animation_finished
	
	await get_tree().create_timer(0.5).timeout

	# Fade out
	animation_player.play("FadeOut")
	await animation_player.animation_finished

	# Carica la scena e sostituisci l'attuale
	var packed_scene = load(scene_to_load)
	get_tree().change_scene_to_packed(packed_scene)
	
	# Questo nodo non serve più
	queue_free()
