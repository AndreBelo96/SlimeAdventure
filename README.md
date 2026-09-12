## Architettura del Progetto

### Struttura cartelle Scripts

```
Global/
  SceneNavigator.gd       ← autoload, transizioni di scena/menu (ex GameManager)
  LevelStateManager.gd     ← autoload, stato run corrente (livello, tempo, passi, morti, slot)
  LocationManager.gd       ← autoload, mapping livello↔location, tileset, dark overlay (delega a DarkOverlayService).
							 NON ha class_name (non può averlo: conflitto col nome dell'autoload stesso).
  GameLogger.gd           ← autoload, logging su file. write_log() ora crea il file se non esiste (prima falliva
                             silenziosamente se user://game_log.txt non era ancora stato creato).
  SaveManager.gd           ← autoload, salvataggio slot
  SettingsManager.gd      ← autoload, impostazioni
  SoundManager.gd          ← autoload, musica/sfx. `play_sfx(path, volume_db=0.0, pitch_variation=0.0)` e
                             `play_environment(path, pitch_variation=0.0)` hanno un parametro opzionale
                             `pitch_variation` (0.0 = nessuna variazione). Se > 0, applica un `pitch_scale`
                             random in `[1-variation, 1+variation]`. In uso su: Jump.wav (0.18), Bounce.wav (0.08),
                             Fall.wav (0.06), SmashStone.wav (0.08), suoni ambientali (0.1). Torce: pitch fisso
                             per istanza (non per-riproduzione, essendo loop persistenti) via `BaseTorch.pitch_variation`
                             applicato una volta in `_ready()`. Volutamente NON applicato ai suoni UI/menu
                             (SFX_MOVE/CONFIRM). `play_music()` non ha più variabili `tween` in scope annidati
                             confusi (rinominate `fade_out_tween`/`fade_in_tween`).
  DisplayManager.gd        ← autoload, fullscreen/risoluzione. Usa `is_fullscreen` come intero a 3 stati (0/1/2),
                             MA `SettingsManager.fullscreen` è un `bool` e `OptionMenu.do_fullscreen()/do_windowed()`
                             chiamano `DisplayServer` direttamente, bypassando questo autoload. Sembra scollegato
                             dal resto del flusso impostazioni — vedi "Bug aperti / in verifica".
  PortraitManager.gd      ← autoload, ritratti dialoghi
  VoiceManager.gd          ← autoload, velocità voci
  ThemeManager.gd          ← autoload, UNICA fonte di temi/suoni bottoni per location + colori centralizzati
                             (LOCATION_RESULT_BG_COLORS, LOCATION_ACCENT_COLORS). BUTTON_THEMES/BUTTON_SOUNDS/
                             LOCATION_*_COLORS sono `var` (non `const`): usano `LocationManager.Location.*` come
                             chiave, e un autoload senza class_name non è risolvibile a tempo di compilazione.
  GridUtils.gd             ← autoload, utility griglia isometrica
  PlayerRef.gd             ← autoload NUOVO. Riferimento centralizzato al player corrente: `Player.gd._ready()`
                             chiama `PlayerRef.register(self)` (e `_exit_tree()` chiama `PlayerRef.clear(self)`).
                             Tutti gli script che prima facevano `get_tree().get_first_node_in_group("player")`
                             (Wip.gd, TileSwitch.gd, TileSpikeSwitch.gd, DungeonBoss.gd) ora leggono `PlayerRef.player`
                             live, senza cache locale (per non rischiare di catturare `null` se il player non si è
                             ancora registrato). Nota: è un service locator, non vera dependency injection come
                             `setup_level_logic()` — scelto perché i 4 chiamanti hanno basi/lifecycle troppo
							 diversi (Resource, Node2D standalone, TileBase) per un'iniezione comune pulita.

Presets/
  AudioPresets.gd        ← costanti percorsi audio. Copre musica/ambient + SFX ripetuti in più file:
							 SMASH_STONE, ACTIVATE_SPINE, DEACTIVATE_SPINE, DEATH, BOSS_HIT. Percorsi SFX usati
							 una sola volta restano stringhe letterali sul posto (scelta consapevole, non ogni
							 singolo path merita una costante).

Scripts/
  Levels/
	LevelManager.gd      ← base scene livello (Node2D); setup_background() data-driven via LocationManager.get_background_generator_for_level().
							 Helper condivisi dai level script: dlg(...) costruisce una riga di dialogo;
							 play_intro(lines, delay_before=0.0) mostra il dialogo, avvia time_running e musica.
							 check_unlock_exit_condition() (ex check_victory_condition, sblocca l'uscita quando
                             la condizione vittoria è soddisfatta) e check_player_reached_exit() (ex check_victory,
                             controlla se il player è fisicamente sopra il tile uscita) — nomi ora distinti e
                             non più ambigui. Gruppo porte rinominato `"doors"` (ex `"porte"`).
    LevelLogic.gd        ← orchestratore turni/tile/nemici; _connect_all_tiles() inietta level_logic nelle tile che espongono setup_level_logic()
    LevelTileManager.gd  ← conta tile attive, gestisce vittoria tile. Variabile locale `nodo`→`node` nel loop di
                             assegnazione custom data (assign_keys). Gruppi controllati: `"spikes"`/`"switches"`
                             (ex `"spine"`/`"interruttori"`). NOTA: `chiave`/`azione` (nomi custom data layer del
                             TileSet + variabili passate a runtime) sono ancora in italiano — vedi Next Steps.
    SwitchSpikeHandler.gd ← logica switch→spine (Resource). Gruppi `"spikes"`/`"switches"` aggiornati. `chiave`/
                             `azione`/valori stringa `"attiva"`/`"disattiva"` ancora da tradurre — vedi Next Steps.
    EnemyTurnHandler.gd  ← logica turno nemici (Resource). get_tile_under_enemy() ora usa `TileSpatialIndex`
                             (cache lazy per posizione griglia) invece di scansione lineare con confronto distanze
                             a ogni chiamata — stesso pattern di `Pathfinder`, condiviso tramite la classe comune.
    Camera.gd            ← player cachato in @onready, non più letto da path ogni frame
    level1.gd, level2.gd, level3.gd, level5.gd, level7.gd, level9.gd ← data-driven: usano dlg()/play_intro()
    level4.gd            ← stesso pattern data-driven, dialogo lungo (9 righe, Slime + Nonno)
    level6.gd, level8.gd, level10/11/12.gd ← invariati, nessun dialogo (solo setup ambient/musica + time_running = true)
    level13.gd            ← invariato, boss intro troppo custom per rientrare in play_intro()

  Player/
    Player.gd            ← orchestratore (Node2D). lock_input()/unlock_input() a CONTATORE (_input_lock_count).
                             _ready() ora si registra su `PlayerRef` (vedi Global/PlayerRef.gd sopra).
                             Flag _terminal_state, settato in on_player_died()/on_player_won(), impedisce a
                             qualsiasi unlock_input() di riattivare i controlli dopo morte/vittoria — vedi
							 "Bug aperti / in verifica" per l'interazione tra i due meccanismi.
							 Segnale `light_time_changed` RIMOSSO (era dichiarato ma mai emesso né connesso
							 da nessuna parte — dead code, non una feature incompleta da recuperare).
	PlayerInput.gd       ← Resource
	PlayerMovement.gd    ← Resource (griglia, salto, bounce). find_child_at_coords() scansiona ANCORA
							 linearmente i children ad ogni chiamata, senza cache — NON toccato in questo giro
							 (solo EnemyTurnHandler/Pathfinder hanno ricevuto TileSpatialIndex). Se si vuole
							 coerenza totale, stesso pattern applicabile qui — vedi Next Steps.
	PlayerInteraction.gd ← Resource (tile/pickup under player). _get_tile_under_player()/_get_pickup_under_player()
							 stessa scansione lineare non cachata, stessa nota di cui sopra — NON toccato.
	PlayerAnimation.gd   ← Resource. play_death() semplificato: 3 branch identici (SPIKES/ENEMY/TIMEOUT) collassati
							 in un unico `if death_type != DEATH.VOID: anim_sprite.play("Death")` + suono comune
							 (`AudioPresets.DEATH`) sempre eseguito; solo VOID salta l'animazione.
    PlayerLight.gd       ← Resource
    DeathType.gd         ← enum morti

  Tiles/
    TileBase.gd          ← classe base (Node2D scene-as-tile). NON espone on_enemy_enter() (ISP). Segnale
                             `state_changed` marcato `@warning_ignore("UNUSED_SIGNAL")` (è emesso da una
							 sottoclassse, TileSpikeSwitch, non dalla base stessa — falso positivo dell'analisi
							 statica di Godot, non codice morto).
	TileActivator.gd     ← tile attivabile, cuore del gameplay. _create_animations() ora usa un helper condiviso
							 `_add_frame_animation(frames, anim_name, row, columns)` invece di due loop quasi
							 identici (range diretto per "Activate", `range(6,-1,-1)` per "Deactivate").
	TileNormal.gd
	TileWall.gd          ← `isBreak`→`is_broken`, `peso`→`weight` (nome ancora da fare, vedi Next Steps: solo i
							 gruppi sono stati rinominati finora, le proprietà tile restano il prossimo giro)
	TileSpike.gd         ← implementa on_enemy_enter(). `isUp`/`peso` ancora in italiano-stile, vedi Next Steps.
	TileSpikeStep.gd     ← spine che si attivano ogni N step; implementa on_enemy_enter() e setup_level_logic().
							 **Decisione presa**: NON blocca l'input del player durante l'animazione UP/DOWN
							 (provato, risultava fastidioso da giocare ogni ~3 passi) — rischio di desync da
							 doppio input rapido accettato, vedi "Bug aperti / in verifica".
	TileSpikeSwitch.gd   ← spine controllate da switch; implementa on_enemy_enter(). Usa `_play_locked()` con
							 `PlayerRef.player.lock_input()`/`unlock_input()` (ex group lookup diretto). Gruppo
							 `add_to_group("spikes")` (ex `"spine"`). `chiave`/`azione`/`attivo`/`attiva()`/
							 `disattiva()` ancora in italiano — vedi Next Steps.
	TileSwitch.gd        ← switch che attiva/disattiva spine. Stesso `PlayerRef` per il player. Gruppo
							 `add_to_group("switches")` (ex `"interruttori"`).
	TileBorder.gd / TileFlipBorder.gd

  Enemy/Boss/
	BaseBoss.gd (class_name EnemyBase) ← classe base nemici. take_turn() fa push_error se non overridato.
							 breath()/damage_animation()/change_steps() hook opzionali no-op. level_logic
							 iniettato via setup_level_logic(). `vita`→`health_points` (esposta a LevelManager
							 per la HP bar del boss). `posizione_tile`→`grid_position`. Segnale `finished_turn`
							 marcato `@warning_ignore("UNUSED_SIGNAL")` (emesso da DungeonBoss, sottoclasse —
							 falso positivo, non dead code).
							 **take_damage() chiama damage_animation() SENZA await** — vedi "Bug aperti / in
							 verifica", non risolto in questo giro.
	DungeonBoss.gd       ← boss del dungeon (livello 13). movement_map/visual_map/warning_tile_scene/
							 ceiling_debris_scene/starting_health/starting_grid_position/effects_layer ora tutti
							 `@export` (prima hardcodati/path fissi) — assegnati nell'Inspector sulla scena del
                             livello 13. `_show_attack_warning()` (in `BossAttack`, Resource) aggiunge i warning
                             tile a `effects_layer` (Node2D dedicato aggiunto in `Level13.tscn`), non più a
                             `get_tree().current_scene`. damage_animation() usa `PlayerRef.player.lock_input()`/
                             `unlock_input()` (ex `slime.` group lookup) e `VisualEffects.flash()` per il glow
                             danno (ex `Color(2,2,2)` letterale, vedi VisualEffects.gd sotto). Va ancora
                             verificato che il flash/lock venga davvero atteso da take_damage() (vedi sopra).

  Pickups/
    PickupBase.gd        ← `posizione_tile` ancora in italiano — vedi Next Steps (stesso nome usato in EnemyBase,
                             quindi la rinomina a `grid_position` va fatta in entrambe le classi insieme).
    PickupLantern.gd / PickupSunglasses.gd / PickupPickaxe.gd

  Decorations/
    Interactive/Doors/   ← PortaBase (class_name ancora italiano) + PortaN/S/E/W (da unificare, vedi Next Steps
                             punto 2). Gruppo rinominato `"doors"` (ex `"porte"`).
    Interactive/Torch/   ← BaseTorch, Torch, BackWallTorch. **`is_on` inizializzato a `true` di default**: bug
                             non risolto, vedi "Bug aperti / in verifica". Aggiunto `pitch_variation` (@export,
                             default 0.1): ogni torcia riceve un pitch fisso e diverso dalle altre, assegnato una
                             volta in `_ready()` (non ri-randomizzato a ogni accensione, essendo un loop persistente).
    Warning/WarningTile.gd
    Particelle/CeilingDebris.gd

  Backgrounds/
    BackgroundManager.gd
    IBackgroundGenerator.gd  ← interfaccia
    PanelBackgroundGenerator.gd
    SkullBackgroundGenerator.gd
    DarkOverlayService.gd    ← LEVEL_LIGHTING: dizionario per-livello unificato (dark/color/sun_toggle) + override_dark_state() (hook per gimmick futura sole on/off)

  UI/
    MainMenu/
	  SelectableMenu.gd       ← NUOVA classe base comune (Control), nata dall'unione di BaseMenu.gd +
								 SelectableMenuPanel.gd (erano quasi duplicate al 100%). Contiene: buttons/
								 selectors/current_selection/base_positions/input_enabled, _ready()/
								 _unhandled_input(), setup_languages()/setup_buttons()/setup_selectors()/
								 handle_selection() (da overridare), handle_navigation()/change_selection()
								 (default verticale con clamp, silenzioso se già al limite), _connect_mouse(),
								 set_current_selection(), _start_tween() (bounce selettori, loop **finito ma
								 alto** `set_loops(100000)` invece di infinito — evita il bug noto del motore
								 "Infinite loop detected" su frame con delta anomalo, es. subito dopo un
								 caricamento scena), calibrate_positions().
								 **`BaseMenu.gd` ELIMINATO**: non aggiungeva nulla sopra `SelectableMenu` (i
								 gruppi extra `buttons_save`/`buttons_location`/ecc. erano dead code, mai
								 popolati da nessuna sottoclasse) e non era referenziato altrove.
	  SelectableMenuPanel.gd  ← ora extends SelectableMenu, aggiunge solo `activate()`/`deactivate()`
								 (lifecycle specifico dei pannelli di MenuRoot, non delle schermate standalone).
	  MenuRoot.gd             ← invariato: state machine dei pannelli menu, fade con Tween tracciato.
								 **OptionMenu non rientra davvero nella state machine** (bug separato, non
								 toccato — vedi "Bug aperti / in verifica").
	  MainMenuPanel.gd        ← pannello Main Menu. handle_selection() ora usa `enum Btn` invece di indici
								 `0/1/2/3/4` letterali (Btn.START/PROFILE/SCOREBOARD/OPTIONS/EXIT).
	  SaveMenuPanel.gd        ← coordinatore locale tra i due pannelli sotto
	  SlotSelectPanel.gd      ← selezione dei 4 slot di salvataggio
	  SlotActionsPanel.gd     ← azioni sullo slot scelto. Stringhe "Empty Slot"/"Today"/"Yesterday" ora `tr()`
								 (chiavi EMPTY_SLOT/TODAY/YESTERDAY).
	  LocationMenuPanel.gd    ← selezione location, emette `location_chosen`
	  LevelMenuPanel.gd      ← selezione livello per la location scelta; bottoni generati dinamicamente
	BaseResultScreen.gd      ← extends SelectableMenu (ex extends BaseMenu). Estrae da Victory/Defeat la parte
								 comune delle animazioni di fine livello. root/title_wrapper/title/
								 buttons_container dichiarate come `var` semplici nella base, valorizzate dalle
								 sottoclassi in _ready() (mai ridichiarate con @onready nella sottoclasse).
	Victory.gd               ← extends BaseResultScreen. `isRecordBool`→`is_record` (var membro; rimossa anche
								 la variabile locale omonima in setup_results() che lo shadowava). handle_selection()
								 con `enum Btn { NEXT, RETRY, BACK_LEVEL_SELECT, BACK_MAIN_MENU }`. handle_navigation()
								 custom rimosso (era identico a quello ereditato da SelectableMenu).
	Defeat.gd                ← extends BaseResultScreen. Stesso pattern: `enum Btn { RESTART, BACK_LEVEL_SELECT,
								 BACK_MAIN_MENU }`, handle_navigation() custom (con `current_selection < 2`
								 hardcoded) rimosso.
	Pause.gd                 ← extends SelectableMenu (ex extends BaseMenu). `enum Btn { CONTINUE, RETRY,
								 BACK_MAIN_MENU }`. `_on_pause_visible()` usa `calibrate_positions()` ereditato
								 invece del loop manuale.
	DialogInterface.gd       ← sistema dialoghi con typewriter; _apply_location_theme() legge da ThemeManager
	LevelHUDManager.gd       ← stringhe "Passi: %d"/"Tempo: %ds" ora `tr()` (chiavi STEPS_LBL/TIME_LBL).
								 _ready() ora chiama update_steps(0)/update_time(0.0) subito, invece di aspettare
								 il primo evento reale — evitava un mismatch visibile tra il placeholder scritto
								 a mano nell'editor (in italiano) e la lingua vera del gioco al primo aggiornamento.
    OptionMenu.gd            ← rename tipo `LangaugeOption`→`LanguageOption` completato (nodo scena + funzione +
                                 segnale ricollegato in editor). Bug separato non toccato: back button rompe la
                                 state machine di MenuRoot — vedi "Bug aperti / in verifica".
    Buttons/LevelButtonFactory.gd / LevelLoader.gd ← ALL_LEVELS ora scansionato via `DirAccess`
                                 (get_all_levels()) invece di lista manuale.
    TransitionScreen/TransitionScreen.gd / DungeonManager.gd  ← invariati
    Utils/RoundProgressBar.gd
    Utils/HPBarDisplay.gd    ← nodo Control riusabile, genera N segmenti colorati in base a max_hp/current_hp

  Utils/
    Pathfinder.gd        ← A* su griglia isometrica. get_tile_instance_at()/get_tile_cost() ora deleghi a
                             `TileSpatialIndex` (vedi sotto) invece di una cache privata (`_tile_cache` rimossa).
    TileSpatialIndex.gd  ← NUOVA classe (RefCounted) riusabile: indicizza per posizione-griglia i figli
                             `TileBase` di un layer, con cache lazy (`get_tile_at()`, `invalidate()`). Usata sia
                             da `Pathfinder` che da `EnemyTurnHandler` — stesso lavoro, un solo posto dove vive.
    VisualEffects.gd     ← NUOVA classe (RefCounted): `flash(node, duration=0.2, color=Color(2,2,2))` centralizza
                             il pattern "glow" ripetuto in `DungeonBoss.damage_animation()` e nel tile con
                             flash attivazione/disattivazione (`Color(2,2,2)`/`Color(2,0.6,0.3)` come default/override).

  NPCs/
    NonnoSlime.gd

  Environment/
    AmbientAudioController.gd
```

---

### Struttura scena livello (BaseLevel.tscn)

```
Level (Node2D)  ← script LevelManager.gd
├── LevelLogic
├── BackgroundManager
├── LogicMapLayer        ← TileMapLayer atlas nascosto (custom data layer "chiave"/"azione" — vedi Next Steps)
├── MovementLogicMapLayer ← TileMapLayer maschera movimento (MovementMask)
├── DecorationTileMapLayer
├── TileMapLayer         ← contiene le scene-as-tile (TileActivator, TileSpike, ecc.)
├── YSort (Node2D, y_sort_enabled=true)
│   ├── TerrainMapLayer  ← pavimento (z=-2)
│   ├── WallMapLayer
│   ├── DecorationWallMapLayer
│   ├── DoorsMapLayer    ← porte (scene-as-tile, gruppo "doors")
│   ├── PickupMapLayer
│   ├── StairMapLayer
│   ├── NPCMapLayer
│   ├── Player
│   ├── TorchMapLayer
│   └── ExitParticles
├── DarkOverlay
├── CanvasHUD
│   ├── HUD (LevelHUDManager)
│   ├── DialogInterface
│   └── Pause
├── Camera2D
│   └── Effects
└── AmbientAudioController
```

### Z-index rendering

```
Z+0  → mondo giocabile: muri, player, tile logiche, oggetti  (Y-sort attivo)
Z-1  → decorazioni pavimento
Z-2  → pavimento base
```

---

### Sistemi chiave

#### Griglia isometrica
Niente RigidBody/Area2D. Tutto su coordinate `Vector2i` via `TileMapLayer`. Il player si muove tile per tile. Ogni entità ha un `Marker2D Center` che funge da pivot per Y-sort e posizionamento. `GridUtils.gd` (autoload) centralizza: `snap_to_tile_center`, `is_adjacent_4`, `is_adjacent_8`, `DIRECTION_BITS`, `coords_from_global`, `get_tile_center_global`.

#### Turn-based
```
Input player → PlayerMovement.move_to()
             → on_movement_finished()
             → steps_changed signal
             → LevelManager._on_steps_changed()
             → LevelLogic.on_player_step()
                 → SwitchSpikeHandler.on_step_begin()  (reset switch)
                 → emit global_step                     (tile step reagiscono)
                 → EnemyTurnHandler.process_enemies()   (nemici si muovono)
                     → enemy_turn_done signal
                     → LevelLogic._try_resolve_damage() (tile effetto su nemico)
```
Nota: `can_move` torna `true` subito dopo `on_movement_finished()`, **prima** che `global_step`/`EnemyTurnHandler` abbiano finito di processare tile e nemici. Le animazioni che devono proteggere questa finestra (spine che salgono, boss colpito) usano `lock_input()`/`unlock_input()` esplicitamente.

#### Tile system
Le tile logiche sono **scene-as-tile** nel `TileMapLayer`. `TileBase` è la classe padre — espone solo `on_player_enter()`/`can_enter()` a tutte le tile; `on_enemy_enter()` è dichiarato **solo** nelle tile che lo usano davvero (ISP). Le tile comunicano via segnale `tile_triggered(sender, action, data)` → `LevelLogic._on_tile_triggered()`.

Il mapping switch→spine usa un `TileMapLayer` atlas nascosto (`LogicMapLayer`) con custom data `chiave`/`azione` che `LevelTileManager.assign_keys()` legge a runtime e inietta nelle istanze delle scene. **Questi due nomi sono ancora in italiano** (sia i Custom Data Layer del TileSet che le variabili/valori a runtime) — vedi Next Steps, prossimo pezzo del naming.

Le tile che hanno bisogno di `level_logic` lo ricevono per iniezione (`setup_level_logic()`). Il riferimento al **player** ora passa da `PlayerRef` (autoload, service locator) invece che da group lookup sparsi — vedi `Global/PlayerRef.gd` sopra.

#### Sistema dialoghi
`DialogInterface` gestisce dialoghi multi-linea con typewriter, paginazione automatica, ritratti, voci. Usato dai level script tramite l'helper `play_intro()` di `LevelManager`. Emette `dialogue_finished` quando finisce.

#### Save system
4 slot di salvataggio, file JSON in `user://`. `SaveManager` gestisce lettura/scrittura/migrazione. `LevelStateManager` tiene in memoria lo stato corrente della sessione.

#### Illuminazione/oscurità livello
`DarkOverlayService` ha un'unica config per-livello `LEVEL_LIGHTING` (dark/color/sun_toggle). `_runtime_overrides` + `override_dark_state()` sono l'hook per una gimmick futura sole on/off, non ancora usato da nessun livello.

#### Sistema menu (MenuRoot)
`MenuRoot.tscn` contiene 5 nodi fratelli sempre presenti: `MainMenuPanel`, `SaveMenuPanel`, `LocationMenuPanel`, `LevelMenuPanel`, `OptionMenu`. `MenuRoot._switch_to(state, target)` disattiva gli altri pannelli, chiama `activate()` sul target **prima** del fade, poi anima con `Tween` tracciato in `_transition_tween`.

Ogni pannello concreto estende `SelectableMenuPanel` (→ `SelectableMenu`, vedi sopra) e implementa `setup_buttons()`, `setup_selectors()`, `handle_selection()`. `_unhandled_input` marca l'evento come gestito **prima** di eseguire `handle_selection()` (necessario perché può cambiare scena).

`SaveMenuPanel` smista tra `SlotSelectPanel` (i 4 slot) e `SlotActionsPanel` (play/delete/back + preview), comunicanti via segnali. Restano entrambi visibili simultaneamente una volta scelto uno slot.

`LevelMenuPanel` è l'unico pannello con bottoni **dinamici**: rigenera i bottoni-livello a ogni `activate()`.

Le schermate di fine livello (Defeat/Victory/Pause) restano scene standalone, ora dirette sottoclassi di `SelectableMenu` (`BaseResultScreen`/`Pause`), fuori dalla state machine di `MenuRoot`.

#### Sistema di lock dell'input player
`Player.gd` espone `lock_input()`/`unlock_input()` a **contatore** (`_input_lock_count`): ogni chiamante che blocca deve anche sbloccare, i controlli tornano attivi solo quando l'ultimo lock in sospeso viene rilasciato. Chiamanti attuali: `enter_cutscene()`/`exit_cutscene()`, `DungeonBoss.damage_animation()`, `TileSpikeStep._play_locked()`. `on_player_died()`/`on_player_won()` impostano `input_enabled = false` **direttamente** (stato terminale, non passa dal contatore) — vedi "Bug aperti / in verifica".

`Defeat.gd` e `Victory.gd` condividono `animate_title_slime()` e `animate_buttons()` tramite `BaseResultScreen`.

---
