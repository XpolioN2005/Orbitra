extends Node2D

@export var orbit_speed: float = 180
@export var hold_threshold: float = 0.15 # seconds before orbiting starts
@export var fire_cooldown: float = 0.3

var angle_deg: float = 0
var fire_timer: float = 0

@onready var player = %player
@onready var boss = %boss
@onready var bullet_engine = %bulletEngine


# Track touches
var active_touches = {}

func _ready():
	player.boss = boss

func _process(delta):
	handle_orbit(delta, delta)
	fire_timer -= delta
	update_player_position()

func handle_orbit(delta, dt):
	var left = false
	var right = false
	
	for touch_index in active_touches.keys():
		var touch_data = active_touches[touch_index]
		touch_data["duration"] += dt
		
		# Only start orbiting after hold_threshold
		if touch_data["duration"] >= hold_threshold:
			if touch_data["position"].x < get_viewport().size.x / 2:
				left = true
			else:
				right = true
	
	if left:
		angle_deg -= orbit_speed * delta
	if right:
		angle_deg += orbit_speed * delta

func update_player_position():
	var radius = (get_viewport().size.y -60) / 1.5
	var rad = deg_to_rad(angle_deg)
	player.global_position = global_position + Vector2(sin(rad), cos(rad)) * radius
	player.look_at(global_position)


func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			# New touch: store start time & position
			active_touches[event.index] = {
				"duration": 0.0,
				"position": event.position
			}
		else:
			# Touch released → tap if under threshold
			var touch_data = active_touches.get(event.index)
			if touch_data:
				if touch_data["duration"] < hold_threshold:

					var dir =  boss.global_position - player.global_position
					bullet_engine.shoot_straight(player.global_position, dir, player)
				
				active_touches.erase(event.index)
