extends VBoxContainer

enum CHARACTER {
	PRODUCTIVE_MINION,
	MINION,
	TANK,
	FIGHTER,
	MARKSMAN,
	BLASTER,
	MAGE
}
var pro_minion_packed_scene: PackedScene = preload("res://Instances/productive_minion.tscn")
var minion_packed_scene: PackedScene = preload("res://Instances/minion.tscn")
var tank_packed_scene: PackedScene = preload("res://Instances/tank.tscn")
var fighter_packed_scene: PackedScene = preload("res://Instances/fighter.tscn")
var marksman_packed_scene: PackedScene = preload("res://Instances/marksman.tscn")
var blaster_packed_scene: PackedScene = preload("res://Instances/blaster.tscn")
var mage_packed_scene: PackedScene = preload("res://Instances/mage.tscn")
var character: Dictionary = {
	CHARACTER.PRODUCTIVE_MINION: {
		cost = 300,
		cooldown_duration = 2,
		packed_scene = pro_minion_packed_scene,
		cooldown_animation = null
	},
	CHARACTER.MINION: {
		cost = 300,
		cooldown_duration = 3,
		packed_scene = minion_packed_scene,
		cooldown_animation = null
	},
	CHARACTER.TANK: {
		cost = 500,
		cooldown_duration = 5,
		packed_scene = tank_packed_scene,
		cooldown_animation = null
	},
	CHARACTER.FIGHTER: {
		cost = 1500,
		cooldown_duration = 6,
		packed_scene = fighter_packed_scene,
		cooldown_animation = null
	},
	CHARACTER.MARKSMAN: {
		cost = 2000,
		cooldown_duration = 7,
		packed_scene = marksman_packed_scene,
		cooldown_animation = null
	},
	CHARACTER.BLASTER: {
		cost = 3000,
		cooldown_duration = 10,
		packed_scene = blaster_packed_scene,
		cooldown_animation = null
	},
	CHARACTER.MAGE: {
		cost = 7000,
		cooldown_duration = 60,
		packed_scene = mage_packed_scene,
		cooldown_animation = null
	}
}
var slots_configuration: Array[Array] = [
	[CHARACTER.PRODUCTIVE_MINION, CHARACTER.MINION, CHARACTER.TANK, CHARACTER.FIGHTER, CHARACTER.MARKSMAN],
	[CHARACTER.BLASTER, CHARACTER.MAGE, null, null, null],
]
@onready var base: StaticBody2D = get_tree().get_first_node_in_group("base")

func _ready() -> void:
	var rows: Array[Node] = get_children()
	
	for row_index in range(rows.size()):
		var slots: Array[Node] = rows[row_index].get_children()
		
		for slot_index in range(slots.size()):
			var slot: Control = slots[slot_index]
			var slot_cost_label: Label = slot.get_child(1)
			var slot_invisible_button: Button = slot.get_child(2)
			var slot_label: Label = slot.get_child(3)
			var configured_character = slots_configuration[row_index][slot_index]
			
			if configured_character != null:
				slot_cost_label.text = str(character[configured_character].cost)
				slot_invisible_button.pressed.connect(spawn.bind(row_index, slot_index))
				slot_label.text = CHARACTER.find_key((row_index * 5) + slot_index).capitalize()
	
	cooldown_all()

func spawn(row_index: int, slot_index: int) -> void:
	var configured_character: CHARACTER = slots_configuration[row_index][slot_index]
	var global_configured_character: Dictionary = character[configured_character]
	
	if owner.money_owned_in_wallet >= global_configured_character.cost and global_configured_character.cooldown_animation == null:
		var spawned_character: CharacterBody2D = global_configured_character.packed_scene.instantiate()
		var base_spawnpoint: Marker2D = base.get_node("Spawnpoint")
		var slot: Control = get_child(row_index).get_child(slot_index)
		var slot_cooldown_progress_bar: TextureProgressBar = slot.get_child(0)
		
		owner.register_uid(spawned_character)
		owner.get_node("AllyLayer").add_child(spawned_character)
		owner.money_owned_in_wallet -= global_configured_character.cost
		spawned_character.global_position = base_spawnpoint.global_position
		slot_cooldown_progress_bar.value = 0
		global_configured_character.cooldown_animation = create_tween().tween_property(slot_cooldown_progress_bar, "value", slot_cooldown_progress_bar.max_value, global_configured_character.cooldown_duration).finished.connect(
			func() -> void:
				#slot_cooldown_progress_bar.value = 0
				global_configured_character.cooldown_animation = null
		)

func cooldown_all():
	var rows: Array[Node] = get_children()
	
	for row_index in range(rows.size()):
		var slots = get_child(row_index)
		
		for slot_index in range(slots.get_children().size()):
			if slots_configuration[row_index][slot_index] != null:
				var configured_character: CHARACTER = slots_configuration[row_index][slot_index]
				var global_configured_character: Dictionary = character[configured_character]
				var slot_cooldown_progress_bar: TextureProgressBar = slots.get_child(slot_index).get_child(0)
				
				global_configured_character.cooldown_animation = create_tween().tween_property(slot_cooldown_progress_bar, "value", slot_cooldown_progress_bar.max_value, global_configured_character.cooldown_duration).finished.connect(
					func() -> void:
						#slot_cooldown_progress_bar.value = 0
						global_configured_character.cooldown_animation = null
				)
