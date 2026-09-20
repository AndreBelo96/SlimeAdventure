extends MarginContainer
class_name ProfileBossCard

@onready var reward_icon: TextureRect = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/RewardIcon
@onready var boss_icon: TextureRect = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/BossIcon
@onready var name_lbl: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/NameLbl
@onready var record_steps_lbl: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Label3
@onready var record_time_lbl: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Label4
@onready var total_deaths_lbl: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Label5
@onready var total_steps_lbl: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Label6
@onready var total_time_lbl: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Label7

var _defeated := false
var _reward_unlocked := false

func _ready() -> void:
	reward_icon.resized.connect(func(): reward_icon.pivot_offset = reward_icon.size / 2.0)
	boss_icon.resized.connect(func(): boss_icon.pivot_offset = boss_icon.size / 2.0)

func setup(level: int, data: Dictionary, reward_id, unlocked: bool, portrait_key) -> void:
	name_lbl.text = LocationManager.get_level_name(level)
	_setup_reward(reward_id, unlocked)
	var defeated: bool = data.has("steps") or unlocked
	_setup_boss(portrait_key, defeated)
	
	_defeated = defeated
	_reward_unlocked = unlocked and reward_id != null
	_setup_shine(reward_icon, _reward_unlocked)
	_setup_shine(boss_icon, _defeated)
	
	if data.is_empty():
		record_steps_lbl.text = "👣: -"
		record_time_lbl.text = "⌛: -"
		total_deaths_lbl.text = "☠️: -"
		total_steps_lbl.text = "👣: -"
		total_time_lbl.text = "⌛: -"
		modulate.v = 0.6
		return

	record_steps_lbl.text = "👣: %d" % data.get("steps", 0)
	record_time_lbl.text = "⌛: %s" % _format_time(data.get("time", 0.0))
	total_deaths_lbl.text = "☠️: %d" % _sum_deaths(data.get("deaths", {}))
	total_steps_lbl.text = "👣: %d" % data.get("total_steps", 0)
	total_time_lbl.text = "⌛: %s" % _format_time(data.get("total_time", 0.0))

func _setup_reward(reward_id, unlocked: bool) -> void:
	reward_icon.visible = reward_id != null
	if reward_id == null:
		return
	var atlas := AtlasTexture.new()
	atlas.atlas = LocationManager.PICKUP_SPRITESHEET
	atlas.region = LocationManager.boss_reward_icons.get(reward_id, Rect2())
	reward_icon.texture = atlas
	reward_icon.modulate = Color.WHITE if unlocked else Color(0.25, 0.25, 0.25)

func _setup_boss(portrait_key, defeated: bool) -> void:
	boss_icon.visible = portrait_key != null
	if portrait_key == null:
		return
	boss_icon.texture = PortraitManager.get_portrait(portrait_key)
	boss_icon.modulate = Color.WHITE if defeated else Color(0.0, 0.0, 0.0, 0.7)


func _sum_deaths(deaths: Dictionary) -> int:
	var total := 0
	for v in deaths.values():
		total += v
	return total

func _format_time(seconds: float) -> String:
	var total := int(seconds)
	@warning_ignore("integer_division")
	var minutes := int(total / 60)
	return "%02d:%02d" % [minutes, total % 60]

func play_intro(delay: float) -> void:
	_pop_in(boss_icon, delay).finished.connect(func():
		if _defeated:
			UIFx.breathe(boss_icon)
		else:
			UIFx.pulse_alpha(boss_icon, 0.45, 0.7)
	)
	_pop_in(reward_icon, delay + 0.12).finished.connect(func():
		if _reward_unlocked:
			UIFx.flick(reward_icon)
	)

func _pop_in(node: Control, delay: float) -> Tween:
	node.scale = Vector2.ZERO
	var t := create_tween()
	t.tween_property(node, "scale", Vector2.ONE, 0.35).set_delay(delay)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return t

func _breathe(node: Control) -> void:
	var t := create_tween().set_loops(100000)
	t.tween_property(node, "scale", Vector2(1.0, 1.04), 1.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(node, "scale", Vector2.ONE, 1.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _flick(node: Control) -> void:
	var t := create_tween().set_loops(100000)
	t.tween_interval(2.0)
	t.tween_property(node, "rotation", -0.15, 0.08)
	t.tween_property(node, "rotation", 0.15, 0.16)
	t.tween_property(node, "rotation", 0.0, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
func _setup_shine(icon: TextureRect, active: bool) -> void:
	if not active or not icon.material is ShaderMaterial:
		icon.material = null
		return
	icon.material = icon.material.duplicate()  # ogni icona ha la sua dimensione
	(icon.material as ShaderMaterial).set_shader_parameter("tag_size", icon.size)
