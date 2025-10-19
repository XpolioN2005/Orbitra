extends Control

var audio_played = false

@onready var audio = $audio

func _process(_delta):
	if Global.is_gameover:
		get_tree().paused = true
		if !audio_played:
			audio.play()
			audio_played =  true
		visible =  true
	else:
		audio_played =  false
		visible = false

func _on_button_pressed() -> void:
	get_tree().paused = false

	Global.is_gameover = false
	Global.is_gameWon =  false
	get_tree().reload_current_scene()