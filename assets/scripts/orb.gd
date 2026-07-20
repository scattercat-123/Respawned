extends Node3D

var played = false
var collecting = false

func _process(delta):
	if collecting:
		position.y += 10 * delta
		if position.y >= 5:
			queue_free()

	elif position.y < 1 and !played:
		$AudioStreamPlayer3D.play()
		played = true

func _on_area_body_entered(_body):
	$collect.play()
	collecting = true
	$AnimationPlayer.stop()
	Global.orbs_collected += 1
