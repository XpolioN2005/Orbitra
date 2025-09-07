extends Area2D
class_name Bullet

@export var speed: float = 300.0
@export var dmg: int = 1
@export var type: String = "normal"
@export var lifetime: float = 5.0
@export var shooter : Node

var velocity: Vector2 = Vector2.ZERO

func _ready():
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
