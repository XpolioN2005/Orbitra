class_name Projectile
extends Area2D

var target: Node2D

var speed : float = 100
var velocity : Vector2 = Vector2.ZERO

var dmg : int = 1

var type : String = "normal"

func _ready():
	body_entered.connect(_body_enter)

func _process(delta):
	global_position += velocity *delta
	look_at(target.global_position)

func set_target():
	velocity = (target.global_position - global_position).normalized() *speed	


func _body_enter(body: Node):
	if body.is_in_group("damageable"):
		body.take_dmg(dmg, type)
	queue_free()
