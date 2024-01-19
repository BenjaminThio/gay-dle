extends Area2D

enum DIRECTION {
	LEFT,
	RIGHT
}
@export var direction: DIRECTION = DIRECTION.LEFT
@export var speed: int = 150
var damage: int
var velocity: Vector2 = Vector2.ZERO
var target_uid: int
var single_attack: bool

func _physics_process(delta) -> void:
	velocity.x = speed * get_direction() * delta
	
	translate(velocity)

func get_direction() -> int: return (direction * 2) - 1

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		if single_attack and body.uid == target_uid or not single_attack:
			body.deal_damage_to_self(damage, 0)
		
		queue_free()
