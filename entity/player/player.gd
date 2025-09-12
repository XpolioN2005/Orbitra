extends Area2D

@export var bullet_scene: PackedScene

@onready var boss : Node =  get_tree().get_first_node_in_group("boss")
@onready var sprite = $Sprite

var hp = 20

func _ready():
	add_to_group("damageable")
	add_to_group("player")


func take_dmg(dmg: int, type: String):

	match type:
		"normal":
			hp -= dmg
			
