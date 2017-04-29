module(..., package.seeall)

local FightRecordUI = require("src/modules/arena/ui/FightRecordUI")
setmetatable(_M, {__index = FightRecordUI})

local Define = require("src/modules/peak/PeakDefine")

function new()
	local ctrl = FightRecordUI.new()
	setmetatable(ctrl,{__index = _M})
	ctrl.name = "PeakRecordUI"
	ctrl:init()
	return ctrl
end

function init(self)
	self.name1:setVisible(false)
	self.name2:setVisible(false)
end

function addRankToList(self,record)
	local list = self.jilu
	local no = list:addItem()
	local ctrl = list.itemContainer[no]
	local master = Master.getInstance()
	local itemSelf = ctrl.left
	local itemEnemy = ctrl.right

	itemSelf.charName:setString(master.name)
	itemSelf.lv:setString("lv."..master.lv)
	itemEnemy.charName:setString(record.name)
	itemEnemy.lv:setAnchorPoint(1,0)
	itemEnemy.lv:setString("lv."..record.lv)

	if record.result == Define.RESULT_SUCCESS then
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

	local fightList = record.fightList
	table.sort(fightList,function(a,b)return a.pos < b.pos end)
	local enemyList = record.enemyList
	table.sort(enemyList,function(a,b)return a.pos < b.pos end)
	for i = 1,4 do
		if fightList[i] then
			local grid = HeroGridS.new(itemSelf["hero"..i].jnBG,fightList[i].pos)
			grid:setHero({name = fightList[i].name,lv = fightList[i].lv,quality = fightList[i].quality})
			grid:setScale(58/92)
		else
			itemSelf["hero"..i].jnBG:setVisible(false)
		end
		if enemyList[i] then
			local grid = HeroGridS.new(itemEnemy["hero"..i].jnBG,enemyList[i].pos)
			grid:setHero({name = enemyList[i].name,lv = enemyList[i].lv,quality = enemyList[i].quality})
			grid:setScale(58/92)
		else
			itemEnemy["hero"..i].jnBG:setVisible(false)
		end
	end
end
