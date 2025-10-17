extends Control


func _process(_delta):
	if Global.is_gameWon:
		visible =  true
	else:
		visible = false

func _on_button_pressed() -> void:
	Global.is_gameover = false
	Global.is_gameWon =  false
	get_tree().reload_current_scene()