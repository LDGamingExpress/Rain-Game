extends CharacterBody2D
var Team = null # Group the bullet comes from, set when created
var Damage = 1 # Damage the bullet does, set when created
var ImpactP = load("res://ImpactParticles.tscn")
var TimeRange = 2.0

# Called when the node enters the scene tree for the first time.
func _ready():
	velocity = 800 * Vector2(cos(rotation),sin(rotation)) # Gives the bullet it's velocity
	await get_tree().create_timer(TimeRange).timeout
	queue_free() # Deletes bullet


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $RayCast2D.is_colliding():
		_on_hit_area_body_entered($RayCast2D.get_collider())
	move_and_slide() # Moves the bullet based on velocity


func _on_hit_area_body_entered(body): # Activated when the bullet hits an object
	if Team == "Player" or Team == "Allies": # Checks if bullet came from the player or an ally
		if body.is_in_group("Enemies"): # Checks if impact is on an enemy
			body.TakeDamage(Damage) # Damages enemy
	if Team == "Enemies": # Checks if bullet came from an enemy
		if body.is_in_group("Allies") or body.is_in_group("Player"): # Checks if bullet impact is on the player or an ally
			body.TakeDamage(Damage) # Damages the player or ally
	var NewObj = ImpactP.instantiate()
	NewObj.position = position
	get_parent().add_child(NewObj)
	queue_free() # Deletes bullet
