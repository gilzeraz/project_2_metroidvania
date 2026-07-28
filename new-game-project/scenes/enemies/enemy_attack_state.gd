class_name EnemyAttackState
extends State
## Controls melee and dash attack states with frame-based hit detection.
##
## Manages attack animations, movement interpolation, cooldown timing, and
## deferred monitoring triggers for hitboxes.


## Velocity of dash attack gravity.
const DASH_GRAVITY: float = 490.0


## State to transition to once the attack animation completes.
@export var next_state: State
## Amount of damage dealt to the target upon a successful hit.
@export var damage: int = 15
## Animation frame index where weapon collision checking is initiated.
@export var hit_frame: int = 3
## Duration in seconds the combat area remains active to register damage.
@export var active_duration: float = 0.1
## Cooldown duration in seconds before this attack state can be selected again.
@export var cooldown: float = 1.0
## Name of the animation resource assigned to this attack.
@export var attack_animation: String = ""
## Dash velocity applied upon entering the attack state.
@export var dash_speed: float = 0.0
## Friction coefficient used to decelerate horizontal dash velocity.
@export var friction: float = 0.0


var attack_finished: bool = false
var dash_direction: int = 0

var _hit_triggered: bool = false
var _cooldown_timer: float = 0.0


# Processes cooldown updates globally even when this state is not currently active
func _process(delta: float) -> void:
	if _cooldown_timer > 0.0:
		_cooldown_timer -= delta


func enter() -> void:
	actor.sprite.frame_changed.connect(_on_frame_changed)
	actor.sprite.animation_finished.connect(_on_animation_finished)
	actor.attack_area.body_entered.connect(_on_body_entered)

	attack_finished = false
	_hit_triggered = false
	_cooldown_timer = cooldown

	actor.velocity.x = 0.0
	actor.sprite.play(attack_animation)

	dash_direction = actor.facing_direction
	actor.velocity.x = float(dash_direction) * dash_speed
	actor.move_and_slide()


func physics_update(delta: float) -> State:
	if not actor.is_on_floor():
		actor.velocity.y += (
			actor.get_gravity().y * delta
			if dash_speed == 0.0
			else DASH_GRAVITY * delta
		)

	actor.velocity.x = lerpf(actor.velocity.x, 0.0, friction * delta)
	actor.move_and_slide()

	if attack_finished:
		return next_state

	return null


func exit() -> void:
	_set_attack_monitoring(false)

	actor.sprite.frame_changed.disconnect(_on_frame_changed)
	actor.sprite.animation_finished.disconnect(_on_animation_finished)
	actor.attack_area.body_entered.disconnect(_on_body_entered)


# Checks if this attack state is off cooldown and ready to be executed
func is_ready() -> bool:
	return _cooldown_timer <= 0.0


# Handles frame-by-frame verification to execute the damage query sequence
func _on_frame_changed() -> void:
	if state_machine.current_state != self: return

	if actor.sprite.frame == hit_frame and not _hit_triggered:
		_hit_triggered = true
		_trigger_hit()


# Signals complete animation execution to trigger standard state transitions
func _on_animation_finished() -> void:
	if state_machine.current_state != self: return

	if actor.sprite.animation == attack_animation:
		attack_finished = true


# Detects target intrusion on the active combat boundary and inflicts damage
func _on_body_entered(body: Node) -> void:
	if state_machine.current_state != self: return

	if body.has_method("take_damage"):
		body.take_damage(damage)


# Enables physical collision queries and schedules expiration lifetime
func _trigger_hit() -> void:
	_set_attack_monitoring(true)
	await get_tree().create_timer(active_duration).timeout
	_set_attack_monitoring(false)


# Updates the physics detection state of the damage source area
func _set_attack_monitoring(active: bool) -> void:
	actor.attack_area.set_deferred("monitoring", active)
