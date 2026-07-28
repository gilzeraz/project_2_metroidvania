class_name SlimePatrolState
extends State
## Patrol state for the slime enemy unit.
##
## Manages horizontal patrolling behavior within a defined distance constraint, 
## handles directional changes on physical obstacles, and transitions to player 
## engagement states upon target detection.


## Maximum horizontal distance the unit can travel before turning back.
@export var patrol_distance: float = 100.0

## State to transition to once the player character enters detection range.
@export var on_player_detected_state: State

## Horizontal spawn point from which the patrol boundary is measured.
var start_position: Vector2


func enter() -> void:
	start_position = actor.global_position
	actor.sprite.play("patrol")


func physics_update(delta: float) -> State:
	if not actor.is_on_floor():
		actor.velocity.y += actor.get_gravity().y * delta
		
	if actor.is_on_wall():
		actor.facing_direction *= -1
		
	actor.velocity.x = actor.facing_direction * actor.speed
	actor.move_and_slide()
	if not actor.ray.is_colliding():
		actor.facing_direction *= -1

	if actor.player_near and on_player_detected_state:
		return on_player_detected_state

	return null
