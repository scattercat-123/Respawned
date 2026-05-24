extends Node3D

signal mouse_visible
signal mouse_capture

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(_delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("esc") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and Global.settings_menu_open == false:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		emit_signal("mouse_visible")
	elif event.is_action_pressed("esc") and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE and Global.settings_menu_open == false:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		emit_signal("mouse_capture")
