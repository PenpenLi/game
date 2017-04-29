module("Sprite", package.seeall)
setmetatable(Sprite, {__index = Control}) 
UI_SPRITE_TYPE = "Sprite"

isSprite = true

function new(name, fileUrl, rect)
	local spr = { 
		name = name,
		uiType = UI_SPRITE_TYPE,
	}
	setmetatable(spr, {__index = Sprite})
	if not fileUrl then
		spr._ccnode = cc.Sprite:create()
	else
		spr:addTexture(fileUrl)
		if not rect then
			spr._ccnode = cc.Sprite:create(fileUrl)
		else
			spr._ccnode = cc.Sprite:create(fileUrl, rect)
		end
	end
	if spr._ccnode == nil then
		return
	else
	    spr._ccnode:setAnchorPoint(cc.p(0,0))
		return spr
	end
end

function createWithSpriteFrame(name, frame)
	local spr = { 
		name = spriteFrameName,
		uiType = UI_SPRITE_TYPE,
		_ccnode = cc.Sprite:createWithSpriteFrame(frame),
	}
	setmetatable(spr, {__index = Sprite})
    spr._ccnode:setAnchorPoint(cc.p(0,0))
	return spr
end

function createWithSpriteFrameName(spriteFrameName,name)
	local spr = { 
		name = name or spriteFrameName,
		uiType = UI_SPRITE_TYPE,
		_ccnode = cc.Sprite:createWithSpriteFrameName(spriteFrameName .. ".png"),
	}
	setmetatable(spr, {__index = Sprite})
    spr._ccnode:setAnchorPoint(cc.p(0,0))
	return spr
end

local emptyFrame = emptyFrame or nil 
function getEmptyFrame(rect)
	if not emptyFrame then
		emptyFrame = cc.SpriteFrame:create("res/common/non.png", rect or  cc.rect(0,0,2,2))
		emptyFrame:retain()
	end
	return emptyFrame 
end

function setSpriteFrame(self, frame)
	assert(frame, "invalid frame. " .. self.name)
	self._ccnode:setSpriteFrame(frame)
end

function setSpriteFrameByName(self, frameName)
	local frame = cc.SpriteFrameCache:getInstance():spriteFrame(frameName .. ".png")
	self._ccnode:setSpriteFrame(frame)
end

function setTexture(self, texture)
	self._ccnode:setTexture(texture)
end

function getTexture(self)
	return self._ccnode:getTexture()
end

function setOpacity(self, value)
	self._ccnode:setOpacity(value)
end

function shader(self, shaderName, ...)
	Shader.setShader(self._ccnode, shaderName, ...)
end
