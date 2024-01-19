extends CharacterBody2D

enum DIRECTION {
	LEFT,
	RIGHT
}
@export var direction: DIRECTION = DIRECTION.RIGHT
@export var speed: int = 700
@export var damage: int = 500
@export var max_hitpoints: float = 200
@export var attack_gap_duration: float = 0.1
@export var single_attack: bool = true
@export var knockback_vector: Vector2 = Vector2(300, -300)
@export var knockback_duration: float = 0.8
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var weapon_scene: PackedScene = preload("res://Instances/weapon.tscn")
var soul_packed_scene: PackedScene = preload("res://Instances/soul.tscn")
var hitpoints: float = max_hitpoints
var opponents_hitbox_uid: Array[int] = []
var slaying_range_opponents_uid: Array[int] = []
var has_knockback: bool = false
var is_knockbacking: bool = false
var uid: int
var blink_scene: PackedScene = preload("res://Instances/blink.tscn")
var moveable: bool = false
@onready var battlefield: Node2D = get_tree().root.get_node("Battlefield")
@onready var blink_marker: Marker2D = $BlinkMarker

func _ready() -> void:
	await time.pauseable_sleep(battlefield, 1)
	
	var blink: Sprite2D = blink_scene.instantiate()
	
	blink_marker.add_child(blink)
	Audio.play_sound("blink")
	
	await time.pauseable_sleep(battlefield, 1.5)
	
	moveable = true
	
	knockback_vector.x *= get_direction() * -1
	slay()

func _physics_process(delta) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if not is_knockbacking:
		#print(opponents_hitbox_uid)
		if slaying_range_opponents_uid.size() == 0 and moveable:
			velocity.x = speed * get_direction()
		else:
			velocity.x = 0
	
	move_and_slide()

func deal_damage_to_self(opponent_damage: int, _from = null) -> void:
	var half_max_hitpoints: float = max_hitpoints / 2
	
	if _from != 0:
		hitpoints -= opponent_damage
	#print(hitpoints)
	
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

func slay() -> void:
	var weapon: Area2D = weapon_scene.instantiate()
	
	weapon.damage = damage
	weapon.single_attack = single_attack
	if single_attack and slaying_range_opponents_uid.size() > 0:
		weapon.target_uid = slaying_range_opponents_uid[0]
	battlefield.add_child.call_deferred(weapon)
	weapon.global_position = global_position + Vector2(64, -48)
	
	await time.pauseable_sleep(battlefield, attack_gap_duration)
	
	slay()

func _on_ally_entered_hitbox(body: Node2D) -> void:
	if body.is_in_group("ally"):
		opponents_hitbox_uid.append(body.uid)

func _on_ally_exited_hitbox(body: Node2D) -> void:
	if body.is_in_group("ally"):
		opponents_hitbox_uid.erase(body.uid)

func _on_ally_entered_shooting_range(body: Node2D) -> void:
	if body.is_in_group("ally"):
		slaying_range_opponents_uid.append(body.uid)

func _on_ally_exited_shooting_range(body: Node2D) -> void:
	if body.is_in_group("ally"):
		slaying_range_opponents_uid.erase(body.uid)

func _on_visible_on_screen_notifier_screen_exited() -> void:
	queue_free()
