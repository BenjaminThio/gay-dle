extends Sprite2D

@export var speed: int = 100
var velocity: Vector2 = Vector2.ZERO

func _physics_process(delta):
	velocity.y = -speed * delta
	
	translate(velocity)

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
