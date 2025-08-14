# Scripts/Backgrounds/DarkOverlayService.gd
extends Resource
class_name DarkOverlayService

var dark_overlay_by_level := {
	1: Color(1, 1, 1, 1),
	2: Color(1, 1, 1, 1),
	3: Color(1, 1, 1, 1),
	4: Color(0.3, 0.3, 0.3, 1),
	5: Color(0.3, 0.3, 0.3, 1),
	6: Color(0.3, 0.3, 0.3, 1),
	7: Color(0.5, 0.5, 0.5, 1),
	8: Color(0.5, 0.5, 0.5, 1),
	9: Color(0.5, 0.5, 0.5, 1),
	10: Color(0.8, 0.8, 0.8, 1),
	11: Color(0.8, 0.8, 0.8, 1),
	12: Color(0.8, 0.8, 0.8, 1),
	13: Color(1, 1, 1, 1),
}

func get_for_level(level: int) -> Color:
	return dark_overlay_by_level.get(level)
