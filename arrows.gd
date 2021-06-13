extends Node2D

var space_started = false
var arrows_started = false

func _input(event):
#	if event.is_action_pressed("switch") and not space_started:
#		space_started = true
#		var t = Tween.new()
#		t.interpolate_property($Space, "modulate", Color(1,1,1,1), Color(1,1,1,0), 0.5, Tween.TRANS_CIRC, Tween.EASE_OUT)
#		t.interpolate_property($Arrows, "modulate", Color(1,1,1,0), Color(1,1,1,1), 0.5, Tween.TRANS_CIRC, Tween.EASE_IN)
#		add_child(t)
#		t.start()
#		yield(t, "tween_completed")
#		$Space.hide()
	
	if not arrows_started and (event.is_action_pressed("up") or event.is_action_pressed("down") or event.is_action_pressed("left") or event.is_action_pressed("right")):
		arrows_started = true
		var t = Tween.new()
		t.interpolate_property(self, "modulate", Color(1,1,1,1), Color(1,1,1,0), 0.2, Tween.TRANS_CIRC, Tween.EASE_OUT)
		add_child(t)
		t.start()
		yield(t, "tween_completed")
		$Arrows.hide()
	
