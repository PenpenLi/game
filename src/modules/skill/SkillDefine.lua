module(...,package.seeall)

MIN_SKILL_LV = 1
MAX_SKILL_LV = 100

MAX_EQUIP_ITEM = 4      --最多可装备技能数

--技能类型
TYPE_NORMAL = 1 	--普通技能
TYPE_FINAL  = 2		--必杀技
TYPE_ASSIST = 3		--援助技能
TYPE_COVER  = 4		--补位技能
TYPE_COMBO  = 5		--连招技能
TYPE_BROKE  = 6		--破招技能
TYPE_ASSISTR = 7		--被动援助技能
TYPE_MAP = {
	[TYPE_NORMAL] = 1,
	[TYPE_FINAL]  = 2,
	[TYPE_ASSIST] = 3,
	[TYPE_COVER]  = 4,
	[TYPE_COMBO]  = 5,
	[TYPE_BROKE]  = 6,
	[TYPE_ASSISTR]  = 7,
}
TYPE_CONF = {
	[TYPE_NORMAL] = {equipNum=3,costType="money",upType="normal"},
	--怒气技
	[TYPE_FINAL]  = {equipNum=1,costType="rage",upType="final"},
	[TYPE_COMBO]  = {equipNum=1,costType="rage",upType="combo"},
	[TYPE_BROKE]  = {equipNum=1,costType="rage",upType="broke"},
	--援助类型
	[TYPE_ASSIST] = {equipNum=1,costType="assist",upType="assist"},
	[TYPE_ASSISTR] = {equipNum=3,costType="money",upType="assist"},
}

CTYPE_NORMAL = 1 --普通招数
CTYPE_RAGE = 2	  --怒气技能
CTYPE_ASSIST = 3	--援助技

--攻击方式/装备位置/出手方式
EQUIP_NONE = 0      --未装备
EQUIP_A = 1			
EQUIP_B = 2			
EQUIP_C = 3			
--EQUIP_D = 4			
EQUIP_TYPE_MAP = {
    [EQUIP_A] = "A",
    [EQUIP_B] = "B",  
    [EQUIP_C] = "C", 
    --[EQUIP_D] = "D", 
}

--经验类型
EXP_TYPE_MAP = {
	[TYPE_FINAL] = true,
	[TYPE_ASSIST] = true,
}
EXP_ITEM_ID = 1203001  --经验丹

--克制效果
OppoCName = {
    maxHp = '血量',
    hpR ='血量回复值',
    assistR ='援助回复值',
    rageR ='怒气回复值',
    atkSpeed ='攻速',
    atk ='攻击值',
    def ='防御值',
    crthit ='暴击值',
    antiCrthit ='防爆值',
    block ='格挡值',
    antiBlock  ='破挡值',
    damage  ='真实伤害值',
}

AssistFight = 300000	--援助攻击系数

AssistAttr = {
	none = 0,
	atk = 1,
	hp = 2,
	rageA = 3,
	rageD = 4,
	atkBuf = 5,
	timeA = 6,
	timeD = 7,
	hpR = 8,
}


AssistAttrCName = {
	none = "无用，逗你玩",
	atk = "召唤攻击",
	hp = "瞬加血",
	rageA = "瞬加怒",
	rageD = "瞬减怒",
	atkBuf = "加攻",
	timeA = "延长战斗时间",
	timeD = "缩短战斗时间",
	hpR = "缓慢加血",
}

--防御系数
DefFactor = 5000


--技能碎片
Item2Career = {
	[2101001] = 1,
	[2101002] = 2,
	[2101003] = 3,
	[2101004] = 4,
	[2101005] = 5,
	[2101006] = 6,
	[2101007] = 7,
}
Career2Item = {}
for k,v in pairs(Item2Career) do
	Career2Item[v] = k
end




ERROR_CODE = Common.newEnum({
	"ERROR_CONF",
	"NOT_HERO_SKILL",
	"NO_SKILL",
	"NOT_EMPTY_POS",
	"HAD_EQUIP",
	"NOT_FIT_TYPE",
	"COST_OVER",
	"NOT_OPEN_LV",
	"ERROR_TYPE",
	"UPGRADE_MAX_LV",
	"SKILL_LIMIT",
	"EXCEED_HERO_LV",
	"UP_NEED_ITEM",
	"NO_MONEY",
	"NO_RAGE",
	"NO_ASSIST",
})

ERROR_CONTENT = {
	[ERROR_CODE.ERROR_CONF] = "配置出错",
	[ERROR_CODE.NOT_HERO_SKILL] = "英雄没有该技能",
	[ERROR_CODE.NO_SKILL] = "英雄未达到技能开放等级",
	[ERROR_CODE.NOT_EMPTY_POS] = "格子已满",
	[ERROR_CODE.HAD_EQUIP] = "已装备",
	[ERROR_CODE.NOT_FIT_TYPE] = "装备类型不符",
	[ERROR_CODE.COST_OVER] = "超出cost值",
	[ERROR_CODE.NOT_OPEN_LV] = "未达到技能开放等级",
	[ERROR_CODE.ERROR_TYPE] = "错误的技能类型",
	[ERROR_CODE.UPGRADE_MAX_LV] = "已达到最大技能等级",
	[ERROR_CODE.SKILL_LIMIT] = "技能限定",
	[ERROR_CODE.EXCEED_HERO_LV] = "技能等级不能超过英雄等级",
	[ERROR_CODE.UP_NEED_ITEM] = "缺少技能经验书",
	[ERROR_CODE.NO_MONEY] = "金币不足",
	[ERROR_CODE.NO_RAGE] = "怒气点不足",
	[ERROR_CODE.NO_ASSIST] = "援助点不足",
}



