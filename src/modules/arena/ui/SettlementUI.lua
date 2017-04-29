module(..., package.seeall)
local SettlementWinUI = require("src/ui/SettlementWinUI")
local SettlementLoseUI = require("src/ui/SettlementLoseUI")
local ArenaDefine = require("src/modules/arena/ArenaDefine")
local ArenaData = require("src/modules/arena/ArenaData")
local ArenaConstConfig = require("src/config/ArenaConstConfig").Config

function new(result,rewards)
	local ctrl
	if result == ArenaDefine.WIN then
    	ctrl = SettlementWinUI.new()
		setmetatable(_M, {__index = SettlementWinUI}) 
		setmetatable(ctrl,{__index = _M})
    	ctrl:win(rewards)
	else
    	ctrl = SettlementLoseUI.new()
		setmetatable(_M, {__index = SettlementLoseUI}) 
		setmetatable(ctrl,{__index = _M})
		ctrl:lose()
	end
    return ctrl
end

function win(self,rewards)
	SettlementWinUI.init(self)
	self:addConfirmBtn()
	local master = Master:getInstance()
	local win = ArenaConstConfig[1].win
	self:setMaster(master.lv,percent,0,win)
	local expedition = {}
	local data = ArenaData.getArenaData()
	table.foreachi(data.fightList, function(i, v) 
						table.insert(expedition,v.name)
					end)
	local reward = {}
	for _,r in ipairs(rewards) do 
		reward[r.rewardName] = r.cnt
	end
	self:setReward(reward)
	self:setHeroes(expedition,reward.heroExp)
	self:setTitle("竞技场")
end

function setMaster(self,lv,percent,rewardExp,rewardMoney)
	local block = self.main.master
	--block.txtlv:setString('等级：'.. lv)
	--block.exp:setPercent(percent)

	self.rewardExpBlock = rewardExp
	self.rewardMoney = rewardMoney
	if rewardExp and rewardExp > 0 then
		Common.addNumAction(block.txtexp, rewardExp, "+")
	else
		block.txtexp:setString("")
	end
	--block.txtyb:setString("积分:")
	CommonGrid.setCoinIcon(block.jbbicon,"arena")
	if rewardMoney and rewardMoney > 0 then
		Common.addNumAction(block.txtmoney, rewardMoney, Master.getInstance().fame - rewardMoney.. "+")
	else
		block.txtmoney:setString("0")
	end  
end

function lose(self)
	SettlementLoseUI.init(self)
	local expedition = {}
	local data = ArenaData.getArenaData()
	table.foreachi(data.fightList, function(i, v) 
						table.insert(expedition,v.name)
					end)
	self:setHeroes(expedition,0)
end

function onClose(self,event,target)
	UIManager.removeUI(self)
	if Stage.currentScene.name ~= 'main' then
		local scene = require("src/scene/MainScene").new()
		Stage.replaceScene(scene)
		scene:addEventListener(Event.InitEnd, function()
			UIManager.replaceUI("src/modules/arena/ui/ArenaUI")
		end)
	end
end

function onStopNumRun(self, evt)
	local block = self.main.master
	if self.rewardExpBlock ~= nil and self.rewardMoney ~= nil then
		block.txtexp:stopAllActions()
		if self.rewardExpBlock and self.rewardExpBlock > 0 then
			block.txtexp:setString("+" .. self.rewardExpBlock)
		else
			block.txtexp:setString("")
		end

		local fame = Master.getInstance().fame -self.rewardMoney
		block.txtmoney:stopAllActions()
		if self.rewardMoney and self.rewardMoney > 0 then
			block.txtmoney:setString(fame .. "+" .. self.rewardMoney)
		else
			block.txtmoney:setString(fame .. "+0")
		end
		self.rewardExpBlock = nil
		self.rewardMoney = nil
	end

	if self.rewardExp ~= nil then 
		block = self.main.heroes
		for i,name in ipairs(self.expedition) do
			local heroGrid = block['hero'..i]
			heroGrid.txtexp:stopAllActions()
			if self.rewardExp then
				heroGrid.txtexp:setString("EXP+" .. self.rewardExp)
			else
				heroGrid.txtexp:setString("")
			end
		end
		self.rewardExp = nil
	end
end

