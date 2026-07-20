extends Node2D
@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"

var hover_x_button = false
var hover_resume_button = false

func _process(delta: float) -> void:
	if hover_resume_button == true and Input.is_action_just_pressed("lmb"):
		get_tree().quit()
	if hover_x_button == true and Input.is_action_just_pressed("lmb") and not animation_player.is_playing():
		animation_player.play_backwards("developers_note_in")
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_area_2d_mouse_entered() -> void:
	hover_x_button = true

func _on_area_2d_mouse_exited() -> void:
	hover_x_button = false

func _on_area_2d_area_entered(area: Area2D) -> void:
	hover_resume_button = true

func _on_area_2d_area_exited(area: Area2D) -> void:
	hover_resume_button = false
