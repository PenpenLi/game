module(..., package.seeall)
setmetatable(_M, {__index = Control}) 

local MonsterConfig = require("src/config/MonsterConfig").Config
local Hero = require("src/modules/hero/Hero")
local HeroDefine = require("src/modules/hero/HeroDefine")
local BaseMath = require("src/modules/public/BaseMath")
local RuleUI = require("src/ui/RuleUI")
local RankDefine = require("src/modules/rank/RankDefine")
local FlowerDefine = require("src/modules/flower/FlowerDefine")

local OrochiConfig = require("src/config/OrochiConfig").Config
local Logic = require("src/modules/orochi/OrochiLogic")
local Define = require("src/modules/orochi/OrochiDefine")

function new()
    local ctrl = Control.new(require("res/trial/RankSkin"),{"res/trial/Rank.plist"})
    setmetatable(ctrl,{__index = _M})
    ctrl:init()
    return ctrl
end

function uiEffect()
	return UIManager.FIRST_TEMP
end

function init(self)
	self:addArmatureFrame("res/trial/effect/Shine.ExportJson")
	self.isFullScreen = true
	Network.sendMsg(PacketID.CG_TRIAL_RANK_QUERY)

	self.master = Master.getInstance()
	self.close:addEventListener(Event.Click, onClose, self)
	self.rankList:setBgVisiable(false)
	self.rankList:setTopSpace(0)
end

function uiEffect()
	return UIManager.FIRST_TEMP_FULL
end

function addStage(self)
	--self:setPositionY(Stage.uiBottom)
end

function setRankData(self,rankList,score)
	self.rankList:removeAllItem()
	self.scoreLabel:setString(tostring(score))
	local myRankNum = "未上榜"
	if next(rankList) then
		self.noData:setVisible(false)
	end
	for index,v in ipairs(rankList) do
		local itemNum = self.rankList:addItem()
		local item = self.rankList:getItemByNum(itemNum)
		--名次
		for i=1,3 do
			item["rank" .. i]:setVisible(false)
		end
		if index <= 3 then
			item["rank" .. index]:setVisible(true)
			item.rank:setVisible(false)
			--effect
			local shineAnimation =ccs.Armature:create('Shine')
			shineAnimation:getAnimation():play("Animation1",-1,-1)
			shineAnimation:setAnchorPoint(0,0)
			shineAnimation:setPosition(30,10)
			item["rank" .. index]._ccnode:addChild(shineAnimation)
		else
			item.rank.rankLabel:setString(tostring(index))
		end
		if v.name == self.master.name then
			myRankNum = index
		end
		item.nameLabel:setString(v.name)
		item.lvLabel:setString(string.format("Lv%s",v.lv))
		item.scoreLabel:setString(tostring(v.score))
		CommonGrid.bind(item.body)
		item.body:setBodyIcon(v.bodyId)
		item:addEventListener(Event.TouchEvent, onCheck, index)
	end
	self.rankNumLabel:setString(tostring(myRankNum))
end

function onCheck(rank,evt)
	if evt.etype == Event.Touch_ended then
		Network.sendMsg(PacketID.CG_RANK_CHECK,RankDefine.RANK_TYPE_TRIAL , rank)
	end
end

function onClose(self, evt)
	UIManager.removeUI(self)
end

function showTeamUI(self,info)
	local ui = UIManager.addChildUI("src/ui/TeamTipsUI")
	ui:refreshInfo(info,FlowerDefine.FLOWER_FROM_TYPE_TRIAL)
end





