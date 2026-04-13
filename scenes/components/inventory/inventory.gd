extends Resource

##inventory for costume storage
class_name inventory

##array for holding costumes
@export var equipment: Array[costume]
#should be an array of size 1, but it could be funny to equip multiple costumess

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
			drop(equipment[selected_costume])
			equipment[selected_costume] = item
			
func drop(item: costume):
	pass
