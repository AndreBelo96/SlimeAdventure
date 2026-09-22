extends CPUParticles2D
class_name ConfusionFog

@export var puffs_per_point := 4

func setup(points: PackedVector2Array) -> void:
	emission_shape = EMISSION_SHAPE_POINTS
	texture_filter = TEXTURE_FILTER_LINEAR
	emission_points = points
	amount = max(points.size() * puffs_per_point, 1)
	restart()
