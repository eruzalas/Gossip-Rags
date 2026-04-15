extends Resource

##inventory for costume storage
class_name inventory

##array for holding costumes
@export var equipment: Array[costume]
#should be an array of size 1, but it could be funny to equip multiple costumess

##used for spawning dropped costumes
var dropped_item = preload("res://scenes/components/inventory/Costumes/costume_collectable.tscn")



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
			
##equips costume in slot, returns previous item if slot was occupied
func equip(item: costume, selected = 0):
	var replace = true
	for i in range (size()):
		if (equipment[i]):
			pass
		else:
			equipment[i] = item
			replace = false
			break
	if (replace == true):
			var old_item = equipment[selected]
			equipment[selected] = item
			return(old_item)
			

##functionality for manually removing items from inventory (doesn't drop)
func remove(equip_slot: int):
	if (equipment[equip_slot]):
		equipment[equip_slot] = null

##adds an empty slot to the end of the inventory array
func add_slot():
	equipment.append(null)

##removes slot from inventory, can be specified slot (by array index number) otherwise removes an empty slot or the last slot if no empty slots availablep
func remove_slot(slot = null):
	if (slot and equipment[slot]):
		equipment.remove_at(slot)
		return
	var delete_last = true
	for i in range (size()):
		if (equipment[i]):
			pass
		else:
			equipment.remove_at(i)
			delete_last = false
			break
	if (delete_last == true):
		equipment.remove_at((size() - 1))
		
