extends Projectile
class_name CurveBullet

@export var arc_height: float = 200.0  # how high the bullet arches
@export var travel_time: float = 1.0   # time to reach the target in seconds

var start_pos: Vector2
var target_pos: Vector2
var elapsed_time: float = 0.0

var target

func _ready():
	super._ready()
	if target:
		start_pos = global_position
		target_pos = target.global_position

func _physics_process(delta: float) -> void:
	if target == null:
		return

	elapsed_time += delta
	var t = elapsed_time / travel_time
	

	# Vector from start to target
	var dir = target_pos - start_pos
	var mid = start_pos + dir * 0.5

	# Perpendicular vector for arc direction
	var perp = Vector2(-dir.y, dir.x).normalized()
	var control = mid + perp * arc_height

	# Quadratic Bézier
	global_position = (1 - t)*(1 - t)*start_pos + 2*(1 - t)*t*control + t*t*target_pos

	# Rotation
	if elapsed_time > 0.0:
		rotation = (global_position - position).angle()
