extends Area2D

var opponents_hitbox: Array = []
var damage: int

func explode():
	await time.pauseable_sleep(self, 0.00001)
	
	loop_shake_by_position(self)
	
	for scale_index in range(5):
		var test: float = (scale_index + 1) * 2 / 13.0
		var test2: float = (scale_index + 1) * 2 / 10.0
		
		await create_tween().tween_property(self, "scale", Vector2(test2, test2), 1.0 + test).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT_IN).finished
		
		await time.pauseable_sleep(self, test)
	
	for opponent_hitbox in opponents_hitbox:
		opponent_hitbox.deal_damage_to_self(damage)
	
	queue_free()

func loop_shake_by_position(target: Node2D, offset_value: float = 1.0, delay_time: float = 0.03) -> void:
	await shake_by_position(target, offset_value, delay_time)
	loop_shake_by_position(target, offset_value, delay_time)

func shake_by_position(target: Node2D, offset_value: float = 1.0, delay_time: float = 0.03) -> void:
	var target_origin: Vector2 = target.position
	
	target.position = Vector2(target_origin.x + generate_random_shake_offset(offset_value), target_origin.y + generate_random_shake_offset(offset_value))
	await time.sleep(delay_time)
	target.position = target_origin

func generate_random_shake_offset(offset_value: float) -> float:
	var offset_values: PackedFloat32Array = [-offset_value, offset_value]
	
	return Random.choice(offset_values)

func _on_opponent_entered(body):
	if body.is_in_group("enemy"):
		opponents_hitbox.append(body)

func _on_opponent_exited(body):
	if body.is_in_group("enemy"):
		opponents_hitbox.erase(body)
