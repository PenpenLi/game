module(...,package.seeall)
GRID_STATE = {
	active = 0,
	noActive = 1,
	notActive = 2,
	canCompose = 3,
	canActive = 4
}

kMaxStrengthCellCap = 6
kMaxStrengthGridCap = 1
kMaxStrengthLv = 10
kMaxTransferLv = 10

STRENGTH_QUERY_RET = {
	kOk = 1,
	kDataErr = 2,
}

STRENGTH_EQUIP_RET = {
	kOk = 1,
	kClientErr = 2,
	kDataErr = 3,
	kNoMaterial = 4,
	kNoLv = 5,
}

STRENGTH_EQUIP_RET_TIPS = {
	[1] = "装备材料成功",
	[2] = "客户端数据错误",
	[3] = "配置数据错误",
	[4] = "材料不足",
	[5] = "英雄等级不足",
}
STRENGTH_QUICK_EQUIP_RET = {
	kOk = 1,
	kNoEquip = 2,
	kClientErr = 3,
}

STRENGTH_QUICK_EQUIP_RET_TIPS = {
	[1] = "一键装备成功",
	[2] = "没有可以装备的",
	[3] = "数据错误",
}

STRENGTH_LV_UP_RET = {
	kOk = 1,
	kClientErr = 2,
	kDataErr = 3,
	kMaxLv = 4,
	kNoMaterial = 5,
}

STRENGTH_LV_UP_RET_TIPS = {
	[1] = "进阶成功",
	[2] = "客户端数据错误",
	[3] = "配置数据错误",
	[4] = "已经是最大品阶",
	[5] = "进阶材料不足",
}

STRENGTH_TRANSFER_RET = {
	kOk = 1,
	kClientErr = 2,
	kNotLv = 3,
	kMaxLv = 4
}

STRENGTH_TRANSFER_RET_TIPS= {
	[1] = "转职成功",
	[2] = "客户端数据错误",
	[3] = "品阶不足",
	[4] = "已经是最大品阶",
}

MATERIAL_COMPOSE_RET = {
	kOk = 1,
	kClientErr = 2,
	kNoMaterial = 3,
	kBagFull = 4,
	kAtom = 5,
	kNoMoney = 6,
}

MATERIAL_COMPOSE_RET_TIPS = {
	[1] = "合成成功",
	[2] = "客户端数据错误",
	[3] = "材料不足",
	[4] = "背包已满",
	[5] = "该材料不能合成",
	[6] = "金币不足",
}

FRAG_COMPOSE_RET = {
	kOk = 1,
	kClientErr = 2,
	kNoMaterial = 3,
	kBagFull = 4,
	kAtom = 5,
	kNoMoney = 6,
}

FRAG_COMPOSE_RET_TIPS = {
	[1] = "合成成功",
	[2] = "客户端数据错误",
	[3] = "材料不足",
	[4] = "背包已满",
	[5] = "该材料不能合成",
	[6] = "金币不足",
}
