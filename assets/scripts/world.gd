extends Node3D

@onready var character: CharacterBody3D = $Character
@onready var intro_camera: Camera3D = $"intro_camera_pivot/Intro Camera"
@onready var camera_3d: Camera3D = $Camera/SpringArm3D/Camera3D
@onready var overlay_player: AnimationPlayer = $Overlay/AnimationPlayer
@onready var player_animation: AnimationPlayer = $Character/AnimationPlayer
@onready var ui: CanvasLayer = $UI
@onready var keyboard_sprite: AnimatedSprite2D = $UI/Tutorial/AnimatedSprite2D
@onready var keyboard_label: Label = $UI/Tutorial/Label
@onready var ui_animation_player: AnimationPlayer = $UI/AnimationPlayer

var memory_orb = preload("res://assets/scenes/orb.tscn")
var last_collected_orb = 0
var illness_started = false
var pressing_key_tutorial = ""

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
	if Global.ill == true and illness_started == false:
		illness_started = true
		overlay_player.play_backwards("in")
		await get_tree().create_timer(3.0).timeout
		character.position = Vector3(4.117, -11.9, 0)
		overlay_player.play("in")
		character.cutscene_changer(false)
		await get_tree().create_timer(1.0).timeout
		Dialogic.start("tutorial_1")
	if pressing_key_tutorial:
		if Input.is_action_pressed("c") and pressing_key_tutorial == "c":
			keyboard_sprite.play("c_press")
			await get_tree().create_timer(1.0).timeout
			ui_animation_player.play_backwards("press")
			pressing_key_tutorial == ""
			Dialogic.start("c_pressed")
		if Input.is_action_pressed("1") and pressing_key_tutorial == "1":
			keyboard_sprite.play("1_press")
			await get_tree().create_timer(1.0).timeout
			ui_animation_player.play_backwards("press")
			pressing_key_tutorial == ""
			Dialogic.start("1_pressed")
		if Input.is_action_pressed("2") and pressing_key_tutorial == "2":
			keyboard_sprite.play("2_press")
			await get_tree().create_timer(1.0).timeout
			ui_animation_player.play_backwards("press")
			pressing_key_tutorial == ""
			Dialogic.start("2_pressed")

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
	if argument == "press_c":
		pressing_key_tutorial = "c"
		ui_animation_player.play("press")
		keyboard_sprite.play("c")
	if argument == "1_press":
		pressing_key_tutorial = "1"
		ui_animation_player.play("press")
		keyboard_sprite.play("1")
	if argument == "2_press":
		pressing_key_tutorial = "2"
		ui_animation_player.play("press")
		keyboard_sprite.play("2")
	if argument == "get_up":
		keyboard_sprite.play("default")
		overlay_player.play_backwards("in")
		await overlay_player.animation_finished
		character.position = Vector3(0, 0.75, 0)
		overlay_player.play("in")
		await get_tree().create_timer(0.75).timeout
		character.cutscene_changer(true)
		player_animation.play("combat-get-up")
		await player_animation.animation_finished
		character.cutscene_changer(false)
		character.combat_mode = false
		player_animation.play("combat-idle")
		await get_tree().create_timer(7.5).timeout
		ui_animation_player.play("developers_note_in")
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		Input.warp_mouse(Vector2(5, 5))
		
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
