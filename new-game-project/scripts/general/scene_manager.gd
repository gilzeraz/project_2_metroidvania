class_name SceneManager
extends Node2D
## Manages scene transitions.
##
## Performs a deferred scene change and emits `new_scene_ready`
## once the new scene has been loaded.


## Emitted after a new scene is ready. Parameter is the target area id.
signal new_scene_ready(target_area: int)


## Change to `new_scene` and notify with `target_area`.
func transition_scene(new_scene: String, target_area: int) -> void:
	get_tree().change_scene_to_file.call_deferred(new_scene)
	await get_tree().scene_changed
	new_scene_ready.emit(target_area)
