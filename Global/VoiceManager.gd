extends Node

const SLIME = "Slime"
const NONNO = "Nonno Slime"
const DEFAULT = "Default"

const SPEEDS = {
	SLIME: 2,
	NONNO: 6,
	DEFAULT: 3,
}

static func get_speed(character: String) -> int:
	return SPEEDS.get(character, SPEEDS[DEFAULT])
