extends CharacterBody3D
@onready var mesh: Node3D = $AuxScene6
@onready var camera_spring_arm: SpringArm3D = $"../Camera/SpringArm3D"
@onready var camera: Camera3D = $"../Camera/SpringArm3D/Camera3D"
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var floating_text: CanvasLayer = $"Floating text"
@onready var debug_label: Label = $Debug/Label
@onready var running: AudioStreamPlayer3D = $sounds/running
@onready var groan: AudioStreamPlayer3D = $sounds/groan

const FLOATING_TXT = preload("uid://cfdtq2rpm7d3v")

var turning_angle = 0.0
var combat_mode = false
var player_speed = 3
var mouse_sensitivity = 0.005
var current_anim = ""
var input_dir
var attacking = false
var last_hand_punch = "right"
var last_leg_kick = "right"
var jump_force = 3
var is_jumping = false
var last_collected_orb = 0
var cutscene_mode = false

func _ready() -> void:
	if Global.debug_mode == true:
		debug_label.visible = true

func _physics_process(delta: float) -> void:
	RenderingServer.global_shader_parameter_set("player_pos", position)
	camera.fov = Global.FOV
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and !is_jumping:
		sounds("jump")
		velocity.y = jump_force
		is_jumping = true
		animation_player.play("combat-jump")
		animation_player.seek(0.85)
		await get_tree().create_timer(0.6).timeout
		sounds("land")
		is_jumping = false
		current_anim = ""
		
	$"../Camera".global_position = lerp($"../Camera".global_position, global_position, 0.5)
	if not is_on_floor():
		velocity += get_gravity() * delta

	input_dir = Input.get_vector("d", "a", "s", "w")
	mesh.rotation.y = lerp_angle(
		mesh.rotation.y,
		camera.global_rotation.y + PI + turning_angle,
		delta * 5
	)
	
	var direction = Vector3(input_dir.x, 0, input_dir.y)
	direction = direction.rotated(Vector3.UP, mesh.rotation.y - turning_angle).normalized()
	if combat_mode == false:
		if direction != Vector3.ZERO:
			velocity.x = direction.x * player_speed
			velocity.z = direction.z * player_speed
		else:
			velocity.x = lerp(velocity.x, direction.x * player_speed, delta * 10)
			velocity.z = lerp(velocity.z, direction.z * player_speed, delta * 10)
		
	move_and_slide()

func _process(_delta: float) -> void:
	debug_label.text = str(Global.orbs_collected)
	movement()
	sounds("process")
	combat()
			
	if Global.orbs_collected != last_collected_orb:
		last_collected_orb = Global.orbs_collected
		text_msg("System log #00" + str(Global.orbs_collected), Color(0.525, 0.0, 0.0, 1.0), 60, 2)
		await get_tree().create_timer(0.4).timeout
		text_msg("Memory_restor_percent = " + str(snapped((Global.orbs_collected*10 + randf_range(0.0, 5.0)), 0.01)), Color(0.599, 0.411, 0.0, 1.0), 50, 2)
	
	if Global.orbs_collected == 9 and not Global.find_10th_orb:
		await get_tree().create_timer(5).timeout
		Global.find_10th_orb = true
		await get_tree().create_timer(10).timeout
		Dialogic.start_timeline("cannot_find_10th_orb")
		await Dialogic.timeline_ended
		Dialogic.start_timeline("weak")
		await Dialogic.timeline_ended
		groan.play()
		cutscene_mode = true
		animation_player.play("combat-weak")
		await get_tree().create_timer(2.5).timeout
		Global.ill = true

func combat():
	if cutscene_mode == true:
		return
	if Input.is_action_just_pressed("c") and (animation_player.current_animation != "combat-punch-idle1" and animation_player.current_animation != "combat-punch-idle2"):
		combat_mode = true
		velocity.x = 0
		velocity.z = 0
		var anim = random(2, ["combat-punch-idle1", "combat-punch-idle2"])
		play_anim(anim)
		var rand_percentage = snappedf(randf_range(80, 100), 0.01)
		if animation_player.current_animation == "combat-punch-idle1":
			text_msg("combat type:Alpha=" + str(rand_percentage), Color(0, 0, 0), 80, 2)
		else:
			text_msg("combat type:Beta=" + str(rand_percentage), Color(0, 0, 0), 80, 2)
	elif Input.is_action_just_pressed("c") and combat_mode == true:
		combat_mode = false
	if Input.is_action_pressed("shift") and Input.is_action_pressed("1") and attacking == false:
		animation_player.speed_scale=1.3
		var anim = random(2, ["combat-punch-combo1", "combat-punch-combo2"])
		play_anim(anim)
		attacking = true
		await animation_player.animation_finished
		var idle_anim = random(2, ["combat-punch-idle1", "combat-punch-idle2"])
		play_anim(idle_anim)
		if animation_player.current_animation == "combat-punch-idle1":
			text_msg("combat return type:Alpha", Color(0.252, 0.252, 0.252, 1.0), 60, 3)
		else:
			text_msg("combat return type:Beta", Color(0.248, 0.248, 0.248, 1.0), 60, 3)
		attacking = false
		animation_player.speed_scale=1
	elif Input.is_action_just_pressed("1") and combat_mode == true and attacking == false:
		if last_hand_punch == "right":
			play_anim("combat-punch-left")
			text_msg("close-range lower L-limb pressure applied", Color(0.545, 0.0, 0.0, 1.0), 80, 2)
			last_hand_punch = "left"
		elif last_hand_punch == "left":
			play_anim("combat-punch-right")
			text_msg("close-range lower R-limb pressure applied", Color(0.545, 0.0, 0.0, 1.0), 80, 2)
			last_hand_punch = "right"
		attacking = true
		await animation_player.animation_finished
		attacking = false
		var anim = random(2, ["combat-punch-idle1", "combat-punch-idle2"])
		play_anim(anim)
		if animation_player.current_animation == "combat-punch-idle1":
			text_msg("combat return type:Alpha", Color(0.252, 0.252, 0.252, 1.0), 60, 3)
		else:
			text_msg("combat return type:Beta", Color(0.248, 0.248, 0.248, 1.0), 60, 3)
	if Input.is_action_just_pressed("2") and combat_mode == true and attacking == false and Input.is_action_pressed("shift"):
		var anim = random(2, ["combat-kick-fly1", "combat-kick-fly2"])
		var kick_dir = mesh.global_transform.basis.z
		play_anim(anim)
		if anim == "combat-kick-fly1":
			text_msg("airborne sequence in progress with type null", Color(0.545, 0.0, 0.0, 1.0), 70, 2)
			velocity.y = 3
			velocity.x = kick_dir.x * 150
			velocity.z = kick_dir.z * 150
		else:
			animation_player.seek(0.9)
			velocity.y = 2
			velocity.x = kick_dir.x * 100
			velocity.z = kick_dir.z * 100
			text_msg("airborne sequence in progress with type delta", Color(0.545, 0.0, 0.0, 1.0), 70, 2)
		attacking = true
		await animation_player.animation_finished
		velocity = Vector3.ZERO
		var idle_anim = random(2, ["combat-punch-idle1", "combat-punch-idle2"])
		play_anim(idle_anim)
		if animation_player.current_animation == "combat-punch-idle1":
			text_msg("combat return type:Alpha", Color(0.252, 0.252, 0.252, 1.0), 60, 3)
		else:
			text_msg("combat return type:Beta", Color(0.248, 0.248, 0.248, 1.0), 60, 3)
		attacking = false
	elif Input.is_action_just_pressed("2") and combat_mode == true and attacking == false:
		animation_player.speed_scale = 1.6
		if last_leg_kick == "right":
			play_anim("combat-kick-left")
			text_msg("L-limb pressure applied", Color(0.545, 0.0, 0.0, 1.0), 80, 2)
			last_leg_kick = "left"
		elif last_leg_kick == "left":
			play_anim("combat-kick-right")
			text_msg("R-limb pressure applied", Color(0.545, 0.0, 0.0, 1.0), 80, 2)
			last_leg_kick = "right"
		attacking = true
		await animation_player.animation_finished
		animation_player.speed_scale = 1
		attacking = false
		var anim = random(2, ["combat-punch-idle1", "combat-punch-idle2"])
		play_anim(anim)
		if animation_player.current_animation == "combat-punch-idle1":
			text_msg("combat return type:Alpha", Color(0.252, 0.252, 0.252, 1.0), 60, 3)
		else:
			text_msg("combat return type:Beta", Color(0.248, 0.248, 0.248, 1.0), 60, 3)

func sounds(sound : String):
	var move_speed = Vector2(velocity.x, velocity.z).length()
	if sound == "jump":
		var rand = randi_range(1, 4)
		get_node("sounds/jump"+str(rand)).play()
	if sound == "land":
		var rand = randi_range(1, 4)
		get_node("sounds/land"+str(rand)).play()
	if sound == "process":
		if move_speed > 0.1 and is_on_floor():
			var target_db : float
			if !running.playing:
				running.play()
			running.pitch_scale = move_speed / 3.5
			if Input.is_action_pressed("w"):
				target_db = -15
			else:
				target_db = -19
			running.volume_db = lerpf(running.volume_db, target_db, 0.05)
		else:
			running.volume_db = lerpf(running.volume_db, -80, 0.1)

func movement():
	if cutscene_mode == true:
		return
	if combat_mode == false and is_jumping == false:
		if Input.is_action_pressed("w") and Input.is_action_pressed("a"):
			play_anim("combat-run-front")
			player_speed = 3
			turning_angle=45
		elif Input.is_action_pressed("w") and Input.is_action_pressed("d"):
			play_anim("combat-run-front")
			player_speed = 3
			turning_angle = -45
		elif Input.is_action_pressed("s") and Input.is_action_pressed("a"):
			play_anim("combat-strafe-left")
			player_speed = 2
			turning_angle = 20
		elif Input.is_action_pressed("s") and Input.is_action_pressed("d"):
			play_anim("combat-strafe-right")
			player_speed = 2
			turning_angle = -20
		elif Input.is_action_pressed("w"):
			play_anim("combat-run-front")
			turning_angle = 0
			player_speed = 3
		elif Input.is_action_pressed("a"):
			turning_angle = 0
			player_speed = 2
			play_anim("combat-strafe-left")
		elif Input.is_action_pressed("d"):
			turning_angle = 0
			player_speed = 2
			play_anim("combat-strafe-right")
		elif Input.is_action_pressed("s"):
			turning_angle = 0
			play_anim("combat-run-back")
			player_speed = 2
		else:
			if attacking==false:
				play_anim("combat-idle")

func text_msg(txt : String, color : Color, size : int, speed : float):
	var label = Label.new()
	add_child(label)
	label.text = txt
	label.add_theme_font_size_override("font_size", size - 22)
	label.theme = FLOATING_TXT
	label.add_theme_color_override("font_color", color)
	label.position = Vector2(1090, 540)
	var pos_tween = create_tween()
	var fade_tween = create_tween()
	pos_tween.tween_property(label, "position", label.position+Vector2(0, +800), speed)
	fade_tween.tween_property(label, "modulate:a", 0.3, 1.5)
	await pos_tween.finished
	label.queue_free()
	
func play_anim(animation : String):
	if current_anim != animation:
		animation_player.play(animation)
		current_anim = animation

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_spring_arm.rotation.x -= event.relative.y * mouse_sensitivity
		camera_spring_arm.rotation.y -= event.relative.x * mouse_sensitivity
		
		camera_spring_arm.rotation.y = wrapf(camera_spring_arm.rotation.y, 0.0, TAU)
		camera_spring_arm.rotation.x = clamp(camera_spring_arm.rotation.x, -PI/2, PI/4)

func random(many : int, what : Array):
	var rand = randi_range(0, many-1)
	return what[rand]

func cutscene_changer(true_or_false : bool):
	cutscene_mode = true_or_false
	if true_or_false == false:
		animation_player.play("combat-idle")
