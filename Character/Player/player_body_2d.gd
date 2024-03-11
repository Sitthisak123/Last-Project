extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -350.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
enum ANIME_STATE {
	attacking,
	jumping,
	climimg,
	running,
	idling,
	idle,
	dead,
	hit
}
var playerState = ANIME_STATE.idle
var playerPrevState = null
var player_Attak = {}
var cannotMoveState = [
ANIME_STATE.attacking, 
ANIME_STATE.dead, 
ANIME_STATE.hit,
]
var origin_gravity = gravity

var maxHP = get_meta("maxHP") if get_meta("maxHP") else 100.0
@export var HP = 100.0
var ATK = get_meta("ATK") if get_meta("ATK") else 10.0
var COIN = 0

signal on_player_takeDamage(atk)
signal on_player_getCoin

const relicCount = 3
@export var remainRelic = []
@export var relicsDroped = []
@export var keepRelic = []
var relicAnimates2D = []

@export var interact = {
	"SealStone": [],
	"Gate": [],
}

func _ready():
	remainRelic = range(1, relicCount+1)
	var sprite1 = get_node("Control/MarginContainer2/AnimatedSprite2D1")
	var sprite2 = get_node("Control/MarginContainer2/AnimatedSprite2D2")
	var sprite3 = get_node("Control/MarginContainer2/AnimatedSprite2D3")
	relicAnimates2D.append(sprite1)
	relicAnimates2D.append(sprite2)
	relicAnimates2D.append(sprite3)
	
	HP = get_meta("HP") if get_meta("HP") else 100.0
	$Control/MarginContainer/ProgressBar.set_value_no_signal(HP/maxHP*100.0)
	
func _process(delta):
	for  idx in range(0,3):
		if(idx < keepRelic.size()):
			relicAnimates2D[idx].play(str(keepRelic[idx]))
			relicAnimates2D[idx].visible = true
		else:
			relicAnimates2D[idx].visible = false
	if(interact["SealStone"].size()):
		var SealStoneNodes = get_tree().get_nodes_in_group("SealStone")
		for StoneKey in interact["SealStone"]:
			if (StoneKey in keepRelic):
				$TipTextAssignItem.visible = true
			else:
				$TipTextAssignItem.visible = false
		$RichTextLabel.visible = false
	elif(interact["Gate"]):
		$RichTextLabel.visible = true
		$TipTextAssignItem.visible = false
	else:
		$TipTextAssignItem.visible = false
		$RichTextLabel.visible = false
		
func _physics_process(delta):
	var direction = Input.get_axis("left", "right")
	if(HP > 0):
		if not is_on_floor() and playerState != ANIME_STATE.attacking or playerState != ANIME_STATE.hit:
			velocity.y += gravity * delta
		if Input.is_action_just_pressed("attack - light") and $AnimationPlayer.current_animation != "Hit - 01":
			lightAttack()
			pass
		if Input.is_action_just_pressed("attack - heavy"):
			print(ANIME_STATE.keys()[playerState])
			pass				
		if Input.is_action_just_pressed("interact") and is_on_floor() and $AnimationPlayer.current_animation != "Hit - 01":
			if(interact["SealStone"].size()):
				var SealStoneNodes = get_tree().get_nodes_in_group("SealStone")		
				var interactStone = interact["SealStone"]
				interactStone.reverse()
				for sealStoneKey in interactStone:
					for key in keepRelic:
						for SealStone in SealStoneNodes:
							if(SealStone.relicKey == sealStoneKey and sealStoneKey == key):
								keepRelic.erase(key)
								SealStone.get_node("AnimatedSprite2D").modulate = Color(1 ,1 ,1 ,1)
								SealStone.get_node("Area2D/CollisionShape2D").disabled = true
								get_parent().get_node("Node2D/Gate").sealStone += 1
								break
			elif(interact["Gate"]):
				get_tree().change_scene_to_file("res://Scene/Ending.tscn")	
			
		# Handle jump.
		if Input.is_action_just_pressed("up") and is_on_floor() and $AnimationPlayer.current_animation != "Hit - 01":
			velocity.y = JUMP_VELOCITY
			playerPrevState = playerState
			playerState = ANIME_STATE.jumping
			$Attack_Area/CollisionPolygon2D.disabled = true
			$AnimatedSprite2D.play("Player - Jump all")
			if($AnimationPlayer.is_playing()):
				$AnimationPlayer.stop()
		if(playerState ==  ANIME_STATE.attacking or playerState == ANIME_STATE.hit):
			velocity.x = 0
			velocity.y = 0
			


		if direction and not playerState in cannotMoveState:
			velocity.x = direction * SPEED
			playerPrevState = playerState
			playerState = ANIME_STATE.running
			$AnimatedSprite2D.play("Player - Run")
			player_Change_Direction(direction)
					
		elif (playerState == ANIME_STATE.hit and $AnimatedSprite2D.animation != "Player - Hit"):
			velocity.x = 0
			velocity.y = 0
			$AnimatedSprite2D.play("Player - Hit")
			$AnimationPlayer.play("Hit - 01")
			pass
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			if (not playerState in cannotMoveState):
				if(playerState != ANIME_STATE.jumping):
					playerPrevState = playerState
					playerState = ANIME_STATE.idle
					$AnimatedSprite2D.play("Player - Idle")
			elif(direction):
				#player_Change_Direction(direction)
				pass				
				
		
		move_and_slide()
	else:
		playerState = ANIME_STATE.dead
		if($AnimatedSprite2D.animation != "Player - Dead"):
			$AnimatedSprite2D.play("Player - Dead")
	
func lightAttack():
	var direction = Vector2.LEFT if $AnimatedSprite2D.flip_h == true else Vector2.RIGHT
	var forward = direction.x
	
	playerPrevState = playerState
	playerState = ANIME_STATE.attacking
	$AnimatedSprite2D.play("Player - Attack_Light All")
	$AnimationPlayer.play("Attack - 01")
	$".".position.x = global_position.x + 7 * forward
	player_Attak = {"atk": ATK}
	
func player_Change_Direction(direction):
	if direction < 0:
		$AnimatedSprite2D.flip_h = true
		$Attack_Area/CollisionPolygon2D.scale.x = -1
	else:
		$AnimatedSprite2D.flip_h = false
		$Attack_Area/CollisionPolygon2D.scale.x = 1




func _on_animated_sprite_2d_animation_finished():
	
	if(playerState == ANIME_STATE.jumping):
		playerPrevState = playerState
		playerState = ANIME_STATE.idle
		pass
	elif(playerState == ANIME_STATE.attacking):
		playerPrevState = playerState
		playerState = ANIME_STATE.idle
		pass
	elif(playerState == ANIME_STATE.running):
		playerPrevState = playerState
		playerState = ANIME_STATE.idle
		pass
	elif(playerState == ANIME_STATE.hit):
		playerPrevState = playerState
		playerState = ANIME_STATE.idle
		pass
	elif(playerState == ANIME_STATE.dead):
		$AnimatedSprite2D.pause()
		var GameOverMenu_ins = preload("res://Scene/GameIsOver.tscn").instantiate()
		get_parent().add_child(GameOverMenu_ins)
	pass
	


func _on_animated_sprite_2d_frame_changed():
	if playerState == ANIME_STATE.attacking and $AnimatedSprite2D.get_frame() == 4:
		var direction = Vector2.LEFT if $AnimatedSprite2D.flip_h == true else Vector2.RIGHT
		var forward = direction.x
		$".".position.x = (global_position.x + 7 * forward)
		player_Attak = {"atk": ATK}

	#elif(playerState == ANIME_STATE.attacking and $AnimatedSprite2D.get_frame() == )





func _on_attack_area_body_entered(body):
	if "enemy" in body.get_groups():
		player_attacked(body, player_Attak["atk"])


func _on_on_player_take_damage(enemy_atk):
	HP -= enemy_atk
	$Control/MarginContainer/ProgressBar.set_value(HP/maxHP*100.0)
	playerState = ANIME_STATE.hit

	
func player_attacked(enemy_Node, player_atk = 0):
	enemy_Node.on_enemy_TakeDammage.emit(player_atk)
	


func _on_on_player_get_coin():
	COIN += 1
	$Control/MarginContainer2/Sprite2D/RichTextLabel_CoinAmount.set_text(str(COIN))
	pass # Replace with function body.
