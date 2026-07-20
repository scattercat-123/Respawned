extends CanvasLayer
@onready var achievement_description_label: Label = $Objectives/Label2
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var fps_counter_label: Label = $Fps_counter_label

var find_10_orb_once = false

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	fps_counter_label.text = "FPS: " + str(snapped(Engine.get_frames_per_second(), 0))
	if Global.find_10th_orb == true and find_10_orb_once == false:
		find_10_orb_once = true
		objective_text("Find the last orb")
		await get_tree().create_timer(10.0).timeout

func objective_text(text : String):
	animation_player.play("objective_in")
	achievement_description_label.text = text
	$Objectives/Timer.start()
	await $Objectives/Timer.timeout
	animation_player.play_backwards("objective_in")
