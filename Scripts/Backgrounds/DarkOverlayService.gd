# Scripts/Backgrounds/DarkOverlayService.gd
extends Resource
class_name DarkOverlayService

const LEVEL_LIGHTING := {
	1:  {"dark": false, "color": Color.WHITE,             "sun_toggle": false},
	2:  {"dark": false, "color": Color.WHITE,             "sun_toggle": false},
	3:  {"dark": false, "color": Color.WHITE,             "sun_toggle": false},
	4:  {"dark": true,  "color": Color(0.3, 0.3, 0.3, 1), "sun_toggle": false},
	5:  {"dark": true,  "color": Color(0.3, 0.3, 0.3, 1), "sun_toggle": false},
	6:  {"dark": true,  "color": Color(0.3, 0.3, 0.3, 1), "sun_toggle": false},
	7:  {"dark": true,  "color": Color(0.5, 0.5, 0.5, 1), "sun_toggle": false},
	8:  {"dark": true,  "color": Color(0.5, 0.5, 0.5, 1), "sun_toggle": false},
	9:  {"dark": true,  "color": Color(0.5, 0.5, 0.5, 1), "sun_toggle": false},
	10: {"dark": true,  "color": Color(0.8, 0.8, 0.8, 1), "sun_toggle": false},
	11: {"dark": true,  "color": Color(0.8, 0.8, 0.8, 1), "sun_toggle": false},
	12: {"dark": true,  "color": Color(0.8, 0.8, 0.8, 1), "sun_toggle": false},
	13: {"dark": true,  "color": Color.WHITE,             "sun_toggle": false},
}

const DEFAULT_ENTRY := {"dark": false, "color": Color.WHITE, "sun_toggle": false}

var _runtime_overrides: Dictionary = {}

func _get_entry(level: int) -> Dictionary:
	return LEVEL_LIGHTING.get(level, DEFAULT_ENTRY)

func is_dark_level(level: int) -> bool:
	if _runtime_overrides.has(level):
		return _runtime_overrides[level]
	return _get_entry(level)["dark"]

func get_for_level(level: int) -> Color:
	return _get_entry(level)["color"]

func can_toggle_sun(level: int) -> bool:
	return _get_entry(level)["sun_toggle"]

func override_dark_state(level: int, is_dark: bool) -> void:
	if not can_toggle_sun(level):
		push_warning("override_dark_state chiamato su livello %d, che non supporta il toggle sole" % level)
		return
	_runtime_overrides[level] = is_dark

func clear_override(level: int) -> void:
	_runtime_overrides.erase(level)
