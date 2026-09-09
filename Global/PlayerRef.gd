extends Node
## Riferimento centralizzato al player corrente del livello.
## Il Player si registra da solo in _ready(); tutti gli altri leggono PlayerRef.player.

var player: Node = null

func register(p: Node) -> void:
	player = p

func clear(p: Node) -> void:
	if player == p:
		player = null
