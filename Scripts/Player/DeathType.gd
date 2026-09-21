# DeathType.gd
# Enum per i tipi di morte dello slime
class_name DeathType

enum Type {
	SPIKES,   # Morso dalle spikes
	VOID,     # Caduta nel vuoto
	ENEMY,    # Contatto con nemico
	TIMEOUT   # Scaduto il tempo
}

const type_names := {
	Type.SPIKES: "DEATH_SPIKES",
	Type.VOID: "DEATH_VOID",
	Type.ENEMY: "DEATH_ENEMY",
	Type.TIMEOUT: "DEATH_TIMEOUT"
}

func _most_frequent_death(deaths: Dictionary) -> String:
	var best_key := ""
	var best_count := 0
	for key in deaths:
		if deaths[key] > best_count:
			best_count = deaths[key]
			best_key = key
	if best_key == "":
		return ""
	return tr(DeathType.type_names.get(int(best_key), "DEATH_UNKNOWN"))
