extends Projectile
class_name SpiralBullet

@export var angular_speed: float = 2.0
@export var initial_radius: float = 100.0
@export var radius_growth: float = 30.0   # units per second increase
@export var center_speed: float = 50.0

var angle: float = 0.0
var spiral_radius: float
var center_pos: Vector2
var target: Node2D

func _ready():
	lifetime = 10.0
	super._ready()
	center_pos = global_position
	spiral_radius = initial_radius

func _physics_process(delta):
	if target:
		# move spiral center toward target
		var dir_to_target = (target.global_position - center_pos).normalized()
		center_pos += dir_to_target * center_speed * delta

	# increase radius over time
	spiral_radius += (radius_growth * delta) /2

	# spiral motion
	angle += angular_speed * delta
	var offset = Vector2.RIGHT.rotated(angle) * spiral_radius
	global_position = center_pos + offset
