class_name State
extends Node

# Base state node for the player's state machine.
#
# Provides empty virtual methods that concrete states override.


var player: Node = null
var state_machine: StateMachine = null


# Handles input events forwarded to this state
func input(_event: InputEvent) -> void:
	pass


# Called when this state becomes active
func enter() -> void:
	pass


# Optional per-frame update; return a State to change immediately
func update(_delta: float) -> State:
	return null


# Physics-tick update; should return a new State to trigger a state change
func physics_update(_delta: float) -> State:
	return null


# Called when this state is exited
func exit() -> void:
	pass
	
	
