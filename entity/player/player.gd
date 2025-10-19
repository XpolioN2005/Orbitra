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


func hit_effect_vulnerable():
	var original_scale = sprite.scale
	sprite.modulate = Color(1, 0.3, 0.3)   # brighter flash
	sprite.scale = original_scale * 1.05   # small punch
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color(1, 1, 1)
	sprite.scale = original_scale


func take_dmg(dmg: int, type: String):

	match type:
		"normal":
			hp -= dmg
		
	hit_effect_vulnerable()
			
