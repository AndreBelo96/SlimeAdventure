extends Node2D
class_name PickupBase

enum ItemType { NONE, SUNGLASSES, LANTERN, MACE }
var ITEM_TYPE: ItemType = ItemType.NONE

const float_amount := 1.0
const float_speed := 2.0

var start_y: float = 0.0
var elapsed: float = 0.0

func _ready():
	print("Creazione pickup: ", ItemType.keys()[ITEM_TYPE])
	start_y = position.y

func _process(delta):
	elapsed += delta
	position.y = start_y + sin(elapsed * float_speed) * float_amount

func on_player_enter(_player: Node) -> void:
	pass
