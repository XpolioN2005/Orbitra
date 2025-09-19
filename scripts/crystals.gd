extends Node

@export var min_interval: float = 0.1
@export var max_interval: float = 0.6

var children: Array = []
var timer: float = 0.0
var next_time: float = 0.0

func _ready():
	# Collect all AnimatedSprite2D children
	for child in get_children():
		if child is AnimatedSprite2D:
			children.append(child)

	# set first random trigger
	_reset_timer()

func _process(delta):
	timer += delta
	if timer >= next_time and children.size() > 0:
		timer = 0
		_reset_timer()

		# Pick random child
		var chosen = children[randi() % children.size()]

		# Play its default animation
		if chosen.sprite_frames != null:
			var anims = chosen.sprite_frames.get_animation_names()
			if anims.size() > 0:
				chosen.play(anims[0])  # play first (default) animation

func _reset_timer():
	next_time = randf_range(min_interval, max_interval)
