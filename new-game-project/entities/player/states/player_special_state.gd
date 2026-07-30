class_name SpecialState
extends State
## Controls special multi-hit sequence attacks and cooldown tracking.


## Multiplier applied to calculate dash impulse force.
const DASH_IMPULSE_MULTIPLIER: float = 10.0
## Active duration in seconds for the expanded hitbox window per hit.
const HITBOX_ACTIVE_DURATION: float = 0.08

## Time in seconds the actor must wait before using this special ability again.
@export var cooldown_time: float = 2.0
## Animation frame indices where each dash-and-hit strike triggers.
@export var hit_frames: Array[int] = [2, 6, 10, 14]
## Base dash distance magnitude per hit strike.
@export var dash_distance: float = 60.0
## Multiplier applied to the hitbox scale during active strikes.
@export var hitbox_expansion_scale := Vector2(2.5, 2.5)

var _cooldown_timer: float = 0.0
var _hits_done: int = 0
var _original_hitbox_scale := Vector2.ONE
var _hitbox_duration_timer: float = 0.0


func enter() -> void:
	actor.velocity.x = 0.0
	actor.can_change_state = false
	_hits_done = 0
	_hitbox_duration_timer = 0.0

	if actor.hitbox:
		_original_hitbox_scale = actor.hitbox.scale

	actor.sprite.play("attack_special")
	actor.sprite.frame_changed.connect(_on_frame_changed)


func physics_update(delta: float) -> State:
	if _cooldown_timer > 0.0:
		_cooldown_timer -= delta

	if _hitbox_duration_timer > 0.0:
		_hitbox_duration_timer -= delta
		if _hitbox_duration_timer <= 0.0:
			_restore_hitbox()

	if not actor.sprite.is_playing():
		_cooldown_timer = cooldown_time
		return actor.idle

	return null


func exit() -> void:
	actor.can_change_state = true
	_restore_hitbox()
	if actor.sprite.frame_changed.is_connected(_on_frame_changed):
		actor.sprite.frame_changed.disconnect(_on_frame_changed)


## Checks if the special ability has finished its cooldown period
func is_ready() -> bool:
	return _cooldown_timer <= 0.0


## Triggers dash impulse and hitbox activation on specific animation frames
func _on_frame_changed() -> void:
	if _hits_done < hit_frames.size() and actor.sprite.frame == hit_frames[_hits_done]:
		_perform_dash_hit()
		_hits_done += 1


## Applies directional forward impulse velocity and scales the active hitbox
func _perform_dash_hit() -> void:
	var direction: float = 1.0 if actor.is_right else -1.0
	actor.velocity.x = dash_distance * direction * DASH_IMPULSE_MULTIPLIER

	if actor.hitbox:
		actor.hitbox.scale = _original_hitbox_scale * hitbox_expansion_scale
		actor.hitbox.activate()
		_hitbox_duration_timer = HITBOX_ACTIVE_DURATION


## Deactivates the hitbox and resets scale back to its original dimensions
func _restore_hitbox() -> void:
	if actor.hitbox:
		actor.hitbox.deactivate()
		actor.hitbox.scale = _original_hitbox_scale
