class_name PlayerAnimation
extends Resource

const DEATH = DeathType.Type

var anim_sprite

func setup(sprite):
	anim_sprite = sprite

func play_idle():
	anim_sprite.play("Idle")

func play_move():
	anim_sprite.play("Move")
	_play_sfx("res://Assets/Audio/Jump.wav")

func play_death(death_type: int):
	if not anim_sprite:
		return
	
	match death_type:
		DEATH.SPIKES:
			anim_sprite.play("Death")
			SoundManager.play_sfx("res://Assets/Audio/Death.wav")
		DEATH.VOID:
			SoundManager.play_sfx("res://Assets/Audio/Death.wav")
		DEATH.ENEMY:
			anim_sprite.play("Death")
			SoundManager.play_sfx("res://Assets/Audio/Death.wav")
		DEATH.TIMEOUT:
			anim_sprite.play("Death")
			SoundManager.play_sfx("res://Assets/Audio/Death.wav")


# --- PRIVATI ---
func _play_sfx(path: String) -> void:
	SoundManager.play_sfx(path)
