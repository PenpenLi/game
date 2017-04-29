module(..., package.seeall)
setmetatable(_M, {__index = Control})

local expeditionData = require("src/modules/expedition/ExpeditionData").getInstance()
local Define = require("src/modules/expedition/ExpeditionDefine")
local Common = require("src/core/utils/Common")
local Hero = require("src/modules/hero/Hero")
local HeroDefine = require("src/modules/hero/HeroDefine")


function new()
	local ctrl = Control.new(require("res/expedition/ExpeditionEnemySkin"), {"res/expedition/ExpeditionEnemy.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	return ctrl
end

function uiEffect()
	return UIManager.SECOND_TEMP_FULL
end

function init(self)
	self.touchParent = false
	self.tiaozhan1.close:addEventListener(Event.Click, onClose, self)
	self.tiaozhan1.touchParent = false

	self.tiaozhan1.team.txicon:setVisible(false)
	local size = self.tiaozhan1.team.txicon:getContentSize()
	self.bodyGrid = CommonGrid.new()
	self.bodyGrid:setBodyIcon(Master.getInstance().bodyId)
	self.bodyGrid:setScale(0.4)
	self.bodyGrid:setPosition(self.tiaozhan1.team.txicon:getPositionX() + size.width / 2, self.tiaozhan1.team.txicon:getPositionY() + size.height / 2)
	self.tiaozhan1.team:addChild(self.bodyGrid)

	self.tiaozhan1.team.lv.txtshuzi:setString(Master.getInstance().lv)

	self.enemyGridList = {}
	local heroBg = self.tiaozhan1.yingxiong
	for i=1,4 do
		local grid = HeroGridS.new(heroBg['touxiangk' .. i], i)
		grid.name = 'HeroGridS' .. i
		--self.tiaozhan1.yingxiong:getChild("touxiangk" .. i):addChild(grid)
		grid:setAnchorPoint(0, 0)
		grid:setHero()
		grid:setPosition(heroBg['touxiangk' .. i]:getPositionX() - 7, heroBg['touxiangk' .. i]:getPositionY() + 18)
		table.insert(self.enemyGridList, grid)
	end

	self.tiaozhan1.tiaozhan:addEventListener(Event.Click, function(p, evt)
			Network.sendMsg(PacketID.CG_EXPEDITION_HERO_LIST)
		end
	, self.tiaozhan1)
end

function onClose(self, evt)
	UIManager.removeUI(self)
end

function showChallangeUI(self, name, lv, icon, guildName)
	self.tiaozhan1.txtzd:setString(name)
	self.tiaozhan1.txtsz:setString("(" .. expeditionData:getCurId() .. "/" .. Define.COPY_NUM .. ")")
	self.tiaozhan1.txtghmz:setString(guildName)

	for index,enemy in ipairs(expeditionData:getEnemyList()) do
		local headCon = self.tiaozhan1.yingxiong:getChild("touxiangk" .. index)
		local headBG = headCon.itembg
		local hero = Hero.new(enemy.name, enemy.exp, enemy.lv, enemy.quality, index, 0, HeroDefine.STATUS_NORMAL, enemy.dyAttr)
		headCon:getChild("xuetiao"):setScaleX(enemy.hp / hero.dyAttr.maxHp)

		if enemy.hp > 0 then
			headCon:shader()
			headCon:getChild("yzw"):setVisible(false)
		else
			headCon:shader(Shader.SHADER_TYPE_GRAY)
			headCon:getChild("yzw"):setVisible(true)
		end

		self.enemyGridList[index]:setHero(hero)  
		--self.enemyGridList[index]:setItemNum(enemy.lv)
		--self.enemyGridList[index]:setAnchorPoint(0.5, 0.5)
		--self.enemyGridList[index]:setPosition(headBG:getContentSize().width / 2 + headBG:getPositionX(),
		 --headBG:getContentSize().height / 2 + headBG:getPositionY())
	end
	local enemyLen = #expeditionData:getEnemyList()
	for index = enemyLen + 1,Define.TEAM_MEMBER_NUM do
		local headCon = self.tiaozhan1.yingxiong:getChild("touxiangk" .. index)
		headCon:setVisible(false)
	end
end
