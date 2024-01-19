extends Control

var opponents_hitbox: Array[CharacterBody2D] = []

func activate(cannon_damage: int):
	for opponent_hitbox in opponents_hitbox:
		if not opponent_hitbox.is_knockbacking:
			opponent_hitbox.knockback()
			opponent_hitbox.deal_damage_to_self(cannon_damage)

func _on_body_entered(body : Node2D) -> void:
	if body.is_in_group("enemy"):
		opponents_hitbox.append(body)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		opponents_hitbox.erase(body)
