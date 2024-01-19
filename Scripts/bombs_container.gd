extends HBoxContainer

var bomb_quantity: int = 6
var max_bomb_alpha: float = 0.7
var bomb_appear_duration: float = 0.2
var bomb_dissapear_duration: float = 0.4
var new_bomb_appear_gap_duration: float = 0.2

func fire(cannon_damage: int):
	var bombs: Array[Node] = get_children()
	
	bombs.reverse()
	
	for bomb in bombs:
		create_tween().tween_property(bomb, "modulate:a", max_bomb_alpha, bomb_appear_duration).finished.connect(
			func() -> void:
				bomb.activate(cannon_damage)
				create_tween().tween_property(bomb, "modulate:a", 0, bomb_dissapear_duration)
		)
		
		await time.sleep(new_bomb_appear_gap_duration)
