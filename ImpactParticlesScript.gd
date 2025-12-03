extends GPUParticles2D
@onready var SFX := preload("res://SFXObject.tscn")

func _ready() -> void:
	var NewSFX = SFX.instantiate()
	NewSFX.stream = load("res://SFX/ImpactSound.mp3")
	NewSFX.position = position
	get_parent().call_deferred("add_child",NewSFX)
	emitting = true

func _on_finished() -> void:
	queue_free()
