module("Image", package.seeall)
setmetatable(Image, {__index = DisplayObject}) 

UI_IMAGE_TYPE = "Image"
UI_IMAGE_DEFAULT_STATE = "normal"
UI_IMAGE_DEFAULT_SKIN = {
	name="myImage",type="Image",x=0,y=0,width=0,height=0,
	normal={source="diceng",x=0,y=0,width=0,height=0},
}

isImage = true

function new(skin)
	local img = { 
		name = skin.name,
		uiType = UI_IMAGE_TYPE, 
		imgSkin = nil,
		_state = UI_IMAGE_DEFAULT_STATE,
		_skin = skin, 
		_ccnode = nil,
	}
	setmetatable(img, {__index = Image})
	init(img, skin)
	return img
end

function init(self, skin)
	local imgSkin = self:getStateSkin(self._state) or self:getStateSkinByIndex(1) 
	local spr = cc.Sprite:createWithSpriteFrameName(imgSkin.source .. ".png")
	spr:setPosition(cc.p((skin.x or 0) + (imgSkin.x or 0), (skin.y or 0) + (imgSkin.y or 0)))
    spr:setAnchorPoint(cc.p(0,0))
	spr:setContentSize(cc.size(skin.width,skin.height))
	self.imgSkin = imgSkin
	self._ccnode = spr 
end

function getSkin(self)
	return self._skin
end

function getState(self)
	return self._state 
end

function shader(self, shaderName, ...)
	Shader.setShader(self._ccnode, shaderName, ...)
end

function show(self, imgSkin)
	local cur = self.imgSkin 
	local skin = imgSkin or cur 

	if imgSkin.source ~= "" then
		local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(skin.source.. ".png")
		self._ccnode:setSpriteFrame(frame)
	elseif imgSkin.states ~= "down" then
		local frame = Sprite.getEmptyFrame()
		self._ccnode:setSpriteFrame(frame)
	end

	local x, y = self:getPosition()
	self._ccnode:setPosition(cc.p(x - (cur.x or 0) + (skin.x or 0), y - (cur.y or 0) + (skin.y or 0)))    

	self.imgSkin = skin
	self:fx()
end

function getStateSkin(self,state)
    for k,v in ipairs(self._skin.states) do
        if v.state == state then
            return v
        end
    end
end

function getStateSkinByIndex(self,index)
    return self._skin.states[index]
end

function getStateSkinByName(self,name)
    for k,v in ipairs(self._skin) do
        if v.name == name then
            return v
        end
    end
end

--设置状态
--force：缺对应图片帧时是否也强设状态（down状态处理为当前图变大，其余用透明帧替代）
--isUseNormal:在某种状态没有皮肤时，是否使用normal状态皮肤(暂用于button灰化)
local stateTable = {normal = 1,down = 2,disable = 3,over = 4,}
function setState(self, state, force, isUseNormal)
	if self._state == state then
		return true 
	end

    local imgSkin = self:getStateSkin(state) or self:getStateSkinByIndex(stateTable[state] or -1)
	if force and not imgSkin then
		imgSkin = {name="non",states =state,source="",x=0,y=0,width=2,height=2}
	end
	if isUseNormal and not imgSkin then
		-- imgSkin = self:getStateSkin(UI_IMAGE_DEFAULT_STATE)
		imgSkin = self:getStateSkinByIndex(stateTable[UI_IMAGE_DEFAULT_STATE] or -1)
	end
	if not imgSkin then
		return false
	end

	self._state = state 
	self:show(imgSkin)
	return true
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

	if self.imgSkin.source == "" and self.imgSkin.states == "down" then
		self.fx_down = true 
		local dx, dy = self._skin.width * 0.025, self._skin.height * 0.025  
		local x, y = self:getPosition()
		self._ccnode:setPosition(x - dx, y - dy)            
		self:setScale(self:getScale() * 1.05)
	end
end




