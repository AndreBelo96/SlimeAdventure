# Scripts/Backgrounds/DarkOverlayService.gd
extends Resource
class_name DarkOverlayService


# Mappa dei livelli -> colore overlay
const DARK_OVERLAY_BY_LEVEL := {
	1: Color.WHITE,
	2: Color.WHITE,
	3: Color.WHITE,
	4: Color(0.3, 0.3, 0.3, 1),
	5: Color(0.3, 0.3, 0.3, 1),
	6: Color(0.3, 0.3, 0.3, 1),
	7: Color(0.5, 0.5, 0.5, 1),
	8: Color(0.5, 0.5, 0.5, 1),
	9: Color(0.5, 0.5, 0.5, 1),
	10: Color(0.8, 0.8, 0.8, 1),
	11: Color(0.8, 0.8, 0.8, 1),
	12: Color(0.8, 0.8, 0.8, 1),
	13: Color.WHITE,
}

const DEFAULT_COLOR: Color = Color.WHITE

func get_for_level(level: int) -> Color:
	return DARK_OVERLAY_BY_LEVEL.get(level, DEFAULT_COLOR)
