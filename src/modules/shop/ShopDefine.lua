module(...,package.seeall)

SHOP_BUY_RET = {
	kOk = 1,
	kDataErr = 2,
	kDayLimited = 3,
	kDateLimited = 4,
	kBagFull = 5,
	kNotRmb = 6,
	kNotMoney = 7,
	kNotPowerCoin = 8,
}

SHOP_BUY_RET_TIPS = {
	[1] = "购买成功",
	[2]	= "数据错误",
	[3]	= "今天购买次数已满",
	[4]	= "不在限购活动期间",
	[5]	= "背包已满",
	[6]	= "钻石不足",
	[7]	= "金币不足",
	[8]	= "力量币不足",
}

SHOP_SELL_RET = {
	kOk = 1,
	kDataErr = 2,
	kNoItem = 3,
}

SHOP_SELL_RET_TIPS = {
	[1] = "兑换成功",
	[2]	= "数据错误",
	[3]	= "力量道具不足",
}

COMMON_ONCE_RET = {
	kOk = 1,
	kNoItem = 2,
}

COMMON_ONCE_RET_TIPS= {
	[1] = "抽奖成功",
	[2] = "金币不足",
}

COMMON_TEN_RET = {
	kOk = 1,
	kNoGold = 2,
}

COMMON_TEN_RET_TIPS = {
	[1] = "抽奖成功",
	[2] = "金币不足",
}

RARE_ONCE_RET = {
	kOk = 1,
	kNoGold = 2,
}

RARE_ONCE_RET_TIPS = {
	[1] = "抽奖成功",
	[2] = "钻石不足",
	[3] = "没有更多的英雄可抽取",
}

RARE_TEN_RET = {
	kOk = 1,
	kNoGold = 2,
}

RARE_TEN_RET_TIPS = {
	[1] = "抽奖成功",
	[2] = "钻石不足",
}
EXCHANGE_BUY_RET = {
	kOk = 1,
	kErrData = 2,
	kHasBuy = 3,
	kNoCoin = 4,
}
EXCHANGE_BUY_RET_TIPS = {
	[1] = "兑换成功",
	[2] = "数据错误",
	[3] = "已经购买过",
	[4] = "兑换积分不足",
}

EXCHANGE_REFRESH_RET = {
	kOk = 1,
	kNoTimes = 2,
	kErrData = 3,
	kNoCoin = 4,
}

EXCHANGE_REFRESH_RET_TIPS = {
	[1] = "刷新成功",
	[2] = "次数不足",
	[3] = "数据错误",
	[4] = "钻石不足",
}

K_SHOP_BUY_RMB = 1
K_SHOP_BUY_MONEY = 2
K_SHOP_BUY_POWER = 3
K_SHOP_BUY_ARENA = 4

K_SHOP_COMMON_ONCE = 1
K_SHOP_RARE_ONCE = 2

RARE_TEN = 10

K_SHOP_LOTTERY = 0
K_SHOP_HOTSELL = 1
K_SHOP_COST = 2
K_SHOP_LVUP = 3
K_SHOP_LIMITED = 4
K_SHOP_POWER = 5

K_SHOP_VIRTUAL_MONEY_ID = 1001
K_SHOP_VIRTUAL_PHY_ID = 1002
K_SHOP_VIRTUAL_ARENA_ID = 1003
K_SHOP_VIRTUAL_TREASUREDOUBLE_ID = 1005
K_SHOP_VIRTUAL_TREASURESAFE_ID = 1006
K_SHOP_VIRTUAL_TREASUREEXTEND_ID = 1007
K_SHOP_VIRTUAL_TREASUREGRAB_ID = 1008
K_SHOP_VIRTUAL_RESETBUYCNT_ID = 1009
K_SHOP_VIRTUAL_TRIAL_1_ID = 1010
K_SHOP_VIRTUAL_TRIAL_2_ID = 1011
K_SHOP_VIRTUAL_TRIAL_3_ID = 1012
K_SHOP_VIRTUAL_TREASUREFIGHT_ID = 1013
K_SHOP_VIRTUAL_TREASUREREFRESHMAP_ID = 1014
K_SHOP_VIRTUAL_VIPLEVELTIMES = 1015


