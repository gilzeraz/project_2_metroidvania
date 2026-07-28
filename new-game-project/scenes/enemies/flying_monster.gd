class_name FlyingMonster
extends BaseEnemy
## Aerial enemy entity tracking vertical patrol baselines and initial spawn points.
##
## Manages spawn position retention and updates patrol elevation anchors used by
## aerial idle and return states.


var spawn_position: Vector2 = Vector2.ZERO
## Baseline vertical altitude maintained during default air patrol routes.
var patrol_y: float = 0.0


@onready var idle_state: IdleEnemyState = $StateMachine/IdleEnemyState


func _ready() -> void:
	super()
	spawn_position = global_position
	patrol_y = global_position.y


func _physics_process(delta: float) -> void:
	super(delta)
