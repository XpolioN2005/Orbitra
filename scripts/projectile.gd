extends Area2D
class_name Projectile

@export var speed: float = 300.0
@export var dmg: int = 1
@export var type: String = "normal"
@export var shooter : Node

@export var is_parry_ble : bool =  true

var velocity: Vector2 = Vector2.ZERO

var is_disbaled : bool = true

func _ready():

	add_to_group("projectile")

	if is_parry_ble:
		add_to_group("parryble")
	
	monitoring = false
	monitorable = false


func _physics_process(delta: float) -> void:
	
	global_position += velocity * delta

func set_direction(dir: Vector2):
	
	velocity = dir.normalized() * speed
	rotation = velocity.angle()

func _on_body_entered(area: Node):


	if is_disbaled:
		return
	
	if area == shooter:
		return
	
	if area.is_in_group("damageable") and area.has_method("take_dmg"):
		area.take_dmg(dmg, type)

		reset()
	
	if area.is_in_group("parryble") and area.shooter != shooter:
		reset()

func reset():
	
	is_disbaled =  true

	visible = false
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	set_physics_process(false)

	# Stop any collision callbacks from firing
	if area_entered.is_connected(_on_body_entered):
		area_entered.disconnect(_on_body_entered)

	dmg = 0
	shooter = null
	speed = 0
	global_position = Vector2.ZERO
	velocity = Vector2.ZERO

func fire(
	start_pos: Vector2,
	dir: Vector2,
	shooter_node: Node,
	bullet_speed: float = 300,
	bullet_dmg: int = 1
):
	# Reset the bullet first
	reset()
	
	# Set properties
	global_position = start_pos
	shooter = shooter_node
	speed = bullet_speed
	dmg = bullet_dmg

	is_disbaled = false
	visible = true

	set_deferred("monitoring", true)
	set_deferred("monitorable", true)
	
	area_entered.connect(_on_body_entered)

	# Set movement
	set_direction(dir)
	set_physics_process(true)
