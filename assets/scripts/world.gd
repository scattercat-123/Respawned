extends Node3D

@onready var character: CharacterBody3D = $Character
@onready var intro_camera: Camera3D = $"intro_camera_pivot/Intro Camera"
@onready var camera_3d: Camera3D = $Camera/SpringArm3D/Camera3D
@onready var overlay_player: AnimationPlayer = $Overlay/AnimationPlayer
@onready var player_animation: AnimationPlayer = $Character/AnimationPlayer

signal mouse_visible
signal mouse_capture

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(_delta):
	if Global.started == false:
		$intro_camera_pivot.rotation.y += 0.02
	elif Global.started == true and not camera_3d.current:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		player_animation.play("combat-idle")
		$Overlay.visible = true
		overlay_player.play("in")
		camera_3d.current = true
		intro_camera.current = false
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("esc") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and Global.settings_menu_open == false:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		emit_signal("mouse_visible")
	elif event.is_action_pressed("esc") and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE and Global.settings_menu_open == false:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		emit_signal("mouse_capture")
