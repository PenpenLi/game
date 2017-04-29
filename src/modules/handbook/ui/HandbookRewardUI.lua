module(..., package.seeall)
setmetatable(_M, {__index = Control})

local Handbook = require("src/modules/handbook/Handbook")
local Def = require("src/modules/handbook/HandbookDefine")
local HeroDefineConfig = require("src/config/HeroDefineConfig").Config
local HeroDefine = require("src/modules/hero/HeroDefine")
local Hero = require("src/modules/hero/Hero")
local ItemConfig = require("src/config/ItemConfig").Config
local ItemHandbookConfig = require("src/config/ItemHandbookConfig").Config
local HeroHandbookConfig = require("src/config/HeroHandbookConfig").Config


function new(name)
	local ctrl = Control.new(require("res/handbook/HandbookRewardSkin"),{"res/handbook/HandbookReward.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(name)
	return ctrl	
end

function addStage(self)
	local bg = LayerColor.new('bg',34,19,16,216, Stage.winSize.width, Stage.winSize.height)
	bg.touchEnabled = false
	bg:setPositionX(0-(Stage.width-self:getContentSize().width)/2)
	self:addChild(bg,-1)
end


function showReward(self,name)
	self.rewardlist:setItemNum(0)
	local conf
	if name == 'item' then
		conf = ItemHandbookConfig
	elseif name == 'hero' then
		conf = HeroHandbookConfig
	end
	local function onClose(self,event,target) 
		UIManager.removeUI(self)
	end
	self.close:addEventListener(Event.Click,onClose,self)

	local function onReward(self,event,target)
		Network.sendMsg(PacketID.CG_HANDBOOK_REWARD,target.name,target.id)
	end



	local rewardList = Handbook.getRewardList(name)
	if rewardList then
		for i,r in ipairs(rewardList) do
			if conf[i] then
				local no = self.rewardlist:addItem()
				local item = self.rewardlist.itemContainer[no]
				local num = conf[i].num
				local desc
				if name == 'hero' then
					desc = '搜集'..num..'个英雄图鉴'
				elseif name == 'item' then
					desc = '收集'..num..'个道具图鉴'
				end
				item.txtrewarddesc:setString(desc)
				if r == Def.STATUS_NOTCOMPLETE then
					item.get:setVisible(false)
					item.txtgot:setString('未完成')
				elseif r == Def.STATUS_NOTREWARDED then
					item.get:setVisible(true)
				elseif r == Def.STATUS_REWARDED then
					item.get:setVisible(false)
					item.txtgot:setString('已领取')
				end

				local id
				local rewardIndex = 0
				for itemId,cnt in pairs(conf[i].reward) do
					if id == nil then id = itemId end
					rewardIndex = rewardIndex + 1
					if rewardIndex <= 2 then
						CommonGrid.bind(item['reward'..rewardIndex].rewardbg)
						item['reward'..rewardIndex].rewardbg:setItemIconBySize(itemId,25)
						item['reward'..rewardIndex].txtnum:setString("x"..cnt)
					end

				end
				item.get.name = name
				item.get.id = i
				CommonGrid.bind(item.iconBG)
				item.iconBG:setItemIcon(id,"descIcon")
				item.get:addEventListener(Event.Click,onReward,self)

			end
		end
	end
end

function init(self,name)
	self:showReward(name)
end
