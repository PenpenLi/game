module(..., package.seeall)
setmetatable(_M, {__index = Control})
local BagOperateUI = require("src/modules/bag/ui/BagOperateUI")
local BagData = require("src/modules/bag/BagData")
local BagDefine = require("src/modules/bag/BagDefine")
local BAG_TAG = BagDefine.BAG_TAG
local ItemConfig = require("src/config/ItemConfig").Config
local MaterialConfig = require("src/config/StrengthMaterialConfig").Config
local ItemCmd = require("src/modules/bag/ItemCmd")
local Hero = require("src/modules/hero/Hero")
local StrengthLogic = require("src/modules/strength/StrengthLogic")
local USE_ITEM = BagDefine.USE_ITEM

function new()
	local ctrl = Control.new(require("res/bag/BagSkin"),{"res/bag/Bag.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	return ctrl
end

function uiEffect(self)
	return UIManager.FIRST_TEMP_LABEL
end

function init(self)
	--self.beibao.gezi:setTopSpace(20)
	self.beibao.gezi:setBtwSpace(12)
	self.beibao.gezi:setBgVisiable(false)

	self.beibao.fenlei.qb:addEventListener(Event.Click,onClassfy,self)
	self.beibao.fenlei.zbsp:addEventListener(Event.Click,onClassfy,self)
	self.beibao.fenlei.xhp:addEventListener(Event.Click,onClassfy,self)
	self.beibao.fenlei.material:addEventListener(Event.Click,onClassfy,self)
	self.beibao.fenlei.item:addEventListener(Event.Click,onClassfy,self)
	self.beibao.fenlei.qb:setSelected(true)
	--self.beibao.tujian.skillzi:setString("道具图鉴")
	self.daojuxinxi.txtmingzi:setAnchorPoint(0,0)
	self.daojuxinxi.txtshuliang:setAnchorPoint(0,0)
	self.sellPosX = self.daojuxinxi.sell:getPositionX()

	--self.beibao.zhengli:addEventListener(Event.TouchEvent,onSort,self)
	--self.beibao.kuochong:addEventListener(Event.TouchEvent,onExpand,self)
	--self.beibao.tujian:addEventListener(Event.Click,onHandBook,self)
	--屏蔽图鉴功能
	--self.beibao.tujian:setVisible(false)
	--屏蔽扩充和整理功能
	--self.beibao.zhengli:setVisible(false)
	--self.beibao.kuochong:setVisible(false)

	self.beibao:addEventListener(Event.TouchEvent,onBlankClick,self)

	self.back:addEventListener(Event.TouchEvent,onClose,self)

	self:initInfoPanel()

	self.lastClickGrid = nil	--最后点击的格子

	self:refreshBag(true)

	self:openTimer()

	self:addEventListener(Event.Frame, addRowByFrame)

	ActionUI.joint({["left"] = {self.daojuxinxi},["right"] = {self.beibao}})
	local mainUI = require("src/modules/master/ui/MainUI").Instance
	if mainUI then
		ActionUI.joint({["up"] = {mainUI.up}})
	end
end

function addRowItem(self,row)
	local list = self.beibao.gezi
	local no = list:addItem()
	local ctrl = list.itemContainer[no]
	if not ctrl:hasEventListener(Event.TouchEvent,onBlankClick) then
		ctrl:addEventListener(Event.TouchEvent,onBlankClick,self)
	end
	for col = 1,BagDefine.kCols do
		local item = row[col]
		if item then
			local grid = ctrl["gezi"..col]
			grid:setVisible(true)
			CommonGrid.bind(grid.headBG)
			grid.pos = item.pos
			grid.id = item.id
			grid.cnt = item.cnt
			grid.light:setVisible(false)
			grid.light:reorder(1)
			if item.cnt > 0 then
				grid.headBG:setItemIcon(item.id)
			end
			grid.headBG:setItemNum(item.cnt)
			if not grid:hasEventListener(Event.TouchEvent,onGridClick) then
				grid:addEventListener(Event.TouchEvent,onGridClick,self)
			end
		else
			local grid = ctrl["gezi"..col]
			grid:setVisible(false)
			grid.light:setVisible(false)
			grid.light:reorder(1)
		end
	end
end

function addRowByFrame(self,event)
	local frameRate = 1
	if self.rowsToBeAdd and #self.rowsToBeAdd > 0 then
		for i = 1,frameRate do
			if self.rowsToBeAdd[1] then
				local row = self.rowsToBeAdd[1]
				table.remove(self.rowsToBeAdd,1)
				self:addRowItem(row)
			else
				break
			end
		end
	end
end

function lastGridClick(self)
	local list = self.beibao.gezi
	local lastClick = self.lastClick or 1
	local col = math.floor((lastClick-1) / BagDefine.kCols) + 1
	local row = (lastClick-1)% BagDefine.kCols + 1
	local ctrl = list:getItemByNum(col)
	if ctrl then
		local grid = ctrl["gezi"..row]
		grid:dispatchEvent(Event.TouchEvent,{etype= Event.Touch_ended})
	end
end

function firstGridClick(self)
	local list = self.beibao.gezi
	local ctrl = list:getItemByNum(1)
	if ctrl then
		local grid = ctrl["gezi1"]
		grid:dispatchEvent(Event.TouchEvent,{etype= Event.Touch_ended})
	end
end

function addStage(self)
	self:setPositionY(Stage.uiBottom)
end

function setXinXiFontSize(self)
	self.daojuxinxi.txtmingzi:setFontSize(20)
	--self.daojuxinxi.txtshuliang:setFontSize(24)
	--self.daojuxinxi.desctxtnl.txtshuoming:setFontSize(24)
	--self.daojuxinxi.desctxtnl.txtbcsm:setFontSize(24)
	----self.daojuxinxi.desctxt.fragNum:setFontSize(24)
	----self.daojuxinxi.desctxt.line1:setFontSize(24)
	----self.daojuxinxi.desctxt.line2:setFontSize(24)
	----self.daojuxinxi.desctxt.line3:setFontSize(24)
	--self.daojuxinxi.cost:setFontSize(24)
	--self.daojuxinxi.txtcsjg:setFontSize(24)
end

function initInfoPanel(self)
	self:setXinXiFontSize()
	self.daojuxinxi:setVisible(false)
	--local skin = self.daojuxinxi.desctxtnl.txtbcsm:getSkin()
	--self.daojuxinxi.desctxtnl.txtbcsm:setAnchorPoint(0,1)
	--self.daojuxinxi.desctxtnl.txtbcsm:setDimensions(skin.width,0)
	--self.daojuxinxi.desctxtnl.txtbcsm:setPositionY(skin.y + skin.height)
	--self.daojuxinxi.desctxtnl.txtbcsm:setString("")
	self.daojuxinxi.desctxtnl.txtbcsm:setDimensions(self.daojuxinxi.xbt6:getContentSize().width-20,0)
	self.descPosY = self.daojuxinxi.desctxtnl.txtshuoming:getPositionY()
	self.extraDescPosY = self.daojuxinxi.desctxtnl.txtbcsm:getPositionY()
	self.xbt6PosY = self.daojuxinxi.xbt6:getPositionY()

	CommonGrid.bind(self.daojuxinxi.daoju)

	--local skin = self.daojuxinxi.desctxtnl.txtshuoming:getSkin()
	--self.daojuxinxi.desctxtnl.txtshuoming:setAnchorPoint(0,1)
	--self.daojuxinxi.desctxtnl.txtshuoming:setDimensions(skin.width,0)
	--self.daojuxinxi.desctxtnl.txtshuoming:setPositionY(skin.y + skin.height)
	self.daojuxinxi.desctxtnl.txtshuoming:setString("")
	self.daojuxinxi.desctxtnl.txtshuoming:setDimensions(self.daojuxinxi.xbt6:getContentSize().width-20,0)

	self.daojuxinxi.txtshuliang:setString("数量：0")
	self.daojuxinxi.txtmingzi:setString("道具")

	self:closeItemInfoPanel()

	self.daojuxinxi.use.num = 1
	self.daojuxinxi.tenUse.num = 10
	self.daojuxinxi.use:addEventListener(Event.Click,onUseItem,self)
	self.daojuxinxi.tenUse:addEventListener(Event.Click,onUseItem,self)
	self.daojuxinxi.sell:addEventListener(Event.Click,onSellItem,self)
	self.daojuxinxi.compose:addEventListener(Event.Click,onCompose,self)
	self.daojuxinxi.details:addEventListener(Event.Click,onDetails,self)
end

function closeItemInfoPanel(self)
	if self.lastClickGrid then
		self.lastClickGrid.light:setVisible(false)
		self.lastClickGrid = nil
	end
	self.daojuxinxi.id = 0
	self.daojuxinxi.cnt = 0
	self.daojuxinxi.pos = 0
	self.daojuxinxi:setVisible(false)
end

function openItemItemInfoPanel(self,id,cnt,pos)
	self:closeItemInfoPanel()
	self.daojuxinxi:setVisible(true)
	--ActionUI.slide(self.daojuxinxi)
	self.daojuxinxi.id = id
	self.daojuxinxi.cnt = cnt
	self.daojuxinxi.pos = pos
	local itemCfg = ItemConfig[id]
	self.daojuxinxi.daoju:setItemIcon(id,"descIcon")
	self.daojuxinxi.desctxtnl.txtbcsm:setString(itemCfg.extraDesc)
	self.daojuxinxi.desctxtnl.txtshuoming:setString(itemCfg.desc)

	local adjustY = self.daojuxinxi.desctxtnl.txtshuoming:getContentSize().height-15
	local adjustY2 = self.daojuxinxi.desctxtnl.txtbcsm:getContentSize().height-15
	self.daojuxinxi.desctxtnl.txtshuoming:setPositionY(self.descPosY-adjustY)
	self.daojuxinxi.xbt6:setContentSize(cc.size(self.daojuxinxi.xbt6:getContentSize().width,self.daojuxinxi.desctxtnl.txtshuoming:getContentSize().height+20))
	self.daojuxinxi.xbt6:setPositionY(self.xbt6PosY-adjustY)
	self.daojuxinxi.desctxtnl.txtbcsm:setPositionY(self.extraDescPosY-adjustY-adjustY2)

	self.daojuxinxi.txtmingzi:setString(itemCfg.name)
	self.daojuxinxi.txtshuliang:setString("数量："..tostring(cnt))
	
	local function setBtnVisible(btnName)
		self.daojuxinxi.use:setVisible(false)
		self.daojuxinxi.details:setVisible(false)
		self.daojuxinxi.compose:setVisible(false)
		if self.daojuxinxi[btnName] then
			self.daojuxinxi[btnName]:setVisible(true)
			self.daojuxinxi.sell:setPositionX(self.sellPosX,0)
		else
			self.daojuxinxi.sell:setPositionX(self.sellPosX+75,0)
		end
	end
	local function setBtnLeftVisible(btnName)
		self.daojuxinxi.tenUse:setVisible(false)
		self.daojuxinxi.sell:setVisible(false)
		self.daojuxinxi[btnName]:setVisible(true)
	end
	local btnName = "none"
	if ItemCmd.checkUse(id) then
		btnName = "use"
	end
	--self.daojuxinxi.desctxt:setVisible(false)
	self.daojuxinxi.desctxtnl:setVisible(true)
	self.daojuxinxi.cost:setString(itemCfg.price)

	if math.ceil(id/100000) == math.ceil(BagDefine.ITEM_TYPE.kStrengthFrag/100) then
		--if BagData.getItemType(id) == BagDefine.ITEM_TYPE.kStrengthFrag 
		--	and StrengthLogic.getFragConfig()[id] then
		if StrengthLogic.getFragConfig()[id] then
			btnName = "compose"
		else
			--self.daojuxinxi.desctxtnl:setVisible(false)
			--self.daojuxinxi.desctxt:setVisible(true)
			local mCfg = MaterialConfig[id]
			if mCfg then
				local index = 1
				for k, v in pairs(mCfg.attr) do
					local attrName = Hero.getAttrCName(k)	
					--self.daojuxinxi.desctxt["line"..index]:setString(attrName .. ":" ..v)
					index = index + 1
					if index > 3 then
						break
					end
				end
				for i = index,3 do
					--self.daojuxinxi.desctxt["line"..i]:setVisible(false)
				end
			end
			local needNum = 0
			local srcId = 0
			local StrengthFragConfig = StrengthLogic.getFragConfig()
			for k,v in pairs(StrengthFragConfig) do
				if v.destId == id then
					needNum = v.num
					srcId = k
					break
				end
			end
			local ownNum = BagData.getItemNumByItemId(srcId)
			local str = string.format("合成需要碎片:%d/%d",ownNum,needNum)
			--self.daojuxinxi.desctxt.fragNum:setString(str)
			btnName = "details"
		end
	end
	setBtnVisible(btnName)
	if math.floor(id/1000) == BagDefine.ITEM_TYPE.kOpenBox then
		setBtnLeftVisible("tenUse")
	else
		setBtnLeftVisible("sell")
	end
end

function onClose(self,event)
	if event.etype == Event.Touch_ended then
		UIManager.removeUI(self)
	end
end

function onClassfy(self,event)
	self:refreshBag(true)
end

function onHandBook(self,event)
	Network.sendMsg(PacketID.CG_HANDBOOK_ITEMLIB)
	-- UIManager.replaceUI("src/modules/handbook/ui/HandbookUI","item")
end

function onSort(self,event)
	if event.etype == Event.Touch_ended then
		Network.sendMsg(PacketID.CG_BAG_SORT)
	end
end

function onExpand(self,event)
	--if event.etype == Event.Touch_ended then
	--	--Network.sendMsg(PacketID.CG_BAG_EXPAND)
	--	local tips = require("src/ui/TipsUI")
	--	if BagData.getBagCap() + BagDefine.kCols <= BagDefine.kMaxCap then
	--		local master = Master.getInstance()
	--		if master.money < BagDefine.kExpandCost then
	--			Common.showMsg("金币不足")
	--		else
	--			local tipsPanel = tips.showTips(string.format("是否花费%d金币，扩充%d个背包格子？",BagDefine.kExpandCost,BagDefine.kCols))
	--			tipsPanel:addEventListener(Event.Confirm,function(self,event) 
	--				if event.etype == Event.Confirm_yes then
	--					Network.sendMsg(PacketID.CG_BAG_EXPAND)
	--				end
	--			end,self)
	--		end
	--	else
	--		tips.showTipsOnlyConfirm("你已经拥有最大容量的背包了，不需要再扩充^-^!")
	--	end
	--end
end

function onUseItem(self,event,target)
	local ret,err = ItemCmd.useItem(self.daojuxinxi.id,target.num)
	if ret then
		if err == USE_ITEM.kItemCanNotUse then
			return Common.showMsg(string.format("该道具不能使用"))
		elseif err == USE_ITEM.kItemWineOwn then
			local tips = TipsUI.showTips("您已经使用过一种酒类物品，继续使用会覆盖之前的效果，确定使用吗？")
			tips:addEventListener(Event.Confirm,function(self1,event) 
				if event.etype == Event.Confirm_yes then
					Network.sendMsg(PacketID.CG_ITEM_USE,self.daojuxinxi.pos,1)
				end
			end)
		elseif err == USE_ITEM.kItemBoxOpen then
			Network.sendMsg(PacketID.CG_ITEM_USE,self.daojuxinxi.pos,target.num)
		end
	else
		local panel = UIManager.addChildUI("src/modules/bag/ui/BagOperateUI",BagOperateUI.kOpUse,self.daojuxinxi.pos)
	end
end

function onSellItem(self,event)
	local panel = UIManager.addChildUI("src/modules/bag/ui/BagOperateUI",BagOperateUI.kOpSell,self.daojuxinxi.pos)
end

function onCompose(self,event)
	local panel = UIManager.addChildUI("src/modules/strength/ui/StrengthCompose",self.daojuxinxi.id)
end

function onDetails(self,event)
	local panel = UIManager.addChildUI("src/modules/strength/ui/StrengthDetails",self.daojuxinxi.id)
end

function onGridClick(self,event,target)
	if event.etype == Event.Touch_ended then
		--print('--------------------------------id,cnt,pos',target.id,target.cnt,target.pos)
		if target.cnt <= 0 then
			--self:closeItemInfoPanel()
		else
			--if target.pos == self.daojuxinxi.pos then
			--	self:closeItemInfoPanel()
			--else
				self:openItemItemInfoPanel(target.id,target.cnt,target.pos)
				self.lastClickGrid = target
				self.lastClick = target.pos
				target.light:setVisible(true)
			--end
		end
	end
end

function onBlankClick(self,event,target)
	if not self._parent then
		return
	end
	if event.etype == Event.Touch_ended then
		if target:getTouchedChild(event.p) then
		else
			--self:closeItemInfoPanel()
		end
	end
end

function getUpdatePos(self,bag)
	local changePos,changeId = BagData.getChangePos()
	local itemId = BagData.getItemByPos(changePos)
	if changePos > 0 and self.tag ~= BAG_TAG.kTagAll and itemId ~= changeId then
		local grids = BagData.bag.grids
		for i = changePos,#grids do
			local tag = BagData.getItemTag(grids[i].id)
			if tag == self.tag then
				itemId = grids[i].id
				break
			end
		end
	end
	local pos = 1
	if changePos > 0 then
		pos = #bag + 1
		for i = 1,#bag do
			if bag[i].id == itemId then
				pos = i
			end
		end
	end
	return pos 
end

function clearGrid(self,bag,force)
	self.lastClickGrid = nil
	local list = self.beibao.gezi
	if force then
		list:removeAllItem()
		BagData.bag.changePos = 0
	else
		local pos = getUpdatePos(self,bag)
		if pos > 0 then
			local row = math.floor((pos-1) / BagDefine.kCols) + 1
			list:removeBackItem(row)
		end
	end
end

function showGrid(self,bag)
	self.rowsToBeAdd = {}
	local row = {}
	local pos = getUpdatePos(self,bag)
	local offset = pos%BagDefine.kCols == 0 and BagDefine.kCols or pos%BagDefine.kCols
	local pos = pos - offset + 1
	for i = pos,#bag do
		table.insert(row,bag[i])
		if #row >= BagDefine.kCols or i == #bag then
			table.insert(self.rowsToBeAdd,row)
			row = {}
		end
	end
	BagData.bag.changePos = 0
end

function refreshBySell(self)
end

function refreshBag(self,force)
	local tag = BAG_TAG.kTagAll
	if self.beibao.fenlei.qb:getSelected() then	-- 全部
		tag = BAG_TAG.kTagAll
	elseif self.beibao.fenlei.zbsp:getSelected() then --装备碎片
		tag = BAG_TAG.kTagEquipPiece
	elseif self.beibao.fenlei.xhp:getSelected() then	--消耗品
		tag = BAG_TAG.kTagCost
	elseif self.beibao.fenlei.material:getSelected() then	--材料
		tag = BAG_TAG.kTagMaterial
	elseif self.beibao.fenlei.item:getSelected() then	--道具
		tag = BAG_TAG.kTagItem
	end
	self.tag = tag
	local bag = BagData.getItemByTag(tag)
	self:clearGrid(bag,force)
	self:showGrid(bag)
	if self.daojuxinxi.pos and self.daojuxinxi.pos ~= 0 then
		local itemId,cnt = BagData.getItemByPos(self.daojuxinxi.pos)
		if cnt > 0 then
			self:openItemItemInfoPanel(itemId,cnt,self.daojuxinxi.pos)
		else
			self:closeItemInfoPanel()
		end
	end
	self:addRowByFrame()
	--self:firstGridClick()
	self:lastGridClick()
end
