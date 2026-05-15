extends Sprite3D

# external references
@onready var timer: Timer = $SubViewport/Timer
@onready var v_box_container: VBoxContainer = $SubViewport/VBoxContainer
@onready var npc: Npc = $".."
@onready var gossiper_component: Node = $"../GossiperComponent"

# runtime vars
var dialogue_bubble_prefab = preload("res://scenes/components/dialogue_component/dialogue_bubble/dialogue_bubble.tscn")
var current_dialogue
var can_speak: bool = true
var previous_npc_status: Enums.NpcState = Enums.NpcState.IDLE
var current_npc_status: Enums.NpcState = Enums.NpcState.IDLE

# consts
const MIN_WAIT: float = 10.0
const MAX_WAIT: float = 20.0
const SECONDS_PER_CHARACTER = 0.1

func _ready() -> void:
	# signal connections
	npc.player_in_range.connect(_update_vbox_visibility)
	npc.npc_status_changed.connect(_set_status)
	
	randomize()
	
	# start the speaking timer
	timer.start(randf_range(MIN_WAIT, MAX_WAIT))
	
	if npc.npc_type == Enums.NpcType.GOSSIPER:
		can_speak = false
		gossiper_component.current_gossip.connect(_add_bubble)
		gossiper_component.gossiping_active.connect(_set_gossiping)

# called from NPC
func _set_gossiping(passed_status: bool) -> void:
	# revert bool for the sake of readability
	can_speak = !passed_status
	
	# set that timer uuup
	if can_speak:
		timer.start(randf_range(MIN_WAIT, MAX_WAIT))
	else:
		timer.stop()


func _remove_bubble(child):
	child.queue_free()

# range call for visibility of vboxcontainer
# internally the DialogueBubbles continue rendering with altered alpha vals
func _update_vbox_visibility(is_in_range: bool):
	v_box_container.visible = is_in_range

# add DialogueBubble
func _add_bubble(dialogue: Dictionary) -> void:
	# THIS CODE IS FUCKING STUPID IDK WHY I DID IT ILL FIX IT LATER
	var v_box_children = v_box_container.get_children()
	if v_box_children.size() > 0:
		_remove_bubble(v_box_children[0])
	
	# get dat bubble
	var bubble = dialogue_bubble_prefab.instantiate()
	
	# config it and add it in
	v_box_container.add_child(bubble)
	var typewriter_delay = SECONDS_PER_CHARACTER * dialogue["dialogue"].length()
	bubble._set_text(dialogue["dialogue"], true, (typewriter_delay/2))
	bubble._set_texture(dialogue["bubble_icon"])
	bubble.is_transparent.connect(_remove_bubble)
	_update_all_bubbles()
	
# tell children to update their visibility calculations
# NO LONGER NEEDED DUE TO THE SINGLE STACK DIALOGUE
# REMOVE LATER - NOT URGENT
func _update_all_bubbles() -> void:
	var children = v_box_container.get_children()
	var index = 0
	for child in children:
		child._update_transparency((children.size() - 1) - index)
		index += 1

# set new npc status
# a gossiper should not be in the WATCHING state and speaking WATCHING specific dialogue
# as such a stupid asf function like ts has to be in place
func _set_status(new_status: Enums.NpcState) -> void:
	previous_npc_status = current_npc_status
	current_npc_status = new_status
	
	if current_npc_status == Enums.NpcState.WATCHING:
		current_npc_status = previous_npc_status
	
	elif new_status == Enums.NpcState.ALERTED:
		# lorenzo gets the dialogue
		_lorenzo_gets_the_dialogue()
		_add_bubble(current_dialogue)
		can_speak = false
	
	else:
		can_speak = true

# on timeout interface with the DialogueProcessor (thank lorenzo for gettin the dialogue)
func _on_timer_timeout() -> void:
	if can_speak:
		_lorenzo_gets_the_dialogue()
		_add_bubble(current_dialogue)

# virtual lorenzo has to grab dialogue - if this breaks blame lorenzo
func _lorenzo_gets_the_dialogue() -> void:
	if current_dialogue == null:
		current_dialogue = DialogueProcessor._get_random_npc_dialogue(npc.current_state)
	# if initialised, but next_id is not "" - get next dialogue
	elif current_dialogue["next_id"] != "":
		current_dialogue = DialogueProcessor._get_next_dialogue(current_dialogue["next_id"])
		
	# else (aka is initialised and does not have a next_id) - get random dialogue
	else:
		current_dialogue = DialogueProcessor._get_random_npc_dialogue(npc.current_state)
	
