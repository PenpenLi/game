module(...,package.seeall)

KICK_BEGIN_RET = {
	kOk = 1,
	kNoGuild = 2,
	kNoArena = 3,
	kNoCnt = 4, --今日次数不足
	kKickCD = 5,
}

KICK_BEGIN_RET_TIPS = {
	[1] = "成功",
	[2] = "没有公会",
	[3] = "请先参加竞技场挑战",
	[4] = "今日次数不足",
	[5] = "挑战CD中",
}

KICK_WIN = 1
KICK_LOSE = 2
