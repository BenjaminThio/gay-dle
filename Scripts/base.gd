extends StaticBody2D

@export var max_hitpoints: int = 2000
var hitpoints: int = max_hitpoints
var opponents_hitbox_uid: Array[int] = []
var uid: int
@onready var hitpoints_label: Label = $HitpointsLabel

func _ready():
	update_hitpoints_label()

func deal_damage_to_self(opponent_damage: int, _from = null) -> void:
	hitpoints -= opponent_damage
	update_hitpoints_label()
	
	if hitpoints <= 0:
		Global.victory = false
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/game_over.tscn")

func keep_dealing_damage_to_self(opponent_damage: int, opponent_attack_gap_duration: float, opponent_uid: int) -> void:
	deal_damage_to_self(opponent_damage)
	
	await time.pauseable_sleep(owner, opponent_attack_gap_duration)
	
	if opponent_uid in opponents_hitbox_uid:
		keep_dealing_damage_to_self(opponent_damage, opponent_attack_gap_duration, opponent_uid)

func update_hitpoints_label():
	hitpoints_label.text = str(hitpoints) + "/" + str(max_hitpoints)

func _on_opponent_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		opponents_hitbox_uid.append(body.uid)

func _on_opponent_body_exited(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		opponents_hitbox_uid.erase(body.uid)
