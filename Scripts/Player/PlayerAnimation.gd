class_name PlayerAnimation
extends Resource

const DEATH = DeathType.Type

var anim_sprite

func setup(sprite):
	anim_sprite = sprite

func play_idle():
	anim_sprite.play("Idle")

func play_death(death_type: int):
	if not anim_sprite:
		return
	
	match death_type:
		DEATH.SPIKES:
			anim_sprite.play("Death")
			SoundManager.play_sfx("res://Assets/Audio/Sound/Death.wav")
		DEATH.VOID:
			SoundManager.play_sfx("res://Assets/Audio/Sound/Death.wav")
		DEATH.ENEMY:
			anim_sprite.play("Death")
			SoundManager.play_sfx("res://Assets/Audio/Sound/Death.wav")
		DEATH.TIMEOUT:
			anim_sprite.play("Death")
			SoundManager.play_sfx("res://Assets/Audio/Sound/Death.wav")

# --- PRIVATI ---
func _play_sfx(path: String, pitch_variation: float = 0.0) -> void:
	SoundManager.play_sfx(path, 0.0, pitch_variation)

func play_move():
	anim_sprite.play("Move")
	_play_sfx("res://Assets/Audio/Sound/Jump.wav", 0.18)
