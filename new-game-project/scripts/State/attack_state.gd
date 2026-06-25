class_name AttackState
extends State


## Maximum time (seconds) allowed between combo inputs.
const MAX_COMBO_TIME: float = 0.3
## Maximum number of combo steps.
const MAX_COMBO: int = 3

var _combo: int = 0
var _combo_timer: float = 0.0
var _can_combo: bool = false


func enter() -> void:
	player.can_change_state = false
	_combo = 0
	_combo_timer = 0.0
	_can_combo = false
	player.velocity.x = 0
	player.sprite.play("attack_0")
	player.sprite.animation_finished.connect(_on_attack_finished)


func physics_update(delta: float) -> State:
	if (
		Input.is_action_just_pressed("attack")
		and _can_combo
		and _combo < MAX_COMBO
	):
		_can_combo = false
		_combo += 1
		player.sprite.play("attack_" + str(_combo))
		player.sprite.animation_finished.connect(_on_attack_finished)

	if _can_combo:
		_combo_timer += delta
		if _combo_timer >= MAX_COMBO_TIME:
			player.sprite.play("attack_" + str(_combo) + "_return")
			await player.sprite.animation_finished
			return player.idle

	return null


func exit() -> void:
	player.can_change_state = true


## Enables the next combo input when the current attack animation ends
func _on_attack_finished() -> void:
	_can_combo = true
	_combo_timer = 0.0
	player.sprite.animation_finished.disconnect(_on_attack_finished)
