extends Area2D

@export var bullet_scene: PackedScene

@onready var boss : Node =  get_tree().get_first_node_in_group("boss")
@onready var sprite = $Sprite

var MAXHP = 20.0
var hp = 20.0

func _ready():
	add_to_group("damageable")
	add_to_group("player")

func _process(_delta):
	if hp <=0:
		Global.is_gameover = true
	else: Global.is_gameover = false



func take_dmg(dmg: int, type: String):

	match type:
		"normal":
			hp -= dmg
			
