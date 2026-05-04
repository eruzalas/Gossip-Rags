extends Node

signal player_listening_call(gossiper_npc: Npc, listening_status: bool)
signal incremented_timeline(bar_num: int, value: float)
signal in_zone_sus(player: Player)
signal caused_attention(player: Player, attention_value: float)

signal player_current_attention(player: Player, current_attention: float)
signal global_current_attention(current_attention: float)
