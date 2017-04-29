module(..., package.seeall)
setmetatable(_M, {__index = Control})

local Common = require("src/core/utils/Common")
local worldBossData = require("src/modules/worldBoss/WorldBossData").getInstance()
local TeamTipsUI = require("src/ui/TeamTipsUI")
local FlowerDefine = require("src/modules/flower/FlowerDefine")

function new()
	local ctrl = Control.new(require("res/worldBoss/WorldBossRankSkin"), {"res/worldBoss/WorldBossRank.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	return ctrl
end

function init(self)
	self.tipsUI = nil
	self.rankList.levelrankbg:setVisible(false)	
	_M.touch = Common.outSideTouch
	self.close:setVisible(false)
	self:addListener()
end

function addListener(self)
	self.close:addEventListener(Event.Click, onClose, self)
end

function uiEffect()
	--return UIManager.FIRST_TEMP_RAW
	return UIManager.THIRD_TEMP
end

function onClose(self)
	UIManager.removeUI(self)
end

function addStage(self)
	Network.sendMsg(PacketID.CG_WORLD_BOSS_RANK)
	--self:setPositionY(Stage.uiBottom)
	self:adjustTouchBox(0,Stage.uiBottom,0,2*Stage.uiBottom)
end

function refreshList(self)
	self.rankList:removeAllItem()

	local dataList = worldBossData:getRankList()
	if #dataList ~= 0 then
		self.noRankTipTxt:setVisible(false)

		local function onCheckTeam(rank, evt)
			Network.sendMsg(PacketID.CG_WORLD_BOSS_CHECK_TEAM, rank)
		end

		local function refreshItem(item, data)
			local grid = CommonGrid.new()
			grid:setBodyIcon(data.icon)
			grid:setPosition(item.headBG:getPositionX() + item.headBG:getContentSize().width / 2, item.headBG:getPositionY() + item.headBG:getContentSize().height/2)
			item:addChild(grid)
			
			item.lvTxt:setString("lv" .. data.lv)
			item.nameTxt:setString(data.name)
			item.hurtTxt:setString("伤害血量：" .. data.hurt)

			item.teamBtn:addEventListener(Event.Click, onCheckTeam, data.rank)

			item.rankIcon1:setVisible(false)
			item.rankIcon2:setVisible(false)
			item.rankIcon3:setVisible(false)
			if data.rank < 4 then
				item["rankIcon" .. data.rank]:setVisible(true)
				item.bg:setVisible(false)
				item.rankTxt:setString("")
			else
				item.bg:setVisible(true)
				item.rankTxt:setString(data.rank)
			end
		end

		for index,data in ipairs(dataList) do
			self.rankList:addItem()
			local item = self.rankList:getItemByNum(index)
			refreshItem(item, data)
		end

	else
		self.noRankTipTxt:setVisible(true)
	end
end

function showTeamUI(self, rank, fighting, flowerCount, heroList)
	local data = worldBossData:getRankList()[rank]

	local tab = {}
	for _,heroData in pairs(heroList) do
		table.insert(tab, {name = heroData.name, lv = heroData.lv, quality = heroData.quality})
	end

	local info = {name = data.name, flowerCount = flowerCount, guild = data.guild, lv = data.lv, fightVal = fighting, rank = data.rank, icon = data.icon, fightList = tab}
	local tipsUI = TeamTipsUI.new()
	tipsUI.txtszz:setVisible(false)
	tipsUI.txtsc:setVisible(false)
	tipsUI:refreshInfo(info, FlowerDefine.FLOWER_FROM_TYPE_BOSS)
	self:addChild(tipsUI)
end
