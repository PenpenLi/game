module(..., package.seeall)
setmetatable(_M, {__index = Control})

local Chapter = require("src/modules/chapter/Chapter")
local ChapterConfig = require("src/config/ChapterConfig").Config
local LevelConfig = require("src/config/LevelConfig").Config

Instance = nil
function new(chapterId,difficulty)
	local ctrl = Control.new(require("res/chapter/LevelRewardSkin"),{"res/chapter/LevelReward.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(chapterId,difficulty)
	Instance = ctrl
	return ctrl	
end



function uiEffect()
	return UIManager.THIRD_TEMP
end

function setButton(self,no,txt)
	self['reward'..no].receive.skillzi:setString(txt)
	self['reward'..no].receive:setEnabled(false)
end

function init(self,chapterId,difficulty)
	_M.touch = function(self, event)
		local ret = Common.outSideTouch(self, event)
		if ret == true then
			Stage.currentScene:dispatchEvent(Event.GuideRemove)
		end
	end

	local function onBoxReceive(self,event,target)
		Network.sendMsg(PacketID.CG_CHAPTER_BOX_REWARD,chapterId,difficulty,target.boxId)
	end
	for i=1,3 do
		self['reward'..i].receive:addEventListener(Event.Click,onBoxReceive,self)
		for j=1,4 do
			CommonGrid.bind(self['reward'..i]['rewardgrid'..j],true)
		end
		self['reward'..i].receive.boxId = i
		Common.setLabelCenter(self['reward'..i].receive.skillzi)
	end
	for i=1,3 do
		local starConf = ChapterConfig[chapterId][difficulty]['boxStar'..i]
		local rewardConf = ChapterConfig[chapterId][difficulty]['boxReward'..i]
		local curStar,maxStar = Chapter.getStar(chapterId,difficulty)
		self['reward'..i].titleTxt:setString('达到'..starConf)
		if starConf and starConf>0 then
			local no = 1
			if curStar >= starConf then 
				self['reward'..i].receive:setState(Button.UI_BUTTON_NORMAL)
				self['reward'..i].receive:setVisible(true)
				self['reward'..i].receive.skillzi:setString('领取')
				self['reward'..i].receive:setEnabled(true)
				if Chapter.getBox(chapterId,difficulty,i) then
					-- self['reward'..i].receive:setState(Button.UI_BUTTON_DISABLE)
					self['reward'..i].receive:setVisible(false)
					self['reward'..i].receivetitle:setString('已领取')
					-- self:setButton(i,'已领取')
				end
			else
				self['reward'..i].receive:setState(Button.UI_BUTTON_DISABLE)
				self['reward'..i].receive:setEnabled(false)
				self['reward'..i].receive:setVisible(false)
				self['reward'..i].receivetitle:setString("未达成")
			end
			for itemId,r in pairs(rewardConf) do
				if type(itemId) == 'number' then 
					self['reward'..i]['rewardgrid'..no]:setItemIcon(itemId,'sIcon')
					self['reward'..i]['rewardgrid'..no]:setItemNum(r)
					no = no + 1
				end
			end
		else
			self['reward'..i]:setVisible(false)
		end
	end


end

function  clear(self)
	Instance = nil
	Control.clear(self)
end
