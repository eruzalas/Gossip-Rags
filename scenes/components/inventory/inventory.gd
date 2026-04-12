extends Resource

##inventory for costume storage
class_name inventory

##array for holding costumes
@export var equipment: Array[costume]
#should be an array of size 1, but it could be funny to equip multiple costumess

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
