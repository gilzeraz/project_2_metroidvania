class_name Slime
extends BaseEnemy
## Base controller for the Slime enemy unit.
##
## Manages references to the unique behavioral state machine components 
## associated with Slime movement and target tracking.


@export var running_speed: float = 300.0

@onready var patrol: EnemyPatrolState = $StateMachine/Patrol
@onready var running: EnemyRunningState = $StateMachine/Running
@onready var ray: RayCast2D = $RayCast2D


func _set_facing_direction(direction: int) -> void:
	super(direction)
	ray.position.x *= -1
