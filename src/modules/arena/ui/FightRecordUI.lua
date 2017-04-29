module(..., package.seeall)
setmetatable(_M, {__index = Control})
local ArenaDefine = require("src/modules/arena/ArenaDefine")

function new()
	local ctrl = Control.new(require("res/arena/FightRecordSkin"),{"res/arena/FightRecord.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	return ctrl
end

function uiEffect()
	return UIManager.THIRD_TEMP
end

function init(self)
	self.jilu:setBgVisiable(false)
	self.norecord:setVisible(false)
	self:openTimer()
	self:addEventListener(Event.Frame, addRankByFrame)
	self.count = 1
end

function addRankByFrame(self,event)
	self.count = self.count + 1
	if self.count % 3 == 0 then
		local frameRate = 1
		if self.sortedRank and #self.sortedRank > 0 then
			for i = 1,frameRate do
				if self.sortedRank[1] then
					local rank = self.sortedRank[1]
					table.remove(self.sortedRank,1)
					self:addRankToList(rank)
				else
					break
				end
			end
		end
	end
end

function addRankToList(self,record)
	local list = self.jilu
	local no = list:addItem()
	local ctrl = list.itemContainer[no]
	local master = Master.getInstance()
	local itemSelf
	local itemEnemy
	if record.lead == ArenaDefine.PASSIVE then
		itemSelf = ctrl.right
		itemEnemy = ctrl.left
		itemSelf.lv:setAnchorPoint(1,0)
	else
		itemSelf = ctrl.left
		itemEnemy = ctrl.right
		itemEnemy.lv:setAnchorPoint(1,0)
	end
	itemSelf.charName:setString(master.name)
	itemSelf.lv:setString("lv."..master.lv)
	itemEnemy.charName:setString(record.name)
	itemEnemy.lv:setString("lv."..record.lv)
	if record.result == ArenaDefine.WIN then
		itemEnemy.losezi:setVisible(true)
		itemEnemy.winzi:setVisible(false)
		itemSelf.losezi:setVisible(false)
		itemSelf.winzi:setVisible(true)
	else
		itemSelf.losezi:setVisible(true)
		itemSelf.winzi:setVisible(false)
		itemEnemy.losezi:setVisible(false)
		itemEnemy.winzi:setVisible(true)
	end
	itemSelf.touxiang:setVisible(false)
	CommonGrid.bind(itemSelf.zjbg)
	itemSelf.zjbg:setBodyIcon(master.bodyId,0.5)
	itemEnemy.touxiang:setVisible(false)
	CommonGrid.bind(itemEnemy.zjbg)
	itemEnemy.zjbg:setBodyIcon(record.icon,0.5)

	ctrl.txtxj:setVisible(false)
	ctrl.downicon:setVisible(false)
	ctrl.txtss:setVisible(false)
	ctrl.upicon:setVisible(false)
	if record.rise > 0 then
		if record.lead == ArenaDefine.PASSIVE then
			ctrl.txtxj:setString(record.rise)
			ctrl.txtxj:setVisible(true)
			ctrl.downicon:setVisible(true)
		else
			ctrl.txtss:setString(record.rise)
			ctrl.txtss:setVisible(true)
			ctrl.upicon:setVisible(true)
		end
	end

	local fightList = record.fightList
	table.sort(fightList,function(a,b)return a.pos < b.pos end)
	local enemyList = record.enemyList
	table.sort(enemyList,function(a,b)return a.pos < b.pos end)
	for i = 1,4 do
		if fightList[i] then
			local grid = HeroGridS.new(itemSelf["hero"..i].jnBG,fightList[i].pos)
			grid:setHero({name = fightList[i].name,lv = fightList[i].lv,quality = fightList[i].quality,transferLv = fightList[i].transferLv})
			grid:setScale(58/92)
		else
			itemSelf["hero"..i].jnBG:setVisible(false)
		end
		if enemyList[i] then
			local grid = HeroGridS.new(itemEnemy["hero"..i].jnBG,enemyList[i].pos)
			grid:setHero({name = enemyList[i].name,lv = enemyList[i].lv,quality = enemyList[i].quality,transferLv = enemyList[i].transferLv})
			grid:setScale(58/92)
		else
			itemEnemy["hero"..i].jnBG:setVisible(false)
		end
	end
end

_M.touch = function(self,event)
	Common.outSideTouch(self,event)
end

function refreshInfo(self,recordData)
	local list = self.jilu
	local len = #recordData
	if len > 0 then
		self.norecord:setVisible(false)
	else
		self.norecord:setVisible(true)
	end
	list:removeAllItem()
	self.sortedRank = recordData
	
end
