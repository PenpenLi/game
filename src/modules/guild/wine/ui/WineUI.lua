module(..., package.seeall)
setmetatable(_M, {__index = Control})
local WineLvConfig = require("src/config/WineConfig").WineLvConfig
local WineConstConfig = require("src/config/WineConfig").WineConstConfig
local BagDefine = require("src/modules/bag/BagDefine")
local BagData = require("src/modules/bag/BagData")
local WineLogic = require("src/modules/guild/wine/WineLogic")
local BagEventHandler = require("src/modules/bag/EventHandler")

function new()
	local ctrl = Control.new(require("res/guild/WineSkin"),{"res/guild/Wine.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(index)
	return ctrl
end

function addBg(self)
	local bg = Sprite.new('WineScene','res/guild/Winebg.jpg')
	bg.touchEnabled = false
	self.bg = bg
	self:addChild(bg,-1)
	bg:setPositionY(-Stage.uiBottom)
end

function init(self)
	self:addArmatureFrame("res/guild/effect/Wine.ExportJson")
	self:addArmatureFrame("res/common/effect/complete/Complete.ExportJson")
	self:addBg()
	local function onClose(self,event,target)
		UIManager.removeUI(self)
	end
	local function onRule(self,event,target)
		local ui = UIManager.addChildUI("src/ui/RuleScrollUI")
		ui:setId(RuleUI.GuildWine)
	end
	local function onStart(self,event,target)
		local id = self:getSelectId()
		Network.sendMsg(PacketID.CG_WINE_START,id)
	end
	local function onDonate(self,event,target)
		--self.wineBag:setVisible(true)
		ActionUI.show(self.wineBag,"scale")
		self:refreshBag()
	end
	local function onCloseBag(self,event,target)
		ActionUI.hide(self.wineBag,"scaleHide")
		--self.wineBag:setVisible(false)
	end
	local function onDonateBag(self,event,target)
		if self.lastClickGrid then
			local id = self.lastClickGrid.id
			--Network.sendMsg(PacketID.CG_WINE_DONATE,id)
			UIManager.addChildUI("src/modules/guild/wine/ui/WineBagUI",id)
		end
	end
	function onSelectOption(self,event,target)
		local id = target.regionId
		local lv = self.lv or 1
		local items = WineLogic.getWineItems(id,lv)
		for i = 1,5 do
			if items[i] then
				self.topgrids["jiu"..i]:setVisible(true)
				self.topgrids["jiu"..i].jnBG:setItemIcon(items[i].id,"sIcon")
			else
				self.topgrids["jiu"..i]:setVisible(false)
			end
		end
	end
	for i = 1,5 do
		CommonGrid.bind(self.topgrids["jiu"..i].jnBG,"tips")
	end
	for i = 1,3 do
		self.selectregion["region"..i]:addEventListener(Event.Click,onSelectOption,self)
		self.selectregion['region'..i].regionId = i
		local cost = WineConstConfig[1]["cost"..i]
		self.selectregion['region'..i]['jiu'..i].cost:setString(cost)
	end
	self.back:addEventListener(Event.Click,onClose,self)
	self.rule:addEventListener(Event.Click,onRule,self)
	self.rule:setPositionY(-Stage.uiBottom)
	self.start:addEventListener(Event.Click,onStart,self)
	self.donate:addEventListener(Event.Click,onDonate,self)
	self.donate:setPositionY(-Stage.uiBottom)
	self.wineBag.close:addEventListener(Event.Click,onCloseBag,self)
	self.wineBag.donate:addEventListener(Event.Click,onDonateBag,self)
	self.wineBag:setVisible(false)
	self.txtlv:setString("")
	self.txtexp:setString("")
	self.txtcnt:setString("")
	self.selectregion['region1']:setSelected(true)
	onSelectOption(self,nil,self.selectregion['region1'])
	Network.sendMsg(PacketID.CG_WINE_QUERY)
	Bag.getInstance():addEventListener(Event.BagRefresh,wineBagRefresh,self)
end

function wineBagRefresh(self)
	if self.wineBag:isVisible() then
		self:refreshBag()
	end
end

function clear(self)
	Bag.getInstance():removeEventListener(Event.BagRefresh,wineBagRefresh)
	Control.clear(self)
end

function getSelectId(self)
	for i = 1,3 do
		if self.selectregion['region'..i]:getSelected() then
			return i
		end
	end
	return 0
end

function addStage(self)
	self:setPositionY(Stage.uiBottom)
end

function uiEffect()
	return UIManager.FIRST_TEMP_FULL
end

function refreshInfo(self,lv,exp,cnt)
	self.lv = lv
	self.txtlv:setString("奶茶店等级:"..lv)
	local maxExp = WineLvConfig[#WineLvConfig].exp 
	if lv < #WineLvConfig then
		maxExp =  WineLvConfig[lv+1].exp
	end
	local lvCnt = WineLvConfig[lv].cnt
	self.txtexp:setString(string.format("奶茶店经验:%d/%d",exp,maxExp))
	local left = lvCnt - cnt
	self.txtcnt:setString("今日次数:"..left)

	local id = self:getSelectId()
	onSelectOption(self,nil,self.selectregion['region'..id])
end

function onGridClick(self,event,target)
	if event.etype == Event.Touch_ended then
		if self.lastClickGrid then
			self.lastClickGrid.light:setVisible(false)
		end
		target.light:setVisible(true)
		self.lastClickGrid = target
	end
end

function refreshBag(self)
	local list = self.wineBag.body
	local bag = BagData.getItemByType(BagDefine.ITEM_TYPE.kWine)
	list:removeAllItem()
	self.lastClickGrid = nil
	local cap = #bag
	local colDefine = 5
	local rows = math.ceil(cap / colDefine)
	list:setItemNum(rows)
	for i = 1,rows do
		local ctrl = list:getItemByNum(i)
		for col = 1,colDefine do
			local grid = ctrl["grid"..col]
			CommonGrid.bind(grid.itembg,"tips")
			grid.light:setVisible(false)
			local index = (i-1)*colDefine+col
			if index <= cap then
				local item = bag[index]
				grid.id = item.id
				grid.itembg:setItemIcon(item.id)
				grid.itembg:setItemNum(item.cnt)
				if not grid:hasEventListener(Event.TouchEvent,onGridClick) then
					grid:addEventListener(Event.TouchEvent,onGridClick,self)
				end
			end
		end
	end
	local ctrl = list:getItemByNum(1)
	if ctrl then
		ctrl["grid1"]:dispatchEvent(Event.TouchEvent,{etype = Event.Touch_ended})
	end
end

function playEffect(self,rewards)
	local layer = UIManager.newGrayLayer()
	if not self:getChild("gray_layer") then
		self:addChild(layer)
		local bone = Common.setBtnAnimation(self._ccnode,"Wine","1",{y=60})
		bone:getAnimation():setFrameEventCallFunc(function(bonep,evt,originFrameIndex,currentFrameIndex) 
			local bone1 = Common.setBtnAnimation(bone,"Complete","wine",{x=-100,y=-100})
			bone1:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID) 
				if movementType == ccs.MovementEventType.complete then
					layer:removeFromParent()
					BagEventHandler.onGCRewardTips(rewards)
				end
			end)
		end)
	end
end

