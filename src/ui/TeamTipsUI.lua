module(..., package.seeall)
setmetatable(_M, {__index = Control})

local FlowerDefine = require("src/modules/flower/FlowerDefine")
local HeroDefineConfig = require("src/config/HeroDefineConfig").Config

function new(team)
	local ctrl = Control.new(require("res/common/TeamInfoSkin"),{"res/common/TeamInfo.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(team)
	return ctrl
end

_M.touch = function(self,event)
	Common.outSideTouch(self,event)
end

function init(self,team)
	for i=1,4 do
		local lvTxt = cc.LabelAtlas:_create("0123456789", "res/common/atkSpeedNum.png", 15, 19, string.byte('0'))
		lvTxt:setPositionX(self.szyx['grid'..i].lv.shape:getPositionX() + 20)
		lvTxt:setPositionY(self.szyx['grid'..i].lv.shape:getPositionY() - 2)
		self.szyx['grid'..i].lv.lvTxt = lvTxt
		self.szyx['grid'..i].lv._ccnode:addChild(lvTxt)
	end

	function onClose(self)
		UIManager.removeUI(self)
	end
	self.close:addEventListener(Event.Click,onClose,self)
	self.close:setVisible(false)
	self:refreshInfo(team)


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

--team = {
--	name = "",
--	lv = 0,
--	rank = 0,
--	win = 0,
--	guild = "",
--	icon = 0,
--	fightVal = 0,
--	flowerCount = 0,
--	fightList = {
--		[1] = {name = "",lv = 1},
--		[2] = {name = "",lv = 1},
--		[3] = {name = "",lv = 1},
--		[4] = {name = "",lv = 1},
--		}
--	}
function refreshInfo(self,team, flowerFromType)
	if not team then
		return
	end
	self.flowerFromType = flowerFromType
	if team.index == nil then 
		self.index = team.rank or 0
	else 
		self.index = team.index
	end 
	self.yxxx.mz.txtmz:setString(team.name or "")
	self.yxxx.txtsz:setString(team.rank or 0)
	self.txtszz:setString(team.win or 0)
	self.txtghm:setString(team.guild or "")
	self.yxxx.mz.lv:setString("lv."..tostring(team.lv or 0))
	self.yxxx.zdl.txtsz:setString(team.fightVal or 0)
	self.fightTxt:setString(team.flowerCount)
	for i = 1,4 do
		self.szyx["grid"..i].lv:setVisible(false)
	end
	if team.fightList then
		for i = 1,4 do
			if team.fightList[i] then
				local heroName = team.fightList[i].name
				if heroName and heroName ~= "" then
					local grid = HeroGridS.new(self.szyx["grid"..i].itembg,i)
					local hero = {
						name = heroName,
						quality = team.fightList[i].quality or 1,
						lv = team.fightList[i].lv or 1,
					}
					grid:setHero(hero)
				end
			end
		end
	end
	--local body = cc.Sprite:createWithSpriteFrameName(string.format("Body.body%d.png",team.icon or 0))
	--body:setAnchorPoint(0,0)
	--self.yxxx.itembg._ccnode:addChild(body)
	local icon = 1
	if not team.icon then
		team.icon = team.bodyId
	end
	if team.icon then
		icon = tonumber(team.icon)	
	end
	CommonGrid.bind(self.yxxx.headbg)
	self.yxxx.headbg:setBodyIcon(icon)
end
