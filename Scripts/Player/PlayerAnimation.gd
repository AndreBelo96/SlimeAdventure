class_name PlayerAnimation
extends Resource

const DeathType = preload("res://Scripts/Player/DeathType.gd").DeathType

var anim_sprite

func setup(sprite):
	anim_sprite = sprite

func play_idle():
	anim_sprite.play("Idle")

func play_move():
	anim_sprite.play("Move")
	SoundManager.play_sfx("res://Assets/Audio/Jump.wav")

func play_death(death_type: int):
	if not anim_sprite:
		return
	
	match death_type:
		DeathType.SPIKES:
			anim_sprite.play("Death")
			SoundManager.play_sfx("res://Assets/Audio/Death.wav")
		DeathType.VOID:
			#anim_sprite.play("Death")
			SoundManager.play_sfx("res://Assets/Audio/Death.wav")
		DeathType.ENEMY:
			anim_sprite.play("Death")
			SoundManager.play_sfx("res://Assets/Audio/Death.wav")
		DeathType.TIMEOUT:
			anim_sprite.play("Death")
			SoundManager.play_sfx("res://Assets/Audio/Death.wav")
