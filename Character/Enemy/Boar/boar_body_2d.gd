extends CharacterBody2D


const SPEED = 80
const SPEED_alert = 120
const SPEED_walk = 25
const JUMP_VELOCITY = -400
var direction = Vector2.LEFT
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
enum ANIME_STATE {
	idle,
	alert,
	walk,
	hit
}

var animeStates = ""
var playerDetected = false

func _ready():
	animeStates = ANIME_STATE[get_meta("init_animeState")]
	
func _physics_process(delta):
	#print(get_parent().get_node("PlayerBody2D").global_position.x - global_position.x)
	# Add the gravity.
	#print($Alert_timeout_Delay.wait_time - $Alert_timeout_Delay.time_left)
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if(animeStates == ANIME_STATE.walk):
		$AnimatedSprite2D.play("Walk")
		translate(direction * SPEED_walk * delta)
	elif(animeStates == ANIME_STATE.alert):
		$AnimatedSprite2D.play("Run")		
		translate(direction * SPEED_alert * delta)
	elif(animeStates == ANIME_STATE.hit):
		$AnimatedSprite2D.play("Hit")		
		translate(direction * SPEED_alert * delta)
	else:
		#$AnimatedSprite2D.play("Idle")		
		translate(direction * 0 * delta)	
	if  not $RayCast2D.is_colliding():
		if direction == Vector2.LEFT:
			direction = Vector2.RIGHT  
		else:
			direction = Vector2.LEFT
		$RayCast2D.scale.x *= -1
		$RayCast2D_Detector.scale.x *= -1
	if (animeStates == ANIME_STATE.alert):
		if not isActive_timer($Heading_to_target_Delay):
			$Heading_to_target_Delay.start()
	else:
		$Heading_to_target_Delay.stop()
	
	if $RayCast2D_Detector.is_colliding():
		var collided_object = $RayCast2D_Detector.get_collider()
		if collided_object:
			if (collided_object.name == "PlayerBody2D"):
				playerDetected = true
				if not isActive_timer($Alert_timein_Delay):
					$Alert_timein_Delay.start()			
			else:
				$Alert_timein_Delay.stop()
	else:
		$Alert_timein_Delay.stop()
		if playerDetected:
			playerDetected = false
			$Alert_timeout_Delay.start()
		
	if(direction == Vector2.LEFT):
		$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.flip_h = true
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = 0
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	



func _on_alert_timeout_delay_timeout():
	animeStates = ANIME_STATE[get_meta("init_animeState")]
	$AnimatedSprite2D_Alert_sign.visible = false
	print("WALKKKK")
	pass # Replace with function body.

func isActive_timer(TimerNode):
	return TimerNode.time_left > 0

func _on_alert_timein_delay_timeout():
	print("Alert")
	$AnimatedSprite2D_Alert_sign.visible = true	
	animeStates = ANIME_STATE.alert
	pass # Replace with function body.


func _on_heading_to_target_delay_timeout():
	var player_position = get_parent().get_node("PlayerBody2D").global_position


	if(get_parent().get_node("PlayerBody2D").global_position.x - global_position.x) > 0:
		if(direction != Vector2.RIGHT):
			direction = Vector2.RIGHT
			$RayCast2D.scale.x *= -1
			$RayCast2D_Detector.scale.x *= -1
			pass
	else:
		if(direction != Vector2.LEFT):
			direction = Vector2.LEFT
			$RayCast2D.scale.x *= -1
			$RayCast2D_Detector.scale.x *= -1
			pass




