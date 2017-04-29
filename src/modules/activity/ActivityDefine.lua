module(...,package.seeall)

local VipRechargeConfig = require("src/config/VipRechargeConfig").Config

RET_OK = 0
RET_NOTPERMITTED = 1
RET_CLOSED = 2
RET_LEVEL = 3
RET_NOSUCHACTIVITY = 4
RET_NOINTIME = 5   -- 不在活动时间内
RET_REWARDED = 6   -- 已经领取了
RET_RMB = 7        -- 钻石不足
RET_REPEAT = 8     -- 重复

STATUS_NOTCOMPLETED = 1
STATUS_COMPLETED    = 2
STATUS_REWARDED     = 3


DAY_ACT   = 1
LEVEL_ACT = 2
PHYSICS_ACT = 3
FIRSTCHARGE_ACT = 4
TESTDIAMOND_ACT = 5
TESTHERO_ACT = 6
TESTVIP_ACT = 7
SIGNIN_ACT = 8
MONTHCARD_ACT = 9
SINGLERECHARGE_ACT = 10
FOUNDATION_ACT = 11
WHEEL_ACT = 12
VIP_ACT = 13
ACCU_ACT = 14

MONTHCARD_DAYS = 30

MONTHCARD_RECHARGE_ID = {7,8}
for id,conf in pairs(VipRechargeConfig) do
	if conf.name == "月卡1" then
		MONTHCARD_RECHARGE_ID[1] = id
	elseif conf.name == "月卡2" then
		MONTHCARD_RECHARGE_ID[2] = id
	end
end

PHYSICS_PERIODS = {
{stime = '12:00:00',etime = '14:00:00'},
{stime = '18:00:00',etime = '20:00:00'},
{stime = '22:00:00',etime = '24:00:00'},
}

ActivityList = 
{
	[1] = {name='LoginActivity'},
	[2] = {name='LevelActivity'},
	[3] = {name='PhysicsActivity',conf="PhysicsActivityConfig"},
	-- [4] = {name='FirstChargeActivity',conf="FirstChargeActivityConfig"},
}


ActivityDefineList = 
{
	[2] = {name = 'LevelActivity',conf="LevelActivityConfig"},
	[3] = {name='PhysicsActivity',conf="PhysicsActivityConfig"},
	[4] = {name = "FirstChargeActivity",conf="FirstChargeActivityConfig"},
	[9] = {name = "MonthCardActivity",conf="MonthCardActivityConfig"},
	[10] = {name = "SingleRechargeActivity",conf="SingleRechargeActivityConfig"},
	[11] = {name = "FoundationActivity",conf="FoundationActivityConfig"},
	[12] = {name = "WhellActivity",conf="WhellActivityConfig"},
	[13] = {name = "VipActivity",conf="VipActivityConfig"},
	[14] = {name = "AccuActivity",conf="AccuActivityConfig"},
}

ActivityListOrder = {
		14,  -- 限时
		4,   -- 首充
		
		10,  -- 单笔充值
		9,   -- 月卡
		13,  -- vip
		3,   -- 体力
		11,  -- 开服基金
		2,   -- 冲级大礼
		12,  -- 转盘
}
