# ThemeManager.gd
extends Node

var LOCATION_RESULT_BG_COLORS := {
	LocationManager.Location.TUTORIAL: Color("4a4a4aff"),
	LocationManager.Location.DUNGEON: Color("#0f121a"),
	LocationManager.Location.FOREST: Color("124616ff")
}

var LOCATION_ACCENT_COLORS := {
	LocationManager.Location.TUTORIAL: {"border": Color("#dcdcdc"), "name": Color("#959595"), "text": Color("#dcdcdc")},
	LocationManager.Location.DUNGEON:  {"border": Color("#adb4cb"), "name": Color("#38477a"), "text": Color("#adb4cb")},
	LocationManager.Location.FOREST:   {"border": Color("#43a047"), "name": Color("#1b5e20"), "text": Color("#2e7d32")}
}

var BUTTON_THEMES := {
	LocationManager.Location.TUTORIAL: preload("res://Theme/Button/TutorialButton.tres"),
	LocationManager.Location.DUNGEON: preload("res://Theme/Button/DungeonButton.tres")
}
const DEFAULT_THEME := preload("res://Theme/DefaultButton.tres")

var BUTTON_SOUNDS := {
	LocationManager.Location.TUTORIAL: "res://Assets/Audio/Sound/TutorialBtnClick.wav",
	LocationManager.Location.DUNGEON: "res://Assets/Audio/Sound/TutorialBtnClick.wav"  #TODO da fare, suono dungeon vero
}
const DEFAULT_SOUND = "res://Assets/Audio/Sound/DefaultBtnClick.wav"

func get_theme_for_location_type(location_type: int) -> Theme:
	return BUTTON_THEMES.get(location_type, DEFAULT_THEME)

func get_sound_for_location_type(location_type: int) -> String:
	return BUTTON_SOUNDS.get(location_type, DEFAULT_SOUND)

func get_result_bg_color_for_level(level: int) -> Color:
	var loc : LocationManager.Location = LocationManager.get_location_for_level(level)
	return LOCATION_RESULT_BG_COLORS.get(loc, Color.WHITE)

func get_accent_colors_for_level(level: int) -> Dictionary:
	var loc : LocationManager.Location = LocationManager.get_location_for_level(level)
	return LOCATION_ACCENT_COLORS.get(loc, {})
