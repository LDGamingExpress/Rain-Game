extends AudioStreamPlayer2D

func _ready() -> void:
	pitch_scale = randf_range(0.95,1.05)
	play()

func _on_finished() -> void:
	queue_free()
