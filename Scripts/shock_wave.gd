extends Node2D

@export var blink_scale_up_config: Vector2 = Vector2(0.2, 0.2)
@export var blink_rotation_config: float = 360.0
@export var wave_scale_up_config: Vector2 = Vector2(7.0, 7.0)

@export var blink_scale_up_duration: float = 0.5
@export var blink_rotate_duration: float = 2.0
@export var wave_scale_up_duration: float = 1.0

@export var transition_pause: float = 0.3

@export var blink_invisible_duration: float = 2.0
@export var wave_invisible_duration: float = 0.7

@onready var blink: Sprite2D = $Blink
@onready var wave: Sprite2D = $Wave

func _ready():
	var tween: Tween = create_tween()
	
	tween.tween_property(blink, "scale", blink_scale_up_config, blink_scale_up_duration)
	tween.set_parallel().tween_property(blink, "rotation_degrees", blink_rotation_config, blink_rotate_duration)
	tween.set_parallel().tween_property(wave, "scale", wave_scale_up_config, wave_scale_up_duration)
	
	await time.sleep(transition_pause)
	
	tween = create_tween()
	
	tween.set_parallel().tween_property(blink, "self_modulate:a", 0.0, blink_invisible_duration).finished.connect(queue_free)
	tween.set_parallel().tween_property(wave, "self_modulate:a", 0.0, wave_invisible_duration)
