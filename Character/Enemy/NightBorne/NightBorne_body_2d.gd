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
	walk,
	alert,
	hit,
	newHit,
	dead,
	attacking
}
@export var animeStates = 1
var animePrevStates = null
var playerDetected = false
var maxHP = get_meta("maxHP") if get_meta("maxHP") else 50
@export var HP = 1.0
var atk = 10
var canAttack = true


signal on_enemy_TakeDammage(player_atk)

func _ready():
	HP = get_meta("HP") if get_meta("HP") else 50.0
	$ProgressBar.set_value_no_signal(HP/maxHP*100.0)
	
func _physics_process(delta):
	#print(get_parent().get_node("PlayerBody2D").global_position.x - global_position.x)
	#print($Alert_timeout_Delay.wait_time - $Alert_timeout_Delay.time_left)
	#print($AnimatedSprite2D.animation,"  ", ANIME_STATE.keys()[animeStates], " ",$Alert_timeout_Delay.wait_time - $Alert_timeout_Delay.time_left)
	if(HP > 0):
		if not is_on_floor():
			velocity.y += gravity * delta
			
		if(animeStates == ANIME_STATE.walk):
			$AnimatedSprite2D.play("Walk")
			translate(direction * SPEED_walk * delta)
			
		elif(animeStates == ANIME_STATE.alert):
			if($AnimatedSprite2D.animation == "Attack" and $AnimatedSprite2D.is_playing()):
				translate(direction * 0 * delta)
			elif($RayCast2D_Attack_Dectector.is_colliding()):
				if($RayCast2D_Attack_Dectector.get_collider().name == "PlayerBody2D"):
					translate(direction * 0 * delta)
					$AnimatedSprite2D.play("Idle")
				else:
					translate(direction * SPEED_alert * delta)
			else:
				$AnimatedSprite2D.play("Run")	
				translate(direction * SPEED_alert * delta)
			
		elif(animeStates == ANIME_STATE.newHit):
			$Alert_timeout_Delay.start()
			animeStates = ANIME_STATE.hit
			$AnimationPlayer.stop()
			if($AnimatedSprite2D.is_playing() and $AnimatedSprite2D.animation == "Hit"):
				$AnimatedSprite2D.set_frame(2)
			else:
				$AnimatedSprite2D.play("Hit")
			$Hit_stun.start()
			translate((direction * -1) * 55 * delta)
			
		elif(animeStates == ANIME_STATE.attacking):
			if($AnimatedSprite2D.animation != "Attack" and canAttack):
				canAttack = false
				$Attack_countdown.start()
				$AnimatedSprite2D.play("Attack")
				$AnimationPlayer.play("Attack")	
				
		if  not $RayCast2D.is_colliding() and is_on_floor():
			if direction == Vector2.LEFT:
				direction = Vector2.RIGHT  
			else:
				direction = Vector2.LEFT
			$RayCast2D.scale.x *= -1
			$RayCast2D_Detector.scale.x *= -1
			$RayCast2D_Attack_Dectector.scale.x *= -1
			
		if (animeStates == ANIME_STATE.alert):
			if not isActive_timer($Heading_to_target_Delay):
				$Heading_to_target_Delay.start()
		else:
			$Heading_to_target_Delay.stop()
		
		if $RayCast2D_Attack_Dectector.is_colliding() and animeStates == ANIME_STATE.alert:
			var collider_Obj = $RayCast2D_Attack_Dectector.get_collider()
			if("player" in collider_Obj.get_groups()):		
				animeStates = ANIME_STATE.attacking
		elif(not $RayCast2D_Attack_Dectector.is_colliding() and animeStates == ANIME_STATE.attacking):				
				animeStates = ANIME_STATE.alert
			
		if $RayCast2D_Detector.is_colliding():
			var collided_object = $RayCast2D_Detector.get_collider()
			if collided_object:
				if (collided_object.name == "PlayerBody2D"):
					playerDetected = true
					if not isActive_timer($Alert_timein_Delay) and (animeStates != ANIME_STATE.alert or animeStates != ANIME_STATE.hit):
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

		move_and_slide()
	else:
		$ProgressBar.visible = false
		$AnimatedSprite2D_Alert_sign.visible = false
		animeStates = ANIME_STATE.dead
		$CollisionShape2D.disabled = true
		$AnimatedSprite2D.play("Dead")


func _on_alert_timeout_delay_timeout():
	animeStates = ANIME_STATE.walk
	$AnimatedSprite2D_Alert_sign.visible = false

func isActive_timer(TimerNode):
	return TimerNode.time_left > 0

func _on_alert_timein_delay_timeout():
	$AnimatedSprite2D_Alert_sign.visible = true	
	if(animeStates != ANIME_STATE.hit):
		animePrevStates = animeStates	
		animeStates = ANIME_STATE.alert

func _on_heading_to_target_delay_timeout():
	var player_position = get_parent().get_node("PlayerBody2D").global_position
	if(get_parent().get_node("PlayerBody2D").global_position.x - global_position.x) > 0:
		if(direction != Vector2.RIGHT):
			direction = Vector2.RIGHT
			$RayCast2D.scale.x *= -1
			$RayCast2D_Detector.scale.x *= -1
			$RayCast2D_Attack_Dectector.scale.x *= -1
			$Attack_Area/CollisionPolygon2D.scale.x *= -1

	else:
		if(direction != Vector2.LEFT):
			direction = Vector2.LEFT
			$RayCast2D.scale.x *= -1
			$RayCast2D_Detector.scale.x *= -1
			$RayCast2D_Attack_Dectector.scale.x *= -1
			$Attack_Area/CollisionPolygon2D.scale.x *= -1
			


func _on_on_enemy_take_dammage(player_atk):
	HP -= player_atk
	$ProgressBar.set_value(HP/maxHP*100.0)
	animePrevStates = animeStates	
	animeStates = ANIME_STATE.newHit


func _on_animated_sprite_2d_animation_finished():
	if(animeStates == ANIME_STATE.dead):
		get_parent().on_dead.emit(get_groups(), global_position)
		queue_free()
	if(animeStates == ANIME_STATE.attacking):
		animeStates = ANIME_STATE.alert
		$AnimatedSprite2D.play("Run")
		
func _on_hit_stun_timeout():
	animeStates = ANIME_STATE.alert
	$AnimatedSprite2D_Alert_sign.visible = true	
	$Alert_timeout_Delay.start()

func _on_attack_countdown_timeout():
	canAttack = true
	

func _on_attack_area_body_entered(body):
	if("player" in body.get_groups()):
		body.on_player_takeDamage.emit(atk)
		
