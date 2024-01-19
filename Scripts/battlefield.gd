extends Node2D

const min_wallet_level: int = 1
const max_wallet_level: int = 10

@export var min_wallet_capacity: int = 1500
@export var max_wallet_capacity: int = 15000
@export var money_increase_each_time: int = 7
@export var min_money_increase_pause_gap_duration: float = 0.06
@export var max_money_increase_pause_gap_duration: float = 0.02

var money_owned_in_wallet: float = 0
var wallet_level: float = min_wallet_level
var uid_registered: int = 0

@onready var money_label: Label = $Money
@onready var level_up_wallet_button: Button = $LevelUpWalletButton
@onready var player_base: StaticBody2D = $PlayerBase
@onready var enemy_base: StaticBody2D = $EnemyBase
@onready var background_music: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	for base in [player_base, enemy_base]:
		register_uid(base)
	refresh_level_up_wallet_button_content()
	keep_adding_money()

func change_music(audio: AudioStreamOggVorbis, from_position: float):
	background_music.stream = audio
	background_music.play(from_position)

func keep_adding_money() -> void:
	var money_increase_pause_gap_duration_at_specific_level: float = get_value_at_specific_cut(min_money_increase_pause_gap_duration, max_money_increase_pause_gap_duration, wallet_level, max_wallet_level)
	
	add_money(money_increase_each_time)
	
	await time.pauseable_sleep(self, money_increase_pause_gap_duration_at_specific_level)
	
	keep_adding_money()

func add_money(value: int) -> void:
	var max_wallet_capacity_at_specific_level: float = get_value_at_specific_cut(min_wallet_capacity, max_wallet_capacity, wallet_level, max_wallet_level)
	
	if money_owned_in_wallet + value <= max_wallet_capacity_at_specific_level:
		money_owned_in_wallet += money_increase_each_time
	else:
		money_owned_in_wallet = max_wallet_capacity_at_specific_level
	money_label.text = str(money_owned_in_wallet)

func level_up_wallet() -> void:
	var cost_to_level_up_wallet: float = get_value_at_specific_cut(min_wallet_capacity, max_wallet_capacity, wallet_level, max_wallet_level) / 2
	
	if wallet_level + 1 <= max_wallet_level and money_owned_in_wallet >= cost_to_level_up_wallet:
		wallet_level += 1
		money_increase_each_time += 2
		money_owned_in_wallet -= cost_to_level_up_wallet
		refresh_level_up_wallet_button_content()

func refresh_level_up_wallet_button_content() -> void:
	var cost_to_level_up_wallet: float = get_value_at_specific_cut(min_wallet_capacity, max_wallet_capacity, wallet_level, max_wallet_level) / 2
	
	level_up_wallet_button.text = str(wallet_level)
	if wallet_level < max_wallet_level:
		level_up_wallet_button.text += "\nLEVEL UP WALLET\n" + str(cost_to_level_up_wallet)
	else:
		level_up_wallet_button.text += "\nMAX LEVEL"

func get_value_at_specific_cut(min_value: float, max_value: float, cut: float, max_cuts: int) -> float:
	return min_value + ((max_value - min_value) * (cut - 1) / (max_cuts - 1))

func register_uid(node: Node) -> void:
	node.uid = uid_registered
	uid_registered += 1
