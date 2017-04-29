module(...,package.seeall)

MAX_SHOP_REFRESH_TIMES = 1000

WIN = 1
LOSE = 2

LEAD = 1
PASSIVE = 2

ARENA_BEGIN = {
	kOk = 0,		--成功开始竞技场
	kLeftTimes = 1,	--超过今日次数
	kCdTime = 2,	--挑战CD中
	kNoEnemy = 3,	--对手数据错误
	kEnemying  = 4,	--对手正在竞技场中
}

ARENA_BEGIN_TIPS = {
	[1] = "今日剩余次数不足",
	[2] = "挑战CD中",
	[3] = "对手数据错误",
	[4] = "对手正在竞技场中",
}

ARENA_BUY = {
	kOk = 0,		--购买成功	
	kNoFame = 1,	--声望不足
	kHasBuy = 2,	--已经购买过
	kFullBag = 3,	--背包空间不足
	kErrData= 4,	--数据异常
}

ARENA_BUY_TIPS = {
	[0] = "购买成功",
	[1] = "声望不足",
	[2] = "已经购买过",
	[3] = "背包空间不足",
	[4] = "数据异常",
}

ARENA_REFRESH_TIPS = {
	[0] = "刷新成功",
	[1] = "刷新次数为0",
	[2] = "钻石不足",
	[3] = "数据异常",
}

ARENA_RESETCD_TIPS= {
	[1] = "重置成功",
	[2] = "钻石不足"
}
