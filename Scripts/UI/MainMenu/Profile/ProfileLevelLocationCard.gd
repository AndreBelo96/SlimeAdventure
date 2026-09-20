extends MarginContainer
class_name ProfileLevelLocationCard

const TAG_COLOR_RECORD := Color("9b3411ff")
const TAG_COLOR_TOTAL := Color("5540d2ff")

@onready var record_info: ProfileLevelLocationRecordInfo = $ProfileLevelLocationRecordInfo
@onready var total_info: ProfileLevelLocationTotalInfo = $ProfileLevelLocationTotalInfo
@onready var tag: Label = $TagLayer/Label

var showing_record := true
var _flip_tween: Tween

func _ready() -> void:
	resized.connect(_on_resized)
	$TagLayer.resized.connect(_place_tag)
	tag.resized.connect(_place_tag)

func _on_resized() -> void:
	pivot_offset = size / 2.0
	_place_tag()

func setup(level: int, data: Dictionary) -> void:
	record_info.setup(level, data)
	total_info.setup(level, data)
	showing_record = true
	_apply_faces()
	_apply_tag()
	modulate.v = 1.0 if not data.is_empty() else 0.6

func show_record(animate: bool = true, delay: float = 0.0) -> void:
	_flip_to(true, animate, delay)

func show_total(animate: bool = true, delay: float = 0.0) -> void:
	_flip_to(false, animate, delay)

func _flip_to(to_record: bool, animate: bool, delay: float) -> void:
	showing_record = to_record
	if _flip_tween:
		_flip_tween.kill()
	if not animate:
		_apply_faces()
		_apply_tag()
		scale.x = 1.0
		return
	_flip_tween = create_tween()
	_flip_tween.tween_interval(delay)
	_flip_tween.tween_property(self, "scale:x", 0.0, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_flip_tween.tween_callback(_on_flip_midpoint)
	_flip_tween.tween_property(self, "scale:x", 1.0, 0.28).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func _on_flip_midpoint() -> void:
	_apply_faces()
	_apply_tag()
	_pop_tag()

func _apply_faces() -> void:
	record_info.modulate.a = 1.0 if showing_record else 0.0
	total_info.modulate.a = 0.0 if showing_record else 1.0

func _apply_tag() -> void:
	tag.text = "Record!" if showing_record else "Total!"
	tag.add_theme_color_override("font_color", TAG_COLOR_RECORD if showing_record else TAG_COLOR_TOTAL)
	tag.reset_size()

func _place_tag() -> void:
	var layer: Control = $TagLayer
	if layer.size.x <= 0.0:
		return  # layout non ancora calcolato, arriverà un altro resized
	tag.pivot_offset = tag.size / 2.0
	tag.position = Vector2(layer.size.x - 16.0, 16.0) - tag.size / 2.0
	if tag.material is ShaderMaterial:
		(tag.material as ShaderMaterial).set_shader_parameter("tag_size", tag.size)

func _pop_tag() -> void:
	tag.scale = Vector2(1.5, 1.5)
	tag.create_tween().tween_property(tag, "scale", Vector2.ONE, 0.25)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func play_intro(delay: float) -> void:
	modulate.a = 0.0
	scale = Vector2(0.85, 0.85)
	var t := create_tween().set_parallel(true)
	t.tween_property(self, "modulate:a", 1.0, 0.15).set_delay(delay)
	t.tween_property(self, "scale", Vector2.ONE, 0.3).set_delay(delay)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _apply_state(animate: bool) -> void:
	var shown_panel: Control
	var hidden_panel: Control
	if showing_record:
		shown_panel = record_info
		hidden_panel = total_info
	else:
		shown_panel = total_info
		hidden_panel = record_info

	if not animate:
		hidden_panel.visible = false
		shown_panel.visible = true
		scale.x = 1.0
		return

	var tween := create_tween()
	tween.tween_property(self, "scale:x", 0.0, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(func():
		hidden_panel.visible = false
		shown_panel.visible = true
	)
	tween.tween_property(self, "scale:x", 1.0, 0.28).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
