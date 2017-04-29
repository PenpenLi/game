module(..., package.seeall)

WINE_QUERY_RET = {
	kOk = 1,
	kNoGuild = 2,
}

WINE_START_RET = {
	kOk = 1,
	kNoMoney = 2,
	kDataErr = 3,
	kNoGuild = 4,
	kNoCnt = 5,
}

WINE_START_RET_TIPS = {
	[1] = "调酒成功",
	[2] = "金币不足",
	[3] = "数据错误",
	[4] = "没有公会",
	[5] = "今日次数不足",
}

WINE_DONATE_RET = {
	kOk = 1,
	kDataErr = 2,
	kNoGuild = 3,
}

WINE_DONATE_RET_TIPS = {
	[1] = "捐献成功",
	[2] = "数据错误",
	[3] = "没有公会",
}

MAX_USE_CNT = 50
