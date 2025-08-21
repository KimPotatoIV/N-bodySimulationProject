extends Node2D

##################################################
const GRAVITY: float = 1000.0		# 중력 값. 시뮬레이션 움직임을 활발하게 하려고 높은 값으로 설정
const MAX_DISTANCE: float = 500.0	# 연산을 멈추는 최대 거리
const RADIUS_SCALE: float = 5.0		# 반지름에 곱해줄 비율 (그냥은 particle이 너무 작음)

var velocity: Vector2 = Vector2.ZERO	# 속도 및 방향 벡터 값
var mass: float = 1.0				# 무게
var radius: float = 0.0				# 반지름

##################################################
func _ready() -> void:
	add_to_group("Particle")		# Particle 그룹에 추가
	
	radius = get_radius()		# 반지름 설정

##################################################
func _physics_process(delta: float) -> void:
	# 모든 particles를 목록화 시킴
	var particles: Array = get_tree().get_nodes_in_group("Particle")
	
	# part나icles 순회하며
	for other_particle in particles:
		if other_particle == self:	# 나 자신은 continue
			continue
		
		# particle 사이의  방향을 구함
		var direction: Vector2 = other_particle.global_position - global_position
		var distance: float = direction.length()	# 두 particle 간의 거리를 구함
		
		# 나와 다른 particle의 반지름을 구함
		radius = get_radius()
		var other_radius: float = other_particle.get_radius()
		'''
		만유인력 공식 (두 물체 사이의 중력적 인력)
			→ F = G * { ( m1 * m2 ) / ( r * r ) }
		가속도 계산 공식
			→ F = m * a    →    a = F / m
		'''
		# 너무 멀거나 너무 가까우면 pass
		if distance < MAX_DISTANCE and distance > radius + other_radius:
			# 만유인력을 구함
			var force = \
				GRAVITY * (mass * other_particle.get_mass()) / (distance * distance)
			# 가속도를 구함
			var acceleration = direction.normalized() * force / mass
			velocity += acceleration * delta	# 가속도를 이용해 velocity 설정
		# 너무 가깝거나 내 particle이 더 무거우면
		elif distance <= radius + other_radius and mass >= other_particle.get_mass():
			_merge(other_particle)	# 병합
			radius = get_radius()	# 반지름 재설정
	
	position += velocity * delta	# 위치 이동
	queue_redraw()				# 다시 그리기

##################################################
func _draw() -> void:
	var color_intensity = clamp(mass / 50.0, 0, 1)	# 색상 강도를 무게에 따라 설정
	# 로컬 좌표 원점에 반지름을 구해서 커질수록 빨간 색이 강조됨
	draw_circle(Vector2.ZERO, get_radius(), Color(1, 1 - color_intensity, 0.3))

##################################################
func _merge(other: Node2D) -> void:
	mass += other.mass	# 두 particle의 무게를 더함
	# 운동량 보존 법칙에 따라 속도 * 무게를 구한 후 무게의 합으로 나눔
	velocity = (velocity * mass + other.velocity * other.mass) / (mass + other.mass)
	other.queue_free()	# 다른 particle을 삭제

##################################################
func get_radius() -> float:
	# 그냥은 particle이 너무 작아서 RADIUS_SCALE를 곱해줌
	return sqrt(mass) * RADIUS_SCALE

##################################################
func get_mass() -> float:
	return mass
