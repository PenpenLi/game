module(..., package.seeall)
setmetatable(_M, {__index = Control}) 

local MonsterConfig = require("src/config/MonsterConfig").Config
local Hero = require("src/modules/hero/Hero")
local HeroDefine = require("src/modules/hero/HeroDefine")
local BaseMath = require("src/modules/public/BaseMath")
local RuleUI = require("src/ui/RuleUI")
local RankDefine = require("src/modules/rank/RankDefine")

local OrochiConfig = require("src/config/OrochiConfig").Config
local Logic = require("src/modules/orochi/OrochiLogic")
local Define = require("src/modules/orochi/OrochiDefine")

Instance = nil

function new()
    local ctrl = Control.new(require("res/orochi/OrochiRankSkin"),{"res/orochi/OrochiRank.plist"})
    setmetatable(ctrl,{__index = _M})
    ctrl:init()
	Instance = ctrl
    return ctrl
end

function init(self)
	_M.touch = Common.outSideTouch
	Network.sendMsg(PacketID.CG_OROCHI_RANK_QUERY)
	self.master = Master.getInstance()
	--self.close:addEventListener(Event.Click, onClose, self)
	self.close:setVisible(false)
	self.rank:setBgVisiable(false)
	--self:createList()
end

function clear(self)
	Control.clear(self)
	Instance = nil
end

function uiEffect()
	return UIManager.THIRD_TEMP
end

function onCheck(levelId,evt)
	if evt.etype == Event.Touch_ended then
		Network.sendMsg(PacketID.CG_RANK_CHECK,RankDefine.RANK_TYPE_OROCHI , levelId)
	end
end

function setRankData(self,rankList)
--function createList(self)
	--local list = Logic.getRankList()
	if next(rankList) then
		self.noData:setVisible(false)
	end
	table.sort(rankList,function(a,b) return a.levelId < b.levelId end)
	Common.printR(rankList)
	self.rank:removeAllItem()
	local i = 1 
	for _,v in ipairs(rankList) do
		local itemNum = self.rank:addItem()
		local item = self.rank:getItemByNum(itemNum)
		Common.setLabelCenter(item.monsterLabel)
		Common.setLabelCenter(item.nameLabel)

		local label = cc.LabelAtlas:_create("0123456789", "res/common/gkNumb.png", 26, 29 , string.byte('0'))
		label:setPosition(cc.p(item.lvLabel:getPositionX()+item.lvLabel:getContentSize().width/2,item.lvLabel:getPositionY()))
		label:setAnchorPoint(0.5,0)
		label:setString(tostring(v.levelId))
		item._ccnode:addChild(label)

		local boss = Logic.getLevelBoss(v.levelId)
		local monsterName = Common.getMonsterName(boss.monsterId)
		item.monsterLabel:setString(monsterName)
		--item.lvLabel:setString(tostring(i)
		item.lvLabel:setVisible(false)
		item.nameLabel:setString(v.name)
		item.timeLabel:setString(Common.getDCTime(v.entryTime))
		CommonGrid.bind(item.bodyGrid)
		item.bodyGrid:setBodyIcon(v.bodyId)
		--reward
		local reward = OrochiConfig[v.levelId].chiefAward
		for pos,v in ipairs(reward) do
			local itemId = v[1]
			local num = v[2]
			local grid = item.reward["item" .. pos]
			CommonGrid.bind(grid,"tips")
			grid:setItemIcon(itemId)
			grid:setItemNum(num)
		end
		--item:addEventListener(Event.TouchEvent, onCheck, v.levelId)
	end
end

function onClose(self, evt)
	UIManager.removeUI(self)
end





