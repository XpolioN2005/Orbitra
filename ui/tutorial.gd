extends Control

@onready var controller: Node2D

# Inspector-linked UI
# @onready var panel: Panel = $Panel
@onready var label: Label = %Label

var prev_angle_deg: float = 0.0
var angle_check_timer: float = 0.0

var steps := []
var step_index := 0

func _ready() -> void:
	# find controller
	controller = get_tree().get_first_node_in_group("player_controller")

	if controller and "angle_deg" in controller:
		prev_angle_deg = controller.angle_deg

	_setup_steps()
	_show_current_step()
	set_process(true)

func _setup_steps() -> void:
	steps = [
		{"text":"Hold RIGHT side to rotate anticlockwise", "check": Callable(self, "_check_right_hold")},
		{"text":"Hold LEFT side to rotate clockwise",    "check": Callable(self, "_check_left_hold")},
		{"text":"Tap to shoot the dummy",           "check": Callable(self, "_check_shot_against_boss")},
		{"text":"Destroy the dummy boss",              "check": Callable(self, "_check_boss_dead")}
	]

func _show_current_step() -> void:
	if step_index >= steps.size():
		queue_free()
		return
	label.text = steps[step_index].text

func _process(delta: float) -> void:
	if not controller:
		return

	# sample angle periodically
	angle_check_timer = max(0.0, angle_check_timer - delta)

	if step_index < steps.size():
		if steps[step_index]["check"].call():
			step_index += 1
			_show_current_step()

	if "angle_deg" in controller and angle_check_timer <= 0.0:
		prev_angle_deg = controller.angle_deg
		angle_check_timer = 0.25

# ---- CHECKERS ----
func _check_right_hold() -> bool:
	if "active_touches" in controller and "hold_threshold" in controller:
		for k in controller.active_touches.keys():
			var td = controller.active_touches[k]
			if td.duration >= controller.hold_threshold and td.position.x > get_viewport().size.x * 0.5:
				return true
	if "angle_deg" in controller:
		if controller.angle_deg - prev_angle_deg > 6.0:
			return true
	return false

func _check_left_hold() -> bool:
	if "active_touches" in controller and "hold_threshold" in controller:
		for k in controller.active_touches.keys():
			var td = controller.active_touches[k]
			if td.duration >= controller.hold_threshold and td.position.x < get_viewport().size.x * 0.5:
				return true
	if "angle_deg" in controller:
		if controller.angle_deg - prev_angle_deg < -6.0:
			return true
	return false

func _check_shot_against_boss() -> bool:
	if "boss" in controller and controller.boss:
		if controller.boss.hp < controller.boss.MAXHP:
			return true
	return false

func _check_boss_dead() -> bool:
	if "boss" in controller and controller.boss:
		if controller.boss.hp <= 0:
			return true
	return false
