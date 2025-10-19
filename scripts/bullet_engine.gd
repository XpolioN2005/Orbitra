extends Node2D
class_name BulletEngine

@export var normal_bullet_scene: PackedScene
@export var curve_bullet_scene: PackedScene   # updated: use CurveBullet

@onready var bullet_holder = $bullets
@onready var audio = $audio

@export var normal_bullet_index := 0
@export var curve_bullet_index := 0
@export var MAX_BULLET_COUNT := 100

var normal_bullet_pool: Array = []
var curve_bullet_pool: Array = []

func _ready():
	for i in range(MAX_BULLET_COUNT):
		var inst = normal_bullet_scene.instantiate()
		inst.reset()
		normal_bullet_pool.append(inst)
		bullet_holder.add_child(inst)

		var inst_curv = curve_bullet_scene.instantiate()
		inst_curv.reset()
		curve_bullet_pool.append(inst_curv)
		bullet_holder.add_child(inst_curv)


# audio
func _play_shot_sound():
	audio.pitch_scale = randf_range(0.95, 1.08)  # randomize pitch
	audio.play()


# Spawn straight bullets
func shoot_straight(
	pos: Vector2, 
	direction: Vector2, 
	shooter: Node,
	num_of_bullet: int,
	_bullet_type: PackedScene = normal_bullet_scene, 
	speed: float = 300, 
	dmg: int = 1
):
	for i in range(num_of_bullet):

		var inst = normal_bullet_pool[normal_bullet_index]

		normal_bullet_index = wrapi(normal_bullet_index+1, 0, MAX_BULLET_COUNT)

		_play_shot_sound()
		inst.fire(pos,direction,shooter,speed,dmg)
		
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
	var inst = curve_bullet_pool[curve_bullet_index]

	curve_bullet_index = wrapi(curve_bullet_index+1, 0, MAX_BULLET_COUNT)

	inst.fire_curve(pos,target,shooter,arc_height,travel_time)
	
	_play_shot_sound()
