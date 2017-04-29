module(..., package.seeall)
setmetatable(_M, {__index = Control})
local AnnounceConfig = require("src/config/AnnounceConfig").Config
local Define = require("src/modules/announce/AnnounceDefine")
local Logic = require("src/modules/task/TaskLogic")
local Announce = require("src/modules/announce/Announce")

function new(announce)
	local ctrl = Control.new(require("res/announce/AnnounceSkin"),{"res/announce/Announce.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(announce)
	return ctrl
end

function uiEffect()
	return UIManager.SECOND_TEMP_FULL
end

function init(self,announce)
	self.announce = announce
	self.master = Master.getInstance()
	function onClose(self,event,target)
		if not self.master.loginAnnounce then
			self.master.loginAnnounce = true
		end

		if Logic:hasShowTimeTask() then
			local  announce = {}
			announce.content   = "限时任务已开启，完成可获得丰厚奖励！"
			announce.title   = ""
			Announce.show(announce)
		end 
		
		UIManager.removeUI(self)
	end
	self.confirm:addEventListener(Event.Click,onClose,self)

	self.tag:setVisible(false)
	self.content:setBgVisiable(false)
	self.labelSkin = self.content:getItemSkin().children[1]
	self.menu:setBgVisiable(false)
	self.menu:setBtwSpace(10)
	self.menu:setTopSpace(10)

	self.announceList = {}
	for id,v in ipairs(AnnounceConfig) do
		if v.type == Define.TYPE_LOGIN  then
			if not self.firstId then
				self.firstId = id
			end
			self:addAnnouce(id)
		end
	end
	self.lastBtn = self.announceList[self.firstId] 
	self.announceList[self.firstId]:setState("down", true)
	self:selectAnnounce(self.firstId)
end

function addAnnouce(self,id)
	local conf = AnnounceConfig[id]
	local title = conf.title
	local item = self.menu:getItemByNum(self.menu:addItem())
	Common.setLabelCenter(item.titleBtn.title)
	item.titleBtn.title:setString(title)
	item.titleBtn.id = id
	item.titleBtn:addEventListener(Event.TouchEvent,function(self,event,target) 
		if self.lastBtn then
			self.lastBtn:setState("normal")
		end
		target:setState("down", true)
		self.lastBtn = target
		if event.etype == Event.Touch_ended then
			self:selectAnnounce(id)
		end
	end,self)
	self.announceList[id] = item.titleBtn
	--tag
	if next(conf.tag) then
		for _,tagName in ipairs(conf.tag) do
			local tagSkin = self.tag[tagName]:getSkin()
			local tag = Image.new(tagSkin)
			item.titleBtn:addChild(tag)
		end
	end
end

function selectAnnounce(self,id)
	local conf = AnnounceConfig[id] 
	local content = conf.content
	local rich = RichText2.new()
	rich:setVerticalSpace(5)
	rich:setTextWidth(self.labelSkin.width)
	--rich:setPosition(self.labelSkin.x,self.labelSkin.y+self.labelSkin.height)
	--rich:setPosition(0,0)
	--rich:setContentSize(cc.size(self.labelSkin.width,0))
	--rich:setColor(38,11,11)
	rich:setString(content)
	rich:reverse()
	self.content:removeAllItem()
	self.content:addItem(rich)
end

function addStage(self)
	self:setPositionY(Stage.uiBottom)
end

return AnnounceUI 

