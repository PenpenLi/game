module(..., package.seeall)
setmetatable(_M, {__index = Control})

local Hero = require("src/modules/hero/Hero")
local SkillLogic = require("src/modules/skill/SkillLogic")
local SkillMasterConfig = require("src/config/SkillMasterConfig").Config
local SkillUpConfig = require("src/config/SkillUpConfig").Config
local Define = require("src/modules/skill/SkillDefine")

function new(heroName)
	print("===>>>" , heroName)
	assert(heroName ~= nil, "必须来个英雄名")
	local ctrl = Control.new(require("res/skill/SkillMasterSkin"),{"res/skill/SkillMaster.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl.heroName = heroName
	ctrl.hero = Hero.getHero(heroName)
	ctrl:init()
	return ctrl
end

function init(self)
	local list = SkillLogic.getEquipSkillGroup(self.hero, Define.TYPE_NORMAL)
	self.masterLv = self:getMasterLv(list)

	--local rich = RichText2.new()
	--rich:setString("招数强化大师<font color='255,255,0'> " .. self.masterLv .. "</font> 级" )
	--rich:setPosition(self.titleLabel._skin.x, self.titleLabel._skin.y)
	--self:addChild(rich)
	--self.titleLabel:setString("")
	--self.titleLabel:setString("招数强化大师" .. self.masterLv .. "级")
	
	--local lvTxt = cc.LabelAtlas:_create("0123456789", "res/common/HeroLv.png", 15, 19, string.byte('0'))
	local lvTxt = cc.LabelAtlas:_create("0123456789", "res/common/HeroLv.png", 18, 22, string.byte('0'))
	--lvTxt:setString(tostring(8))
	lvTxt:setString(tostring(self.masterLv))
	lvTxt:setPosition(self.chongzhi5._skin.x + self.chongzhi5._skin.width / 2, self.chongzhi5._skin.y + 2)
	lvTxt:setAnchorPoint(0.5, 0)
	self.chongzhi5:setVisible(false)
	self._ccnode:addChild(lvTxt)

	self.left.title:setString("招数强化大师" .. self.masterLv .. "级")
	self.right.title:setString("招数强化大师" .. self.masterLv + 1 .. "级")
	self.right.tips:setString("(已上阵招数达" .. (self.masterLv + 1) * 5 .. "级)")
	self:setLvInfo(self.left, SkillMasterConfig[self.masterLv])
	self:setLvInfo(self.right, SkillMasterConfig[self.masterLv + 1])
	self:setSkillListInfo(list)
end

function uiEffect()
	return UIManager.THIRD_TEMP
end

function addStage(self)
	self:adjustTouchBox(0,Stage.uiBottom,0,2*Stage.uiBottom)
end

function touch(self,event)
	Common.outSideTouch(self,event)
end

function setLvInfo(self, ctrl, conf)
	if conf then
		for k, v in pairs(conf) do
			if ctrl[k] then
				ctrl[k]:setString("+" .. v)
			end
		end
	else
		conf = SkillMasterConfig[1]
		for k, v in pairs(conf) do
			if ctrl[k] then
				ctrl[k]:setString("+0")
			end
		end
	end
end

function setSkillListInfo(self, group)
	local cols = #group
	local list = self.jd.skill
	--local maxLv = #SkillUpConfig
	local maxLv = (self.masterLv + 1) * 5
	self.jd.zsmc1:setVisible(false)
	self.jd.zsmc2:setVisible(false)
	list:setDirection(0)
	list:setItemNum(cols)
	list:setBtwSpace(-1)
	for i = 1, cols do 
		local ctrl = list:getItemByNum(i)
		local skill = group[i]
		ctrl.skillNameLabel:setString(skill:getConf().groupName)
		ctrl.txtshuzi:enableStroke(110, 64, 37, 4)
		ctrl.txtshuzi:setString(skill.lv .. "/" .. maxLv)
		ctrl.expprog:setPercent(skill.lv / maxLv * 100)
		CommonGrid.bind(ctrl.jnBG)
		ctrl.jnBG:setSkillGroupIcon(skill.groupId, 50)
	end
end

function getMasterLv(self, list)
	--[[
	for k,v in pairs(list) do
		for m,n in pairs(v) do
			print(k,m,n)
		end
	end
	]]
	local minLv = nil 
	for k, v in ipairs(list) do
		if minLv == nil then
			minLv = v.lv
		elseif v.lv < minLv then
			minLv = v.lv
		end
	end
	assert(minLv ~= nil)
	return math.floor(minLv / 5)
end
