# PickupSunglasses.gd
extends PickupBase

func on_ready_custom() -> void:
	item_type = ItemType.LANTERN

func on_player_enter_custom(player: Node) -> void:
	player.turn_on_lights(7.0)
	hide_temporarily()
