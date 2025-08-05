Struttura:

res://
├── Scenes/
│   ├── Main.tscn                  # Entry point del gioco
│   ├── UI/                        # Scene UI e HUD
│   │   ├── HUD.tscn
│   │   └── EndScreen.tscn
│   ├── Levels/                    # Ogni livello ha la sua scena
│   │   ├── Level_01.tscn
│   │   ├── Level_02.tscn
│   │   └── ...
│   └── Tiles/                     # Scene dei vari tipi di tile
│       ├── TileBase.tscn
│       ├── ActivationTile.tscn
│       ├── SpikeTile.tscn
│       ├── IceTile.tscn
│       └── BreakableTile.tscn
│
├── Player/
│   ├── Player.tscn
│   └── Player.gd
│
├── Scripts/
│   ├── GameManager.gd             # Controlla progressi, punteggio, ecc.
│   ├── LevelLogic.gd              # Script generico da attaccare ai livelli
│   ├── Tile/                      # Script tile-specifici
│   │   ├── TileBase.gd
│   │   ├── ActivationTile.gd
│   │   └── ...
│   └── UI/
│       ├── HUD.gd
│       └── EndScreen.gd
│
├── Assets/
│   ├── Sprites/
│   │   ├── Player/
│   │   └── Tiles/
│   ├── Fonts/
│   └── Audio/
│
└── Global/
	└── Autoload/
		└── Globals.gd             # Singleton opzionale per stats, retry, ecc.
		
Struttura livelli Dungeons:
	
	🗺️ Schema Livelli con Tematiche e Progressione
Ogni livello include suggerimenti su direzioni, narrazione e continuità visiva. Le scale sono suggerite nei livelli 3, 6, 9, per simulare un’ascesa nella struttura.

🔹 Livello 1: Risveglio
Tema: La cella. Buio, angusto.

Meccaniche: solo tile attivabili.

Narrativa: "Dove sono...?"

Uscita: Verso sud-est.

Estetica: Muri incrinati, letto, catene.

🔹 Livello 2: Primo pericolo
Tema: Corridoio post-cella.

Meccaniche: Spine fisse.

Narrativa: “Qualcosa non va... queste trappole...”

Entrata: Nord-ovest, Uscita: Sud-est.

Estetica: Grate, torcia a muro, pozzanghere.

🔹 Livello 3: Rovine
Tema: Celle crollate.

Meccaniche: Macerie, buche.

Narrativa: "Il tempo ha distrutto anche queste mura..."

Estetica: Blocchi crollati, ossa, muffa.

Uscita: Una scala verso l’alto (si sale).

🔹 Livello 4: Trappole a tempo
Tema: Sala delle spine mobili.

Meccaniche: Spine a tempo.

Narrativa: "Ogni passo potrebbe essere l’ultimo."

Entrata: Scala da sotto, uscita: verso destra.

Estetica: Pavimenti rotti, meccanismi a parete.

🔹 Livello 5: Il primo enigma
Tema: Stanza di guardia.

Meccaniche: spine fisse + a tempo, tile attivabili in percorsi forzati.

Narrativa: “Era una trappola fin dall’inizio.”

Estetica: Torce, oggetti da guardia (armi rotte, scudi, panchine).

Uscita: verso sinistra.

🔹 Livello 6: Il buio
Tema: Archivi sotterranei/prigioniere dimenticate.

Meccaniche: Buio + torce.

Narrativa: "Non vedo niente... devo seguire la luce."

Estetica: Scaffali distrutti, ragnatele, urla lontane.

Entrata: Da sinistra, uscita con scala.

🔹 Livello 7: Memoria e Paura
Tema: Prigione abbandonata + trappole nel buio.

Meccaniche: Buio + spine fisse.

Narrativa: “Devo ricordare… o morirò.”

Estetica: Graffiti, sangue secco, celle aperte.

Uscita: verso destra.

🔹 Livello 8: Sala della sentenza
Tema: Grande sala, simile a un'arena.

Meccaniche: Tutte combinate.

Narrativa: “È questa l’uscita?... No, qualcosa non va.”

Estetica: Colonne, segni di lotte, oggetti cerimoniali.

Uscita: Verso sinistra o giù.

🔹 Livello 9: Fuga verticale
Tema: Torre interna/prigione alta.

Meccaniche: Percorsi lunghi e verticali, spine, torce, blocchi.

Narrativa: "Ancora più in alto..."

Cutscene suggerita: Ascensore o scale animate.

Estetica: Struttura più ordinata, con segni di via di fuga (frecce, luci).

Uscita: Grandi porte verso il boss.

🔴 Livello 10: Il Guardiano delle Catene
Tema: Arena del boss.

Meccanica: Boss puzzle. Ogni tot passi il boss attiva spine o spara catene. Può bloccare tile attivabili o crearne di false.

Narrativa: “Libertà… a un passo dalla morte.”

Estetica: Enorme statua centrale, catene ovunque, luce dall’alto.

🌟 Idee Extra: Estetica e Atmosfera
Dettagli per arricchire i livelli:
Celle con cadaveri o resti.

Griglie sul pavimento da cui esce vapore.

Urla lontane o rumori ambientali.

Catene penzolanti animate.

Oggetti interattivi: scritte sul muro, diari (dialoghi).

Tile false: sembrano solide, ma sono buchi.

Tile trappola: se attivata, disattiva tutte le altre o fa comparire spine.
	
