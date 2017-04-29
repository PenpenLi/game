module("Image9", package.seeall)
setmetatable(Image9, {__index = DisplayObject}) 

UI_IMAGE9_TYPE = "Image9"
UI_IMAGE9_DEFAULT_STATE = "normal"
UI_IMAGE9_DEFAULT_SKIN = {
	name="myImage",type="Image9",x=0,y=0,width=0,height=0,
	normal ={img="quxiaodi",x=0,y=0,width=76,height=26,top=8,right=8,bottom=8,left=8},
}

isImage9 = true
local midPixs = 3

function new(skin)
	local img = { 
		name = skin.name,
		uiType = UI_IMAGE9_TYPE, 
		imgSkin = nil,
		_state = UI_IMAGE9_DEFAULT_STATE,
		_skin = skin, 
		_ccnode = nil,
	}
	setmetatable(img, {__index = Image9})
	init(img, skin)
	return img
end

function init(self, skin)
	print(self._state)
	print(skin.name)

	local imgSkin = self:getStateSkin(self._state) or self:getStateSkinByIndex(1)
    local insetRect = cc.rect(imgSkin.left,imgSkin.bottom,imgSkin.midWidth or midPixs,imgSkin.midHeight or midPixs)
    local image = cc.Scale9Sprite:createWithSpriteFrameName(imgSkin.img .. ".png",insetRect)
	image:setPosition(cc.p(skin.x, skin.y))            
    image:setAnchorPoint(cc.p(0,0))
	image:setContentSize(cc.size(skin.width,skin.height))
	self.imgSkin = imgSkin
	self._ccnode = image
end

function getSkin(self)
	return self._skin
end

function shader(self, shaderName, ...)
	Shader.setShader(self._ccnode, shaderName, ...)
end

function getState(self)
	return self._state 
end

function getStateSkin(self,state)
    for k,v in ipairs(self._skin) do
        if v.status == state then
            return v
        end
    end
end

function getStateSkinByIndex(self,index)
    return self._skin[index]
end

function getStateSkinByName(self,name)
    for k,v in ipairs(self._skin) do
        if v.name == name then
            return v
        end
    end
end

local stateTable = {normal = 1,down = 2,disable = 3,over = 4,}
function setState(self, state, force, isUseNormal)
	if self._state == state then
		return true 
	end

    local imgSkin = self:getStateSkin(state) or self:getStateSkinByIndex(stateTable[state] or -1)
	if force and not imgSkin then
		imgSkin = {name="non",status=state,img="",x=0,y=0,width=2,height=2}
	end
	if isUseNormal and not imgSkin then
		imgSkin = self:getStateSkin(UI_IMAGE_DEFAULT_STATE)
	end
	if not imgSkin then
		return false
	end

	self._state = state 
	self:show(imgSkin)
	return true
end

function show(self, imgSkin)
	local cur = self.imgSkin 
	local skin = imgSkin or cur 

	if imgSkin.img ~= "" then
		local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(imgSkin.img .. ".png")
    	local insetRect = cc.rect(imgSkin.left,imgSkin.bottom,imgSkin.midWidth or midPixs,imgSkin.midHeight or midPixs)
		self._ccnode:setSpriteFrame(frame)
		self._ccnode:setCapInsets(insetRect)
		self._ccnode:setContentSize(imgSkin.width,imgSkin.height)
	elseif imgSkin.status ~= "down" then
		local frame = Sprite.getEmptyFrame()
		self._ccnode:setSpriteFrame(frame)
	end

	local x, y = self:getPosition()
	self._ccnode:setPosition(cc.p(x - cur.x + skin.x, y - cur.y + skin.y))    

	self.imgSkin = skin
	self:fx()
end

--图片特效:
function fx(self)
	-- 选中（变大，变亮)
	if self.fx_down then
		local dx, dy = self._skin.width * 0.025, self._skin.height * 0.025  
		local x, y = self:getPosition()
		self._ccnode:setPosition(x + dx, y + dy)            
		self:setScale(self:getScale() / 1.05)
		self.fx_down = nil 
	end

	if self.imgSkin.img == "" and self.imgSkin.status == "down" then
		self.fx_down = true 
		local dx, dy = self._skin.width * 0.025, self._skin.height * 0.025  
		local x, y = self:getPosition()
		self._ccnode:setPosition(x - dx, y - dy)            
		self:setScale(self:getScale() * 1.05)
	end
end

