extends Sprite2D

@export var blink_scale_up_config: Vector2 = Vector2(0.2, 0.2)
@export var blink_scale_up_duration: float = 0.3

@export var transition_pause: float = 0.3

@export var blink_invisible_duration: float = 1.0

func _ready():
	var tween: Tween = create_tween()
	
	tween.tween_property(self, "scale", blink_scale_up_config, blink_scale_up_duration)
	
	await time.sleep(transition_pause)
	
	tween = create_tween()
	
	tween.set_parallel().tween_property(self, "self_modulate:a", 0.0, blink_invisible_duration).finished.connect(queue_free)
