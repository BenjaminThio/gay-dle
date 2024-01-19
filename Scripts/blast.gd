extends Area2D

enum DIRECTION {
	LEFT,
	RIGHT
}
@export var direction: DIRECTION = DIRECTION.LEFT
@export var speed: int = 100
var damage: int
var second_damage: int
var velocity: Vector2 = Vector2.ZERO
var target_uid: int
var single_attack: bool
var moveable: bool = true

func _physics_process(delta) -> void:
	if moveable:
		velocity.x = speed * get_direction() * delta
	else:
		velocity.x = 0
	
	translate(velocity)

func get_direction() -> int: return (direction * 2) - 1

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		if single_attack and body.uid == target_uid or not single_attack:
			body.deal_damage_to_self(damage, 0)
		
		moveable = false
		
		var tween: Tween = create_tween()
		
		tween.tween_property(self, "scale", Vector2(2, 2), 0.5)
		tween.set_parallel().tween_property(self, "modulate:a", 0, 0.5).finished.connect(
			func() -> void:
				if body != null:
					body.deal_damage_to_self(damage, 0)
				
				queue_free()
		)

