# PortraitManager.gd
extends Node

const ATLAS = preload("res://Assets/Sprites/UI/DialogueImages.png")

const PORTRAITS = {
	"Nonno": Rect2(Vector2(0,0), Vector2(32,32)),
	"Slime_Sunglasses": Rect2(Vector2(32,0), Vector2(32,32)),
	"Slime": Rect2(Vector2(64,0), Vector2(32,32)),
}

func get_portrait(portrait_name: String) -> Texture2D:
	if not PORTRAITS.has(portrait_name):
		push_error("Portrait not found: " + portrait_name)
		return null
	var tex = AtlasTexture.new()
	tex.atlas = ATLAS
	tex.region = PORTRAITS[portrait_name]
	return tex
