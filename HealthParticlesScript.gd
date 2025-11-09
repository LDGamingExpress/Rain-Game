extends GPUParticles2D


# Called when the node enters the scene tree for the first time.
func _ready():
	emitting = true # Starts particle effect
	await get_tree().create_timer(0.8).timeout # Waits till particles have finished (set to 0.8 seconds)
	queue_free() # Deletes particles after they finish


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
