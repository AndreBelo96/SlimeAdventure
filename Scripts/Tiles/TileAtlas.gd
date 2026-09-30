class_name TileAtlas
extends RefCounted
## Unica fonte di verità sul Logic_Tileset.
## Colonna = tipo di tile / frame. Riga = location (LocationManager.get_tileset_row).
## Le SpriteFrames si costruiscono una volta per (tile, riga) e sono condivise.

const TEXTURE := preload("res://Assets/Sprites/Tiles/Logic_Tileset.png")
const CELL := Vector2i(64, 48)
const BORDER := 1

## Mappa colonne:
##  0-6   activator (spento -> acceso)
##  7-11  spine (abbassate -> alzate)
##  12-22 sasso (12 intatto, 12-22 esplosione)
##  23-26 switch (su -> premuto)
##  27    fungo
##  28    aggancio liana
## id -> { animazione: [colonna iniziale, colonna finale, fps] }
const ANIMATIONS := {
	"activator":    {"Activate": [0, 6, 30.0], "Deactivate": [6, 0, 30.0]},
	"spike":        {"default": [11, 11, 1.0]},
	"spike_step":   {"UP": [7, 11, 10.0], "DOWN": [11, 7, 10.0]},
	"spike_switch": {"ON": [7, 11, 10.0], "OFF": [11, 7, 10.0]},
	"wall":         {"default": [12, 12, 1.0], "EXPLOSION": [12, 22, 10.0]},
	"switch":       {"PRESSED": [23, 26, 30.0], "UNPRESSED": [26, 23, 30.0]},
	"mushroom":     {"default": [27, 27, 1.0]},
	"vine_anchor":  {"default": [28, 28, 1.0]},
}

static var _cache := {}

static func get_frames(id: String, row: int) -> SpriteFrames:
	var key := "%s:%d" % [id, row]
	if not _cache.has(key):
		_cache[key] = _build(ANIMATIONS[id], row)
	return _cache[key]

static func region(col: int, row: int) -> Rect2:
	var block := CELL + Vector2i(BORDER, BORDER) * 2
	return Rect2(Vector2(col * block.x + BORDER, row * block.y + BORDER), CELL)

static func _build(anims: Dictionary, row: int) -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	for anim_name in anims:
		var a: Array = anims[anim_name]
		frames.add_animation(anim_name)
		frames.set_animation_speed(anim_name, a[2])
		frames.set_animation_loop(anim_name, false)
		var step := 1 if a[1] >= a[0] else -1
		for col in range(a[0], a[1] + step, step):
			var tex := AtlasTexture.new()
			tex.atlas = TEXTURE
			tex.region = region(col, row)
			frames.add_frame(anim_name, tex)
	return frames
