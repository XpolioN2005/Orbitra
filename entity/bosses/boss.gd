extends Area2D
class_name Boss

# --- References ---
@onready var player: Node = get_tree().get_first_node_in_group("player")
@onready var bullet_engine: BulletEngine = %bulletEngine
@onready var sprite: Sprite2D = $Sprite2D # make sure you have a Sprite2D child

# --- Boss properties ---
var boss_name = "prototype boss"
var hp = 200
var phase := 1
var invincible := false
@export var invincibility_time := 0.8

# --- Timer ---
var attack_timer := Timer.new()


func _ready():
	add_to_group("damageable")
	add_to_group("boss")

	# Add and configure attack timer
	attack_timer.wait_time = 3.0
	attack_timer.autostart = true
	attack_timer.one_shot = false
	add_child(attack_timer)
	attack_timer.timeout.connect(_on_attack_cycle)

	print("Boss ready. Attack timer started.")

	if player == null:
		print("Warning: Player not found! Make sure the player is in 'player' group.")
	if bullet_engine == null:
		print("Warning: BulletEngine not found! Make sure $bulletEngine exists.")


# --- Damage + Invincibility ---
func take_dmg(dmg: int, type: String):
	if invincible:
		print("Boss is invincible, damage ignored")
		return

	match type:
		"normal":
			hp -= dmg
			print("Boss took ", dmg, " damage. HP now: ", hp)
			if hp <= 0:
				print("Boss defeated!")
				queue_free()
			else:
				_start_invincibility()


func _start_invincibility():
	invincible = true
	flash_sprite()
	await get_tree().create_timer(invincibility_time).timeout
	invincible = false
	sprite.modulate = Color(1, 1, 1) # reset
	print("Boss invincibility ended.")


func flash_sprite():
	sprite.modulate = Color(1, 0.3, 0.3) # quick red flash feedback


# --- Attacks ---

# straight shoot
func straight_shoot():
	if player == null or bullet_engine == null:
		print("Cannot straight_shoot: missing player or bullet_engine")
		return

	print("Straight shoot triggered")
	var dir = (player.global_position - global_position).normalized()
	await bullet_engine.shoot_straight(global_position, dir, self, 5, bullet_engine.normal_bullet_scene, 250, 1)


# ring shoot
func ring_shoot(num_of_ring: int = 3):
	if bullet_engine == null:
		print("Cannot ring_shoot: missing bullet_engine")
		return

	print("Ring shoot triggered, rings: ", num_of_ring)
	var ring_offset := 0.0
	for i in range(num_of_ring):
		bullet_engine.shoot_ring(global_position, 8, self, bullet_engine.normal_bullet_scene, 200, 1, 0, ring_offset)
		ring_offset += PI / 10
		await get_tree().create_timer(0.3).timeout


# beam (stream of bullets)
func beam_player(length: int = 10):
	if player == null or bullet_engine == null:
		print("Cannot beam_player: missing player or bullet_engine")
		return

	print("Beam shoot triggered, length: ", length)
	for i in range(length):
		var dir = (player.global_position - global_position).normalized()
		bullet_engine.shoot_straight(global_position, dir, self, 1, bullet_engine.normal_bullet_scene, 250, 1)
		await get_tree().create_timer(0.1).timeout


# curve shoot
func curve_shoot(num: int = 3):
	if player == null or bullet_engine == null:
		print("Cannot curve_shoot: missing player or bullet_engine")
		return

	print("Curve shoot triggered, num: ", num)
	for i in range(num):
		bullet_engine.shoot_curve(global_position, self, player)
		await get_tree().create_timer(0.2).timeout


# curve beam (stream of curve bullets)
func curve_beam(length: int = 10):
	if player == null or bullet_engine == null:
		print("Cannot curve_beam: missing player or bullet_engine")
		return

	print("Curve beam triggered, length: ", length)
	for i in range(length):
		bullet_engine.shoot_curve(global_position, self, player)
		await get_tree().create_timer(0.1).timeout


# --- Phase Pattern Cycle ---
func _on_attack_cycle():
	print("Attack cycle triggered, phase: ", phase)

	match phase:
		1:
			await straight_shoot()
			await ring_shoot(2)
		2:
			await beam_player(12)
			await curve_shoot(4)
		3:
			await curve_beam(12)
			await ring_shoot(3)

	phase += 1
	if phase > 3:
		phase = 1
