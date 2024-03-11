extends Node2D


# Called when the node enters the scene tree for the first time.
var relicKey
func _ready():
	relicKey = get_meta("RelicKey")
	$AnimatedSprite2D.play(str(relicKey))
	$AnimatedSprite2D.modulate = Color(0.5, 0.5, 0.5, 0.5)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_body_entered(body):
	if(body.is_in_group("player")):
		body.interact["SealStone"].append(relicKey)	



func _on_area_2d_body_exited(body):
	if(body.is_in_group("player")):
		body.interact["SealStone"].erase(relicKey)
