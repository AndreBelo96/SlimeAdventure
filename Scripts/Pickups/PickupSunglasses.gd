# PickupSunglasses.gd
extends PickupBase

func _ready():
	ITEM_TYPE = ItemType.SUNGLASSES
	super._ready()

func on_player_enter(_player: Node) -> void:
	print("Pickup raccolto: ", ItemType.keys()[ITEM_TYPE])
	SoundManager.play_sfx("res://Assets/Audio/Pickup.wav")
	#player.add_light()
	queue_free()
