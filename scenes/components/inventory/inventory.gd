extends Resource

##inventory for costume storage
class_name inventory

##array for holding costumes
@export var equipment: Array[costume]
#should be an array of size 1, but it could be funny to equip multiple costumess

##used for spawning dropped costumes
var dropped_item = preload("res://scenes/components/inventory/Costumes/costume_collectable.tscn")

##costume to be replaced on new costume pickup
var selected_costume = 0

func size():
	return equipment.size()

##prints costumes (+stats) in inventory to console
func print():
	print("inv size: "+ str(size()))
	for i in range(size()):
		print("slot " + str(i + 1) + "---")
		if (!equipment[i]):
			print("empty")
			pass
		else:
			equipment[i].print()
			
##equips costume in empty slot
func equip(item: costume):
	var replace = true
	for i in range (size()):
		if (equipment[i]):
			pass
		else:
			equipment[i] = item
			replace = false
			break
	if (replace == true):
			var old_item = equipment[selected_costume]
			equipment[selected_costume] = item
			return(old_item)
			

##functionality for manually removing items from inventory (doesn't drop)
func remove(equip_slot: int):
	if (equipment[equip_slot]):
		equipment.remove_at(equip_slot)
