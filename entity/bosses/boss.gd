extends Area2D

@export var bullet_scene: PackedScene
@export var player: PackedScene

var hp = 200

func _ready():
	add_to_group("damageable")


func take_dmg(dmg: int, type: String):

	match type:
		"normal":
			hp -= dmg
			
