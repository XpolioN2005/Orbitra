extends Node2D

@export var orbit_speed: float = 180
@export var hold_threshold: float = 0.15 # seconds before orbiting starts
@export var fire_cooldown: float = 0.3
@export var radius_base: float = 300
@export var radius_bump: float = 80          # how far radius expands
@export var bump_speed: float = 8.0          # how fast bump happens
@export var return_speed: float = 4.0        # how fast it returns

var angle_deg: float = 0
var fire_timer: float = 0

var current_radius: float
var target_radius: float

@onready var player = %player
@onready var boss = %boss
@onready var bullet_engine = %bulletEngine

# Track touches
var active_touches = {}

func _ready():
	current_radius = radius_base
	target_radius = radius_base

func _process(delta):
	handle_orbit(delta, delta)
	fire_timer -= delta

	# Smoothly approach target radius
	current_radius = move_toward(current_radius, target_radius, delta * (bump_speed if target_radius > radius_base else return_speed) * radius_bump)

	# When close to target and it's bumped, switch back to base
	if target_radius > radius_base and abs(current_radius - target_radius) < 1.0:
		target_radius = radius_base

	update_player_position()

func handle_orbit(delta, dt):
	var left = false
	var right = false
	
	for touch_index in active_touches.keys():
		var touch_data = active_touches[touch_index]
		touch_data["duration"] += dt
		
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
	var rad = deg_to_rad(angle_deg)
	player.global_position = global_position + Vector2(sin(rad), cos(rad)) * current_radius
	
	var pos_x = (global_position - player.global_position).x
	player.sprite.flip_h = pos_x < 0

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			active_touches[event.index] = {
				"duration": 0.0,
				"position": event.position
			}
		else:
			var touch_data = active_touches.get(event.index)
			if touch_data:
				if touch_data["duration"] < hold_threshold:
					var dir = boss.global_position - player.global_position
					bullet_engine.shoot_straight(player.global_position, dir, player, 1)

					target_radius = radius_base + radius_bump

				active_touches.erase(event.index)
