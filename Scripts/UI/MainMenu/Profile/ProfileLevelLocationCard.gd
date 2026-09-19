extends CenterContainer
class_name ProfileLevelLocationCard

@onready var record_info: ProfileLevelLocationRecordInfo = $ProfileLevelLocationRecordInfo
@onready var total_info: ProfileLevelLocationTotalInfo = $ProfileLevelLocationTotalInfo

var showing_record := true

func _ready() -> void:
	resized.connect(func(): pivot_offset = size / 2)

func setup(level: int, data: Dictionary) -> void:
	record_info.setup(level, data)
	total_info.setup(level, data)
	showing_record = true
	_apply_state(false)

func show_record(animate: bool = true) -> void:
	showing_record = true
	_apply_state(animate)

func show_total(animate: bool = true) -> void:
	showing_record = false
	_apply_state(animate)

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
