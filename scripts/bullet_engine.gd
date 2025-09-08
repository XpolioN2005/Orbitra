extends Node2D
class_name BulletEngine

@export var normal_bullet_scene: PackedScene
@export var curve_bullet_scene: PackedScene   # updated: use CurveBullet

@onready var bullet_holder = $bullets

# Spawn straight bullets
func shoot_straight(
	pos: Vector2, 
	direction: Vector2, 
	shooter: Node,
	num_of_bullet: int,
	bullet_type: PackedScene = normal_bullet_scene, 
	speed: float = 300, 
	dmg: int = 1
):
	for i in range(num_of_bullet):
		var b = bullet_type.instantiate()
		b.global_position = pos
		b.shooter = shooter
		
		b.speed = speed
		b.dmg = dmg
		
		if b.has_method("set_direction"):
			b.set_direction(direction)
		
		bullet_holder.add_child(b)
		await get_tree().create_timer(0.1).timeout

# Spawn bullets in a ring
func shoot_ring(
	pos: Vector2, 
	bullet_count: int, 
	shooter: Node, 
	bullet_type: PackedScene = normal_bullet_scene, 
	speed: float = 300, 
	dmg: int = 1, 
	radius: float = 0,
	angle_offset: float = 0.0
):
	for i in range(bullet_count):
		var angle = (TAU / bullet_count) * i + angle_offset
		var dir = Vector2.RIGHT.rotated(angle)
		shoot_straight(pos + dir * radius, dir, shooter, 1, bullet_type, speed, dmg)

# Spawn curve bullets (CurveBullet script handles curve logic)
func shoot_curve(pos: Vector2, shooter: Node,target: Node, arc_height: float = 200.0, travel_time: float = 1.0):
	var b = curve_bullet_scene.instantiate()
	b.global_position = pos
	b.target = target
	b.shooter = shooter
	b.arc_height = arc_height
	b.travel_time = travel_time
	bullet_holder.add_child(b)
