extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_world_fall_out_body_entered(body):
	if(body.is_in_group("RelicStone")):
		print(get_parent().get_node("PlayerBody2D").remainRelic)
		get_parent().get_node("PlayerBody2D").remainRelic.append(body.RelicKey)
		print(get_parent().get_node("PlayerBody2D").remainRelic)
	for group in ["enemy", "player"]:
		if body.is_in_group(group):
			body.HP = 0
			break
