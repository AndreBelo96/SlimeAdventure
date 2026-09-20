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
	Type.SPIKES: "Spuntoni",
	Type.VOID: "Vuoto",
	Type.ENEMY: "Nemici",
	Type.TIMEOUT: "Tempo scaduto"
}
