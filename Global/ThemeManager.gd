# ThemeManager.gd
extends Node

const BUTTON_THEMES := {
	GameManager.Location.TUTORIAL: preload("res://Theme/TutorialButton.tres"),
	GameManager.Location.DUNGEON: preload("res://Theme/DungeonButton.tres")
}

func get_theme_for_location_type(location_type: int) -> Theme:
	return BUTTON_THEMES.get(location_type, null)
