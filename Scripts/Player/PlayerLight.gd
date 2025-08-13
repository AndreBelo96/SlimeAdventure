class_name PlayerLight
extends Resource

var light_node: PointLight2D

func setup(light: PointLight2D):
	light_node = light

func enable():
	if light_node:
		light_node.visible = true

func disable():
	if light_node:
		light_node.visible = false

func set_enabled(is_enabled: bool):
	if light_node:
		light_node.visible = is_enabled
