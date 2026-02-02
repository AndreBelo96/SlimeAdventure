extends Node2D

@onready var p := $CPUParticles2D

func play():
	p.emitting = true
