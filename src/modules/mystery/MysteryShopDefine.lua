module(...,package.seeall) 

MAX_MYSTERY_SHOP_LEN = 10

K_SHOP_TAG1 = 1
K_SHOP_TAG2 = 2
K_SHOP_TAG3 = 3

MYSTERY_BUY = {
	kOk = 1,
	kErrData = 2,
	kHasBuy = 3,
	kNoMoney= 4,
	kNoRmb= 5,
}

MYSTERY_BUY_RET = {
	[1] = "购买成功",
	[2] = "数据错误",
	[3] = "已经购买",
	[4] = "金币不足",
	[5] = "钻石不足",
}

MYSTERY_REFRESH = {
	kOk = 1,
	kNoMoney= 2,
	kNoTimes= 3,
}

MYSTERY_REFRESH_RET = {
	[1] = "刷新成功",
	[2] = "钻石不足",
	[3] = "刷新次数不足",
}
