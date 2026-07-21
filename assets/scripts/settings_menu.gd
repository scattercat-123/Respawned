extends Control

@onready var click: AudioStreamPlayer = $Click
@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"
@onready var return_to_menu = [$ReturnToMenu1, $ReturnToMenu2]
@onready var settings_menu = [$Settings1, $Settings2]

var quit_hover = false
var settings_hover = false
var return_to_menu_hover = false
var last_mouse_state := false
var back_hover = false

func _process(_delta: float) -> void:
	if settings_hover and Input.is_action_just_pressed("lmb") and animation_player.current_animation != "Settings Open":
		animation_player.play("Settings Open")
		Global.settings_menu_open = true
	if back_hover and Input.is_action_just_pressed("lmb") and animation_player.current_animation != "Settings Open":
		animation_player.play_backwards("Settings Open")
		Global.settings_menu_open = false
	if quit_hover and Input.is_action_just_pressed("lmb") and animation_player.current_animation != "Settings Open":
		get_tree().quit()
		
func button_hover(buttons : Array):
	buttons[0].visible = false
	buttons[1].visible = true
	click.play()
	
func button_unhover(buttons : Array):
	buttons[0].visible = true
	buttons[1].visible = false

func _on_return_to_menu_mouse_entered() -> void:
	return_to_menu_hover = true
	if animation_player.is_playing() == false and Global.settings_menu_open == false:
		button_hover(return_to_menu)

func _on_return_to_menu_mouse_exited() -> void:
	return_to_menu_hover = false
	if animation_player.is_playing() == false and Global.settings_menu_open == false:
		button_unhover(return_to_menu)

func _on_settings_mouse_entered() -> void:
	settings_hover = true
	if animation_player.is_playing() == false and Global.settings_menu_open == false:
		button_hover(settings_menu)

func _on_settings_mouse_exited() -> void:
	settings_hover = false
	if animation_player.is_playing() == false and Global.settings_menu_open == false:
		button_unhover(settings_menu)

func _on_world_mouse_capture() -> void:
	if Global.settings_menu_open == false:
		animation_player.play_backwards("in")

func _on_world_mouse_visible() -> void:
	animation_player.play("in")


func _on_back_button_mouse_entered() -> void:
	click.play()
	$"../Back".position.y += 10
	back_hover = true

func _on_back_button_mouse_exited() -> void:
	$"../Back".position.y -= 10
	back_hover = false


func _on_quit_area_mouse_entered() -> void:
	quit_hover =true


func _on_quit_area_mouse_exited() -> void:
	quit_hover = false
