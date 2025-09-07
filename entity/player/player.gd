extends Area2D

@export var bullet_scene: PackedScene

var boss

var hp = 20

func _ready():
    add_to_group("damageable")


func take_dmg(dmg: int, type: String):

    match type:
        "normal":
            hp -= dmg
            
