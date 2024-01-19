extends Node

func sleep(sec: float, timeout_function: Callable = Callable()) -> void:
	var timer: SceneTreeTimer = get_tree().create_timer(sec)
	
	if not timeout_function.is_null():
		timer.timeout.connect(timeout_function)
	await timer.timeout

func pauseable_sleep(owner_node: Node, sec: float, timeout_function: Callable = Callable()) -> void:
	var timer: Timer = Timer.new()
	
	owner_node.add_child.call_deferred(timer)
	timer.wait_time = sec
	timer.autostart = true
	timer.timeout.connect(
		func() -> void:
			if not timeout_function.is_null():
				timeout_function.call()
			owner_node.remove_child(timer)
			timer.queue_free()
	)
	await timer.timeout
