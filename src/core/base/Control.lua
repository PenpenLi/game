module("Control", package.seeall)
setmetatable(Control, {__index = DisplayObject}) 
UI_CONTROL_TYPE = "Control"
UI_CONTROL_DEFAULT_SKIN = {
	name="myCtrl",type="Container",x=0,y=0,width=768,height=1024,
	children={}
}

--Container
touchEnabled = true
touchChildren = true
touchParent = true
enabled = true
isControl = true
alive = true

function new(skin,res)
	local ctrl = { 
		name = skin.name,
		uiType = UI_CONTROL_TYPE,
		_lastTouch = nil,
		_resCache = nil,
		_skin = skin, 
		_ccnode = nil,
	}
	setmetatable(ctrl, {__index = Control})
	if res then
	    for _,url in ipairs(res) do
	        ctrl:addSpriteFrames(url)
        end
    end
	init(ctrl, skin)
	ctrl:createChildren(skin)
	return ctrl
end

function init(self, skin)
	local node = cc.Node:create()
	node:setPosition(skin.x, skin.y)            
    node:setAnchorPoint(0, 0)
	node:setContentSize(cc.size(skin.width,skin.height))
	self._ccnode = node 
end

function getSkin(self)
	return self._skin
end

function addChild(self, child, zOder)
	assert(self._ccnode,"self._ccnode is nil")
	assert(child._ccnode,"child._ccnode is nil")
	assert(child._parent == nil,"child._parent not nil")
	if not self._children then
		self._children = {}
	end
	if not self:getChild(child.name) then
		table.insert(self._children, child)
        if  zOder then
		    self._ccnode:addChild(child._ccnode,zOder)
        else
            self._ccnode:addChild(child._ccnode)
        end
		child._parent = self
		self[child.name] = child
		child:addStage()
		return child
	else
		child:clear()
		assert(false, "child already exists !! --> " .. child.name) 
	end
end

function removeChild(self, child, clear)
	assert(self._ccnode,"self._ccnode is nil")
	assert(child._ccnode,"child._ccnode is nil")
	if self._children then
		for k, v in ipairs(self._children) do
			if v == child then
				table.remove(self._children, k)
				if clear == nil then clear = true end
				self._ccnode:removeChild(child._ccnode, clear)
				child._parent = nil
				if clear then
					v:clear()
				end
				return v
			end
		end
	end
end

function removeChildByName(self, name, clear)
	assert(self._ccnode)
	if self._children then
		for k, v in ipairs(self._children) do
			if v.name == name then
				table.remove(self._children, k)
				if clear == nil then clear = true end
				self._ccnode:removeChild(v._ccnode, clear)
				v:clear()
				self[name] = nil
				return v
			end
		end
	end
end

function removeAllChildren(self)
	self._ccnode:removeAllChildren(true)
	if self._children then
		for k,v in ipairs(self._children) do
			v:clear()
		end
	end
	self._children = nil
end

function getChild(self, name)
	if self._children then
		for k,v in ipairs(self._children) do
			if v.name == name then
				return v
			end
		end
	end
end

function getChildByType(self, uiType)
	if self._children then
		for _, v in ipairs(self._children) do
			if v.uiType == uiType then
				return v
			end
		end
	end
end

function getChildren(self)
	return self._children
end

function getChildrenCount(self)
	return #self._children
end

function getChildrenByType(self, uiType)
	local ret = {}
	if self._children then
		for _, v in ipairs(self._children) do
			if v.uiType == uiType then
				table.insert(ret, v)
			end
		end
	end
	return ret
end

function createChildren(self, skin)
	assert(self._children == nil) 
	self._children = {}
	for _, childSkin in ipairs(skin.children) do
		local ctor = _G[childSkin.type] or Control
		local node = ctor.new(childSkin)
		self[node.name] = node
		self:addChild(node)
	end
end

function appendChildren(self, skin)
	assert(self._children ~= nil) 
	for _, childSkin in ipairs(skin.children) do
		local ctor = _G[childSkin.type] or Control
		local node = ctor.new(childSkin)
		self[node.name] = node
		self:addChild(node)
	end
end

function shader(self, shaderName, ...)
	if self._children then
		for k, v in ipairs(self._children) do
			v:shader(shaderName, ...)
		end
	end
end

function touch(self, event)
	-- print("touch name="..self.name.." "..tostring(self.enabled).." "..tostring(self.touchEnabled).." "..tostring(self:isVisible()))
	local touchParent = true 
	if self.enabled and self.touchEnabled and self:isVisible() then
		if self.touchChildren then
			local child = getTouchedChild(self, event.p)

			if self._lastTouch ~= child then
				if child then
					local ev = {etype=Event.Touch_over, x=event.x, y=event.y, p=event.p}
					child:touch(ev)
				end
				if self._lastTouch and self._lastTouch._parent == self then
					local ev = {etype=Event.Touch_out, x=event.x, y=event.y, p=event.p}
					self._lastTouch:touch(ev)
				end
				self._lastTouch = child
			end

			if child then
				touchParent = child:touch(event)
			end
		end
		if touchParent then
			self:dispatchEvent(Event.TouchEvent, event)
		end
	end
	return touchParent and self.touchParent 
end

function getTouchedChild(self, worldPoint)
	if self._children and next(self._children) then 
		local touchLocation = self._ccnode:convertToNodeSpace(worldPoint) 
		--print("x,y=".. touchLocation.x ..",".. touchLocation.y)
		for i = #self._children, 1, -1 do
			local child = self._children[i]
			if child.touchEnabled and child:isVisible() then
				local bound = child:getBoundingBox()
				if cc.rectContainsPoint(bound, touchLocation) then
					print("child:hit:".. child.name)
					return child
				end
			end
		end
	end
end


local gTextureCache = gTextureCache or {} 
function addTexture(self, path)
	if not self._imgCache then
		self._imgCache = {}
	end
	if not self._imgCache[path] then
		self._imgCache[path] = true 
		if not gTextureCache[path] then
			gTextureCache[path] = {}
		end
		trace("----add:" .. self.name .. "  img:".. path)
		gTextureCache[path][self] = true
	end
end

local gCache = gCache or {} 
function addSpriteFrames(self, plist, png)
	if not png then
		png = string.sub(plist, 1,#plist - 5) .. "png"
	end
	if not self._resCache then
		self._resCache = {}
	end
	if not self._resCache[plist] then
		self._resCache[plist] = png
		if not gCache[plist] then
			gCache[plist] = {}
			gCache[plist][self] = true
			trace("----add:" .. self.name .. "  frames:".. plist)
			cc.SpriteFrameCache:getInstance():addSpriteFrames(plist,png)
		else
			gCache[plist][self] = true
		end
	end
end

gArmatureCache = gArmatureCache or {} 
function addArmatureFrame(self,exportJson,plistCnt)
	if not self._armatureCache then
		self._armatureCache = {}
	end
	if not self._armatureCache[exportJson] then
		self._armatureCache[exportJson] = true
		if not gArmatureCache[exportJson] then
			gArmatureCache[exportJson] = {}
			gArmatureCache[exportJson][self] = true

			--[[".ExportJson" 猥琐解决动画资源释放不干净的问题
			local plist = string.sub(exportJson, 1,#exportJson - 11)
			plistCnt = plistCnt or 4
			for i=1,plistCnt do
				--self:addSpriteFrames(plist .. (i-1) .. ".plist")
			end
			]]

			trace("----add:" .. self.name .. "  armature:".. exportJson)
			ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(exportJson)
		else
			gArmatureCache[exportJson][self] = true
		end
	end
end

function clear(self)
	if self._children then
		for k,v in ipairs(self._children) do
		    v:clear()
		end
	end
	
	DisplayObject.clear(self)

	if self._imgCache then
		for path, _ in pairs(self._imgCache) do
			gTextureCache[path][self] = nil 
			if not next(gTextureCache[path]) then
				trace("----clear:".. self.name .. "  img:" .. path)
				cc.Director:getInstance():getTextureCache():removeTextureForKey(path)
				gTextureCache[path] = nil
			end
		end
	end

	if self._resCache then
		for plist, png in pairs(self._resCache) do
			gCache[plist][self] = nil 
			if not next(gCache[plist]) then
				trace("----clear:".. self.name .. "  frames:" .. plist)
				cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(plist) 
				cc.Director:getInstance():getTextureCache():removeTextureForKey(png)
				gCache[plist] = nil
			end
		end
		--cc.Director:getInstance():getTextureCache():removeUnusedTextures()
	end

	if self._armatureCache then
		for exportJson, _ in pairs(self._armatureCache) do
			gArmatureCache[exportJson][self] = nil 
			if not next(gArmatureCache[exportJson]) then
				trace("----clear:".. self.name .. "  armature:" .. exportJson)
				ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(exportJson)
				gArmatureCache[exportJson] = nil
			end
		end
		--cc.Director:getInstance():getTextureCache():removeUnusedTextures()
	end
end


