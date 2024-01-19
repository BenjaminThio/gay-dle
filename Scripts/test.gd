extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var knockback_vector: Vector2 = Vector2(-300, -300)
var knockback_duration: float = 0.8
var is_knockbacking: bool = false

func _physics_process(delta) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if Input.is_action_just_pressed("ui_accept") and not is_knockbacking:
		velocity = knockback_vector
		is_knockbacking = true
		create_tween().tween_property(self, "velocity:x", 0, knockback_duration).finished.connect(
			func() -> void:
				is_knockbacking = false
		)
	
	move_and_slide()
