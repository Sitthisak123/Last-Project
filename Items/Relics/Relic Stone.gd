extends CharacterBody2D

const JUMP_VELOCITY = -200.0  # Adjusted for better bounce height
var coinRolling = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var RelicKey : int;

func _ready():
	RelicKey = get_meta("RelicKey")
	$AnimatedSprite2D.play(str(RelicKey))
	$bounce_timer.start()

func _physics_process(delta):
	#print(coinRolling, $bounce_timer.time_left)
	if coinRolling:
		velocity.y = JUMP_VELOCITY
	if not is_on_floor() and not coinRolling:
		velocity.y += gravity * delta
		$Area2D/CollisionShape2D.disabled = false
	move_and_slide()


func _on_area_2d_body_entered(body):
	if "player" in body.get_groups():
		body.keepRelic.append(RelicKey)
		queue_free()
	pass


func _on_bounce_timer_timeout():
	coinRolling = false
	# Optional: Play a sound effect or animation to indicate the end of the bounce
