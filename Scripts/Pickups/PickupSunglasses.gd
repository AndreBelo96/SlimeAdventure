# PickupSunglasses.gd
extends PickupBase

func _ready():
	ITEM_TYPE = ItemType.SUNGLASSES
	super._ready()

func on_player_enter(player: Node) -> void:
	print("Pickup raccolto: ", ItemType.keys()[ITEM_TYPE])
	#player.add_light()
	queue_free()
