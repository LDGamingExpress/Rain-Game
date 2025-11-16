extends AnimatedSprite2D
var Team = null # Group the bullet comes from, set when created
var Damage = 1 # Damage the bullet does, set when created
var DoDamage = true

func _on_frame_changed() -> void:
	if frame == 5:
		DoDamage = false


func _on_animation_finished() -> void:
	queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if DoDamage:
		if Team == "Player" or Team == "Allies": # Checks if bullet came from the player or an ally
			if body.is_in_group("Enemies"): # Checks if impact is on an enemy
				body.TakeDamage(Damage) # Damages enemy
		if Team == "Enemies": # Checks if bullet came from an enemy
			if body.is_in_group("Allies") or body.is_in_group("Player"): # Checks if bullet impact is on the player or an ally
				body.TakeDamage(Damage) # Damages the player or ally
