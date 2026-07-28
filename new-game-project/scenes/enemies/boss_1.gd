class_name Boss
extends BaseEnemy
## Base logic for boss entities managing combat combos, ranges, and health signals.
##
## Emits health updates to the user interface, manages melee and ranged combo
## state transitions, and mirrors attack area scales reactively.


## Probability threshold (10%) for triggering a ranged attack.
const RANGED_ATTACK_CHANCE: float = 0.1


## Minimum distance required to trigger close combat melee attacks.
@export var attack_range: float = 45.0
## Maximum distance from which a high-mobility approach or ranged attack can be initiated.
@export var max_attack_range: float = 120.0
## Minimum distance required to evaluate ranged attack options.
@export var min_attack_range: float = 80.0
## State to return to when the player is out of detection range.
@export var idle_state: State
## Array of available melee attack states.
@export var attack_states: Array[State] = []
## Array of available ranged attack states.
@export var ranged_attack_states: Array[State] = []
## Minimum number of attack states to chain in a melee combo.
@export var min_combo: int = 1
## Maximum number of attack states to chain in a melee combo.
@export var max_combo: int = 2
## Minimum rest duration in seconds spent in idle state after a combo.
@export var min_rest_time: float = 0.5
## Maximum rest duration in seconds spent in idle state after a combo.
@export var max_rest_time: float = 1.0

var current_combo: Array[State] = []
var is_comboing: bool = false
var can_take_damage: bool = true


@onready var cool_down_timer: Timer = $CoolDownTimer


## Emitted when the boss takes damage, notifying the UI of current and max health.
signal health_changed(current_hp: int, max_hp: int)


func _ready() -> void:
	super()
	health_changed.emit(health, max_health)

	cool_down_timer.timeout.connect(
		func() -> void:
			can_take_damage = true
	)

	if idle_state and "is_archer" in idle_state:
		idle_state.is_archer = false


func _physics_process(delta: float) -> void:
	super(delta)

	if not is_initialized: return

	if state_machine.current_state == death_state or state_machine.current_state == hurt_state:
		return

	if state_machine.current_state == idle_state:
		is_comboing = false

	if is_comboing or not Player.player: return

	var distance_vector: float = Player.player.global_position.x - global_position.x
	var direction: float = signf(distance_vector)
	var distance: float = absf(distance_vector)

	if direction != 0.0:
		facing_direction = int(direction)

	if state_machine.current_state is IdleEnemyState: return

	if distance <= attack_range:
		velocity.x = 0.0
		current_combo = get_combo(attack_states, min_combo, max_combo)

		for i: int in range(current_combo.size()):
			if i < current_combo.size() - 1:
				current_combo[i].next_state = current_combo[i + 1]
			else:
				current_combo[i].next_state = idle_state
				idle_state.wait_time = randf_range(min_rest_time, max_rest_time)

		if not current_combo.is_empty():
			state_machine.change_state(current_combo[0])
			is_comboing = true

		return

	elif distance >= min_attack_range and distance <= max_attack_range:
		if randf() < RANGED_ATTACK_CHANCE:
			var ranged_attack: State = _decide_attack(ranged_attack_states)
			if ranged_attack:
				ranged_attack.next_state = idle_state
				state_machine.change_state(ranged_attack)
				is_comboing = true


# Inflicts damage, notifies health changes, and triggers state transitions
func take_damage(damage_amount: int) -> void:
	if not can_take_damage: return

	health -= damage_amount
	health_changed.emit(health, max_health)
	is_comboing = false

	if health <= 0:
		state_machine.change_state(death_state)
	else:
		state_machine.change_state(hurt_state)
		can_take_damage = false
		cool_down_timer.start()


# Generates a random sequence array of attack states for combo chaining
func get_combo(attacks: Array[State], min_attacks: int, max_attacks: int) -> Array[State]:
	var attack_amount: int = mini(randi_range(min_attacks, max_attacks), attacks.size())
	var combo: Array[State] = []
	var available_attacks: Array[State] = attacks.duplicate()

	for i: int in attack_amount:
		var random_attack: State = available_attacks.pick_random()
		combo.append(random_attack)
		available_attacks.erase(random_attack)

	return combo


# Overrides orientation setter to update facing direction and mirror attack area scale
func _set_facing_direction(direction: int) -> void:
	super(direction)
	if attack_area:
		attack_area.scale.x = float(direction)


# Filters attack options and returns a random selection
func _decide_attack(attacks: Array[State]) -> State:
	if attacks.is_empty():
		return null

	return attacks.pick_random()
