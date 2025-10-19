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

func reset():
	# Call parent reset
	super.reset()

	# Reset curve-specific variables
	start_pos = Vector2.ZERO
	target_pos = Vector2.ZERO
	target = null
	elapsed_time = 0.0
	arc_height = 200.0
	travel_time = 1.0

func fire_curve(
	pos: Vector2,
	target_node: Node,
	shooter_node: Node,
	curve_height: float = 200.0,
	travel_seconds: float = 1.0,
	bullet_dmg: int = 1
):
	# Reset the bullet first
	reset()

	# Set common projectile properties
	global_position = pos
	shooter = shooter_node
	dmg = bullet_dmg

	# CurveBullet-specific properties
	start_pos = pos
	target = target_node
	target_pos = target.global_position
	arc_height = curve_height
	travel_time = travel_seconds
	elapsed_time = 0.0

	# Activate bullet
	is_disbaled = false
	visible = true
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)
	area_entered.connect(_on_body_entered)
	set_physics_process(true)
