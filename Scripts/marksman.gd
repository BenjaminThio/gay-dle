extends CharacterBody2D

enum DIRECTION {
	LEFT,
	RIGHT
}
@export var direction: DIRECTION = DIRECTION.LEFT
@export var speed: int = 110
@export var damage: int = 50
@export var max_hitpoints: float = 50
@export var attack_gap_duration: float = 0.5
@export var single_attack: bool = true
@export var knockback_vector: Vector2 = Vector2(300, -300)
@export var knockback_duration: float = 0.8
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var bullet_scene: PackedScene = preload("res://Instances/bullet.tscn")
var soul_packed_scene: PackedScene = preload("res://Instances/soul.tscn")
var hitpoints: float = max_hitpoints
var is_shooting: bool = false
var opponents_hitbox_uid: Array[int] = []
var shooting_range_opponents_uid: Array[int] = []
var has_knockback: bool = false
var is_knockbacking: bool = false
var uid: int
@onready var battlefield: Node2D = get_tree().root.get_node("Battlefield")

func _ready() -> void:
	knockback_vector.x *= get_direction() * -1

func _physics_process(delta) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if not is_knockbacking:
		if shooting_range_opponents_uid.size() == 0:
			velocity.x = speed * get_direction()
		else:
			velocity.x = 0
	
	move_and_slide()

func deal_damage_to_self(opponent_damage: int, _from = null) -> void:
	var half_max_hitpoints: float = max_hitpoints / 2
	
	hitpoints -= opponent_damage
	
	if hitpoints <= 0:
		var soul: Sprite2D = soul_packed_scene.instantiate()
		
		knockback()
		
		await time.sleep(knockback_duration / 2)
		
		battlefield.add_child(soul)
		soul.global_position = global_position
		queue_free()
	elif hitpoints <= half_max_hitpoints and not has_knockback:
		knockback()

func keep_dealing_damage_to_self(opponent_damage: int, opponent_attack_gap_duration: float, opponent_uid: int) -> void:
	deal_damage_to_self(opponent_damage)
	
	await time.pauseable_sleep(battlefield, opponent_attack_gap_duration)
	
	if opponent_uid in opponents_hitbox_uid:
		keep_dealing_damage_to_self(opponent_damage, opponent_attack_gap_duration, opponent_uid)

func knockback() -> void:
	velocity = knockback_vector
	has_knockback = true
	is_knockbacking = true
	create_tween().tween_property(self, "velocity:x", 0, knockback_duration).finished.connect(
		func() -> void:
			is_knockbacking = false
	)

func get_direction() -> int: return (direction * 2) - 1

func shoot() -> void:
	var bullet: Area2D = bullet_scene.instantiate()
	
	is_shooting = true
	bullet.damage = damage
	bullet.single_attack = single_attack
	if single_attack:
		bullet.target_uid = shooting_range_opponents_uid[0]
	battlefield.call_deferred("add_child", bullet)
	bullet.global_position = global_position
	
	await time.pauseable_sleep(battlefield, attack_gap_duration)
	
	if shooting_range_opponents_uid.size() > 0:
		shoot()
	else:
		is_shooting = false

func _on_enemy_entered_hitbox(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		opponents_hitbox_uid.append(body.uid)

func _on_enemy_exited_hitbox(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		opponents_hitbox_uid.erase(body.uid)

func _on_enemy_entered_shooting_range(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		shooting_range_opponents_uid.append(body.uid)
		
		if shooting_range_opponents_uid.size() > 0:
			if not is_shooting:
				shoot()

func _on_enemy_exited_shooting_range(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		shooting_range_opponents_uid.erase(body.uid)

func _on_visible_on_screen_notifier_screen_exited() -> void:
	queue_free()
