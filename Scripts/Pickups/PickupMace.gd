# PickupMace.gd
extends PickupBase

func on_ready_custom() -> void:
	item_type = ItemType.MACE

func on_player_enter_custom(_player: Node) -> void:
	#player.add_mace()
	queue_free()
