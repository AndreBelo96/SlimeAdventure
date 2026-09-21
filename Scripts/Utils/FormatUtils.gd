class_name FormatUtils
extends RefCounted

## MM:SS — tempo di un singolo livello
static func format_time_short(seconds: float) -> String:
	var total := int(seconds)
	@warning_ignore("integer_division")
	var minutes := total / 60
	return "%02d:%02d" % [minutes, total % 60]

## HH:MM:SS — tempi aggregati
static func format_time_long(seconds: float) -> String:
	var total := int(seconds)
	@warning_ignore("integer_division")
	var hours := total / 3600
	@warning_ignore("integer_division")
	var minutes := (total % 3600) / 60
	return "%02d:%02d:%02d" % [hours, minutes, total % 60]

static func sum_deaths(deaths: Dictionary) -> int:
	var total := 0
	for v in deaths.values():
		total += v
	return total
