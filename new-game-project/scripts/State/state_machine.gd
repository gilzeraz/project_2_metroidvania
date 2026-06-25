class_name StateMachine
extends Node
# Manages switching and updating of `State` child nodes.
#
# Initializes states with a reference to the player and routes physics updates.


var current_state: State = null


## Assigns `player` to each child `State` and switches to the starting state
func initialize(starting_state: State, player: Node) -> void:
	for state: State in get_children():
		state.player = player
		state.state_machine = self
	change_state(starting_state)


## Changes the active state, calling `exit` and `enter` appropriately
func change_state(new_state: State) -> void:
	if current_state == new_state:
		return
	if current_state:
		current_state.exit()
	current_state = new_state
	current_state.enter()


## Optional per-frame update (currently unused)
func update(_delta: float) -> void:
	pass


## Awaits the current state's physics_update and applies a state change if returned
func physics_update(delta: float) -> void:
	@warning_ignore("redundant_await")
	var new_state: State = await current_state.physics_update(delta)
	if new_state:
		change_state(new_state)
