class_name Player
extends CharacterBody2D
## Controls player movement, actions, and combat state routing.
##
## Manages state transitions via StateMachine, handles player collision behaviors,
## and holds core combat attributes such as health and invincibility.

#region Properties
## Default vertical jump velocity.
const JUMP_VELOCITY: float = -400.0
## Default roll velocity.
const ROLL_VELOCITY: float = 350.0
## Maximum number of jumps allowed before landing.
const MAX_JUMPS: int = 2
## Collision layer index for one-way platforms.
const ONE_WAY_PLATFORM_LAYER: int = 2
## Damage multiplier applied when the player takes damage while defending.
const DEFENSE_DAMAGE_MULTIPLIER: float = 0.2

## Global reference to the current active player instance.
static var player: Player = null

## Maximum health value assigned to the player on initialization.
@export var max_health: int = 8
## Maximum mana value assigned to the player on initialization.
@export var max_mana: int = 8

var speed: float = 300.0
var dropping_through_timer: float = 0.25
var health: int = 0
var mana: int = 0
var coins: int = 0
var jump_count: int = MAX_JUMPS
var is_invincible: bool = false
var is_defending: bool = false
var is_right: bool = true:
	set = set_is_right
var can_change_state: bool = true
var is_dropping: bool = false
var _impact_velocity: float = 0.0

@onready var state_machine: StateMachine = $StateMachine
@onready var hitbox: Area2D = $Hitbox
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $Camera
@onready var idle: IdleState = $StateMachine/Idle
@onready var run: RunState = $StateMachine/Run
@onready var jump: JumpState = $StateMachine/Jump
@onready var attack: AttackState = $StateMachine/Attack
@onready var hurt: HurtState = $StateMachine/Hurt
@onready var death: DeathState = $StateMachine/Death
@onready var defend: DefendState = $StateMachine/Defend
@onready var roll: RollState = $StateMachine/Roll
@onready var fall: FallState = $StateMachine/Fall
@onready var jump_attack: JumpAttack = $StateMachine/JumpAttack
@onready var special: SpecialState = $StateMachine/Special
#endregion

func _ready() -> void:
	mana = max_mana
	health = max_health
	state_machine.initialize(idle, self)
	player = self


func _physics_process(delta: float) -> void:
	if can_change_state:
		var axis: float = Input.get_axis("move_left", "move_right")
		if is_on_floor():
			if Input.is_action_just_pressed("down"):
				drop_through_platform()
			if axis != 0.0:
				state_machine.change_state(run)

			if Input.is_action_just_pressed("jump"):
				state_machine.change_state(jump)

			if Input.is_action_just_pressed("attack"):
				state_machine.change_state(attack)

			if Input.is_action_just_pressed("special"):
				state_machine.change_state(special)

			if Input.is_action_pressed("defend"):
				state_machine.change_state(defend)

			if Input.is_action_pressed("roll"):
				state_machine.change_state(roll)

			if Input.is_action_pressed("death"):
				state_machine.change_state(death)

			if Input.is_action_just_pressed("hurt"):
				state_machine.change_state(hurt)

	state_machine.physics_update(delta)


## Updates character facing direction and flips sprite horizontally
func set_is_right(value: bool) -> void:
	is_right = value
	if not is_node_ready(): return
	sprite.flip_h = not is_right


## Temporarily disables platform collision to pass through one-way platforms
func drop_through_platform() -> void:
	if is_dropping: return
	is_dropping = true
	set_collision_mask_value(ONE_WAY_PLATFORM_LAYER, false)
	await get_tree().create_timer(dropping_through_timer).timeout
	set_collision_mask_value(ONE_WAY_PLATFORM_LAYER, true)
	is_dropping = false


## Calculates and applies incoming damage based on defensive status
func take_damage(damage_amount: int, attacker: Node2D = null) -> void:
	if is_invincible: return

	if is_defending:
		var reduced_damage: int = int(damage_amount * DEFENSE_DAMAGE_MULTIPLIER)
		health -= reduced_damage
		
		state_machine.current_state.apply_shield_knockback(attacker)
		
		if health <= 0:
			state_machine.change_state(death)
	else:
		health -= damage_amount
		if health > 0:
			state_machine.change_state(hurt)
		else:
			state_machine.change_state(death)
			
			
## Applies the effect of a collected item to the corresponding player stat.
func apply_item(item_data: ItemData) -> void:
	match item_data.effect:
		ItemData.EffectType.HEAL:
			health += item_data.value
			health = clamp(health, 0, max_health)
		ItemData.EffectType.MANA:
			mana += item_data.value
			mana = clamp(mana, 0, max_mana)
		ItemData.EffectType.CURRENCY:
			coins += item_data.value
