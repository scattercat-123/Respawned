extends Node2D
@onready var animation_player: AnimationPlayer = $Menu/AnimationPlayer
@onready var shine: AudioStreamPlayer = $shine
@onready var bass_drop: AudioStreamPlayer = $bass_drop
@onready var person_animation: AnimationPlayer = $World/World/Character/AnimationPlayer
@onready var timer: Timer = $Timer
@onready var musics = [$"Brentin Davis - Combat Fire", $"Gwyn, Lord of Cinder", $"Dorian Concept - Hide CS01", $"Encounter" ]
@onready var musics_names = ["Brentin Davis - Combat Fire", "Gwyn, Lord of Cinder", "Dorian Concept - Hide CS01", "Encounter"]
@onready var music_label: Label = $Music_Label

var animations : Array
var play_button_hover = false

func _ready() -> void:
	randomize()
	if Global.debug_mode:
		Global.started = true
		get_tree().change_scene_to_file("res://assets/scenes/world.tscn")

	animations = person_animation.get_animation_list()
	await get_tree().create_timer(0.75).timeout
	shine.play()
	await get_tree().create_timer(1.75).timeout
	bass_drop.play()

func _process(_delta: float) -> void:
	if play_button_hover == true and Input.is_action_just_pressed("lmb"):
		animation_player.play("play")
		for songs in musics:
			songs.volume_db = -40

func _on_play_area_mouse_entered() -> void:
	play_button_hover = true
	print("yes")

func _on_play_area_mouse_exited() -> void:
	play_button_hover = false

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "intro":
		animation_player.play("bobbing")
		timer.start()
		music()
	if anim_name == "play":
		Global.started = true
		get_tree().change_scene_to_file("res://assets/scenes/world.tscn")

func _on_timer_timeout() -> void:
	if !Global.started:
		timer.start()
		var rand = animations.pick_random()
		person_animation.play(rand)

func _on_gwyn_lord_of_cinder_finished() -> void:
	animation_player.play_backwards("new_music")
	await get_tree().create_timer(1.0).timeout
	music()

func _on_brentin_davis__combat_fire_finished() -> void:
	animation_player.play_backwards("new_music")
	await get_tree().create_timer(1.0).timeout
	music()

func _on_dorian_concept__hide_cs_01_finished() -> void:
	animation_player.play_backwards("new_music")
	await get_tree().create_timer(1.0).timeout
	music()
	
func _on_encounter_finished() -> void:
	animation_player.play_backwards("new_music")
	await get_tree().create_timer(1.0).timeout
	music()
	
func music() -> void:
	var rand = randi_range(0, musics.size()-1)
	if musics[rand].playing == false:
		animation_player.play("new_music")
		music_label.text = musics_names[rand]
		musics[rand].play()
