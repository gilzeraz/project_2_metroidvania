class_name AttackImpactState
extends State
## Controls post-dive impact recovery and area damage delivery.
##
## Halts movement velocity, plays the impact animation, applies overlapping area
## damage to the player, and transitions to the next state upon completion.


## Default next state to transition to after impact recovery finishes.
@export var next_state: State
## Amount of damage applied to overlapping entities during impact recovery.
@export var damage: int = 1

var _animation_done: bool = false


func enter() -> void:
	_animation_done = false
	actor.velocity = Vector2.ZERO
	actor.sprite.play("attack_end")
	actor.sprite.animation_finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)


func physics_update(_delta: float) -> State:
	if _animation_done:
		return next_state

	for body: Node2D in actor.attack_area.get_overlapping_bodies():
		if body is Player:
			body.take_damage(damage, actor)

	return null


func exit() -> void:
	if actor.sprite.animation_finished.is_connected(_on_animation_finished):
		actor.sprite.animation_finished.disconnect(_on_animation_finished)


# Sets animation completion flag when impact animation finishes
func _on_animation_finished() -> void:
	_animation_done = true
