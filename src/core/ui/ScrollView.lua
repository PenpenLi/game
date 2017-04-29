--[[**************************************************************************** 
用法：
UI_ScrollView_DEFAULT_SKIN = {
	name="myScrollView",type="ScrollView",x=0,y=0,width=553,height=364,
	children=
		{
			{name="bg",type="Image",x=0,y=0,width=553,height=364,
			normal={img="listtest.bg",x=0,y=0,width=553,height=364},},
			{name="content",type="Container",x=116,y=132,width=319,height=112,
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
5、function showItem(self,num)，快速移动到第num个item
6、function setDirection(self,direct),设置方向（水平（0）或垂直（1））
7、function setBtwSpace(self,distance)，设置item的间距
8、function setTopSpace(self,distance),设置顶部（左部）间距
9、function removeItem(self,num),移除item，参数代表移除第几个，不带参数则默认移除最后一个
10、function getItemSkin(self),获取默认的item的skin文件
****************************************************************************]]
module("ScrollView",package.seeall)
setmetatable(ScrollView,{__index = Control})

UI_SCROLLVIEW_TYPE = "ScrollView"
UI_HORIZONTAL = 0
UI_VERTICAL = 1
UI_SCROLLVIEW_TOP_DIS_DEFAULT = 5
UI_SCROLLVIEW_GAP_DEFAULT = 5
UI_SCROLLVIEW_MOVE_DISTANCE_DEFAULT = 50
UI_SCROLLVIEW_KEEPFRAME_TIMES_DEFAULT = 4
UI_SCROLLVIEW_BOUNCE_RATE_DEFAULT = 0.5
function new(skin)
	local o = {
		name = skin.name,
		uiType = UI_SCROLLVIEW_TYPE,
		_skin = skin,
		_ccnode = nil,
		_direction = UI_VERTICAL,
		lastPos = {},
		UI_SCROLLVIEW_TOP_DIS = UI_SCROLLVIEW_TOP_DIS_DEFAULT,
		UI_SCROLLVIEW_GAP = UI_SCROLLVIEW_GAP_DEFAULT,
		UI_SCROLLVIEW_MOVE_DISTANCE = UI_SCROLLVIEW_MOVE_DISTANCE_DEFAULT,
		UI_SCROLLVIEW_KEEPFRAME_TIMES = UI_SCROLLVIEW_KEEPFRAME_TIMES_DEFAULT,
		UI_SCROLLVIEW_BOUNCE_RATE = UI_SCROLLVIEW_BOUNCE_RATE_DEFAULT,
	}
	setmetatable(o,{__index = ScrollView})
	o:init(skin)
	o:createContent(skin)
	return o
end

function init(self,skin)
	local node = MX.ScissorNode:create()
	node:setContentSize(cc.size(skin.width,skin.height))
	node:setPosition(cc.p(skin.x,skin.y))
	node:setAnchorPoint(cc.p(0,0))
	self._ccnode = node
	self.topSpace = 0
	local moveSkin = {
		name = "movenode",
		x = 0,
		y = 0,
		width = skin.width,
		height = skin.height,
		children = {},
	}
	local moveNode = Control.new(moveSkin)
	moveNode:setContentSize(cc.size(skin.width,skin.height))
	moveNode:setPosition(0,0)
	self:addChild(moveNode)
	self.moveNode = moveNode
	local function onTick(self,event)
		if self.lastPos then
			table.remove(self.lastPos,1)
		end
	end
	self.tickTimer = self:addTimer(onTick, 0.1, -1, self)
	self:openTimer()
end

function addElement(self,c)
	local cheight = c:getContentSize().height
	self:setContentSize(cc.size(self:getContentSize().width,self:getContentSize().height +cheight))
	for _,child in ipairs(self:getChildren()) do 
		child:setPositionY(child:getPositionY()+cheight)
	end
	c:setPositionY(0)
	self:addChild(c)
end	

function createContent(self,skin)
	for _,childSkin in ipairs(skin.children) do
		if childSkin.type == "Image" or childSkin.type == "Image9" then
			local node = _G[childSkin.type]
			self.bg = node.new(childSkin)
			self:addChild(self.bg)
		elseif childSkin.type == "Container" then
			self.childSkin = childSkin
			self.childSkinX = childSkin.x
			self.childSkinY = childSkin.y
		end
	end
end

function clearMoveNode(self)
	if self.moveNode then
		self:removeChild(self.moveNode,true)
	end
	self.moveNode = nil
end
function setDirection(self,direct)
	if direct == UI_HORIZONTAL or direct ==  UI_VERTICAL then
		self._direction = direct
	end
end

function setTopSpace(self, val)
	self.topSpace = val
end

function setMoveNode(self,node)
	self:clearMoveNode()
	if node then
		--外部提供scrollview的内容
		self.moveNode = node
		self:addChild(self.moveNode)

	else
		--使用skin中的内容作为scrollview的内容
		local moveSkin = {
			name = "movenode",
			x = 0,
			y = 0,
			width = skin.width,
			height = skin.height,
			children = {},
		}
		local childskinCopy = deepCopy(self.childSkin)
		childskinCopy.x = 0
		childskinCopy.y = 0
		moveSkin.children = {childskinCopy}
		self.moveNode = Control.new(childskinCopy)
		self:addChild(self.moveNode)
	end
	self:refreshMoveNode()
end

function refreshMoveNode(self)
	if self._direction == UI_VERTICAL then
		self.startY = self:getContentSize().height - self.moveNode:getContentSize().height - self.topSpace
		self.minY = self.startY
		self.maxY = self.startY <= self.topSpace and self.topSpace or self.startY
		self.moveNode:setPositionY(self.startY)
	else
		self.startX = 0
		self.minX = 0
		self.maxX = self.moveNode:getContentSize().width - self:getContentSize().width
		if self.maxX < 0 then self.maxX = 0 end
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
	self.preX,self.preY = self.moveNode:getPosition()
	self.prePos = event.p
	self.moveNode:stopAllActions()
	self.lastP = event.p
end
function touchMovedFuc(self,event)
	self.move = true
	if self.prePos == nil or self.preX == nil or self.preY == nil then
		touchBeganFuc(self,event)
	end
	--是否为手指move事件
	if self.moveEvent == nil then
		if math.abs(event.p.x-self.prePos.x)>self.UI_SCROLLVIEW_MOVE_DISTANCE or
			math.abs(event.p.y-self.prePos.y)>self.UI_SCROLLVIEW_MOVE_DISTANCE then
			self.moveEvent = true
		end
	end
	--存储后几帧的位置
	if #self.lastPos < self.UI_SCROLLVIEW_KEEPFRAME_TIMES then
		table.insert(self.lastPos,event.p)
	else
		table.remove(self.lastPos,1)
		table.insert(self.lastPos,event.p)
	end
	self:followMove(event)
	self.lastP = event.p
end

function followMove(self,event)
	if self.prePos then
		if self._direction == UI_VERTICAL then
			local curY = self.moveNode:getPositionY()
			local y = 0
			if curY >= self.maxY or curY <= self.minY then
				y = curY + (event.p.y - self.lastP.y)*self.UI_SCROLLVIEW_BOUNCE_RATE
				self.moveNode:setPosition(self.preX,y)
			else
				y = curY + (event.p.y - self.lastP.y)
				self.moveNode:setPosition(self.preX,y)
			end
		elseif self._direction == UI_HORIZONTAL then
			local curX = self.moveNode:getPositionX()
			local x = 0
			if curX >= self.maxX or curX <= self.minX then
				x = curX + (event.p.x - self.lastP.x)*self.UI_SCROLLVIEW_BOUNCE_RATE
				self.moveNode:setPositionX(x)
			else
				x = curX + (event.p.x - self.lastP.x)
				self.moveNode:setPositionX(x)
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
	if self._direction == UI_VERTICAL then
		local curY = self.moveNode:getPositionY()
		local moveAction
		if curY >= self.maxY then
			moveAction = cc.MoveBy:create(1,cc.p(0,self.maxY-curY))
			self.moveNode:runAction(cc.EaseExponentialOut:create(moveAction))
		elseif curY <= self.minY then
			moveAction = cc.MoveBy:create(1,cc.p(0,self.minY - curY))
			self.moveNode:runAction(cc.EaseExponentialOut:create(moveAction))
		else
			local delta = 0
			if self.lastPos and self.lastPos[1] then
				delta = ( event.p.y - self.lastPos[1].y)*10
			end
			if curY + delta > self.maxY then
				delta = self.maxY - curY
			elseif curY + delta < self.minY then
				delta = self.minY - curY
			end
			moveAction = cc.MoveBy:create(1,cc.p(0,delta))
			self.moveNode:runAction(cc.EaseExponentialOut:create(moveAction))
		end
		
	else
		local curX = self.moveNode:getPositionX()
		local moveAction
		if curX >= self.maxX then
			moveAction = cc.MoveBy:create(1,cc.p(self.maxX-curX,0))
			self.moveNode:runAction(cc.EaseExponentialOut:create(moveAction))
		elseif curX <= self.minX then
			moveAction = cc.MoveBy:create(1,cc.p(self.minX - curX,0))
			self.moveNode:runAction(cc.EaseExponentialOut:create(moveAction))
		else
			local delta = 0
			if self.lastPos and self.lastPos[1] then
				delta = ( event.p.x - self.lastPos[1].x)*10
			end
			if curX + delta > self.maxX then
				delta = self.maxX - curX
			elseif curX + delta < self.minX then
				delta = self.minX - curX
			end
			moveAction = cc.MoveBy:create(1,cc.p(delta,0))
			self.moveNode:runAction(cc.EaseExponentialOut:create(moveAction))
		end

	end

end

function clear(self)
	Control.clear(self)
	if self.tickTimer then
		self:delTimer(self.tickTimer)
		self.tickTimer = nil
	end
end


return ScrollView
