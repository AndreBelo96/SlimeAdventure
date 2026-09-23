# PickupArmor.gd
extends PickupBase

@export var respawn := true
const GHOST_ALPHA := 0.3

func on_ready_custom() -> void:
	item_type = ItemType.ARMOR

func on_player_enter_custom(player: Node) -> void:
	if not player.give_armor():
		return
	if not respawn:
		queue_free()
		return
	_set_ghost(true)
	player.armor_changed.connect(_on_armor_changed, CONNECT_ONE_SHOT)

func _on_armor_changed(has_armor: bool) -> void:
	if not has_armor:
		_set_ghost(false)

func _set_ghost(ghost: bool) -> void:
	is_active = not ghost
	modulate.a = GHOST_ALPHA if ghost else 1.0
