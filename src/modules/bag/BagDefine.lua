module(...,package.seeall)

kMaxCap = 100	--最大格子数
kCols = 4		--一排有多少个格子
kExpandCost = 500	--一次扩充需要多少银子

kMaxUseCnt = 50	--一次最多使用50个道具

BAG_OP = {
	kSendAll = 1,	--发送全部
	kSendLocal = 2,	--发送变化
}

BAG_TAG = {
	kTagAll = 0,	--全部
	kTagEquipPiece = 1,	--礼包
	kTagCost = 2,		--消耗
	kTagMaterial = 3,		--材料
	kTagItem = 4,		--道具
}

USE_ITEM = {
	kItemUseOk = 0,		--道具使用成功
	kItemNotExist = 1,	--道具不存在
	kItemCanNotUse = 2,	--道具不能使用
	kItemNotEnoughGrid = 3,	--格子不够用
	kItemWineOwn = 4,	--已经拥有酒类buff
	kItemBoxOpen = 5,	--宝箱使用
}
USE_ITEM_TIPS = {
	[0] = "%s使用成功",
	"道具不存在",
	"该道具不能使用",
	"背包位置不够",
}

--道具分类号
ITEM_TYPE= {
	kEquip = 1101,	--小伙伴装备
	kHeroLvUp = 1201,	--英雄经验丹
	kWeaponLvUp = 1202,	--神兵经验丹
	kHero = 1401,	--英雄卡片
	kHeroFrag = 1402,	--英雄碎片
	kWeapon = 1501,		--神兵
	kWeaponFrag = 1502,	--神兵碎片
	kPartnerFrag = 1602,	--小伙伴碎片
	kPartnerLvupFrag = 1603,	--小伙伴升阶碎片
	kStrengthFrag = 1702,		--力量道具碎片
	kOpenBox = 9906,	--开宝箱
	kWine = 2001,		--酒吧物品
	kVirItem = 9901,		--虚拟道具
}

VIRITEMID2NAME = {
	[9901001] = "money",
	[9901002] = "rmb",
	[9901003] = "arena",
	[9901004] = "tour",
	[9901005] = "power",
	[9901006] = "phy",
	[2102001] = "train",
}

BAG_GRID_OP = {
	kAdd = 1,
	kChange = 2,
	kDel = 3,
}

REWARD_TIPS = {
	[1] = "出售物品成功",
	[2] = "合成物品成功",
	[3] = "购买物品成功",
	[4] = "领取奖励成功",
	[5] = "调制成功",
	[6] = "捐献成功",
	[7] = "兑换礼品成功",
}

ITEM_ID_MONEY = 9901001
ITEM_ID_RMB = 9901002
ITEM_ID_EXPEDITION = 9901004
ITEM_ID_PHY = 9901006
ITEM_ID_TRAIN = 2102001

