module(..., package.seeall)
setmetatable(_M, {__index = Control})

local Define = require("src/modules/rank/RankDefine")
local TeamUI = require("src/modules/rank/ui/RankTeamUI")
local CommonGrid = require("src/ui/CommonGrid")
local FlowerDefine = require("src/modules/flower/FlowerDefine")
local Hero = require("src/modules/hero/Hero")

function new()
	local ctrl = Control.new(require("res/rank/RankSkin"), {"res/rank/Rank.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	return ctrl
end

function uiEffect(self)
	return UIManager.FIRST_TEMP_LABEL
end

function init(self)
	self:initTypeList()
	self:initCurType()
	self:addListTimer()
	self:addListener()
	self:sendMsg(self.curType)
end

function initTypeList(self)
	self.rankTypeArr = {
		Define.RANK_TYPE_ARENA, 
		Define.RANK_TYPE_FIGHT, 
		Define.RANK_TYPE_GUILD, 
		Define.RANK_TYPE_FLOWER,
		Define.RANK_TYPE_HERO,
		Define.RANK_TYPE_MONEY,
		Define.RANK_TYPE_EXP,
		Define.RANK_TYPE_GUILD_FIGHT,
	}
	self.rankNameArr = {
		"竞技场排行榜",
		"战力排行榜",
		"公会活跃排行榜",
		"鲜花排行榜",
		"名将排行榜",
		"金币排行榜",
		"经验排行榜",
		"公会战力排行榜",
	}
	local len = #self.rankTypeArr
	local list = self.rankTypeList
	list:setItemNum(len)
	for i=1,len do
		local item = list:getItemByNum(i)
		item.rankBtn.type = self.rankTypeArr[i]
		item.rankBtn.tabNameTxt:setDimensions(item.rankBtn.tabNameTxt._skin.width, 0)
		item.rankBtn.tabNameTxt:setHorizontalAlignment(Label.Alignment.Center)
		item.rankBtn.tabNameTxt:setString(self.rankNameArr[i])
		item.rankBtn:addEventListener(Event.Click, onSelectRank, self)
	end
end

function initCurType(self)
	self.curType = Define.RANK_TYPE_ARENA
	local item = self.rankTypeList:getItemByNum(self.curType)
	item.rankBtn.normalIcon:setVisible(false)
end

function addListTimer(self)
	self:openTimer()
	self:addEventListener(Event.Frame, onRefreshList, self)
end

function addListener(self)
	self.back:addEventListener(Event.Click, onClose, self)
end

function onClose(self)
	UIManager.removeUI(self)
end

function onSelectRank(self, evt, target)
	self:selectType(target.type)
end

function selectType(self, type)
	self.tempType = type
	self:unselectAllBtn()
	local item = self.rankTypeList:getItemByNum(self.tempType)
	item.rankBtn.normalIcon:setVisible(false)
	self:sendMsg(type)
end

function unselectAllBtn(self)
	local len = #self.rankTypeArr	
	for i=1,len do
		local item = self.rankTypeList:getItemByNum(i)
		item.rankBtn.normalIcon:setVisible(true)
	end
end

function sendMsg(self, type)
	Network.sendMsg(PacketID.CG_RANK_LIST, type)
end

function refresh(self, dataList)
	if self.tempType then
		self.curType = self.tempType
	end
	self.rankList:removeAllItem()
	self.dataList = dataList
	self.dataLen = #dataList
	self.curIndex = 1

	if self.dataLen == 0 then
		self.noDataTipTxt:setVisible(true)
	else
		self.noDataTipTxt:setVisible(false)
	end
end

function onRefreshList(self)
	if self.dataLen and self.curIndex <= self.dataLen then
		local data = self.dataList[self.curIndex]
		local index = self.rankList:addItem()
		local item = self.rankList:getItemByNum(index)
		self:refreshItem(index, item, data)
		self.curIndex = self.curIndex + 1
	end
end

function refreshItem(self, rank, item, data)
	local function onCheck(rank, evt)
		if evt.etype == Event.Touch_ended then
			Network.sendMsg(PacketID.CG_RANK_CHECK, self.curType, rank)
		end
	end

	item.rankIcon1:setVisible(false)
	item.rankIcon2:setVisible(false)
	item.rankIcon3:setVisible(false)
	if rank <= 3 then
		item["rankIcon" .. rank]:setVisible(true)
		item.rank:setVisible(false)

		item.rank:addArmatureFrame("res/common/CrownEff.ExportJson")
		local bone = ccs.Armature:create("CrownEff")
		bone:getAnimation():play("Animation1",-1,-1)
		bone:setAnchorPoint(0.5,0.5)
		bone:setPosition(item["rankIcon" .. rank]:getContentSize().width/2, item["rankIcon" .. rank]:getContentSize().height/2)
		item["rankIcon" .. rank]._ccnode:addChild(bone)
	else
		item.rank.rankLabel:setString(rank)
		item.rank:setVisible(true)
	end


	item.fightCon:setVisible(false)
	item.heroCon:setVisible(false)
	item.moneyCon:setVisible(false)
	item.expCon:setVisible(false)
	item.guildFightCon:setVisible(false)

	item.infoCon.lvTxt:setString("lv." .. data.lv)
	item.infoCon.nameTxt:setString(data.name)
	
	item.fightCon.flowericon:setVisible(false)
	if self.curType == Define.RANK_TYPE_ARENA then
		item.infoCon:setPositionY(item.infoCon:getPositionY() - 25)
		item.fightCon:setVisible(false)
	elseif self.curType == Define.RANK_TYPE_FIGHT then
		item.fightCon:setVisible(true)
		item.fightCon.zdl:setString("战斗力")
		item.fightCon.fightTxt:setString(data.fight)
	elseif self.curType == Define.RANK_TYPE_GUILD then
		item.fightCon:setVisible(true)
		item.fightCon.zdl:setString("日活跃度")
		item.fightCon.fightTxt:setString(data.fight)
	elseif self.curType == Define.RANK_TYPE_FLOWER then
		item.fightCon:setVisible(true)
		item.fightCon.zdl:setString("鲜花数")
		item.fightCon.flowericon:setVisible(true)
		item.fightCon.fightTxt:setPositionX(item.fightCon.flowericon:getPositionX() + 30)
		item.fightCon.fightTxt:setString(data.flowerCount)
	elseif self.curType == Define.RANK_TYPE_HERO then
		item.heroCon:setVisible(true)
		item.heroCon.heroLvTxt:setString(data.flowerCount)
		item.heroCon.fightTxt:setString(data.fight)
	elseif self.curType == Define.RANK_TYPE_MONEY then
		item.moneyCon:setVisible(true)
		item.moneyCon.moneyTxt:setString(data.fight)
	elseif self.curType == Define.RANK_TYPE_EXP then
		item.expCon:setVisible(true)
		item.expCon.expTxt:setString(data.fight)
	elseif self.curType == Define.RANK_TYPE_GUILD_FIGHT then
		item.guildFightCon:setVisible(true)
		item.guildFightCon.fightTxt:setString(data.fight)
	end

	item.itembg:setVisible(false)
	item.herobg2:setVisible(false)

	if self.curType ~= Define.RANK_TYPE_HERO then
		item.itembg:setVisible(true)
		CommonGrid.bind(item.itembg)
		item.itembg:setBodyIcon(tonumber(data.icon), 0.8)
	else
		item.herobg2:setVisible(true)
		CommonGrid.bind(item.herobg2)
		item.herobg2:setHeroIcon(data.icon, nil, 0.8, data.quality)
		item.infoCon.nameTxt:setString(Hero.getCNameByName(data.icon) .. '(' .. data.name .. ')')
	end

	if self.curType ~= Define.RANK_TYPE_EXP and self.curType ~= Define.RANK_TYPE_MONEY then
		item:addEventListener(Event.TouchEvent, onCheck, rank)
	end
end

function showTeamUI(self, data)
	--local teamUI = self:getChild("RankTeamUI")
	--if teamUI == nil then
	--	teamUI = TeamUI.new()
	--	self:addChild(teamUI)
	--end
	--teamUI:setVisible(true)
	--teamUI:refreshInfo(data, self:getFlowerType())
	if self.curType == Define.RANK_TYPE_HERO then
		local ui = UIManager.addChildUI("src/modules/rank/ui/TeamInfo2UI")
		ui:refreshInfo(data, self:getFlowerType())
	elseif self.curType == Define.RANK_TYPE_GUILD_FIGHT then
		local ui = UIManager.addChildUI("src/modules/rank/ui/TeamInfo1UI")
		ui:refreshInfo(data)
	else
		local ui = UIManager.addChildUI("src/modules/rank/ui/RankTeamUI")
		ui:refreshInfo(data, self:getFlowerType())
	end
end

function getFlowerType(self)
	local typeVal = FlowerDefine.FLOWER_FROM_TYPE_RANK_ARENA
	if self.curType == Define.RANK_TYPE_FIGHT then
		typeVal = FlowerDefine.FLOWER_FROM_TYPE_RANK_FIGHT
	elseif self.curType == Define.RANK_TYPE_FLOWER then
		typeVal = FlowerDefine.FLOWER_FROM_TYPE_RANK_FLOWER
	elseif self.curType == Define.RANK_TYPE_GUILD then
		typeVal = -1
	end
	return typeVal
end

function addStage(self)
	self:setPositionY(Stage.uiBottom)
end
