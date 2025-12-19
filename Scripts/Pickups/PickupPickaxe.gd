# PickupPickaxe.gd
extends PickupBase

func on_ready_custom() -> void:
	item_type = ItemType.PICKAXE

func on_player_enter_custom(_player: Node) -> void:
	#_player.powerup_pickaxe = true # Meglio sul gameManager, dato che è una cosa da portarsi dietro nel gioco, ogni volta che accendo
	queue_free()
