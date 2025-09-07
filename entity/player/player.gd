extends Area2D

@export var bullet_scene: PackedScene

var hp = 20

func _ready():
    get_parent().shoot_bullet.connect(_on_shoot_bullet)
    add_to_group("damageable")

func _on_shoot_bullet():

    print("shoot")

func take_dmg(dmg: int, type: String):
    hp -= dmg

    match type:
        "normal":
            pass
