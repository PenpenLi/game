module(..., package.seeall)
local SettlementWinUI = require("src/ui/SettlementWinUI")
local SettlementLoseUI = require("src/ui/SettlementLoseUI")
local GuildDefine = require("src/modules/guild/GuildDefine")
local GuildData = require("src/modules/guild/GuildData")
local KickDefine = require("src/modules/guild/kick/KickDefine")
local KickData = require("src/modules/guild/kick/KickData")
local WineLogic = require("src/modules/guild/wine/WineLogic")
fightList = fightList or {}

function new(result)
	local ctrl
	if result == KickDefine.KICK_WIN then
    	ctrl = SettlementWinUI.new()
		setmetatable(_M, {__index = SettlementWinUI}) 
		setmetatable(ctrl,{__index = _M})
    	ctrl:win()
	else
    	ctrl = SettlementLoseUI.new()
		setmetatable(_M, {__index = SettlementLoseUI}) 
		setmetatable(ctrl,{__index = _M})
		ctrl:lose()
	end
    return ctrl
end

function win(self)
	SettlementWinUI.init(self)
	self:addConfirmBtn()
	local master = Master:getInstance()
	local rewardList = {[9901008]=100}
	WineLogic.wineBuffDeal(human,rewardList,"kick")
	self:setMaster(master.lv,percent,0,rewardList[9901008])

	local expedition = {}
	local fightList = KickData.getFightList()
	--local fightList = fightList
	table.foreachi(fightList, function(i,v) 
						table.insert(expedition,v.name)
					end)
	self:setHeroes(expedition,0)
	self:setTitle("踢馆")
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
	CommonGrid.setCoinIcon(block.jbbicon,"guild")
	if rewardMoney and rewardMoney > 0 then
		Common.addNumAction(block.txtmoney, rewardMoney, Master.getInstance().guildCoin - rewardMoney.. "+")
	else
		block.txtmoney:setString("0")
	end  
end

function lose(self)
	SettlementLoseUI.init(self)
	local expedition = {}
	local fightList = KickData.getFightList()
	--local fightList = fightList
	table.foreachi(fightList, function(i,v) 
						table.insert(expedition,v.name)
					end)
	self:setHeroes(expedition,0)
	self:setTitle("踢馆")
end

function onClose(self,event,target)
	UIManager.removeUI(self)
	if Stage.currentScene.name ~= 'main' then
		local scene = require("src/scene/GuildScene").new("fight")
		Stage.replaceScene(scene)
		scene:addEventListener(Event.InitEnd, function()
			UIManager.replaceUI("src/modules/guild/kick/ui/KickUI")
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

		local fame = Master.getInstance().guildCoin-self.rewardMoney
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
