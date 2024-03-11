extends Node2D

var NightBorneBody2D = preload("res://Character/Enemy/NightBorne/NightBorne_body_2d.tscn")
var Coin2D = preload("res://Items/Coin/coin_2d.tscn")
var Relic2D = preload("res://Items/Relics/Relic Stone.tscn")

signal on_dead(groups: Array, pos)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var count_enemy_group = len(get_tree().get_nodes_in_group("enemy"))
	#print($PlayerBody2D.global_position)
	var remainRelic = get_node('PlayerBody2D').remainRelic
	
	if not count_enemy_group and remainRelic.size() > 0:
		for i in range(3):  # Create 3 unique instances
			var enemy_instance = NightBorneBody2D.instantiate()  # Instantiate a new instance each time
			var rand_pos_x = randi_range(-400, 650)
			while abs(rand_pos_x - $PlayerBody2D.global_position.x) < 20:
				rand_pos_x = randi_range(-400, 650)
			enemy_instance.set_position(Vector2(rand_pos_x, -100))
			enemy_instance.animeStates = 1
			add_child(enemy_instance)

	#print(count_enemy_group)


func _on_on_dead(groups: Array, pos):
	if(groups):
		if("enemy" in groups):
			var remainRelic = get_node('PlayerBody2D').remainRelic
			var remainRelicCount = remainRelic.size()
			if(dropRate(.4)) and remainRelicCount > 0:
				var keepRelic = get_node('PlayerBody2D').keepRelic
				var relicsDroped = get_node('PlayerBody2D').relicsDroped
				var rand_idx = randi() % remainRelicCount
				var selectedRelic = remainRelic[rand_idx]
				relicsDroped.append(selectedRelic)
				remainRelic.remove_at(rand_idx)
				
				var Relic2D_ins = Relic2D.instantiate()
				Relic2D_ins.set_position(pos)
				Relic2D_ins.set_meta("RelicKey", selectedRelic)
				add_child(Relic2D_ins)
			else:
				var Coin2D_ins = Coin2D.instantiate()
				Coin2D_ins.set_position(pos)
				add_child(Coin2D_ins)
		else:
			pass # Replace with function body.
			
func dropRate(chance):
	if chance < 0 or chance > 1:
		print("Warning: Chance value must be between 0 and 1.")
		return false
	var random_float = randf()
	return random_float < chance 
	
	
