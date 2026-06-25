class_name Player
extends CharacterBody2D

# Player controller node.
#
# Handles input routing and exposes the player's named states for the state machine.


## Default vertical jump velocity.
const JUMP_VELOCITY: float = -400.0


var speed: float = 200.0
var is_right: bool = true: set = set_is_right
var can_change_state: bool = true

#region /// reference variables for the states
@onready var state_machine: StateMachine = $StateMachine
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var idle: IdleState = $StateMachine/Idle
@onready var run: RunState = $StateMachine/Run
@onready var jump: JumpState = $StateMachine/Jump
@onready var attack: AttackState = $StateMachine/Attack
@onready var hurt: HurtState = $StateMachine/Hurt
@onready var death: DeathState = $StateMachine/Death
@onready var defend: DefendState = $StateMachine/Defend
@onready var roll: RollState = $StateMachine/Roll
@onready var special: SpecialState = $StateMachine/Special
#endregion

# Initializes the state machine on ready
func _ready() -> void:
	state_machine.initialize(idle, self)


# Routes input to the state machine and changes states based on player input
func _physics_process(delta: float) -> void:
	if can_change_state:
		var axis: float = Input.get_axis("move_left", "move_right")
		if (
			axis != 0.0
			and is_on_floor()
		):
			state_machine.change_state(run)

		if Input.is_action_just_pressed("jump"):
			state_machine.change_state(jump)

		if (
			Input.is_action_just_pressed("attack")
			and is_on_floor()
		):
			state_machine.change_state(attack)

		if (
			Input.is_action_just_pressed("special")
			and is_on_floor()
		):
			state_machine.change_state(special)

		if (
			Input.is_action_pressed("defend")
			and is_on_floor()
		):
			state_machine.change_state(defend)

		if (
			Input.is_action_pressed("roll")
			and is_on_floor()
		):
			state_machine.change_state(roll)
		
		if (
			Input.is_action_pressed("death")
			and is_on_floor()
		):
			state_machine.change_state(death)
		
		if (
			Input.is_action_just_pressed("hurt")
			and is_on_floor()
		):
			state_machine.change_state(hurt)

	state_machine.physics_update(delta)


# Setter for the facing direction; updates cached sprite when node ready
func set_is_right(value: bool) -> void:
	is_right = value
	if not is_node_ready(): return
	sprite.flip_h = not is_right
