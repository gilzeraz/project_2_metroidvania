class_name AttackState
extends State
## Controls melee combo sequences and dash momentum.
##
## Manages timed combo window detection, dynamic sprite animation transitions,
## directional dash forces, and hitbox lifecycle events.


## Maximum time in seconds allowed between combo inputs before resetting.
const MAX_COMBO_TIME: float = 0.3
## Maximum number of additional steps allowed in a combo sequence.
const MAX_COMBO: int = 2
## Horizontal velocity impulse applied during each attack step.
const DASH_FORCE: float = 80.0
## Linear deceleration factor applied to smoothly stop attack dashes.
const FRICTION: float = 5.0


var _combo: int = 0
var _combo_timer: float = 0.0
var _can_combo: bool = false


func enter() -> void:
	actor.can_change_state = false
	_combo = 0
	_combo_timer = 0.0
	_can_combo = false

	actor.velocity.x = 0.0
	actor.sprite.play("attack_0")
	_apply_dash()

	actor.sprite.animation_finished.connect(_on_attack_finished)
	actor.hitbox.activate()


func physics_update(delta: float) -> State:
	actor.velocity.x = lerp(actor.velocity.x, 0.0, delta * FRICTION)
	actor.move_and_slide()

	if Input.is_action_just_pressed("attack") and _can_combo and _combo < MAX_COMBO:
		_can_combo = false
		_combo += 1
		actor.sprite.play("attack_" + str(_combo))
		actor.sprite.animation_finished.connect(_on_attack_finished)
		_apply_dash()
		actor.hitbox.activate()

	if _can_combo:
		_combo_timer += delta
		if _combo_timer >= MAX_COMBO_TIME:
			actor.sprite.play("attack_" + str(_combo) + "_return")
			await actor.sprite.animation_finished
			return actor.idle

	return null


func exit() -> void:
	actor.can_change_state = true
	actor.hitbox.deactivate()
	if actor.sprite.animation_finished.is_connected(_on_attack_finished):
		actor.sprite.animation_finished.disconnect(_on_attack_finished)


# Resets combo flags and opens the timing window for the next input
func _on_attack_finished() -> void:
	_can_combo = true
	_combo_timer = 0.0
	if actor.sprite.animation_finished.is_connected(_on_attack_finished):
		actor.sprite.animation_finished.disconnect(_on_attack_finished)


# Applies directional forward impulse based on current facing direction
func _apply_dash() -> void:
	var direction: float = 1.0 if actor.is_right else -1.0
	actor.velocity.x = DASH_FORCE * direction
