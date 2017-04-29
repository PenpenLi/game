module(...,package.seeall) 

MAX_GUILD_SHOP_LEN = 10

GUILD_BUY = {
	kOk = 1,
	kErrData = 2,
	kHasBuy = 3,
	kNoMoney= 4,
	kNoGuild = 5,
}

GUILD_BUY_RET = {
	[1] = "购买成功",
	[2] = "数据错误",
	[3] = "已经购买",
	[4] = "公会声望不足",
	[5] = "没有公会",
}

GUILD_REFRESH = {
	kOk = 1,
	kNoMoney= 2,
	kNoTimes = 3,
}

GUILD_REFRESH_RET = {
	[1] = "刷新成功",
	[2] = "钻石不足",
	[3] = "刷新次数不足",
}
