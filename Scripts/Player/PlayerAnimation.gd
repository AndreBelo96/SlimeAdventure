class_name PlayerAnimation
extends Resource

const DeathType = preload("res://Scripts/Player/DeathType.gd").DeathType

var anim_sprite
var audio_player

func setup(sprite, audio):
	anim_sprite = sprite
	audio_player = audio

func play_idle():
	anim_sprite.play("Idle")

func play_move():
	anim_sprite.play("Move")
	audio_player.stream = preload("res://Assets/Audio/Jump.wav")
	audio_player.play()

func play_death(death_type: int):
	if not anim_sprite:
		return
	
	match death_type:
		DeathType.SPIKES:
			anim_sprite.play("Death")
			audio_player.stream = preload("res://Assets/Audio/Death.wav")
		DeathType.VOID:
			anim_sprite.play("Death")
			audio_player.stream = preload("res://Assets/Audio/Death.wav")
		DeathType.ENEMY:
			anim_sprite.play("Death")
			audio_player.stream = preload("res://Assets/Audio/Death.wav")
		DeathType.TIMEOUT:
			anim_sprite.play("Death")
			audio_player.stream = preload("res://Assets/Audio/Death.wav")
	
	audio_player.play()
