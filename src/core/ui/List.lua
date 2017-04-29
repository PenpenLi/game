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
module("List",package.seeall)
setmetatable(List,{__index = Control})

UI_LIST_TYPE = "List"
UI_LIST_HORIZONTAL = 0
UI_LIST_VERTICAL = 1
UI_LIST_TOP_DIS_DEFAULT = 5
UI_LIST_BTW_SPACE_DEFAULT = 5
UI_LIST_MOVE_DISTANCE_DEFAULT = 50
UI_LIST_BUFFER_FACTOR_DEFAULT = 2.5
UI_LIST_KEEPFRAME_TIMES_DEFAULT = 4
UI_LIST_DISTANCE_LEVEL_DEFAULT = 5
UI_LIST_DISTANCE_FACTOR_DEFAULT = 10
UI_LIST_ACTION_BUFFER_DEFAULT = 100
UI_LIST_PAGE_LEFT = 1
UI_LIST_PAGE_RIGHT = -1

function new(skin)
	local lt = {
		name = skin.name,
		uiType = UI_LIST_TYPE,
		_skin = skin,
		_ccnode = nil,
		_direction = UI_LIST_VERTICAL,
		itemContainer = {},
		itemNum = 0,
		buffer = false,
		lastPos = {},
		UI_LIST_TOP_DIS = UI_LIST_TOP_DIS_DEFAULT,
		UI_LIST_BTW_SPACE = UI_LIST_BTW_SPACE_DEFAULT,
		UI_LIST_MOVE_DISTANCE = UI_LIST_MOVE_DISTANCE_DEFAULT,
		UI_LIST_BUFFER_FACTOR = UI_LIST_BUFFER_FACTOR_DEFAULT,
		UI_LIST_KEEPFRAME_TIMES = UI_LIST_KEEPFRAME_TIMES_DEFAULT,
		UI_LIST_DISTANCE_LEVEL = UI_LIST_DISTANCE_LEVEL_DEFAULT,
		UI_LIST_DISTANCE_FACTOR = UI_LIST_DISTANCE_FACTOR_DEFAULT,
		UI_LIST_ACTION_BUFFER = UI_LIST_ACTION_BUFFER_DEFAULT,
		itemNameNum = 0,
	}
	setmetatable(lt,{__index = List})
	lt:init(skin)
	lt:createContent(skin)
	return lt
end
function updateIndent(self,event)
	if self._direction == UI_LIST_HORIZONTAL then
		local movenode_offset = self.movenode:getPositionX()
		for i=1,self.itemNum do
			local item  = self.itemContainer[i]
			local localx =item:getPositionX()
			localx = localx +  movenode_offset;
			local o = math.abs(self._skin.width/2-item._skin.width/2 - localx)*self._indent/self._skin.width
			item:setPositionY(item._skin.y + o)
		end
	end
end
function setIndent(self,indent)
	self._indent = indent or 60
	-- self.indentTimer = self:addTimer(updateIndent, 0.05, -1, self)
	self:openTimer()
	self:addEventListener(Event.Frame, updateIndent)
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
	if self._direction == UI_LIST_VERTICAL then
		moveNode:setPositionY(skin.height-self.UI_LIST_TOP_DIS*2)
		moveNode:setContentSize(cc.size(skin.width,self.UI_LIST_TOP_DIS*2))
	else
		moveNode:setContentSize(cc.size(self.UI_LIST_TOP_DIS*2,skin.height))
	end
	self:addChild(moveNode)
	self.moveNode = moveNode
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
	item.name = "item" .. self.itemNum
	self.moveNode:addChild(item)

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
	local offset = 0
	if self._direction == UI_LIST_VERTICAL then
		local itemSize = item:getContentSize()
		offset = itemSize.height + self.UI_LIST_BTW_SPACE
	end

	--重排
	self:resetList("raw")
	local x = self.moveNode:getPositionX()
	local y = self.moveNode:getPositionY() - offset
	self.moveNode:setPosition(x,y)
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

--移除第num个item及其后面的item
function removeBackItem(self,num)
	if self.itemNum >=1 then
		if not num then num = self.itemNum end
		local offset = 0
		for k = self.itemNum,num,-1 do
			local item = self.itemContainer[k]
			assert(item,"invalid num")
			local itemSize = item:getContentSize()
			if self._direction == UI_LIST_VERTICAL then
				offset = offset + itemSize.height + self.UI_LIST_BTW_SPACE
			end
			self.moveNode:removeChild(self.itemContainer[k])
			table.remove(self.itemContainer,k)
		end
		local diffNum = self.itemNum - num
		self.itemNum = num - 1
		self:resetList("raw")
		local x = self.moveNode:getPositionX()
		local y = self.moveNode:getPositionY() + offset
		self.moveNode:setPosition(x,y)
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

--[[
--慎用
function setBottomSpace(self,distance)
	if distance then
		local skin = self:getSkin()
		if self._direction == UI_LIST_VERTICAL then
			self._ccnode:setContentSize(cc.size(skin.width,skin.height - distance))
			self._ccnode:setPosition(cc.p(skin.x,skin.y + distance))
		elseif self._direction == UI_LIST_HORIZONTAL then
			self._ccnode:setContentSize(cc.size(skin.width - distance,skin.height))
			self._ccnode:setPosition(cc.p(skin.x + distance,skin.y))
		end
	end
	self:resetList()
end
--]]

function setContentSize(self,size)
	self._ccnode:setContentSize(size)
	self.moveNode._ccnode:setContentSize(size)
	self:resetList()
end

function resetList(self,raw)
	local width = self.UI_LIST_TOP_DIS*2
	local height = self.UI_LIST_TOP_DIS*2
	--for k=1,self.itemNum do
	local delta = 0
	for k=self.itemNum,1,-1 do
		local item = self.itemContainer[k]
		item.name = "item" .. (self.itemNum - k)
		item._ccnode:setName(item.name)
		local itemSize = item:getContentSize()
		local posX,posY = item:getPosition()
		if self._direction == UI_LIST_VERTICAL then
			delta = delta + self.UI_LIST_BTW_SPACE
			posY = delta
			delta = delta + itemSize.height
			--posY = self.UI_LIST_TOP_DIS + (self.itemNum-(k-1)-1) * (itemSize.height+self.UI_LIST_BTW_SPACE)
			height = height + itemSize.height + self.UI_LIST_BTW_SPACE
		else
			posX = self.UI_LIST_TOP_DIS + (k-1) * (itemSize.width+self.UI_LIST_BTW_SPACE)
			width = width + itemSize.width + self.UI_LIST_BTW_SPACE
		end
		item:setPosition(posX,posY)
	end
	local moveNodeSize = self.moveNode:getContentSize()
	local moveNodeX = 0
	local moveNodeY = 0
	if self._direction == UI_LIST_VERTICAL then
		width = moveNodeSize.width
		moveNodeY = self:getContentSize().height - height
		if self.itemNum > 0 then 
			height = height - self.UI_LIST_BTW_SPACE 
		end
		if height > self:getContentSize().height then
			self.showNotAll = true
		else
			self.showNotAll = false
		end
	else
		height = self:getContentSize().height
		if self.itemNum > 0 then 
			width = width - self.UI_LIST_BTW_SPACE 
		end
		if width > self:getContentSize().width then
			self.showNotAll = true
		else
			self.showNotAll = false
		end
	end
	self.moveNode:setContentSize(cc.size(width,height))
	if not raw then
		self.moveNode:setPosition(moveNodeX,moveNodeY)
	end
end

function showBottom(self)
	if self.showNotAll then
		self.moveNode:setPositionY(0)
	end
end

function turnPage(self,direction,num)
	direction = direction or UI_LIST_PAGE_LEFT
	num = num or 1
	local item = self.itemContainer[1]
	local size = item:getContentSize()
	local posX = self:getItemsPosX()
	local posY = self:getItemsPosY()
	local showLength = math.abs(self.moveNode:getContentSize().width - self:getContentSize().width)
	local needReverse = false
	if not self.showNotAll then
		needReverse = true
	end
	if self._direction == UI_LIST_VERTICAL then
		posY = posY + direction * (size.height+self.UI_LIST_BTW_SPACE) * num
	else
		if direction == UI_LIST_PAGE_LEFT and posX == 0 then
			needReverse = true
		end
		if direction == UI_LIST_PAGE_RIGHT and math.abs(posX) >= showLength then
			needReverse = true
		end
		posX = posX + direction * (size.width+self.UI_LIST_BTW_SPACE) * num
		if posX >0 then 
			posX = 0 
		elseif math.abs(posX) > showLength then
			posX = -showLength
		end
	end
	if needReverse then
		--回弹
		local offset = self.UI_LIST_DISTANCE_FACTOR_DEFAULT
		if direction == UI_LIST_PAGE_RIGHT then
			offset = 1-offset
		end
		local action = cc.MoveBy:create(0.1,cc.p(offset,0))
		local back = cc.EaseSineOut:create(action):reverse()
		self.moveNode:runAction(cc.Sequence:create({action, back}))
	else
		local action = cc.MoveTo:create(0.2,cc.p(posX,posY))
		local sineOut = cc.EaseSineOut:create(action)
		self.moveNode:runAction(sineOut)
	end
end

--@todo
--指定item挪到顶部
function showTopItem(self,num,noAnimate)
	if num<=0 or num>self.itemNum then
		return
	end
	if not self.showNotAll then
		return
	end
	self.moveNode:stopAllActions()
	local a,b,c,d = 0,0,0,0
	if self._direction == UI_LIST_VERTICAL then
		if num > 1 then
		local topItem = self.itemContainer[1]
		local item = self.itemContainer[num]
		local offset = topItem:getPositionY() - item:getPositionY() + self.UI_LIST_BTW_SPACE
		self.moveNode:setPositionY(self.moveNode:getPositionY() + offset)
		end
		--[[
		a = self:getContentSize().height/2-self.UI_LIST_TOP_DIS
		if a>0 then
			b = a-self.childSkin.height/2
			if b>0 then
				c = math.floor(b/(self.UI_LIST_BTW_SPACE+self.childSkin.height))
				d = c+1
			end
		end
		if num<=d then
			local posY = self:getContentSize().height-self.moveNode:getContentSize().height
			if noAnimate then
				self.moveNode:setPositionY(posY)
			else
				local action = cc.MoveTo:create(0.2,cc.p(self:getItemsPosX(),posY))
				local sineOut = cc.EaseSineOut:create(action)
				self.moveNode:runAction(sineOut)
			end
		elseif num>=self.itemNum-(d-1) then
			if noAnimate then
				self.moveNode:setPositionY(0)
			else
				local action = cc.MoveTo:create(0.3,cc.p(self:getItemsPosX(),0))
				local sineOut = cc.EaseSineOut:create(action)
				self.moveNode:runAction(sineOut)
			end
		else
			local posY = self:getContentSize().height/2-((self.itemNum-num)*(self.childSkin.height+self.UI_LIST_BTW_SPACE)
			+self.childSkin.height/2+self.UI_LIST_TOP_DIS)
			if noAnimate then
				self.moveNode:setPositionY(posY)
			else
				local action = cc.MoveTo:create(0.3,cc.p(self:getItemsPosX(),posY))
				local sineOut = cc.EaseSineOut:create(action)
				self.moveNode:runAction(sineOut)
			end
		end
		]]
	elseif self._direction == UI_LIST_HORIZONTAL then
		a = self:getContentSize().width/2-self.UI_LIST_TOP_DIS
		if a>0 then
			b = a-self.childSkin.width/2
			if b>0 then
				c = math.floor(b/(self.UI_LIST_BTW_SPACE+self.childSkin.width))
				d = c+1
			end
		end
		if num<=d then
			local action = cc.MoveTo:create(0.2,cc.p(0,self:getItemsPosY()))
			local sineOut = cc.EaseSineOut:create(action)
			self.moveNode:runAction(sineOut)
		elseif num>=self.itemNum-(d-1) then
			local posX = self:getContentSize().width-self.moveNode:getContentSize().width
			local action = cc.MoveTo:create(0.3,cc.p(posX,self:getItemsPosY()))
			local sineOut = cc.EaseSineOut:create(action)
			self.moveNode:runAction(sineOut)
		else
			local posX = self:getContentSize().width/2-((num-1)*(self.childSkin.width+self.UI_LIST_BTW_SPACE)
			+self.childSkin.width/2+self.UI_LIST_TOP_DIS)
			local action = cc.MoveTo:create(0.3,cc.p(posX,self:getItemsPosY()))
			local sineOut = cc.EaseSineOut:create(action)
			self.moveNode:runAction(sineOut)
		end
	end
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
	self.moveNode:setPosition(x,y)
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
	print("bt onTouchEvent ".. event.etype)
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
		if math.abs(event.p.x-self.prePos.x)>self.UI_LIST_MOVE_DISTANCE or
			math.abs(event.p.y-self.prePos.y)>self.UI_LIST_MOVE_DISTANCE then
			self.moveEvent = true
		end
	end
	--存储后几帧的位置
	if #self.lastPos < self.UI_LIST_KEEPFRAME_TIMES then
		table.insert(self.lastPos,event.p)
	else
		table.remove(self.lastPos,1)
		table.insert(self.lastPos,event.p)
	end
	self:followMove(event)
end

function followMove(self,event)
	if self.prePos then
		if self._direction == UI_LIST_VERTICAL then
			if self.buffer == false then
				local posO = self:getContentSize().height-self.moveNode:getContentSize().height-self.UI_LIST_BTW_SPACE
				if self:getItemsPosY()<posO or self:getItemsPosY()>0 then
					self.buffer = true
					self.preX,self.preY = self:getItemsPos()
					self.prePos = event.p
				end
			end
			if self.buffer then
				self:setItemsPos(self.preX,self.preY+(event.p.y-self.prePos.y)/self.UI_LIST_BUFFER_FACTOR)
			else
				self:setItemsPos(self.preX,self.preY+event.p.y-self.prePos.y)
			end
		elseif self._direction == UI_LIST_HORIZONTAL then
			if self.buffer == false then
				local posO = self:getContentSize().width-self.moveNode:getContentSize().width
				if self:getItemsPosX()>0 or self:getItemsPosX()<posO then
					self.buffer = true
					self.preX,self.preY = self:getItemsPos()
					self.prePos = event.p
				end
			end
			if self.buffer then
				self:setItemsPos(self.preX+(event.p.x-self.prePos.x)/self.UI_LIST_BUFFER_FACTOR,self.preY)
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
	if self._direction == UI_LIST_VERTICAL then
		local posO = self:getContentSize().height-self.moveNode:getContentSize().height-self.UI_LIST_BTW_SPACE
		if self:getItemsPosY()<posO then
			local action = cc.MoveTo:create(0.2,cc.p(self:getItemsPosX(),posO))
			self.moveNode:runAction(action)
		else
			if self.showNotAll then
				if self:getItemsPosY()>0 then
					--list过高还原
					local action = cc.MoveTo:create(0.2,cc.p(self:getItemsPosX(),0))
					self.moveNode:runAction(action)
				else
					--快速移动
					if math.abs(event.p.y-self.prePos.y)>self.UI_LIST_MOVE_DISTANCE
						and math.abs(self.lastPos[1].y-event.p.y)>self.UI_LIST_DISTANCE_LEVEL then
						local dis = (event.p.y-self.lastPos[1].y)*self.UI_LIST_DISTANCE_FACTOR
						if self:getItemsPosY()+dis<posO then
							--Action缓动buffer
							local factor = (posO-self:getItemsPosY())/dis
							local acTime = 0.8*factor
							local action01 = cc.MoveTo:create(acTime,cc.p(self:getItemsPosX(),
							posO-self.UI_LIST_ACTION_BUFFER*factor))
							local sineOut = cc.EaseSineOut:create(action01)
							local action02 = cc.MoveTo:create(0.2,cc.p(self:getItemsPosX(),posO))
							self.moveNode:runAction(cc.Sequence:create({sineOut, action02}))
						elseif self:getItemsPosY()+dis>0 then
							local factor = (0-self:getItemsPosY())/dis
							local acTime = 0.8*factor
							local action01 = cc.MoveTo:create(acTime,cc.p(self:getItemsPosX(),
							0+self.UI_LIST_ACTION_BUFFER*factor))
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
					local action = cc.MoveTo:create(0.2,cc.p(self:getItemsPosX(),posO))
					self.moveNode:runAction(action)
				end
			end
		end
	elseif self._direction == UI_LIST_HORIZONTAL then
		if self:getItemsPosX()>0 then
			local action = cc.MoveTo:create(0.2,cc.p(0,self:getItemsPosY()))
			self.moveNode:runAction(action)
		else
			if self.showNotAll then
				local posO = self:getContentSize().width-self.moveNode:getContentSize().width
				if self:getItemsPosX()<posO then
					--list过高还原
					local action = cc.MoveTo:create(0.2,cc.p(posO,self:getItemsPosY()))
					self.moveNode:runAction(action)
				else
					--快速移动
					if math.abs(event.p.x-self.prePos.x)>self.UI_LIST_MOVE_DISTANCE
						and math.abs(self.lastPos[1].x-event.p.x)>self.UI_LIST_DISTANCE_LEVEL then
						local dis = (event.p.x-self.lastPos[1].x)*self.UI_LIST_DISTANCE_FACTOR
						if self:getItemsPosX()+dis>0 then
							--Action缓动buffer
							local factor = (0-self:getItemsPosX())/dis
							local acTime = 0.8*factor
							local action01 = cc.MoveTo:create(acTime,cc.p(0+self.UI_LIST_ACTION_BUFFER*factor,
							self:getItemsPosY()))
							local sineOut = cc.EaseSineOut:create(action01)
							local action02 = cc.MoveTo:create(0.2,cc.p(0,self:getItemsPosY()))
							self.moveNode:runAction(cc.Sequence:create({sineOut, action02}))
						elseif self:getItemsPosX()+dis<posO then
							local factor = (posO-self:getItemsPosX())/dis
							local acTime = 0.8*factor
							local action01 = cc.MoveTo:create(acTime,cc.p(posO-self.UI_LIST_ACTION_BUFFER*factor,
							self:getItemsPosY()))
							local sineOut = cc.EaseSineOut:create(action01)
							local action02 = cc.MoveTo:create(0.2,cc.p(posO,self:getItemsPosY()))
							self.moveNode:runAction(cc.Sequence:create({sineOut, action02}))
						else
							local action = cc.MoveBy:create(0.8,cc.p(dis,self:getItemsPosY()))
							local sineOut = cc.EaseSineOut:create(action)
							self.moveNode:runAction(sineOut)
						end
					end
				end
			else
				if self:getItemsPosX()<0 then
					--list过高还原
					local action = cc.MoveTo:create(0.2,cc.p(0,self:getItemsPosY()))
					self.moveNode:runAction(action)
				end
			end
		end

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

