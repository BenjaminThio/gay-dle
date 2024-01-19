extends Button

@onready var pause_panel: Panel = $PausePanel

func pause() -> void:
	pause_panel.show()
	get_tree().paused = true
