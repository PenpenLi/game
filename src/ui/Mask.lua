module(..., package.seeall)

setmetatable(_M, {__index = Control})

function new()
	local instance = {}
	setmetatable(instance, {__index = _M})
	instance:init()
	return instance
end

function init(self)
	self.name = "Mask"

	self._ccnode = cc.LayerColor:create(cc.c4b(0, 0, 0, 122))
	self.touchParent = false
	self.touchChildren = false

	self.list = nil
end

function setStoryTalk(self, desc, iconName, dir, scaleVal)
	if self.talkUI == nil then
		local StoryTalkUI = require("src/ui/StoryTalkUI").new()
		self.talkUI = StoryTalkUI.new()
		self:addChild(self.talkUI)
	end

	self.talkUI:setStoryTalk(desc, iconName, dir, scaleVal)	
end

function setStoryTalkList(self, list, isContinueFight)
	if not isContinueFight then
		--暂停战斗
		local Ai = require("src/modules/fight/Ai")
		Stage.currentScene.ui:stopCD()
		Stage.currentScene:changeAiState(Ai.AI_STATE_NONE)
	end

	self.list = Common.deepCopy(list)
	print('setStoryTalkList doNextTalk')
	self:doNextTalk()
	self.talkUI:setScale(Stage.uiScale)
end

function touch(self, event)
	if event.etype == Event.Touch_ended then
		print('touch next talk ==============================')
		self:doNextTalk()
	end
	return false
end

function doNextTalk(self)
	if self.list then
		if self.talkUI and self.talkUI:hasTalking() == true then
			self.talkUI:showTalkDirect()
		else
			self:doTalk()
		end
	end
end

function doTalk(self)
	if #self.list > 0 then
		local record = table.remove(self.list, 1)
		self:setStoryTalk(record.desc, record.iconName, record.dir, record.scale)
	else
		self:endTalk()
	end
end

function endTalk(self)
	--继续战斗
	local Ai = require("src/modules/fight/Ai")
	Stage.currentScene.ui:startCD()
	Stage.currentScene:changeAiState(Ai.AI_STATE_HIT)

	self:removeFromParent()
end
