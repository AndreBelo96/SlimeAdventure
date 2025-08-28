# PickupSunglasses.gd
extends PickupBase

func _ready():
	ITEM_TYPE = ItemType.MACE
	super._ready()

func on_player_enter(_player: Node) -> void:
	print("Pickup raccolto: ", ItemType.keys()[ITEM_TYPE])
	#player.add_light()
	queue_free()
