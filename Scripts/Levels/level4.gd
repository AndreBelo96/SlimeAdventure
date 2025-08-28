extends "res://Scripts/Levels/LevelManager.gd"

func _ready():
	super._ready()
	set_current_level_number(4)
	
	await get_tree().create_timer(0.2).timeout

	var intro_dialogue = [
		{
			"name": "Slime", 
			"text": "Ehm… Nonno? Che cos’è quella cosa strana lì per terra? Ha due occhi finti… con il vetro davanti!",
			"portrait": PortraitManager.get_portrait("Slime")
		},
		
		{
			"name": "Nonno Slime", 
			"text": "Oh, quelli, nipotino, sono… come li chiamano… “occhiali da sole”. Li usano gli avventurieri per sembrare più… fighi... o forse per proteggersi dalla luce, non ricordo bene", 
			"portrait": PortraitManager.get_portrait("Nonno")
		},
		
		{
			"name": "Slime", 
			"text": "Avventurieri? Quelli che entrano qui a urlare “Per il tesoro!” e poi noi li sciogliamo un po’?", 
			"portrait": PortraitManager.get_portrait("Slime")
		},
		
		{
			"name": "Nonno Slime", 
			"text": "Esattamente! Sono strani esseri, sempre in cerca di gloria, ricchezze e… beh, cadaveri come questo. Ma non ti preoccupare: noi Slime siamo più saggi. Noi restiamo a casa.", 
			"portrait": PortraitManager.get_portrait("Nonno")
		},
		
		{
			"name": "Slime", 
			"text": "Nonno, e se questi occhiali avessero visto cose incredibili? Montagne altissime! Cieli sconfinati! Luoghi pieni di luce! 
			\nCosa c’è fuori da queste segrete?", 
			"portrait": PortraitManager.get_portrait("Slime")
		},
		
		{
			"name": "Nonno Slime", 
			"text": "Ehm… fuori? Beh… ci sono altre stanze… e… forse scale? Io… io non sono mai uscito, a dire il vero.", 
			"portrait": PortraitManager.get_portrait("Nonno")
		},
		
		{
			"name": "Slime", 
			"text": "Allora devo farlo io! Se questi occhiali hanno visto il mondo… io voglio vederlo con i miei occhi di slime! 
			\nNon resterò per sempre qui sotto. Voglio saltare là fuori e scoprire cosa c’è oltre queste segrete!", 
			"portrait": PortraitManager.get_portrait("Slime")
		},
		
		{
			"name": "Nonno Slime", 
			"text": "Hai lo stesso fuoco che avevo io da giovane blob… Vai, piccolo mio. Segui ciò che brilla nei tuoi occhi… 
			\nMa stai attento: là fuori non ci saranno solo torce e muffa.", 
			"portrait": PortraitManager.get_portrait("Nonno")
		},
		
		{
			"name": "Slime", 
			"text": "Allora meglio iniziare subito! 
			\nGrazie, Nonno. La mia avventura comincia… ora!", 
			"portrait": PortraitManager.get_portrait("Slime_Sunglasses")
		},
		
	]

	dialog_interface.show_dialogue(intro_dialogue)
