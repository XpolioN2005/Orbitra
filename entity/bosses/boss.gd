extends Area2D
class_name Boss

@onready var player : Node
@onready var bullet_engine: BulletEngine = %bulletEngine
var hp = 200

var attack_timer := Timer.new()
var phase := 2
var ring_offset := 0.0 # for rotating rings


func _ready():
	add_to_group("damageable")

	# setup attack timer
	attack_timer.wait_time = 2.0
	attack_timer.autostart = true
	attack_timer.one_shot = false
	attack_timer.timeout.connect(_on_attack_timeout)
	add_child(attack_timer)

func take_dmg(dmg: int, type: String):
	match type:
		"normal":
			hp -= dmg
			if hp <= 0:
				queue_free()

func _on_attack_timeout():
	match phase:
		1:
			_phase_one()
		2:
			_phase_two()
		3:
			_phase_three()

	# phase shift based on HP
	if hp < 150 and phase == 1:
		phase = 2
		attack_timer.wait_time = 1.5
	elif hp < 75 and phase == 2:
		phase = 3
		attack_timer.wait_time = 1.0

func _phase_one():
	# straight shots toward player
	var dir = (player.global_position - global_position).normalized()
	bullet_engine.shoot_straight(global_position, dir, self, 5 ,bullet_engine.normal_bullet_scene, 250, 1)

func _phase_two():
	# rotating ring around the boss
	bullet_engine.shoot_ring(global_position, 8, self, bullet_engine.normal_bullet_scene, 200, 1, 0, ring_offset)
	ring_offset += PI / 10 # rotate gap every volley

func _phase_three():
	# spirals chasing the player
	bullet_engine.shoot_spiral(
		global_position,
		self,
		player,
		2,      # num_of_bullet
		5.0,    # angular_speed
		60.0,   # center_speed
		1       # dmg
	)
