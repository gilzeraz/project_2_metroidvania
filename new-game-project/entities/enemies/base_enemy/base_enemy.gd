class_name BaseEnemy
extends CharacterBody2D
## Base class for enemy entities managing shared stats and raycast detection.
##
## Tracks health, movement speed, facing orientation, player line-of-sight,
## and delegates behavior execution to a child StateMachine instance.


## Collision mask layer used for player raycast detection queries.
const PLAYER_DETECTION_MASK: int = 17


## Maximum health capacity of this enemy unit.
@export var max_health: int = 3
## Horizontal movement speed of the enemy unit.
@export var speed: float = 60.0
## State to enter immediately upon initialization.
@export var initial_state: State
## State to transition to when receiving a non-lethal hit.
@export var hurt_state: State
## State to transition to upon health depletion.
@export var death_state: State


var health: int = 0
var facing_direction: int = 1: set = _set_facing_direction
var player_near: bool = false
var player_visible: bool = false
var is_initialized: bool = false


@onready var state_machine: StateMachine = $StateMachine
@onready var detection_area: Area2D = $DetectionArea
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var character: BaseEnemy = self


func _ready() -> void:
	health = max_health

	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)

	await get_tree().process_frame

	state_machine.initialize(initial_state, self)
	is_initialized = true


func _physics_process(delta: float) -> void:
	if not is_initialized: return

	state_machine.physics_update(delta)

	if not player_near: return

	var result: Dictionary = check_player()
	if not result.has("collider"): return

	var collider: Node2D = result.collider
	player_visible = (collider is Player)


# Applies damage to health and transitions to hurt or death state
func take_damage(damage_amount: int) -> void:
	health -= damage_amount
	if health > 0:
		state_machine.change_state(hurt_state)
	else:
		state_machine.change_state(death_state)


# Casts a ray towards the player position to verify line-of-sight
func check_player() -> Dictionary:
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(
		global_position,
		Player.player.global_position,
		PLAYER_DETECTION_MASK
	)
	var result: Dictionary = space_state.intersect_ray(query)
	return result


# Callback when a body enters the target detection area
func _on_detection_area_body_entered(_body: Node2D) -> void:
	player_near = true


# Callback when a body exits the target detection area
func _on_detection_area_body_exited(_body: Node2D) -> void:
	player_visible = false
	player_near = false


# Updates facing direction state and adjusts sprite horizontal flipping
func _set_facing_direction(direction: int) -> void:
	facing_direction = direction
	sprite.flip_h = (facing_direction <= 0)
