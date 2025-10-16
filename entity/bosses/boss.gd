extends Area2D
class_name Boss

# --- References ---
@onready var player: Node = get_tree().get_first_node_in_group("player")
@onready var bullet_engine: BulletEngine = %bulletEngine
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D # make sure you have a Sprite2D child

# --- Boss properties ---
var boss_name = "prototype boss"
var MAXHP = 200.0
var hp = 200.0
var phase := 1
var invincible := true

# --- Timer ---
var attack_timer := Timer.new()


func _ready():

	sprite.play("open")

	add_to_group("damageable")
	add_to_group("boss")

	# Add and configure attack timer
	attack_timer.wait_time = 1.5
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
		return

	match type:
		"normal":
			hp -= dmg
			if hp <= 0:
				queue_free()
			else:
				_start_invincibility()


func _start_invincibility():
	invincible = true
	flash_sprite()
	invincible = false
	sprite.modulate = Color(1, 1, 1) # reset
	

func flash_sprite():
	sprite.self_modulate = Color(1, 0.3, 0.3) # quick red flash feedback
	await get_tree().create_timer(0.1).timeout
	sprite.self_modulate = Color(1, 1, 1)  


# --- Attacks ---

# straight shoot
func straight_shoot():
	if player == null or bullet_engine == null:
		return

	var dir = (player.global_position - global_position).normalized()
	await bullet_engine.shoot_straight(global_position, dir, self, 5, bullet_engine.normal_bullet_scene, 600, 1)


# ring shoot
func ring_shoot(num_of_ring: int = 3):
	if bullet_engine == null:
		return

	var ring_offset := 0.0
	for i in range(num_of_ring):
		bullet_engine.shoot_ring(global_position, 8, self, bullet_engine.normal_bullet_scene, 400, 1, 0, ring_offset)
		ring_offset += PI / 10
		await get_tree().create_timer(0.3).timeout


# beam (stream of bullets)
func beam_player(length: int = 15):
	if player == null or bullet_engine == null:
		return

	for i in range(length):
		var dir = (player.global_position - global_position).normalized()
		bullet_engine.shoot_straight(global_position, dir, self, 1, bullet_engine.normal_bullet_scene, 700, 1)
		await get_tree().create_timer(0.1).timeout


# curve shoot
func curve_shoot(num: int = 10):
	if player == null or bullet_engine == null:
		return

	for i in range(num):
		bullet_engine.shoot_curve(global_position, self, player, 200, 0.5)
		await get_tree().create_timer(0.2).timeout


# curve beam (stream of curve bullets)
func curve_beam(length: int = 20):
	if player == null or bullet_engine == null:
		return

	for i in range(length):
		bullet_engine.shoot_curve(global_position, self, player)
		await get_tree().create_timer(0.1).timeout

func  rest(t: int = 5):
	sprite.play("close")
	invincible = false

	await get_tree().create_timer(t).timeout
	invincible = true
	sprite.play("open")

var atk_cycle = [curve_shoot, straight_shoot, ring_shoot, beam_player, curve_beam,ring_shoot,ring_shoot]
# var atk_cycle = [straight_shoot,]

# --- Phase Pattern Cycle ---
var atk_counter := 0
func _on_attack_cycle():
	if atk_cycle.is_empty():
		return

	# Pick a random attack from the cycle
	if invincible:
		atk_counter +=1
		if (atk_counter <=3):
			var attack_func = atk_cycle[randi_range(0, atk_cycle.size() - 1)]
			# Call the selected attack
			attack_func.call()  # call the function stored in the array
		else:
			rest()
			atk_counter = 0
