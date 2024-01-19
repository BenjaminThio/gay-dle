extends CharacterBody2D

enum DIRECTION {
	LEFT,
	RIGHT
}
@export var direction: DIRECTION = DIRECTION.RIGHT
@export var speed: int = 10
@export var damage: int = 700
@export var max_hitpoints: float = 99999
@export var attack_gap_duration: float = 0.8
@export var single_attack: bool = false
@export var knockback_vector: Vector2 = Vector2(70, -150)
@export var knockback_duration: float = 0.8
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var magic_explosion_scene: PackedScene = preload("res://Instances/magic_explosion.tscn")
var soul_packed_scene: PackedScene = preload("res://Instances/soul.tscn")
var filibuster_music: AudioStreamOggVorbis = preload("res://Musics/filibuster.ogg")
var hitpoints: float = max_hitpoints
var is_casting_magic: bool = false
var opponents_hitbox_uid: Array[int] = []
var casting_range_opponents_uid: Array[int] = []
var has_knockback: bool = false
var is_knockbacking: bool = false
var uid: int
var casted_magic_explosion: Area2D
@onready var battlefield: Node2D = get_tree().root.get_node("Battlefield")
@onready var hitpoints_label: Label = $HitpointsLabel

func _ready() -> void:
	update_hitpoints_label()
	
	knockback_vector.x *= get_direction() * -1

func _physics_process(delta) -> void:
	
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if not is_knockbacking:
		#print(opponents_hitbox_uid)
		if casting_range_opponents_uid.size() == 0 and not is_casting_magic:
			velocity.x = speed * get_direction()
		else:
			velocity.x = 0
	
	move_and_slide()

func deal_damage_to_self(opponent_damage: int, _from = null) -> void:
	var half_max_hitpoints: float = max_hitpoints / 2
	
	hitpoints -= opponent_damage
	update_hitpoints_label()
	#print(hitpoints)
	
	if hitpoints <= 0:
		var soul: Sprite2D = soul_packed_scene.instantiate()
		
		knockback()
		
		await time.sleep(knockback_duration / 2)
		
		battlefield.add_child(soul)
		soul.global_position = global_position
		
		battlefield.change_music(filibuster_music, 19.0)
		
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
	if casted_magic_explosion != null:
		casted_magic_explosion.queue_free()
		casted_magic_explosion = null
		is_casting_magic = false
	create_tween().tween_property(self, "velocity:x", 0, knockback_duration).finished.connect(
		func() -> void:
			is_knockbacking = false
	)

func get_direction() -> int: return (direction * 2) - 1

func casting_magic() -> void:
	var magic_explosion: Area2D = magic_explosion_scene.instantiate()
	
	is_casting_magic = true
	casted_magic_explosion = magic_explosion
	magic_explosion.damage = damage
	battlefield.add_child.call_deferred(magic_explosion)
	magic_explosion.global_position = global_position + Vector2(208, -72)
	
	await magic_explosion.explode()
	
	if casting_range_opponents_uid.size() > 0:
		casting_magic()
	else:
		is_casting_magic = false

func _on_ally_entered_hitbox(body: Node2D) -> void:
	if body.is_in_group("ally"):
		opponents_hitbox_uid.append(body.uid)
		
		if casting_range_opponents_uid.size() > 0:
			if not is_casting_magic:
				casting_magic()

func _on_ally_exited_hitbox(body: Node2D) -> void:
	if body.is_in_group("ally"):
		opponents_hitbox_uid.erase(body.uid)
	
		if casting_range_opponents_uid.size() == 0:
			is_casting_magic = false
			if casted_magic_explosion != null:
				casted_magic_explosion.queue_free()
				casted_magic_explosion = null

func _on_ally_entered_shooting_range(body: Node2D) -> void:
	if body.is_in_group("ally"):
		casting_range_opponents_uid.append(body.uid)
		
		if casting_range_opponents_uid.size() > 0:
			if not is_casting_magic:
				casting_magic()

func _on_ally_exited_shooting_range(body: Node2D) -> void:
	if body.is_in_group("ally"):
		casting_range_opponents_uid.erase(body.uid)
		
		if casting_range_opponents_uid.size() == 0:
			is_casting_magic = false
			if casted_magic_explosion != null:
				casted_magic_explosion.queue_free()
				casted_magic_explosion = null

func _on_visible_on_screen_notifier_screen_exited() -> void:
	queue_free()

func update_hitpoints_label():
	hitpoints_label.text = str(hitpoints) + "/" + str(max_hitpoints)
	
	if hitpoints < 0:
		hitpoints_label.text = "0/" + str(max_hitpoints)
