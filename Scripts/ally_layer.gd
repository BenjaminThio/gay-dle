extends Node2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func knockback_all():
	for child in get_children():
		if child.is_in_group("ally"):
			var child_original_knockback_vector: Vector2 = child.knockback_vector
			var child_original_knockback_duration: float = child.knockback_duration
			
			child.gravity = gravity / 2.5
			child.knockback_vector = Vector2(200, -300)
			child.knockback_duration = 2.0
			child.knockback()
			time.pauseable_sleep(owner, child.knockback_duration, 
				func() -> void:
					if child != null:
						child.gravity = gravity
						child.knockback_vector = child_original_knockback_vector
						child.knockback_duration = child_original_knockback_duration
			)

"""func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_RIGHT:
		knockback_all()"""
