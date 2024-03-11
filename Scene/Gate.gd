extends Node2D
var gateState : bool = false
@export var sealStone =  0
const allSealStone = 3
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(sealStone >= allSealStone and $AnimatedSprite2D.animation != "open"):
		$AnimatedSprite2D.play("open")		
		$Area2D/CollisionShape2D.disabled = false


func _on_area_2d_body_entered(body):
	if(body.is_in_group("player")):
		body.interact["Gate"] = true



func _on_area_2d_body_exited(body):
	if(body.is_in_group("player")):
		body.interact["Gate"] = false


func _on_animated_sprite_2d_animation_finished():
	if($AnimatedSprite2D.animation == "open"):
		$ColorRect.visible = true
	pass # Replace with function body.
