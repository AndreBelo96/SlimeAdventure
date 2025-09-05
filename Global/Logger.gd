# Logger.gd
extends Node

var log_file_path = "user://game_log.txt"

func write_log(level: String, message: String) -> void:
	var file := FileAccess.open(log_file_path, FileAccess.READ_WRITE)
	if file:
		file.seek_end()  # append
		var timestamp = _get_timestamp()
		file.store_line("[%s] [%s] %s" % [timestamp, level, message])
		file = null

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
