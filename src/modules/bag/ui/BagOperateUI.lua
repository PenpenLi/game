module(..., package.seeall)
setmetatable(_M, {__index = Control})
local BagData = require("src/modules/bag/BagData")
local BagDefine = require("src/modules/bag/BagDefine")
local ItemConfig = require("src/config/ItemConfig").Config

kOpSell = 1
kOpUse = 2

function new(op,pos)
	local ctrl = Control.new(require("res/bag/BagOperateSkin"),{"res/bag/BagOperate.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(op,pos)
	return ctrl
end

function uiEffect()
	return UIManager.THIRD_TEMP
end

function addStage(self)
end

function init(self,op,pos)
	local itemId,cnt = BagData.getItemByPos(pos)
	if itemId == 0 or not ItemConfig[itemId] then
		assert(false)
		return
	end
	self.itemId = itemId
	self.cnt = cnt
	self.pos = pos
	if op == kOpSell then
		self.daojushiyong:setVisible(false)
		self:initSell(pos)
	else
		self.daojuchushou:setVisible(false)
		self:initUse(pos)
	end
end

function setUseFontSize(self)
	--self.daojushiyong.txtcsgs:setFontSize(20)
	--self.daojushiyong.txtshuliang:setFontSize(20)
	--self.daojushiyong.txtmingzi:setFontSize(20)
end

function initUse(self)
	self:setUseFontSize()
	self:setUseCnt(1)
	local cfg = ItemConfig[self.itemId]
	self.daojushiyong.txtshuliang:setString("数量："..self.cnt)
	self.daojushiyong.txtmingzi:setString(cfg.name)

	CommonGrid.bind(self.daojushiyong.daoju)
	self.daojushiyong.daoju:setItemIcon(self.itemId,"descIcon")

	self.daojushiyong.close:addEventListener(Event.TouchEvent,onClose,self)
	self.daojushiyong.jiashi:addEventListener(Event.TouchEvent,onUseNum,self)
	self.daojushiyong.jianshi:addEventListener(Event.TouchEvent,onUseNum,self)
	self.daojushiyong.jiahao:addEventListener(Event.TouchEvent,onUseNum,self)
	self.daojushiyong.jianhao:addEventListener(Event.TouchEvent,onUseNum,self)

	self.daojushiyong.shiyong:addEventListener(Event.TouchEvent,onUseItem,self)
end

function setUseCnt(self,cnt)
	cnt = math.min(BagDefine.kMaxUseCnt,cnt)
	cnt = math.min(self.cnt,cnt)
	cnt = math.max(1,cnt)
	self.useCnt = cnt
	self.daojushiyong.txtcsgs:setString(string.format("%d／%d",cnt,math.min(BagDefine.kMaxUseCnt,self.cnt)))
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

function onUseItem(self,event)
	if event.etype == Event.Touch_ended then
		--是不是要调用ItemCmd处理通用的？？？
		Network.sendMsg(PacketID.CG_ITEM_USE,self.pos,self.useCnt)
		self:onClose(event)
	end
end

function setSellFontSize(self)
	--self.daojuchushou.txtdanjia:setFontSize(20)
	--self.daojuchushou.txtdanjiamiaoshu:setFontSize(20)
	--self.daojuchushou.txthuodeyinbims:setFontSize(20)
	--self.daojuchushou.txthuodeyinbi:setFontSize(20)
	--self.daojuchushou.txtshuliang:setFontSize(20)
	--self.daojuchushou.txtmingzi:setFontSize(20)
	--self.daojuchushou.txtcssl:setFontSize(20)
	--self.daojuchushou.txtcsgs:setFontSize(20)
end

function initSell(self)
	self:setSellFontSize()
	self:setSellCnt(1)
	local cfg = ItemConfig[self.itemId]
	self.daojuchushou.txtdanjia:setString(cfg.price)
	self.daojuchushou.txtshuliang:setString("数量："..self.cnt)
	self.daojuchushou.txtmingzi:setString(cfg.name)

	self.daojuchushou.close:addEventListener(Event.TouchEvent,onClose,self)
	self.daojuchushou.querenchushou:addEventListener(Event.TouchEvent,onSell,self)
	self.daojuchushou.jiahao:addEventListener(Event.TouchEvent,onSellCnt,self)
	self.daojuchushou.jianhao:addEventListener(Event.TouchEvent,onSellCnt,self)
	self.daojuchushou.zuida:addEventListener(Event.TouchEvent,onSellCnt,self)

	CommonGrid.bind(self.daojuchushou.daoju)
	self.daojuchushou.daoju:setItemIcon(self.itemId,"descIcon")
end

function onClose(self,event)
	if event.etype == Event.Touch_ended then
		UIManager.removeUI(self)
	end
end

function onSell(self,event)
	if event.etype == Event.Touch_ended then
		Network.sendMsg(PacketID.CG_ITEM_SELL,self.pos,self.sellCnt)
	end
end

function setSellCnt(self,cnt)
	cnt = math.max(1,cnt)
	cnt = math.min(self.cnt,cnt)
	self.sellCnt = cnt
	self.daojuchushou.txtcsgs:setString(string.format("%d／%d",cnt,self.cnt))
	self.daojuchushou.txthuodeyinbi:setString(cnt * ItemConfig[self.itemId].price)
end

function onSellCnt(self,event,target)
	if event.etype == Event.Touch_ended then
		if target.name == "jiahao" then
			self:setSellCnt(self.sellCnt + 1)
		elseif target.name == "jianhao" then
			self:setSellCnt(self.sellCnt - 1)
		elseif target.name == "zuida" then
			self:setSellCnt(self.cnt)
		end
	end
end
