extends Area2D

var opponents_hitbox: Array = []
var damage: int
var rotate_speed: float = 30

func _process(delta):
	rotation_degrees += PI * rotate_speed * delta

func explode():
	await time.pauseable_sleep(self, 0.00001)
	
	for scale_index in range(5):
		var test: float = (scale_index + 1) * 2 / 10.0
		var test2: float = (scale_index + 1) * 2 / 7.0
		
		await create_tween().tween_property(self, "scale", Vector2(test2, test2), 1.0 + test).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT_IN).finished
		
		await time.pauseable_sleep(self, test)
	
	for opponent_hitbox in opponents_hitbox:
		if opponent_hitbox.uid == 0:
			opponent_hitbox.deal_damage_to_self(99999)
		else:
			opponent_hitbox.deal_damage_to_self(damage)
	
	queue_free()

func _on_opponent_entered(body):
	if body.is_in_group("ally"):
		opponents_hitbox.append(body)

func _on_opponent_exited(body):
	if body.is_in_group("ally"):
		opponents_hitbox.erase(body)
