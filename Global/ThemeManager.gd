# ThemeManager.gd
extends Node

const BUTTON_THEMES := {
	GameManager.Location.TUTORIAL: preload("res://Theme/TutorialButton.tres"),
	GameManager.Location.DUNGEON: preload("res://Theme/DungeonButton.tres")
}

const BUTTON_SOUNDS := {
	GameManager.Location.TUTORIAL: "res://Assets/Audio/TutorialBtnClick.wav",
	GameManager.Location.DUNGEON: "res://Assets/Audio/TutorialBtnClick.wav"
}

const DEFAULT_SOUND = "res://Assets/Audio/DefaultBtnClick.wav"

func get_theme_for_location_type(location_type: int) -> Theme:
	return BUTTON_THEMES.get(location_type, null)

func get_sound_for_location_type(location_type: int) -> String:
	return BUTTON_SOUNDS.get(location_type, DEFAULT_SOUND)
