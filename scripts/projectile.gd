extends Area2D
class_name Projectile

@export var speed: float = 300.0
@export var dmg: int = 1
@export var type: String = "normal"
@export var lifetime: float = 5.0
@export var shooter : Node

@export var is_parry_ble : bool =  true

var velocity: Vector2 = Vector2.ZERO

func _ready():

	add_to_group("projectile")

	if is_parry_ble:
		add_to_group("parryble")
	
	monitoring = true
	monitorable = true
	area_entered.connect(_on_body_entered)
	
	# Auto-despawn
	await get_tree().create_timer(lifetime).timeout
	
	if is_instance_valid(self):
		queue_free()

func _physics_process(delta: float) -> void:
	
	global_position += velocity * delta

func set_direction(dir: Vector2):
	
	velocity = dir.normalized() * speed
	rotation = velocity.angle()

func _on_body_entered(area: Node):
	
	if area == shooter:
		return
	
	if area.is_in_group("damageable") and area.has_method("take_dmg"):
		area.take_dmg(dmg, type)

		queue_free()
	
	if area.is_in_group("parryble") and area.shooter != shooter:
		
		queue_free()
