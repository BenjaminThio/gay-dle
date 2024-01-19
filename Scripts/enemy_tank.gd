extends CharacterBody2D

enum DIRECTION {
	LEFT,
	RIGHT
}
@export var direction: DIRECTION = DIRECTION.RIGHT
@export var speed: int = 70
@export var damage: int = 6
@export var max_hitpoints: float = 700
@export var kill_reward: float = 400
@export var attack_gap_duration: float = 0.5
@export var single_attack: bool = false
@export var knockback_vector: Vector2 = Vector2(300, -300)
@export var knockback_duration: float = 0.8
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var soul_packed_scene: PackedScene = preload("res://Instances/soul.tscn")
var hitpoints: float = max_hitpoints
var opponents_hitbox_uid: Array[int] = []
var has_knockback: bool = false
var is_knockbacking: bool = false
var uid: int
@onready var battlefield: Node2D = get_tree().root.get_node("Battlefield")

func _ready() -> void:
	knockback_vector.x *= get_direction() * -1 # Opposite direction

func _physics_process(delta) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if not is_knockbacking:
		if opponents_hitbox_uid.size() == 0:
			velocity.x = speed * get_direction()
		else:
			velocity.x = 0
	
	move_and_slide()

func deal_damage_to_self(opponent_damage: int, _from = null) -> void:
	var half_max_hitpoints: float = max_hitpoints / 2
	
	hitpoints -= opponent_damage
	#print("Enemy:" + str(hitpoints))
	
	if hitpoints <= 0:
		var soul: Sprite2D = soul_packed_scene.instantiate()
		
		knockback()
		
		await time.sleep(knockback_duration / 2)
		
		battlefield.add_money(kill_reward)
		battlefield.add_child(soul)
		soul.global_position = global_position
		queue_free()
	elif hitpoints <= half_max_hitpoints and not has_knockback:
		knockback()
		
		battlefield.add_money(kill_reward / 2)

func keep_dealing_damage_to_self(opponent_damage: int, opponent_attack_gap_duration: float, opponent_uid: int) -> void:
	deal_damage_to_self(opponent_damage)
	
	await time.pauseable_sleep(battlefield, opponent_attack_gap_duration)
	
	if opponent_uid in opponents_hitbox_uid:
		keep_dealing_damage_to_self(opponent_damage, opponent_attack_gap_duration, opponent_uid)

func knockback() -> void:
	has_knockback = true
	is_knockbacking = true
	velocity = knockback_vector
	create_tween().tween_property(self, "velocity:x", 0, knockback_duration).finished.connect(
		func() -> void:
			is_knockbacking = false
	)

func get_direction() -> int: return (direction * 2) - 1 # [-1, 1][direction]

func _on_ally_entered(body: Node2D) -> void:
	if body.is_in_group("ally"):
		opponents_hitbox_uid.append(body.uid)
		
		if opponents_hitbox_uid.size() > 0:
			if single_attack and body.uid == opponents_hitbox_uid[0] or not single_attack:
				body.keep_dealing_damage_to_self(damage, attack_gap_duration, uid)

func _on_ally_exited(body: Node2D) -> void:
	if body.is_in_group("ally"):
		opponents_hitbox_uid.erase(body.uid)

func _on_visible_on_screen_notifier_screen_exited() -> void:
	queue_free()
