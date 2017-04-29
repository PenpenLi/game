module(..., package.seeall)

heroBottom = 100  --英雄地面高度

comboPower = 25	--接招
breakPower = 50 --破招
powPower = 100	--必杀

AssistType = {
	none = 0,
	addHp = 1,
	hit = 2,
	defense = 3,
}

FightModel = {
	handA_autoB = 1,
	autoA_autoB = 2,
	handA_handB = 3,
	autoA_handB = 4,
}

FightType = {
	default = 0,
	arena =1,		--竞技场
	guide = 2,		--引导战斗
	chapter = 3,	--关卡
	guild = 4,		--公会
	trial = 5,		--道场
	expedition = 6,	--世界巡回赛
	vipLevel = 7,   -- vip副本
}

AttackLock = { -- 战斗状态锁定类型，类型值高的不能被低的替换 
	normal =  1,  -- 正常态, 包括前进，后退，跳跃，站
	defense = 2, -- 防御态 
	attack = 3, -- 攻击态 
	beat = 4, -- 受击 
	fall = 5, -- 击倒，击飞
	power = 6,  --爆气
}

State =
{
	show = {
	    start = { lock = 0,action = "胜利",nextState = "stand",loop = 0},   --开场秀
		succeed = { lock = 0,action = "胜利",loop = 0,hold = true},  -- 胜利
		fail = { lock = 0,action = "失败",loop = 0,hold = true}, -- 失败 
		dead = { lock = 0,action = "击倒A",loop = 0,isFloor = true,hold = true}, -- 死亡
	},
	normal = {
		stand = { lock = 1,canBreak = true,action = "待机",loop = 1},
		jump = { lock = 1,action = "跳跃",loop = 0,isJump = true,sound="common/Tiao.mp3"}, 
		jump_forward = { lock = 1,action = "跳跃",loop = 0,speedX = 2 * 180,isJump = true,sound="common/Tiao.mp3"}, 
		jump_back = { lock = 1,action = "跳跃",loop = 0,speedX = -2 * 180,isJump = true,sound="common/Tiao.mp3"},
		forward = { lock = 1,canBreak = true,action = "前进",loop = 1,speedX = 180,canRun = true},
		forward_run = { lock = 1,canBreak = true,action = "跑",loop = 1,speedX = 450,canRun = true,sound="common/Qianpao.mp3"},
		back = { lock = 1,canBreak = true,action = "后退",loop = 1,speedX = -1 * 180 ,canRun = true},
		back_run = { lock = 1,canBreak = false,action = "急退",loop = 0,--[[speedX = -2 * 180,--]]canRun = true,sound="common/Houpao.mp3"},
	},
	defense = {
		jump_defense = { lock = 2,action = "空中防御",loop = 0,speedX = -2 * 180,isJump = true},
		stand_light_defense = { lock = 2,canBreak = true,action = "轻防",loop = 0,hold = true},
		stand_heavy_defense = { lock = 2,canBreak = true,action = "重防",loop = 0,hold = true},
	},
	--[[
	attack = {
	},
	--]]
	beat = 
	{
		hit_fly_a = { lock = 4,action = "击飞A",loop = 0,delay=true,nextState = "somesault_up_b",speedX = -1.5 * 180,isJump = true,isFloor = true,sound="common/HitHeavy.mp3"},
		hit_fly_b = { lock = 4,action = "击飞B",loop = 0,delay=true,nextState = "somesault_up_b",speedX = -1.5 * 180,isJump = true,isFloor = true,sound="common/HitHeavy.mp3"},
		hit_light_a= { lock = 4,action = "上段轻受击",loop = 0,hold = true,delay=true,sound="common/HitLight.mp3"},
		hit_light_b= { lock = 4,action = "下段轻受击",loop = 0,hold = true,delay=true,sound="common/HitLight.mp3"},
		hit_heavy_a= { lock = 4,action = "上段重受击",loop = 0,hold = true,delay=true,sound="common/HitHeavy.mp3"},
		hit_heavy_b= { lock = 4,action = "下段重受击",loop = 0,hold = true,delay=true,sound="common/HitHeavy.mp3"},
		--stun = { lock = 4,canBreak = true,action = "晕眩.rn_layer",animationArg = {frames = 4,loop = -1},speedX = 0,beatState = "attacked_heavy"}, -- 击晕
		be_caught = { lock = 4,action = "被抓住",loop = 0,hold = true, }, -- 翻身爬起
	},
	fall = 
	{
		fall_down_a = { lock = 5,action = "击倒A",loop = 0,nextState = "somesault_up_a",isFloor = true,invincible = true}, -- 击倒 
		fall_down_b = { lock = 5,action = "击倒B",loop = 0,nextState = "somesault_up_b",isFloor = true,invincible = true,}, -- 击倒 
		--jump_fall_down = { lock = 5,action = "击倒.rn_layer",animationArg = {frames = 23,loop = 0},speedX = 0,beatState = "attacked_heavy",invincible = true,nextState = "somesault_up",}, -- 击飞 
		somesault_up_a = { lock = 5,action = "爬起A",loop = 0,invincible = true,}, -- 翻身爬起
		somesault_up_b = { lock = 5,action = "爬起B",loop = 0,invincible = true,}, -- 翻身爬起
	},
	power = 
    {
        break_heat = {lock = 6,action = "暴气",loop = 0,sound="common/Baoqi.mp3"},   --打断被击打
    }
}

function cfgState() 
	local cfg = {}
	for k, v in pairs(State) do 
		for name, config in pairs(v) do
			--cfg[name] = {name=name, lock=lock, lockName=k}
			config.name = name
			config.lockName = k
			cfg[name] = config
			--cfg[name] = {name=name,config=config, lockName=k}
		end
	end
	return cfg
end

HeroState = cfgState() 


-----------------------------------------------------------以下是关于英雄的不同处--------------------------------------------------------------------
--身体的骨头
bodyBone = {
	--["Iori"] = {"右手上","左手上","左脚","右脚"},
	["Iori"] = {"受击框"},
	--["Terry"] = {"左手1侧","右手1侧","左脚3侧","右脚3侧","头","头2"},
	--["Terry"] = {"左手1侧","右手1侧","左脚3侧","右脚3侧"},
	["Terry"] = {"受击框"},
	--["Ryo"] = {"前手上","后手上","前脚下","后脚下","头","头前"},
	--["Ryo"] = {"前手上","后手上","前脚下","后脚下"},
	["Ryo"] = {"受击框"},
	--["Robert"] = {"左手_上臂","右手_上臂s","左脚_脚掌","右脚_脚掌","右脚_脚掌5","右脚_脚掌4","右手_上臂2","右手_上臂3","左手_上臂2s"},
	["Robert"] = {"受击框"},
	--["Mai"] = {"左手上臂_侧","右手上臂_侧","左脚脚掌_侧","右脚脚掌_侧"},
	["Mai"] = {"受击框"},
	--["Clark"] = {"前手下","前脚下","后脚下","后手下"},
	["Clark"] = {"受击框"},
}

--资源
resUrl = {
	--["Target"] = "res/armature/target/Target.ExportJson",
	["Iori"] = "res/armature/iori/Iori.ExportJson",
	["Terry"] = "res/armature/terry/Terry.ExportJson",
	--["Terry2"] = "res/armature/terry2/Terry2.ExportJson",
	["Ryo"] = "res/armature/ryo/Ryo.ExportJson",
	["Robert"] = "res/armature/robert/Robert.ExportJson",
	["Mai"] = "res/armature/mai/Mai.ExportJson",
	["Clark"] = "res/armature/clark/Clark.ExportJson",
	["Athena"] = "res/armature/athena/Athena.ExportJson",
	["Shermie"] = "res/armature/shermie/Shermie.ExportJson",
	["Shingo"] = "res/armature/shingo/Shingo.ExportJson",
	["Andy"] = "res/armature/andy/Andy.ExportJson",
	["Daimon"] = "res/armature/daimon/Daimon.ExportJson",
	["Chang"] = "res/armature/chang/Chang.ExportJson",
	["King"] = "res/armature/king/King.ExportJson",
	["Orochi"] = "res/armature/orochi/Orochi.ExportJson",
}
--小资源
sresUrl = {
	["Iori"] = "res/armature/iori/small/Iori.ExportJson",
	["Terry"] = "res/armature/terry/small/Terry.ExportJson",
	["Ryo"] = "res/armature/ryo/small/Ryo.ExportJson",
	["Mai"] = "res/armature/mai/small/Mai.ExportJson",
	["Chang"] = "res/armature/chang/small/Chang.ExportJson",
	["Shermie"] = "res/armature/shermie/small/Shermie.ExportJson",
	["Orochi"] = "res/armature/orochi/small/Orochi.ExportJson",
	["Daimon"] = "res/armature/daimon/small/Daimon.ExportJson",
	["Andy"] = "res/armature/andy/small/Andy.ExportJson",
--[[
	["Robert"] = "res/armature/robert/small/Robert.ExportJson",
	["Clark"] = "res/armature/clark/small/Clark.ExportJson",
	["Athena"] = "res/armature/athena/small/Athena.ExportJson",
	["Shermie"] = "res/armature/shermie/small/Shermie.ExportJson",
	["Shingo"] = "res/armature/shingo/small/Shingo.ExportJson",
	["Andy"] = "res/armature/andy/small/Andy.ExportJson",
	["Daimon"] = "res/armature/daimon/small/Daimon.ExportJson",
	["Chang"] = "res/armature/chang/small/Chang.ExportJson",
	["King"] = "res/armature/king/small/King.ExportJson",
	["Orochi"] = "res/armature/orochi/small/Orochi.ExportJson",
--]]
}

