# PickupBase.gd
extends Node2D
class_name PickupBase

enum ItemType { NONE, SUNGLASSES, LANTERN, MACE }
var item_type: ItemType = ItemType.NONE

const float_amount := 1.0
const float_speed := 2.0

var start_y: float = 0.0
var elapsed: float = 0.0
var is_active: bool = true

func _ready():
	start_y = position.y
	on_ready_custom()

func _process(delta):
	elapsed += delta
	position.y = start_y + sin(elapsed * float_speed) * float_amount

func on_ready_custom() -> void:
	pass

func set_active(state: bool) -> void:
	is_active = state
	visible = state

func on_player_enter(player: Node) -> void:
	SoundManager.play_sfx("res://Assets/Audio/Pickup.wav")
	on_player_enter_custom(player)

func on_player_enter_custom(_player: Node) -> void:
	pass

func hide_temporarily(duration: float = 5.0) -> void:
	set_active(false)
	await get_tree().create_timer(duration).timeout
	set_active(true)
