extends CharacterBody2D
var Team = null # Group the bullet comes from, set when created
var Damage = 1 # Damage the bullet does, set when created
var ImpactP = load("res://ImpactParticles.tscn")
var Explosion = preload("res://Explosion.tscn")
var TimeRange = 2.0
var Frame = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.frame = Frame
	velocity = 800 * Vector2(cos(rotation),sin(rotation)) # Gives the bullet it's velocity
	await get_tree().create_timer(TimeRange).timeout
	queue_free() # Deletes bullet


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if $RayCast2D.is_colliding():
		_on_hit_area_body_entered($RayCast2D.get_collider())
	move_and_slide() # Moves the bullet based on velocity


func _on_hit_area_body_entered(body): # Activated when the bullet hits an object
	var CanDelete = true
	if Team == "Player" or Team == "Allies": # Checks if bullet came from the player or an ally
		if body.is_in_group("Enemies"): # Checks if impact is on an enemy
			body.TakeDamage(Damage) # Damages enemy
		elif  body.is_in_group("Player") or  body.is_in_group("Allies"):
			CanDelete = false
	if Team == "Enemies": # Checks if bullet came from an enemy
		if body.is_in_group("Allies") or body.is_in_group("Player"): # Checks if bullet impact is on the player or an ally
			body.TakeDamage(Damage) # Damages the player or ally
		elif body.is_in_group("Enemies"):
			CanDelete = false
	if body.is_in_group("Crate"):
		var NewObj = ImpactP.instantiate()
		NewObj.position = body.position
		NewObj.self_modulate = Color(0.982, 0.423, 0.0, 1.0)
		get_parent().add_child(NewObj)
		body.queue_free()
	if body.is_in_group("PlantCrate"):
		var NewObj = ImpactP.instantiate()
		NewObj.position = body.position
		NewObj.self_modulate = Color(0.982, 0.423, 0.0, 1.0)
		get_parent().add_child(NewObj)
		var NewObj2 = load("res://PlantMatter.tscn").instantiate()
		NewObj2.position = body.position
		get_parent().call_deferred("add_child",NewObj2)
		body.queue_free()
	if CanDelete:
		if Frame == 3:
			var NewE = Explosion.instantiate()
			NewE.position = position
			NewE.Team = Team
			get_parent().call_deferred("add_child",NewE)
			#get_parent().add_child(NewE)
		var NewObj = ImpactP.instantiate()
		NewObj.position = position
		get_parent().add_child(NewObj)
		queue_free() # Deletes bullet
