class_name RollState
extends State
## Controls horizontal roll evasion and temporary invincibility.


var _is_roll_finished: bool = false


func enter() -> void:
	_is_roll_finished = false
	actor.can_change_state = false

	if actor.is_right:
		actor.velocity.x = actor.ROLL_VELOCITY
	else:
		actor.velocity.x = -actor.ROLL_VELOCITY

	if "is_invincible" in actor:
		actor.is_invincible = true

	actor.sprite.play("roll")
	actor.sprite.animation_finished.connect(_on_animation_finished)


func physics_update(delta: float) -> State:
	if _is_roll_finished:
		return actor.idle

	if not actor.is_on_floor():
		actor.velocity.y += actor.get_gravity().y * delta

	actor.move_and_slide()

	return null


func exit() -> void:
	actor.can_change_state = true

	if "is_invincible" in actor:
		actor.is_invincible = false

	if actor.sprite.animation_finished.is_connected(_on_animation_finished):
		actor.sprite.animation_finished.disconnect(_on_animation_finished)


## Sets completion flag when the roll animation finishes playing
func _on_animation_finished() -> void:
	if actor.sprite.animation == "roll":
		_is_roll_finished = true
