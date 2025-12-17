# PickupMace.gd
extends PickupBase

func on_ready_custom() -> void:
	item_type = ItemType.PICKAXE

func on_player_enter_custom(_player: Node) -> void:
	_player.powerup_pickaxe = true
	queue_free()
