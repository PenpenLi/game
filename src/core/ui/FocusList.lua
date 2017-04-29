--[[**************************************************************************** 
用法：
UI_LIST_DEFAULT_SKIN = {
	name="myList",type="List",x=0,y=0,width=553,height=364,
	children=
		{
			{name="bg",type="Image",x=0,y=0,width=553,height=364,
			normal={img="listtest.bg",x=0,y=0,width=553,height=364},},
			{name="testinner",type="Container",x=116,y=132,width=319,height=112,
				children=
				{
					{name="content",type="Image",x=0,y=0,width=319,height=112,
					normal={img="scrolltest.content",x=0,y=0,width=319,height=112},},
				}
			}
		}
}
默认Skin里面带一个Container和一张Image背景，Container为默认的Item
1、function setDirection(self,direct)，用于设置水平或垂直的方向，第二个参数，0代表水平
2、function addItem(self,skin),增加Item,第二个参数为空时，Item内容与第一个相同
3、function setItemNum(self,num,skin)，设置Item个数
4、通过self.itemContainer[i]:getChild()来获取自己的控件
5、function showTopItem(self,num)，快速移动到第num个item到顶部
6、function setDirection(self,direct),设置方向（水平（0）或垂直（1））
7、function setBtwSpace(self,distance)，设置item的间距
8、function setTopSpace(self,distance),设置顶部（左部）间距
9、function removeItem(self,num),移除item，参数代表移除第几个，不带参数则默认移除最后一个
10、function getItemSkin(self),获取默认的item的skin文件
****************************************************************************]]
module("FocusList",package.seeall)
setmetatable(FocusList,{__index = Control})


UI_FOCUSLIST_TYPE = "FocusList"
UI_FOCUSLIST_HORIZONTAL = 0
UI_FOCUSLIST_VERTICAL = 1
UI_FOCUSLIST_TOP_DIS_DEFAULT = 5
UI_FOCUSLIST_BTW_SPACE_DEFAULT = 5
UI_FOCUSLIST_MOVE_DISTANCE_DEFAULT = 50
UI_FOCUSLIST_BUFFER_FACTOR_DEFAULT = 2.5
UI_FOCUSLIST_KEEPFRAME_TIMES_DEFAULT = 4
UI_FOCUSLIST_DISTANCE_LEVEL_DEFAULT = 5
UI_FOCUSLIST_DISTANCE_FACTOR_DEFAULT = 0.2
UI_FOCUSLIST_ACTION_BUFFER_DEFAULT = 100
UI_FOCUSLIST_ITEM_OVERLAP_DEFAULT = 0.18


function new(skin)
	local lt = {
		name = skin.name,
		uiType = UI_FOCUSLIST_TYPE,
		_skin = skin,
		_ccnode = nil,
		_direction = UI_FOCUSLIST_HORIZONTAL,
		itemContainer = {},
		itemNum = 0,
		buffer = false,
		lastPos = {},
		UI_FOCUSLIST_TOP_DIS = UI_FOCUSLIST_TOP_DIS_DEFAULT,
		UI_FOCUSLIST_BTW_SPACE = UI_FOCUSLIST_BTW_SPACE_DEFAULT,
		UI_FOCUSLIST_MOVE_DISTANCE = UI_FOCUSLIST_MOVE_DISTANCE_DEFAULT,
		UI_FOCUSLIST_BUFFER_FACTOR = UI_FOCUSLIST_BUFFER_FACTOR_DEFAULT,
		UI_FOCUSLIST_KEEPFRAME_TIMES = UI_FOCUSLIST_KEEPFRAME_TIMES_DEFAULT,
		UI_FOCUSLIST_DISTANCE_LEVEL = UI_FOCUSLIST_DISTANCE_LEVEL_DEFAULT,
		UI_FOCUSLIST_DISTANCE_FACTOR = UI_FOCUSLIST_DISTANCE_FACTOR_DEFAULT,
		UI_FOCUSLIST_ACTION_BUFFER = UI_FOCUSLIST_ACTION_BUFFER_DEFAULT,
		UI_FOCUSLIST_ITEM_OVERLAP = UI_FOCUSLIST_ITEM_OVERLAP_DEFAULT,
		itemNameNum = 0,
	}
	setmetatable(lt,{__index = FocusList})
	lt:init(skin)
	lt:createContent(skin)
	return lt
end


function calcSelectedItem(self)
	if self._direction == UI_FOCUSLIST_HORIZONTAL then
		local movenode_offset = self.movenode:getPositionX()
		local width = self:getContentSize().width
		local selected = 0
		local len = width
		for i=1,self.itemNum do
			local item = self.itemContainer[i]
			local itemSize = item:getContentSize()
			-- local pos = movenode_offset + item:getPositionX() + itemSize.width/2
			local pos = movenode_offset + item:getPositionX()
			local itemLen = math.abs(pos - width/2)
			if itemLen < len then 
				selected = i
				len = itemLen
			end
			local scale = 1-itemLen/width
			item:setScale(scale)
		end
		if self.selectedCB and self.selectedItem and self.selectedItem ~= selected then

			-- self.selectedCB(selected,self.itemNum)
			self.selectedItem = selected
			self:adjustOrder()
		end
	end	
end
function timeFunc(self,event)
	self:calcSelectedItem()
	if self.ended and self.moveNode._ccnode:getNumberOfRunningActions() == 0 then
		self:setSelectedItem(self.selectedItem)
		self.ended = false
	end
end


function init(self,skin)
	local node = MX.ScissorNode:create()
	node:setContentSize(cc.size(skin.width,skin.height))
	node:setPosition(cc.p(skin.x,skin.y))
	node:setAnchorPoint(cc.p(0,0))
	self._ccnode = node
	local moveSkin = {
		name = "movenode",
		x = 0,
		y = 0,
		width = skin.width,
		height = skin.height,
		children = {},
	}
	local moveNode = Control.new(moveSkin)
	if self._direction == UI_FOCUSLIST_VERTICAL then
		moveNode:setPositionY(skin.height-self.UI_FOCUSLIST_TOP_DIS*2)
		moveNode:setContentSize(cc.size(skin.width,self.UI_FOCUSLIST_TOP_DIS*2))
	else
		moveNode:setContentSize(cc.size(self.UI_FOCUSLIST_TOP_DIS*2,skin.height))
	end
	self:addChild(moveNode)
	self.moveNode = moveNode
	-- self:setTimer()
	self.selectedItem = 0
	self:openTimer()
	self:addEventListener(Event.Frame, timeFunc)

end

function setSelectedItem(self,itemId,isJump)
	self.selectedItem = itemId
	if itemId > self.itemNum then
		return
	end
	local item = self.itemContainer[itemId]
	local xoffset = item:getPositionX() + self.moveNode:getPositionX()
	local w = self:getContentSize().width/2
	local w2 = item:getContentSize().width/2


	-- local o = w - (item:getPositionX()+ self.moveNode:getPositionX()+item:getContentSize().width/2)
	local o = w - (item:getPositionX()+ self.moveNode:getPositionX())
	local offset = xoffset - w - w2
	self.moveNode:stopAllActions()
	if isJump then
		self.moveNode:setPositionX(w - item:getPositionX())
	else
		local action = cc.MoveBy:create(0.3,cc.p(o,0))
		local sineOut = cc.EaseSineOut:create(action)
		self.moveNode:runAction(sineOut)
	end
	
	self.selectedCB(itemId,self.itemContainer[itemId],#self.itemContainer)

	-- 调整层次
	self:adjustOrder()
	if self.selectedCB then
		self.selectedCB(itemId,self.itemContainer[itemId],#self.itemContainer)
	end
end

function adjustOrder(self)
	local newOrder = {}
	for i=1,self.itemNum do
		table.insert(newOrder,{math.abs(i-self.selectedItem),i})
	end
	local function sortFunc(a,b)
		if a[1] > b[1] then
			return true
		else
			return false
		end
	end
	table.sort(newOrder,sortFunc)
	 
	for i = 1,#newOrder-1 do
		local item = self.itemContainer[newOrder[i][2]]
		item:setTop()
		if newOrder[i][1] < 4 then
			item:setVisible(true)
			-- item.spr._ccnode:setOpacity(255*i/(3*#newOrder))
			item.spr._ccnode:setOpacity(150)
			-- if item.txttitle then
			-- 	item.txttitle._ccnode:setOpacity(255*i/(3*#newOrder))
			-- end
		else
			item:setVisible(false)
		end
		-- item.alpha:setVisible(true)
		-- item.alpha:setTop()
	end
	self.itemContainer[newOrder[#newOrder][2]].spr._ccnode:setOpacity(255)
	-- if self.itemContainer[newOrder[#newOrder][2]].txttitle then
	-- 	self.itemContainer[newOrder[#newOrder][2]].txttitle._ccnode:setOpacity(255)
	-- end
	self.itemContainer[newOrder[#newOrder][2]]:setVisible(true)
	self.itemContainer[newOrder[#newOrder][2]]:setTop()
	-- self.itemContainer[newOrder[#newOrder][2]].alpha:setVisible(false)
end


function setSelectedCB(self,selectedCB)
	self.selectedCB = selectedCB
end

function createContent(self,skin)
	for _,childSkin in ipairs(skin.children) do
		if childSkin.type == "Image" or childSkin.type == "Image9" then
			local node = _G[childSkin.type]
			self.listBg = node.new(childSkin)
			self:addChild(self.listBg)
			self.moveNode:setTop()
		elseif childSkin.type == "Container" then
			self.childSkin = childSkin
			self.childSkinX = childSkin.x
			self.childSkinY = childSkin.y
		end
	end
end

function setBgVisiable(self,flag)
	self.listBg:setVisible(flag)
end


--默认顶部(或者左部)为零
function addItem(self,item,num)
	self.itemNum = self.itemNum + 1
	self.itemNameNum  = self.itemNameNum + 1
	if not item then 
		item = Control.new(self.childSkin)
	end
	-- item.alpha = LayerColor.new('alpha',255,255,255,100,item._skin.width,item._skin.height)
	-- item:addChild(item.alpha)
	item:setAnchorPoint(0.5,0.5)
	if self._direction == UI_FOCUSLIST_VERTICAL then
		item:setPositionX(self._skin.width/2)
	else
		item:setPositionY(self._skin.height/2)
	end
	item.name = "item" .. self.itemNum
	self.moveNode:addChild(item)
	self.moveNode:adjustTouchBox(self._skin.width/2,0)
	if not num or num > self.itemNum then
		num = self.itemNum
	end
	item.num = num
	if num ~= self.itemNum then
		--插入
		for k=self.itemNum,num+1,-1 do
			self.itemContainer[k] = self.itemContainer[k-1]
		end
	end
	self.itemContainer[num] = item

	local function onTouchItem(self,event,target)
		if event.etype == Event.Touch_ended then
			self:setSelectedItem(target.num)
		end
	end
	item:addEventListener(Event.TouchEvent,onTouchItem,self)
	--重排
	self:resetList()
	return num
	--return self.itemNum
end

function addItemByNum(self,item,num)
	return self:addItem(self,item,num)
end

--移除第num个item或最后一个item
function removeItem(self,num)
	if self.itemNum >=1 then
		if not num then num = self.itemNum end
		local item = self.itemContainer[num]
		assert(item,"invalid num")
		self.itemNum = self.itemNum - 1
		self.moveNode:removeChild(self.itemContainer[num])
		table.remove(self.itemContainer,num)
		self:resetList()
	end
end

--移除所有item
function removeAllItem(self)
	if self.itemNum >=1 then
		for k=self.itemNum,1,-1 do
			self.moveNode:removeChild(self.itemContainer[k])
			table.remove(self.itemContainer,k)
		end
		self.itemNum = 0
		self:resetList()
	end
end

function getItemSkin(self)
	return deepCopy(self.childSkin)
end

--获取第num个的Item
function getItemByNum(self,num)
	return self.itemContainer[num]
end

function getItem(self,num,name)
	assert(self.itemNum>=num,"invalid num")
	return self.itemContainer[num]:getChild(name)
end

function setEnabled(self,value)
	if value then
		self.enabled = true
	else
		self.enabled = false
	end
end

function setItemNum(self,num,item)
	assert(num>=0,"invalid num")
	if num>self.itemNum then
		for k=self.itemNum+1,num do
			self:addItem(item)
		end
	elseif num<self.itemNum then
		for k=num+1,self.itemNum do
			self:removeItem()
		end
	end
end

-- 获取item数量
function getItemCount(self)
	return #self.itemContainer
end


function setDirection(self,direct)
	assert(direct)
	self._direction = direct
	self:resetList()
end

function setBtwSpace(self,distance)
	assert(distance)
	self.UI_LIST_BTW_SPACE=distance
	self:resetList()
end

function setTopSpace(self,distance)
	assert(distance,"distance==>",distance)
	self.UI_LIST_TOP_DIS=distance
	self:resetList()
end

function setContentSize(self,size)
	self._ccnode:setContentSize(size)
	self.moveNode._ccnode:setContentSize(size)
	self:resetList()
end

function resetList(self)
	local width = self.UI_FOCUSLIST_TOP_DIS*2
	local height = self.UI_FOCUSLIST_TOP_DIS*2
	--for k=1,self.itemNum do
	local delta = 0
	for k=self.itemNum,1,-1 do
		local item = self.itemContainer[k]
		item.name = "item" .. (self.itemNum - k)
		item._ccnode:setName(item.name)
		local itemSize = item:getContentSize()
		self.itemSize = itemSize
		local posX,posY = item:getPosition()
		if self._direction == UI_FOCUSLIST_VERTICAL then
			delta = delta + self.UI_FOCUSLIST_BTW_SPACE
			posY = delta
			delta = delta + itemSize.height*self.UI_FOCUSLIST_ITEM_OVERLAP
			--posY = self.UI_LIST_TOP_DIS + (self.itemNum-(k-1)-1) * (itemSize.height+self.UI_LIST_BTW_SPACE)
			if k == 1 then 
				height = height + itemSize.height + self.UI_FOCUSLIST_BTW_SPACE
			else
				height = height + itemSize.height*self.UI_FOCUSLIST_ITEM_OVERLAP_DEFAULT + self.UI_FOCUSLIST_BTW_SPACE
			end
		else
			posX = self.UI_FOCUSLIST_TOP_DIS + (k-1) * (itemSize.width*self.UI_FOCUSLIST_ITEM_OVERLAP+self.UI_FOCUSLIST_BTW_SPACE)
			if k == 1 then
				width = width + itemSize.width + self.UI_FOCUSLIST_BTW_SPACE
			else
				width = width + itemSize.width*self.UI_FOCUSLIST_ITEM_OVERLAP_DEFAULT + self.UI_FOCUSLIST_BTW_SPACE
			end
		end
		item:setPosition(posX,posY)
	end
	local moveNodeSize = self.moveNode:getContentSize()
	local moveNodeX = 0
	local moveNodeY = 0
	if self._direction == UI_FOCUSLIST_VERTICAL then
		width = moveNodeSize.width
		moveNodeY = self:getContentSize().height - height
		if self.itemNum > 0 then 
			height = height - self.UI_FOCUSLIST_BTW_SPACE 
		end
		if height > self:getContentSize().height then
			self.showNotAll = true
		else
			self.showNotAll = false
		end
	else
		height = self:getContentSize().height
		if self.itemNum > 0 then 
			width = width - self.UI_FOCUSLIST_BTW_SPACE 
		end
		if width > self:getContentSize().width then
			self.showNotAll = true
		else
			self.showNotAll = false
		end
	end
	self.moveNode:setContentSize(cc.size(width,height))
	self.moveNode:setPosition(moveNodeX,moveNodeY)
end

function getItemsPos(self)
	return self.moveNode:getPosition()
end

function getItemsPosX(self)
	return self.moveNode:getPositionX()
end

function getItemsPosY(self)
	return self.moveNode:getPositionY()
end


function setItemsPos(self,x,y)
	local width = self:getContentSize().width
	local posx = self.moveNode:getPositionX() 
	if posx < width-30 and posx > -1*self.moveNode:getContentSize().width+30 then
		self.moveNode:setPosition(x,y)
	end
	
end

function touch(self,event)
	if self.enabled then
		self:onTouchEvent(event)
	end
	self:dispatchEvent(Event.TouchEvent,event)
	if event.etype == Event.Touch_out then
		self.moveEvent = nil
	end
	if event.etype == Event.Touch_ended then
		if self.moveEvent == nil then
			return Control.touch(self,event)
		else
			self.moveEvent = nil
			local eventOut = event
			eventOut.etype = Event.Touch_out
			Control.touch(self,eventOut)
			return self.touchParent
		end
	else
		return Control.touch(self,event)
	end
end

function onTouchEvent(self, event)
	if event.etype == Event.Touch_began then
		self:touchBeganFuc(event)
	elseif event.etype == Event.Touch_moved then
		self:touchMovedFuc(event)
	elseif event.etype == Event.Touch_ended then
		self:touchEndedFuc(event)
	elseif event.etype == Event.Touch_over then
	elseif event.etype == Event.Touch_out then
		self:touchEndedFuc(event)
	end
end

function touchBeganFuc(self,event)
	self.preX,self.preY = self:getItemsPos()
	self.prePos = event.p
	self.moveNode:stopAllActions()
end

function touchMovedFuc(self,event)
	self.move = true
	if self.prePos == nil or self.preX == nil or self.preY == nil then
		touchBeganFuc(self,event)
	end
	--是否为手指move事件
	if self.moveEvent == nil then
		if math.abs(event.p.x-self.prePos.x)>self.UI_FOCUSLIST_MOVE_DISTANCE or
			math.abs(event.p.y-self.prePos.y)>self.UI_FOCUSLIST_MOVE_DISTANCE then
			self.moveEvent = true
		end
	end
	--存储后几帧的位置
	if #self.lastPos < self.UI_FOCUSLIST_KEEPFRAME_TIMES then
		table.insert(self.lastPos,event.p)
	else
		table.remove(self.lastPos,1)
		table.insert(self.lastPos,event.p)
	end
	self:followMove(event)
end

function followMove(self,event)
	if self.prePos then
		if self._direction == UI_FOCUSLIST_VERTICAL then
			if self.buffer == false then
				local posO = self:getContentSize().height-self.moveNode:getContentSize().height-self.UI_FOCUSLIST_BTW_SPACE
				if self:getItemsPosY()<posO or self:getItemsPosY()>0 then
					self.buffer = true
					self.preX,self.preY = self:getItemsPos()
					self.prePos = event.p
				end
			end
			if self.buffer then
				self:setItemsPos(self.preX,self.preY+(event.p.y-self.prePos.y)/self.UI_FOCUSLIST_BUFFER_FACTOR)
			else
				self:setItemsPos(self.preX,self.preY+event.p.y-self.prePos.y)
			end
		elseif self._direction == UI_FOCUSLIST_HORIZONTAL then
			if self.buffer == false then
				local posO = self:getContentSize().width-self.moveNode:getContentSize().width
				if self:getItemsPosX()>0 or self:getItemsPosX()<posO then
					self.buffer = true
					self.preX,self.preY = self:getItemsPos()
					self.prePos = event.p
				end
			end
			if self.buffer then
				self:setItemsPos(self.preX+(event.p.x-self.prePos.x)/self.UI_FOCUSLIST_BUFFER_FACTOR,self.preY)
			else
				self:setItemsPos(self.preX+event.p.x-self.prePos.x,self.preY)
			end
		end
	end
end

function touchEndedFuc(self,event)
	self.preX = nil
	self.preY = nil
	self.buffer = false
	if self.move == nil then
		return
	end
	self:endedActionFuc(event)
	self.prePos = nil
	self.move = nil
	self.lastPos = {}
end

function endedActionFuc(self,event)
	self.ended = true
	if self._direction == UI_LIST_VERTICAL then
		local posO = self:getContentSize().height-self.moveNode:getContentSize().height-self.UI_FOCUSLIST_BTW_SPACE
		if self:getItemsPosY()<posO then
			-- local action = cc.MoveTo:create(0.2,cc.p(self:getItemsPosX(),posO))
			-- self.moveNode:runAction(action)
		else
			if self.showNotAll then
				if self:getItemsPosY()>0 then
					--list过高还原
					-- local action = cc.MoveTo:create(0.2,cc.p(self:getItemsPosX(),0))
					-- self.moveNode:runAction(action)
				else
					--快速移动
					if math.abs(event.p.y-self.prePos.y)>self.UI_FOCUSLIST_MOVE_DISTANCE
						and math.abs(self.lastPos[1].y-event.p.y)>self.UI_FOCUSLIST_DISTANCE_LEVEL then
						local dis = (event.p.y-self.lastPos[1].y)*self.UI_FOCUSLIST_DISTANCE_FACTOR
						if self:getItemsPosY()+dis<posO then
							--Action缓动buffer
							local factor = (posO-self:getItemsPosY())/dis
							local acTime = 0.8*factor
							local action01 = cc.MoveTo:create(acTime,cc.p(self:getItemsPosX(),
							posO-self.UI_FOCUSLIST_ACTION_BUFFER*factor))
							local sineOut = cc.EaseSineOut:create(action01)
							local action02 = cc.MoveTo:create(0.2,cc.p(self:getItemsPosX(),posO))
							self.moveNode:runAction(cc.Sequence:create({sineOut, action02}))
						elseif self:getItemsPosY()+dis>0 then
							local factor = (0-self:getItemsPosY())/dis
							local acTime = 0.8*factor
							local action01 = cc.MoveTo:create(acTime,cc.p(self:getItemsPosX(),
							0+self.UI_FOCUSLIST_ACTION_BUFFER*factor))
							local sineOut = cc.EaseSineOut:create(action01)
							local action02 = cc.MoveTo:create(0.2,cc.p(self:getItemsPosX(),0))
							self.moveNode:runAction(cc.Sequence:create({sineOut, action02}))
						else
							local action = cc.MoveBy:create(0.8,cc.p(self:getItemsPosX(),dis))
							local sineOut = cc.EaseSineOut:create(action)
							self.moveNode:runAction(sineOut)
						end
					end
				end
			else
				if self:getItemsPosY()>posO then
					--list过高还原
					-- local action = cc.MoveTo:create(0.2,cc.p(self:getItemsPosX(),posO))
					-- self.moveNode:runAction(action)
				end
			end
		end
	elseif self._direction == UI_FOCUSLIST_HORIZONTAL then
		-- if self:getItemsPosX()>self:getContentSize().width/2-self.itemSize.width/2 then
			-- local action = cc.MoveTo:create(0.2,cc.p(0,self:getItemsPosY()))
			-- self.moveNode:runAction(action)
			-- self.moveNode:stopAllActions()
		-- else
			-- if self.showNotAll then
				-- local posO = self:getContentSize().width-self.moveNode:getContentSize().width
				-- if self:getItemsPosX()<posO then
					--list过高还原
					-- local action = cc.MoveTo:create(0.2,cc.p(posO,self:getItemsPosY()))
					-- self.moveNode:runAction(action)
				-- else
					--快速移动
					-- if math.abs(event.p.x-self.prePos.x)>self.UI_FOCUSLIST_MOVE_DISTANCE
					-- 	and math.abs(self.lastPos[1].x-event.p.x)>self.UI_FOCUSLIST_DISTANCE_LEVEL then
						local width = self:getContentSize().width
						-- local dis = math.max(math.min((event.p.x-self.lastPos[1].x)*self.UI_FOCUSLIST_DISTANCE_FACTOR,width/8),-1*width/8)
						local dis = math.min((event.p.x-self.lastPos[1].x)*self.UI_FOCUSLIST_DISTANCE_FACTOR,width/16)
						-- if self:getItemsPosX()+dis>0 then
						-- 	--Action缓动buffer
						-- 	local factor = (0-self:getItemsPosX())/dis
						-- 	local acTime = 0.8*factor
						-- 	local action01 = cc.MoveTo:create(acTime,cc.p(0+self.UI_FOCUSLIST_ACTION_BUFFER*factor,
						-- 	self:getItemsPosY()))
						-- 	local sineOut = cc.EaseSineOut:create(action01)
						-- 	local action02 = cc.MoveTo:create(0.2,cc.p(0,self:getItemsPosY()))
						-- 	self.moveNode:runAction(cc.Sequence:create({sineOut, action02}))
						-- elseif self:getItemsPosX()+dis<posO then
						-- 	local factor = (posO-self:getItemsPosX())/dis
						-- 	local acTime = 0.8*factor
						-- 	local action01 = cc.MoveTo:create(acTime,cc.p(posO-self.UI_FOCUSLIST_ACTION_BUFFER*factor,
						-- 	self:getItemsPosY()))
						-- 	local sineOut = cc.EaseSineOut:create(action01)
						-- 	local action02 = cc.MoveTo:create(0.2,cc.p(posO,self:getItemsPosY()))
						-- 	self.moveNode:runAction(cc.Sequence:create({sineOut, action02}))
						-- else
						local posx = self.moveNode:getPositionX() 
						if posx > width-30 or posx < -1*self.moveNode:getContentSize().width+30 then
							dis = 0
						end
							local action = cc.MoveBy:create(0.2,cc.p(dis,self:getItemsPosY()))
							local sineOut = cc.EaseSineOut:create(action)
							self.moveNode:runAction(sineOut)
						-- end
					-- end
				-- end
			-- else
			-- 	if self:getItemsPosX()<0 then
					--list过高还原
					-- local action = cc.MoveTo:create(0.2,cc.p(0,self:getItemsPosY()))
					-- self.moveNode:runAction(action)
			-- 	end
			-- end
		-- end

	end
end

function deepCopy(ori_tab)
	if (type(ori_tab) ~= "table") then
		return nil;
	end
	local new_tab = {};
	for i,v in pairs(ori_tab) do
		local vtyp = type(v);
		if (vtyp == "table") then
			new_tab[i] = deepCopy(v);
		elseif (vtyp == "thread") then
			new_tab[i] = v;
		elseif (vtyp == "userdata") then
			new_tab[i] = v;
		else
			new_tab[i] = v;
		end
	end
	return new_tab;
end

function clear(self)
	Control.clear(self)
	if self.indentTimer then
		self:delTimer(self.indentTimer)
		self.indentTimer = nil
	end
end

