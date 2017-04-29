module(...,package.seeall)

COMPOSE_RET = {
	kOk = 1,
	kDataErr = 2,
	kNoMaterial = 3,
	kFullBag = 4,
	kNoHero = 5,
}

COMPOSE_RET_TIPS = {
	[1] = "合成成功",
	[2] = "数据错误",
	[3] = "材料不足",
	[4] = "背包已满",
	[5] = "还没有这个英雄",
}

EQUIP_RET = {
	kOk = 1,
	kDataErr = 2,
	kNoHero = 3,
	kNoItem = 4,
}

EQUIP_RET_TIPS = {
	[1] = "装备成功",
	[2] = "数据错误",
	[3] = "没有该英雄",
	[4] = "没有这个道具",
}

ACTIVE_RET = {
	kOk = 1,
	kNoItem = 2,
	kDataErr = 3,
	kHasActive = 4,
}

ACTIVE_RET_TIPS= {
	[1] = "激活成功",
	[2] = "材料不足",
	[3] = "数据错误",
	[4] = "已经激活",
}
