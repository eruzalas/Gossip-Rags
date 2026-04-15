extends Resource

##Equipment
class_name costume

#-------item name and texture-------

##Costume name
@export var name: String = ""
##costume icon texture
@export var texture: Texture2D


#-------character stat modifiers (base x item)-------

##affects player movement speed
@export var speed_modifier: float
##affects player jump height
@export var jump_height_modifier: float = 1
##makes the player speed up faster
@export var accel_modifier: float
##makes the player slow down faster
@export var decel_modifier: float
##affects player suspicion rate
@export var suspicion_modifier: float
##affecys player attention gain
@export var attention_modifier: float

#-------item stats (item's own stats)-------

##Costume's own suspicion stat
@export var costume_suspicion: int = 0
##numerical identifier to key to a player sprite
@export var costume_ID: int

#------- Methods -------
func print():
	print("Name: "+ name)
	print("Speed Modifier: "+ str(speed_modifier))
	print("Jump Modifier: "+ str(jump_height_modifier))
	print("Accelleration Modifier: "+ str(accel_modifier))
	print("Decelleration Modifier: "+ str(decel_modifier))
	print("Suspicion Modifier: "+ str(suspicion_modifier))
	print("Attention Modifier: "+ str(attention_modifier))
	print("Costume Suspicion: "+ str(costume_suspicion))
