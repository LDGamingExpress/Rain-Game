extends AudioStreamPlayer2D

func _ready() -> void:
	pitch_scale = randf_range(0.95,1.05)
	volume_db = randf_range(-0.1,0.2)
	play()

func _on_finished() -> void:
	queue_free()
