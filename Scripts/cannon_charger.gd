extends Node2D

@export var charge_duration: float = 70.0
@export var full_charged_blink_hint_duration: float = 0.4
@export var cannon_damage: int = 200
var fireable: bool = false
var opponents_hitbox: Array[CharacterBody2D] = []
@onready var cooldown_progress_bar: TextureProgressBar = $CooldownProgressBar
@onready var cannon: HBoxContainer = get_tree().get_first_node_in_group("cannon").get_child(0)
@onready var cannon_attack_range_dotted_line: Sprite2D = get_tree().get_first_node_in_group("cannon").get_child(1)

func _ready() -> void:
	charge()

func charge() -> void:
	cannon_attack_range_dotted_line.hide()
	cooldown_progress_bar.tint_progress = Color.MAGENTA
	cooldown_progress_bar.value = cooldown_progress_bar.min_value
	create_tween().tween_property(cooldown_progress_bar, "value", cooldown_progress_bar.max_value, charge_duration).finished.connect(
		func():
			fireable = true
			cannon_attack_range_dotted_line.show()
			blink()
	)

func blink() -> void:
	var full_charged_blink_hint_half_duration: float = full_charged_blink_hint_duration / 2
	
	cooldown_progress_bar.tint_progress = Color(1, 0.5, 1)
	
	await time.pauseable_sleep(owner, full_charged_blink_hint_half_duration)
	
	if fireable: cooldown_progress_bar.tint_progress = Color.MAGENTA
	else: return
	
	await time.pauseable_sleep(owner, full_charged_blink_hint_half_duration)
		
	if fireable: blink()

func _on_fire_button_pressed() -> void:
	if fireable:
		fireable = false
		cannon.fire(cannon_damage)
		charge()
