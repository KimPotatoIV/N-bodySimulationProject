extends Node2D

##################################################
const PARTICLE_SCENE: PackedScene = preload("res://scenes/particle/particle.tscn")
const MAX_SPAWN_COUNT: int = 500

##################################################
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		for i in range(MAX_SPAWN_COUNT):
			var particle_instance: Node2D = PARTICLE_SCENE.instantiate()
			add_child(particle_instance)
			particle_instance.global_position = \
				Vector2(randf_range(10.0, 1910.0), randf_range(10.0, 1070.0))
