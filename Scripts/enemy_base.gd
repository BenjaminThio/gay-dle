extends StaticBody2D

@export var idle_duration: float = 9.5
@export var max_hitpoints: int = 10000

var hitpoints: int = max_hitpoints
var enemy_tank_packed_scene: PackedScene = preload("res://Instances/enemy_tank.tscn")
var enemy_god_packed_scene: PackedScene = preload("res://Instances/enemy_god.tscn")
var enemy_dark_assasin: PackedScene = preload("res://Instances/enemy_dark_assassin.tscn")
var shock_wave_packed_scene: PackedScene = preload("res://Instances/shock_wave.tscn")
var opponents_hitbox_uid: Array[int] = []
var uid: int

@onready var spawnpoint: Marker2D = $Spawnpoint
@onready var hitpoints_label: Label = $HitpointsLabel

func knockback_shockwave():
	var shock_wave: Node2D = shock_wave_packed_scene.instantiate()
	
	spawnpoint.add_child(shock_wave)
	Audio.play_sound("boss_shock_wave")
	owner.get_node("AllyLayer").knockback_all()

func _ready() -> void:
	update_hitpoints_label()
	
	await time.pauseable_sleep(owner, idle_duration)
	
	knockback_shockwave()
	
	spawn_enemy(enemy_god_packed_scene)
	
	await time.pauseable_sleep(owner, 5.0)
	
	for _i in range(2):
		spawn_enemy()
		
		await time.pauseable_sleep(owner, 2.0)
	
	await time.pauseable_sleep(owner, 10.0)
	
	keep_spawning_enemy()

func spawn_enemy(packed_scene: PackedScene = enemy_tank_packed_scene) -> void:
	var enemy: CharacterBody2D = packed_scene.instantiate()
	
	owner.register_uid(enemy)
	add_child.call_deferred(enemy)
	enemy.global_position = spawnpoint.global_position

var spawn_enemies: int = 2

func keep_spawning_enemy(packed_scene: PackedScene = enemy_tank_packed_scene) -> void:
	for _i in range(spawn_enemies):
		spawn_enemy(packed_scene)
		
		await time.pauseable_sleep(owner, 1.5)
	
	await time.pauseable_sleep(owner, 7.0)
	
	keep_spawning_enemy(packed_scene)

var ultied: bool = false

func deal_damage_to_self(opponent_damage: int, _from = null) -> void:
	if hitpoints <= max_hitpoints / 2.0 and not ultied:
		ultied = true
		spawn_enemies = 5
		knockback_shockwave()
		spawn_enemy(enemy_dark_assasin)
	hitpoints -= opponent_damage
	update_hitpoints_label()
	
	if hitpoints <= 0:
		Global.victory = true
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/game_over.tscn")

func keep_dealing_damage_to_self(opponent_damage: int, opponent_attack_gap_duration: float, opponent_uid: int) -> void:
	deal_damage_to_self(opponent_damage)
	
	await time.pauseable_sleep(owner, opponent_attack_gap_duration)
	
	if opponent_uid in opponents_hitbox_uid:
		keep_dealing_damage_to_self(opponent_damage, opponent_attack_gap_duration, opponent_uid)

func update_hitpoints_label():
	hitpoints_label.text = str(hitpoints) + "/" + str(max_hitpoints)

func _on_opponent_body_entered(body: Node2D) -> void:
	if body.is_in_group("ally"):
		opponents_hitbox_uid.append(body.uid)

func _on_opponent_body_exited(body: Node2D) -> void:
	if body.is_in_group("ally"):
		opponents_hitbox_uid.erase(body.uid)
