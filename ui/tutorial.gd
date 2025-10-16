extends Control

@onready var controller: Node2D
@onready var label: Label = %Label
@onready var fade_rect: ColorRect = $FadeRect  # full-screen black ColorRect, alpha 0

var prev_angle_deg: float = 0.0
var angle_check_timer: float = 0.0

var steps := []
var step_index := 0
var transitioning := false

func _ready() -> void:
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
		{"text":"Tap to shoot the dummy",               "check": Callable(self, "_check_shot_against_boss")},
		{"text":"Destroy the dummy boss",               "check": Callable(self, "_check_boss_dead")}
	]

func _show_current_step() -> void:
	if step_index >= steps.size():
		_start_transition()
		return
	label.text = steps[step_index].text

func _process(delta: float) -> void:
	if not controller or transitioning:
		return

	angle_check_timer = max(0.0, angle_check_timer - delta)

	if step_index < steps.size():
		if steps[step_index]["check"].call():
			step_index += 1
			_show_current_step()

	if "angle_deg" in controller and angle_check_timer <= 0.0:
		prev_angle_deg = controller.angle_deg
		angle_check_timer = 0.25

func _start_transition():
	if transitioning:
		return
	transitioning = true
	fade_rect.visible = true
	fade_rect.modulate.a = 0
	# Tween alpha to 1 over 0.5s
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 0.5)
	tween.tween_callback(Callable(self, "_on_transition_complete"))

func _on_transition_complete():
	get_tree().change_scene_to_file("res://scenes/root.tscn")

# ---- CHECKERS (same as before) ----
func _check_right_hold() -> bool:
	for k in controller.active_touches.keys():
		var td = controller.active_touches[k]
		if td.duration >= controller.hold_threshold and td.position.x > get_viewport().size.x * 0.5:
			return true
	if controller.angle_deg - prev_angle_deg > 6.0:
		return true
	return false

func _check_left_hold() -> bool:
	for k in controller.active_touches.keys():
		var td = controller.active_touches[k]
		if td.duration >= controller.hold_threshold and td.position.x < get_viewport().size.x * 0.5:
			return true
	if controller.angle_deg - prev_angle_deg < -6.0:
		return true
	return false

func _check_shot_against_boss() -> bool:
	if controller.boss and controller.boss.hp < controller.boss.MAXHP:
		return true
	return false

func _check_boss_dead() -> bool:
	if controller.boss and controller.boss.hp <= 0:
		return true
	return false
