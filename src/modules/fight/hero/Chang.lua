-- tmp, 通用 特写状态
module(..., package.seeall)
local Hero = require("src/modules/fight/Hero")
local Helper = require("src/modules/fight/KofHelper")
setmetatable(_M, {__index = Hero}) 
Hero.regHeroCtor("Chang", _M)
Helper.initHeroConfig(require("src/config/hero/ChangConfig").Config)
local Define = require("src/modules/fight/Define")
local SoundManager = require("src/modules/fight/SoundManager")

local soundTable = {
	["succeed"] = "chang/Shengli.mp3",
	["start"] = "chang/Kaichang.mp3",
	["dead"] = "chang/Siwang.mp3",
	["forward_run"] = "chang/Jiaobu.mp3",
	["back_run"] = "chang/Jiaobu.mp3",
}
function getSoundTable(self)
	return soundTable
end


function getHitSoundEffect(self)
	if math.random(1,20) > 10 then
		return "chang/Shouji1.mp3"
	else
		return "chang/Shouji2.mp3"
	end
end

function init(self)
	Hero.init(self)
	self:addEventListener(Event.PlayEnd,onPlayEnd,self)

	--[[
	-----配置特写
	self.config["forward_run"] = Define.HeroState["forward_run"]
	self.config["forward_run"].sound = "chang/Jiaobu.mp3"

	self.config["back_run"] = Define.HeroState["back_run"]
	self.config["back_run"].sound = "chang/Jiaobu.mp3"
	--]]
end

function setTarget(self)
	self:addArmatureFrame("res/armature/chang/ChangTarget.ExportJson",0)
end

function onPlayEnd(self,event)
	if not event.isFinish then
		return
	end
	if event.stateName == 2118 then		--_1
		self:play("rush",true)
		self.chang_rushId = 2119 --_2
		self.canRun = true
	end
end

function dispatchEvent(self,evt,arg)
	if arg.stateName == 2118 then
		self.chang_rushPlayId = arg.playId
		self:onPlayEnd(arg)
		return
	elseif arg.stateName == 2119 then
		arg.playId = self.chang_rushPlayId
		self.chang_rushPlayId = nil
	end
	Hero.dispatchEvent(self,evt,arg)
end

local boneRes = {
	["另补层上3"] = {
		"chang_bei_zuoshouxia.png",
		"chang_zheng_zuoshuoshang.png",
		"chang_che_zuoshouxia.png",
		"chang_tieqiu.png",
		"chang_jiaozhang.png",
		"chang_zheng_zuoshuoxia.png",
		"chang_che_zuojiaoxia.png",
		"chang_zheng_zuoshuoxia2.png",
	},

	["另补层上2"] = {
		"chang_che_youjiaoxia.png",
		"chang_tieqiu.png",
		"chang_che_zuojiaoxia.png",
		"chang_bei_zuojiaoxia.png",
		"chang_zheng_zuoshuoxia.png",
		"chang_zheng_youjiaoxia.png",
		"chang_bei_zuoshouxia.png",
		"chang_zheng_zuoshuoxia2.png",
		"chang_bei_youshouxia.png",
		"chang_jiaozhang.png",
		"chang_che_zuoshouxia.png",
		"chang_bei_zuoshoushang.png",
		"chang_zheng_youshuoxia.png",
	},

	["另补层上1"] = {
		"chang_che_zuojiaoxia.png",
		"chang_zheng_youjiaoshang.png",
		"chang_bei_zuoshoushang.png",
		"chang_bei_youjiaoshang.png",
		"chang_tieqiu.png",
		"chang_jiaozhang.png",
		"chang_zheng_zuoshuoshang.png",
		"chang_che_zuo.png",
		"chang_che_youjiaoxia.png",
		"chang_che_youshoushang.png",
		"chang_zheng_zuoshuoxia.png",
		"chang_zheng_zuoshuoxia2.png",
	},

	["左手下"] = {
		"chang_che_zuoshouxia.png",
		"chang_bei_zuoshouxia.png",
		"chang_zheng_zuoshuoxia.png",
		"chang_che_youshouxia.png",
		"chang_tieqiu.png",
		"chang_che_zuo.png",
		"chang_zheng_zuoshuoshang.png",
		"chang_che_zuojiaoxia.png",
	},

	["右手下"] = {
		"chang_che_youshouxia.png",
		"chang_che_zuoshouxia.png",
		"chang_zheng_zuoshuoxia.png",
		"chang_tieqiu.png",
		"chang_bei_youshouxia.png",
		"chang_bei_zuoshouxia.png",
		"chang_che_zuo.png",
		"chang_zheng_zuoshuoshang.png",
		"chang_bei_zuoshoushang.png",
		"chang_zheng_youshuoxia.png",
		"chang_zheng_zuoshuoxia2.png",
	},

	["头"] = {
		"chang_che_tou.png",
		"chang_bei_tou.png",
		"chang_shangduanshouji.png",
		"chang_xiaduanshouji.png",
	},

	["链子3"] = {
		"chang_che_lianzi3.png",
		"chang_bei_lianzi.png",
	},

	["右手上"] = {
		"chang_che_youshoushang.png",
		"chang_bei_youshouxia.png",
		"chang_zheng_zuoshuoxia.png",
		"chang_che_zuoshouxia.png",
		"chang_bei_zuoshoushang.png",
		"chang_zheng_youjiaoshang.png",
		"chang_che_zuo.png",
		"chang_jiaozhang.png",
		"chang_che_youjiaoxia.png",
		"chang_bei_zuoshouxia.png",
	},

	["左手上"] = {
		"chang_che_zuo.png",
		"chang_bei_zuoshoushang.png",
		"chang_che_zuoshouxia.png",
		"chang_tieqiu.png",
		"chang_zheng_zuoshuoshang.png",
		"chang_jiaozhang.png",
		"chang_zheng_youjiaoshang.png",
		"chang_bei_youshouxia.png",
	},

	["链子2"] = {
		"chang_che_lianzi2.png",
		"chang_bei_lianzi2.png",
	},

	["链子1"] = {
		"chang_che_lianzi1.png",
		"chang_bei_lianzi1.png",
	},

	["身体"] = {
		"chang_che_shenti.png",
		"chang_zheng_shenti.png",
		"chang_bei_shenti.png",
	},

	["左脚上"] = {
		"chang_che_zuojiaoshang.png",
		"chang_che_youjiaoshang.png",
		"chang_bei_zuojiaoshang.png",
		"chang_bei_youshouxia.png",
		"chang_zheng_zuojiaoshang.png",
	},

	["左脚下"] = {
		"chang_che_zuojiaoxia.png",
		"chang_bei_zuojiaoxia.png",
		"chang_che_youjiaoxia.png",
	},

	["左脚掌"] = {
		"chang_che_zuojiaozhang.png",
		"chang_jiaozhang1.png",
		"chang_zheng_zuojiaozhang.png",
		"chang_jiaozhang.png",
		"chang_zheng_youjiaozhang.png",
		"chang_che_youjiaozhang.png",
		"chang_bei_zuojiaozhang.png",
	},

	["右脚上"] = {
		"chang_che_youjiaoshang.png",
		"chang_bei_youjiaoshang.png",
		"chang_zheng_youjiaoshang.png",
		"chang_che_zuoshouxia.png",
	},

	["右脚下"] = {
		"chang_che_youjiaoxia.png",
		"chang_bei_youjiaoxia.png",
		"chang_che_youjiaoshang.png",
		"chang_che_zuojiaoxia.png",
		"chang_bei_zuoshoushang.png",
	},

	["右脚掌"] = {
		"chang_che_youjiaozhang.png",
		"chang_jiaozhang1.png",
		"chang_jiaozhang3.png",
		"chang_bei_zuojiaozhang.png",
		"chang_jiaozhang.png",
		"chang_che_zuojiaozhang.png",
		"chang_bei_youjiaozhang.png",
		"chang_bei_zuoshoushang.png",
	},

	["另补层下1"] = {
		"chang_zheng_youshuoshang.png",
		"chang_che_zuo.png",
		"chang_bei_youshoushang.png",
		"chang_che_zuoshouxia.png",
		"chang_zheng_youshuoxia.png",
		"chang_zheng_zuoshuoxia.png",
		"chang_bei_zuoshoushang.png",
		"chang_che_youshoushang.png",
		"chang_zheng_zuoshuoshang.png",
		"chang_bei_youshouxia.png",
		"chang_che_tou.png",
	},

	["另补层下2"] = {
		"chang_zheng_youshuoxia.png",
		"chang_bei_youshouxia.png",
		"chang_che_youshoushang.png",
		"chang_zheng_youshuoshang.png",
		"chang_che_zuoshouxia.png",
		"chang_bei_zuoshoushang.png",
		"chang_bei_youshoushang.png",
	},

	["铁球"] = {
		"chang_tieqiu.png",
		"chang_che_tou.png",
		"chang_zheng_zuoshuoxia.png",
	},


}

function setSkin(self)
	if self.name ~= "heroB" then
		return
	end
	self:addSpriteFrames("res/armature/chang/ChangSkin.plist")
	Hero.setSkin(self,boneRes)
end
local hitSpecialCallback = {
	[2109] = Hero.hitOnce,		--
	[2111] = Hero.hitOnce,		--
	["assist"] = Hero.hitOnce,		--
}

function hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	if hitSpecialCallback[self.curState.name] then
		hitSpecialCallback[self.curState.name](self,bone,evt,originFrameIndex,currentFrameIndex)
	else
		Hero.hit(self,bone,evt,originFrameIndex,currentFrameIndex)
	end
end

function update(self,event)
	local delay = event.delay
	if self.curState.name == "rush" then
		if self:getEnemyDis() < 150 then
			self:play(self.chang_rushId,true,true)
			self.chang_rushId = nil
			self.canRun = nil
		end
	end
end

function startAssist(self)
	Hero.startAssistAtk(self)
end
