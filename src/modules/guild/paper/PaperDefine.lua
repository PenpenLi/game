module(...,package.seeall)

PAPER_QUERY_RET = {
	kOk = 1,
	kNoGuild = 2,
}

PAPER_QUERY_RET_TIPS = {
	[1] = "查询成功",
	[2] = "没有公会",
}

PAPER_SEND_RET = {
	kOk = 1,
	kNoGuild = 2,
	kSumMin = 3,
	kSumMax = 4,
	kNotVip = 5,
}
PAPER_SEND_RET_TIPS = {
	[1] = "发红包成功",
	[2] = "没有公会",
	[3] = "红包数少于公会成员数",
	[4] = "钻石不足",
	[5] = "VIP等级不足",
}

PAPER_GET_RET = {
	kOk = 1,
	kNoGuild = 2,
}

PAPER_GET_RET_TIPS = {
	[1] = "抢到了红包",
	[2] = "没有公会",
}
