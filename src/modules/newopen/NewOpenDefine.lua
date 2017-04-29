module(...,package.seeall)

LOGIN_GET_RET = {
	kOk = 1,
	kHasGot = 2,
	kDataErr = 3,
}
LOGIN_GET_RET_TIPS = {
	[1] = "领取成功",
	[2] = "已经领取过",
	[3] = "数据错误",
}

RECHARGE_GET_RET = {
	kOk = 1,
	kHasGot = 2,
	kNotEnough = 3,
	kDataErr = 4,
}

RECHARGE_GET_RET_TIPS = {
	[1] = "领取成功",
	[2] = "已经领取过",
	[3] = "充值不足",
	[4] = "数据错误",
}

DISCOUNT_BUY_RET = {
	kOk = 1,
	kHasBuy = 2,
	kSellOut = 3,
	kDataErr = 4,
	kNoRmb = 5,
	kLimit = 6,
	kTimeOut = 7,
}

DISCOUNT_BUY_RET_TIPS = {
	[1] = "购买成功",
	[2] = "已经购买过",
	[3] = "买完了",
	[4] = "数据错误",
	[5] = "钻石不足",
	[6] = "已经卖完",
	[7] = "活动结束",
}
