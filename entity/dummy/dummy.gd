extends Area2D
class_name BossDummy

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var MAXHP := 10
var hp := 10

func _ready():
	add_to_group("damageable")
	add_to_group("boss")

# --- Damage ---
func take_dmg(dmg: int, type: String):
	match type:
		"normal":
			hp -= dmg
			if hp <= 0:
				visible = false
			else:
				_play_hit_animation()

func _play_hit_animation():
	sprite.play("hit")  # play hit animation
	await sprite.animation_finished
	sprite.play("default")  # return to idle
