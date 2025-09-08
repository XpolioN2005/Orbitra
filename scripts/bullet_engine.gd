extends Node2D
class_name BulletEngine

@export var normal_bullet_scene: PackedScene
@export var spiral_bullet_scene: PackedScene

@onready var bullet_holder = $bullets

# Spawn straight bullets
func shoot_straight( pos: Vector2, direction: Vector2, shooter: Node ,num_of_bullet:int,bullet_type: PackedScene = normal_bullet_scene, speed: float = 300, dmg: int = 1):
	for i in range(num_of_bullet):
		var b = bullet_type.instantiate()
		b.global_position = pos
		b.shooter = shooter
		
		if b.has_method("set_direction"):
			b.set_direction(direction)
		
		b.speed = speed
		
		b.dmg = dmg
		
		bullet_holder.add_child(b)
		await get_tree().create_timer(0.3).timeout

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
		shoot_straight(pos + dir * radius, dir, shooter, 1 , bullet_type, speed, dmg)

# Spawn a spiral bullet (needs angular_speed in bullet script)
func shoot_spiral(pos: Vector2 ,shooter: Node, target: Node, num_of_bullet: int, angular_speed: float = 4.0, speed: float = 100, dmg: int = 1):
	for i in range(num_of_bullet):
		var b = spiral_bullet_scene.instantiate()
		b.global_position = pos
		b.shooter = shooter
		b.target = target
		
		b.angular_speed = angular_speed
		b.center_speed = speed
		b.dmg = dmg
		
		bullet_holder.add_child(b)
		await get_tree().create_timer(0.3).timeout
