module(..., package.seeall)

POKER_KIND_LEN = 13
POKER_KIND = 4
POKER_NUM = POKER_KIND_LEN*POKER_KIND

TEXAS_START_RET = {
	kOk = 1,
	kNoGuild = 2,
	kNoCnt = 3,
}

TEXAS_START_RET_TIPS = {
	[1] = "发牌",
	[2] = "没有公会",
	[3] = "今日次数不足",
}

TEXAS_RANK_QUERY_RET = {
	kOk = 1,
	kNoGuild = 2,	
}

TEXAS_QUERY_RET = {
	kOk = 1,
	kNoGuild = 2,	
}

TEXAS_DAYCNT = 5
