module(..., package.seeall)
setmetatable(_M, {__index = Control})

local FlowerDefine = require("src/modules/flower/FlowerDefine")
local HeroDefineConfig = require("src/config/HeroDefineConfig").Config
local Hero = require("src/modules/hero/Hero")

function new()
	local ctrl = Control.new(require("res/rank/TeamInfo2Skin"),{"res/rank/TeamInfo2.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(team)
	return ctrl
end

_M.touch = function(self,event)
	Common.outSideTouch(self,event)
end

function init(self)
	self.giveFlowerBtn:setVisible(false)
	self.giveFlowerBtn:addEventListener(Event.Click, onGiveFlower, self)
end

function onGiveFlower(self, evt)
	if Master.getInstance().lv >= FlowerDefine.FLOWER_LIMIT_LV then
		Network.sendMsg(PacketID.CG_FLOWER_GIVE_OPEN, tostring(self.index), self.flowerFromType)
	else
		Common.showMsg('战队等级达到' .. FlowerDefine.FLOWER_LIMIT_LV .. '级开启')
	end
end

function uiEffect()
	return UIManager.THIRD_TEMP
end

function refreshInfo(self, team, flowerFromType)
	if not team then
		return
	end
	local hero = team.fightList[4]
	self.flowerFromType = flowerFromType
	self.index = team.rank or 0
	self.nameTxt:setString(Hero.getCNameByName(team.bodyId) .. ' lv.' .. hero.lv)
	self.rankTxt:setString(team.rank)
	self.power.fightTxt:setString(team.fightVal)
	self.playerNameTxt:setString(team.name)	
	self.playerLvTxt:setString('lv.' .. team.lv)
	self.guildNameTxt:setString(team.guild)
	for i = 1,5 do
		if hero.quality >= i then
			self.starCon["star"..i]:setVisible(true)
		else
			self.starCon["star"..i]:setVisible(false)
		end
	end

	
	self:addArmatureFrame(string.format("res/armature/%s/small/%s.ExportJson",string.lower(team.bodyId),team.bodyId))
	local bgX,bgY = self.armbg:getPosition()
	local heroArm = ccs.Armature:create(team.bodyId)
	heroArm:setScale(0.6)
	heroArm:setPosition(cc.p(bgX+self.armbg:getContentSize().width/2, bgY+30))
	heroArm:getAnimation():playWithNames({'待机'},0,true)
	self._ccnode:addChild(heroArm)
end
