extends Sprite3D

@onready var npc: Npc = $".."
@onready var gossiper_component: Node = $"../GossiperComponent"
@onready var dialogue_component: Node = $SubViewport/DialogueComponent

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if npc.npc_type == Enums.NpcType.GOSSIPER:
		gossiper_component.current_gossip.connect(_display_gossip)
		gossiper_component.gossiping_active.connect(_set_gossiping)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _set_gossiping(status: bool):
	dialogue_component._set_gossiping(status)

func _display_gossip(gossip: Dictionary):
	dialogue_component._display_gossip(gossip)
