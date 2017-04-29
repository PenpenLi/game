module(...,package.seeall)

EVENT_ID = 10
GUILD_BOSS_ID = 90501
BOSS_REFRESH_HP_RATE = 1000   --血量刷新频率
BOSS_DURING_TIME = 1800

BOSS_STATUS_START = 1
BOSS_STATUS_END = 2

BOSS_ENTER_RET = {
	kOk = 1,
	kNoGuild = 2,
	kActEnd = 3,
	kBossDie = 4,
	kBossEnterCD = 5,
}
BOSS_ENTER_QUERY_RET = {
	kOk = 1,
	kNoGuild = 2,
	kActEnd = 3,
	kBossDie = 4,
	kBossEnterCD = 5,
}

BOSS_ENTER_RET_TIPS = {
	[1] = "进入成功",
	[2] = "没有公会",
	[3] = "不在活动时间",
	[4] = "boss已经被击退",
	[5] = "进入CD中",
}

BOSS_HURT_RET = {
	kOk = 1,
	kNoGuild = 2,
	kNoBoss = 3,
}

BOSS_HURT_RET_TIPS = {
	[1] = "伤害成功",
	[2] = "没有公会",
	[3] = "没有boss",
}

BOSS_LEAVE_RET = {
	kOk = 1,
	kNoGuild = 2,
}

BOSS_LEAVE_RET_TIPS = {
	[1] = "离开成功",
	[2] = "没有公会",
}

BOSS_REWARD_TYPE_HURT = 1
BOSS_REWARD_TYPE_RANK = 2
BOSS_REWARD_TYPE_LAST = 3

