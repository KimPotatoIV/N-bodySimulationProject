extends Node2D

##################################################
const GRAVITY: float = 1000.0
const MIN_DISTANCE: float = 4.0
const MAX_DISTANCE: float = 500.0

var velocity: Vector2 = Vector2.ZERO
var mass: float = 1.0
var radius_self: float = 0.0

##################################################
func _ready() -> void:
	add_to_group("Particle")
	
	radius_self = get_radius()

##################################################
func _physics_process(delta: float) -> void:
	var particles: Array = get_tree().get_nodes_in_group("Particle")
	
	for other_particle in particles:
		if other_particle == self:
			continue
		
		var direction: Vector2 = other_particle.global_position - global_position
		var distance: float = direction.length()
		
		var self_radius: float = get_radius()
		var other_radius: float = other_particle.get_radius()
		# 만유인력 공식
		#     → F = G * { ( m1 * m2 ) / ( r * r ) }
		# 가속도 계산 공식
		#     → F = m * a    →    a = F / m
		if distance < MAX_DISTANCE and distance > self_radius + other_radius:
			var force = \
				GRAVITY * (mass * other_particle.get_mass()) / (distance * distance)
			var acceleration = direction.normalized() * force / mass
			velocity += acceleration * delta
		elif distance <= self_radius + other_radius and mass >= other_particle.get_mass():
			_merge(other_particle)
			radius_self = get_radius()
	
	position += velocity * delta
	queue_redraw()

##################################################
func _draw() -> void:
	var color_intensity = clamp(mass / 50.0, 0, 1)
	draw_circle(Vector2.ZERO, get_radius(), \
				Color(1, 1 - color_intensity, 0.3))

##################################################
func _merge(other: Node2D) -> void:
	mass += other.mass
	velocity = (velocity * mass + other.velocity * other.mass) / (mass + other.mass)
	other.queue_free()

##################################################
func get_radius() -> float:
	return sqrt(mass) * 5

##################################################
func get_mass() -> float:
	return mass
