class_name Enums

enum PlayerType {
	PLAYER_ONE,
	PLAYER_TWO,
}

enum NpcState {
	IDLE,
	WATCHING,
	MOVING,
	GOSSIPING,
	INTERRUPTED,
	ALERTED,
}

enum NpcType {
	STATIONARY,
	WANDER_ALL,
	WANDER_ZONE,
	GROUP,
	GOSSIPER,
	SPECIAL,
}

enum TimelineBarType {
	OVERALL,
	SEGMENTED,
}
