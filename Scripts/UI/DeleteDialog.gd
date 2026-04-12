extends Control

signal confirmed
signal canceled

@onready var delete_button = $Panel/VBoxContainer/HBoxContainer/Delete
@onready var cancel_button = $Panel/VBoxContainer/HBoxContainer/Cancel

func _ready():
	$Panel/VBoxContainer/Label.text = tr("DELETE_CONFIRM_LBL")
	$Panel/VBoxContainer/HBoxContainer/Delete.text = tr("DELETE_BTN")
	$Panel/VBoxContainer/HBoxContainer/Cancel.text = tr("CANCEL_BTN")
	
	delete_button.pressed.connect(self._on_delete_pressed)
	cancel_button.pressed.connect(self._on_cancel_pressed)

func _on_delete_pressed():
	emit_signal("confirmed")
	queue_free()  # chiude il dialogo

func _on_cancel_pressed():
	emit_signal("canceled")
	queue_free()  # chiude il dialogo
