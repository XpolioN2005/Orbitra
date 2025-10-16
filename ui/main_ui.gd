extends Control

@onready var player_bar: ProgressBar = %player_bar
@onready var boss_bar: ProgressBar  = %boss_bar

var player: Node2D
var boss: Node2D

@export var smooth_speed: float = 8.0  # higher = snappier

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	boss   = get_tree().get_first_node_in_group("boss")

	player_bar.max_value = player.MAXHP
	boss_bar.max_value  = boss.MAXHP

	# start clean
	player_bar.value = player.hp
	boss_bar.value  = boss.hp

func _process(delta: float) -> void:
	var t: float = clamp(smooth_speed * delta, 0.0, 1.0)
	player_bar.value = lerp(player_bar.value, player.hp, t)
	boss_bar.value  = lerp(boss_bar.value, boss.hp, t)
