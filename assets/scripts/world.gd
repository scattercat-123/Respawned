extends Node3D

@onready var character: CharacterBody3D = $Character
@onready var intro_camera: Camera3D = $"intro_camera_pivot/Intro Camera"
@onready var camera_3d: Camera3D = $Camera/SpringArm3D/Camera3D
@onready var overlay_player: AnimationPlayer = $Overlay/AnimationPlayer
@onready var player_animation: AnimationPlayer = $Character/AnimationPlayer
@onready var ui: CanvasLayer = $UI

var memory_orb = preload("res://assets/scenes/orb.tscn")
var last_collected_orb = 0

signal mouse_visible
signal mouse_capture

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Dialogic.signal_event.connect(_on_dialogic_signal)
	randomize()

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
		Dialogic.start("orb_1")
	if Global.orbs_collected != last_collected_orb:
		last_collected_orb = Global.orbs_collected
		if Global.orbs_collected == 1:
			Dialogic.start_timeline("orb_2")
		elif Global.orbs_collected == 2:
			Dialogic.start_timeline("orb_3")
		elif Global.orbs_collected == 3:
			Dialogic.start_timeline("orb_4")
		elif Global.orbs_collected == 5:
			Dialogic.start_timeline("orb_5")
		elif Global.orbs_collected == 7:
			Dialogic.start_timeline("orb_6")
		elif Global.orbs_collected == 9:
			Dialogic.start_timeline("orb_7")
	if Global.ill == true and $Overlay.visible == false:
		$Overlay.visible = true
		overlay_player.play_backwards("in")
		

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("esc") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and Global.settings_menu_open == false:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		emit_signal("mouse_visible")
	elif event.is_action_pressed("esc") and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE and Global.settings_menu_open == false:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		emit_signal("mouse_capture")

func _on_dialogic_signal(argument:String):
	if argument == "orb_achievement":
		ui.objective_text("Look around the area for clues.")
	if argument == "drop_orbs":
		memory_orb_spawn(9)
		
func memory_orb_spawn(number:int):
	for i in range(number):
		var random_spawn_time = randi_range(1, 3)
		await get_tree().create_timer(random_spawn_time).timeout
		var rand_z = randi_range(-20, 20)
		var rand_x = randi_range(-20, 20)
		var rand_y_rotation = randi_range(0, 360)
		var orb_scene = memory_orb.instantiate()
		orb_scene.position = Vector3(rand_x, 20, rand_z)
		orb_scene.rotation.y = deg_to_rad(rand_y_rotation)
		add_child(orb_scene)
