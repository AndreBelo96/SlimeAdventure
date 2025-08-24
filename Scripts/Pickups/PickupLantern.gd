# PickupSunglasses.gd
extends PickupBase

func _ready():
	ITEM_TYPE = ItemType.LANTERN
	super._ready()

func on_player_enter(player: Node) -> void:
	print("Pickup raccolto: ", ItemType.keys()[ITEM_TYPE])
	player.set_lights_for_duration(5.0)
	queue_free()
