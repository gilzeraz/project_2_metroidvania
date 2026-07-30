class_name BossIdleState
extends State
## Idle state for the enemy boss unit.
##
## Keeps the actor stationary, applies gravity when airborne, and transitions
## to the movement state once a player target is detected.


## State to transition to when a player target is detected.
@export var move_state: State


func enter() -> void:
	actor.velocity.x = 0.0
	actor.sprite.play("idle")


func physics_update(delta: float) -> State:
	if not actor.is_on_floor():
		actor.velocity.y += actor.get_gravity().y * delta
		
	actor.move_and_slide()

	if actor.player_near:
		return move_state

	return null
