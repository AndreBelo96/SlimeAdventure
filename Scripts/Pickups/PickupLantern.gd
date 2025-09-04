# PickupSunglasses.gd
extends PickupBase

func _ready():
	ITEM_TYPE = ItemType.LANTERN
	super._ready()

func on_player_enter(player: Node) -> void:
	print("Pickup raccolto: ", ItemType.keys()[ITEM_TYPE])
	SoundManager.play_sfx("res://Assets/Audio/Pickup.wav")
	player.set_lights_for_duration(7.0)
	_hide_temporarily()

func _hide_temporarily() -> void:
	set_active(false)
	await get_tree().create_timer(5.0).timeout
	set_active(true)
