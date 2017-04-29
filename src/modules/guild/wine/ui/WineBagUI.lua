module(..., package.seeall)
setmetatable(_M, {__index = Control})
local BagData = require("src/modules/bag/BagData")
local ItemConfig = require("src/config/ItemConfig").Config
local WineDefine = require("src/modules/guild/wine/WineDefine")

function new(id)
	local ctrl = Control.new(require("res/bag/BagOperateSkin"),{"res/bag/BagOperate.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(id)
	return ctrl
end

function onClose(self,event,target)
	UIManager.removeUI(self)
end

function init(self,id)
	self.daojuchushou:setVisible(false)
	--self.daojushiyong:setVisible(true)
	self.daojushiyong.close:addEventListener(Event.Click,onClose,self)
	self.daojushiyong.jiashi:addEventListener(Event.TouchEvent,onUseNum,self)
	self.daojushiyong.jianshi:addEventListener(Event.TouchEvent,onUseNum,self)
	self.daojushiyong.jiahao:addEventListener(Event.TouchEvent,onUseNum,self)
	self.daojushiyong.jianhao:addEventListener(Event.TouchEvent,onUseNum,self)
	self.daojushiyong.shiyong:addEventListener(Event.Click,onUseItem,self)

	CommonGrid.bind(self.daojushiyong.daoju)
	self.itemId = id
	self.daojushiyong.daoju:setItemIcon(self.itemId,"descIcon")
	self.daojushiyong.shiyong.skillzi:setString("捐赠")
	local num = BagData.getItemNumByItemId(self.itemId)
	self.cnt = num
	local cfg = ItemConfig[self.itemId]
	self.daojushiyong.txtshuliang:setString(num)
	self.daojushiyong.txtmingzi:setString(cfg.name)
	self:setUseCnt(1)
end

function uiEffect()
	return UIManager.THIRD_TEMP
end

function addStage(self)
end

function onUseNum(self,event,target)
	if event.etype == Event.Touch_ended then
		if target.name == "jiahao" then
			self:setUseCnt(self.useCnt + 1)
		elseif target.name == "jiashi" then
			self:setUseCnt(self.useCnt + 10)
		elseif target.name == "jianhao" then
			self:setUseCnt(self.useCnt - 1)
		elseif target.name =="jianshi" then
			self:setUseCnt(self.useCnt - 10)
		end
	end
end

function setUseCnt(self,cnt)
	cnt = math.min(WineDefine.MAX_USE_CNT,cnt)
	cnt = math.min(self.cnt,cnt)
	cnt = math.max(1,cnt)
	self.useCnt = cnt
	self.daojushiyong.txtcsgs:setString(string.format("%d／%d",cnt,math.min(WineDefine.MAX_USE_CNT,self.cnt)))
end

function onUseItem(self,event)
	Network.sendMsg(PacketID.CG_WINE_DONATE,self.itemId,self.useCnt)
	onClose(self)
end
