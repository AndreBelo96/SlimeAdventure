extends Node
class_name DungeonManager

var chain_frames: SpriteFrames
const chain_sfx: String = "res://Assets/Audio/Catene/ChainTransition.wav"

var chains_data = [
	{"position": Vector2(500, 360), "scale": Vector2(3.5, 3.5)},
	#{"position": Vector2(400, 300), "scale": Vector2(2, 2)},
]

var sprites_data = [
	{"texture": preload("res://Assets/Sprites/Decorations/Chains/chain_wall.png"), "position": Vector2(800, 200), "scale": Vector2(5, 5), "delay": 0.0}
]

func spawn_chains(parent: Node) -> void:
	for data in chains_data:
		var chain = AnimatedSprite2D.new()
		chain.sprite_frames = chain_frames
		chain.animation = chain_frames.get_animation_names()[0]
		chain.position = data["position"]
		chain.scale = data["scale"]
		chain.modulate = Color(0, 0, 0, 1)
		chain.stop()
		parent.add_child(chain)
		chain.frame_changed.connect(Callable(self, "_on_chain_frame_changed").bind(chain))
		
		_start_chain(chain)


func spawn_sprites(parent: Node) -> void:
	for data in sprites_data:
		var spr = Sprite2D.new()
		spr.texture = data["texture"]
		spr.position = data["position"]
		spr.scale = data["scale"]
		spr.rotation = 45;
		spr.modulate = Color(0, 0, 0, 1)
		parent.add_child(spr)


func _start_chain(chain: AnimatedSprite2D) -> void:
	chain.frame = randi() % chain_frames.get_frame_count(chain.animation)
	chain.play()

func _on_chain_frame_changed(chain: AnimatedSprite2D) -> void:
	if chain.frame == 0 or chain.frame == 18:
		if chain_sfx != "":
			SoundManager.play_sfx(chain_sfx)
