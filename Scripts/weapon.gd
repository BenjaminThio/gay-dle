extends Node2D

var damage: int
var target_uid: int
var single_attack: bool
var has_damaged: bool = false

@onready var slay_animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var slay_audio_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	slay_animation.rotation_degrees = randi_range(220, 310)
	slay_animation.play("slay")
	slay_animation.animation_finished.connect(queue_free)
	Audio.play_sound("slay")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("ally"):
		if single_attack and body.uid == target_uid and not has_damaged or not single_attack and not has_damaged:
			body.deal_damage_to_self(damage)
			has_damaged = true
