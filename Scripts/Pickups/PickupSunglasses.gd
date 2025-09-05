# PickupSunglasses.gd
extends PickupBase

func on_ready_custom() -> void:
	item_type = ItemType.SUNGLASSES

func on_player_enter_custom(_player: Node) -> void:
	# Esegui eventuale effetto specifico
	queue_free()
