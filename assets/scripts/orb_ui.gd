extends Node2D
@onready var collected_number_label: Label = $Label
@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"

var moved_in = false
var last_orb_visible_changed = 0

func _process(_delta: float) -> void:
	if Global.orbs_collected == 1 and moved_in == false:
		moved_in = true
		animation_player.play("orbs_collected_ui_move_in")
	if Global.orbs_collected != last_orb_visible_changed:
		collected_number_label.text = str(Global.orbs_collected) + "/10"
		get_node("Orb" + str(Global.orbs_collected)).visible = true
		last_orb_visible_changed = Global.orbs_collected
