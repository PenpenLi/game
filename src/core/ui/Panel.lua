module("Panel", package.seeall)
setmetatable(Panel, {__index = Control})

UI_PANEL_TYPE = "Panel"

isPanel = true

function new(skin, plist, isMultiTouches)
	local panel = {
		name = skin.name,
		uiType = UI_PANEL_TYPE,
		_skin = skin,
		_ccnode = nil,
		multiTouches = {}, --多点数据
		multiCount = 0, 
        isMultiTouches = isMultiTouches and true or false,
	}
	setmetatable(panel, {__index = Panel})
	panel:init(skin, plist)
	panel:createChildren(skin)
	return panel
end

function init(self, skin, plist)
	local layer = cc.Layer:create()
	layer:setPosition(cc.p(skin.x, skin.y))            
	layer:setAnchorPoint(cc.p(0,0))
	if plist then
		self:addSpriteFramesWithFile(plist)
	end

	if self.isMultiTouches then
		local function onTouches(eventType,touches)
			--print("开始多点触摸1")
			local myTouches = {}
			local count = #touches/3
			local touch 
			for i = 1,#touches,3 do
				local x = touches[i]
				local y = touches[i+1]
				local id = touches[i+2]

				touch = self.multiTouches[id]
				if touch then
					touch.id = id
					touch.x = x 
					touch.y = y 
					touch.p = cc.p(x,y) 
				    touch.etype = eventType 
				else
					touch = {id = id, x = x, y = y, p = cc.p(x,y), etype = eventType}
					self.multiTouches[id] = touch
				end
				table.insert(myTouches, touch)
				if eventType == Event.Touch_ended or eventType == Event.cancelled then
					self.multiCount = self.multiCount - 1
				elseif eventType == Event.Touch_began then
					self.multiCount = self.multiCount + 1
				end
			end
			
			self:dispatchEvent(Event.MultiTouchEvent,
				{etype = eventType,touches = myTouches, touchesCount = count})
			for k, touch in ipairs(myTouches) do
				self:touch(touch)
			end

			return true
		end
		--print("面板注册多点触摸")
		layer:registerScriptTouchHandler(onTouches,true)   --多点触摸
	else
		local function onTouch(eventType, x, y)
			self:touch({etype = eventType, p = cc.p(x,y), x = x, y = y})
			return true
		end
		layer:registerScriptTouchHandler(onTouch)   --单点触摸
	end

	layer:setTouchEnabled(true)
	self._ccnode = layer
	layer:setContentSize(cc.size(skin.width,skin.height))
end



