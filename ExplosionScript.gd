extends GPUParticles2D
var Team = null # Group the bullet comes from, set when created
var Damage = 1 # Damage the bullet does, set when created
var DoDamage = true

func _ready() -> void:
	emitting = true
	$GPUParticles2D.emitting = true
	var MapPos = Globals.PropLayer.local_to_map(position)
	Globals.PropLayer.set_cell(MapPos,-1)
	Globals.PropLayer.set_cell(MapPos + Vector2i(-1,0),-1)
	Globals.PropLayer.set_cell(MapPos + Vector2i(1,0),-1)
	Globals.PropLayer.set_cell(MapPos + Vector2i(0,-1),-1)
	Globals.PropLayer.set_cell(MapPos + Vector2i(0,1),-1)
	await get_tree().create_timer(0.2).timeout
	DoDamage = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if DoDamage:
		if Team == "Player" or Team == "Allies": # Checks if bullet came from the player or an ally
			if body.is_in_group("Enemies"): # Checks if impact is on an enemy
				body.TakeDamage(Damage) # Damages enemy
		if Team == "Enemies": # Checks if bullet came from an enemy
			if body.is_in_group("Allies") or body.is_in_group("Player"): # Checks if bullet impact is on the player or an ally
				body.TakeDamage(Damage) # Damages the player or ally


func _on_finished() -> void:
	queue_free()
