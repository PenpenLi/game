module(..., package.seeall)

--培养固定属性
ATTRS = {
	[1] = "atk",
	[2] = "finalAtk",
	[3] = "def",
	[4] = "finalDef",
	[5] = "maxHp",
}

ITEM_ID = 2102001

TrainCnt = {
	[1] = 1,
	[2] = 5,
	[3] = 10
}

TRAIN_RET = {
	kOk = 1,
	kNoHero = 2,
	kDataErr = 3,
	kNoMoney = 4,
	kNoRmb = 5,
	kNoItem = 6,
	kMax = 7,
	kNoLv = 8,
}

TRAIN_RET_TIPS = {
	[1] = "培养成功",
	[2] = "没有这个英雄",
	[3] = "数据错误",
	[4] = "金币不足",
	[5] = "钻石不足",
	[6] = "材料不足",
	[7] = "达到上限",
	[8] = "战队等级%d级开放",
}

TRAIN_ADD_RET = {
	kOk = 1,
	kNoHero = 2,
	kDataErr = 3,
}

TRAIN_ADD_RET_TIPS = {
	[1] = "吸收成功",
	[2] = "没有这个英雄",
	[3] = "数据错误",
	[4] = "没有可以吸收的",
}
