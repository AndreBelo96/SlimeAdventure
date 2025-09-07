# Logger.gd
extends Node

var SAVE_PATH = "user://game_log.txt"

func write_log(level: String, message: String) -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ_WRITE)
	if file:
		file.seek_end()
		var timestamp = _get_timestamp()
		file.store_line("[%s] [%s] %s" % [timestamp, level, message])
		file.close()


func _get_timestamp() -> String:
	var dt = Time.get_datetime_dict_from_system()
	return "%04d-%02d-%02d %02d:%02d:%02d" % [
		dt.year, dt.month, dt.day,
		dt.hour, dt.minute, dt.second
	]

# --- Livelli di log ---
func info(message: String) -> void:
	write_log("INFO", message)

func warn(message: String) -> void:
	write_log("WARN", message)

func error(message: String) -> void:
	write_log("ERROR", message)
