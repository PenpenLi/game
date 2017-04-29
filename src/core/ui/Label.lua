module("Label", package.seeall)
setmetatable(Label, {__index = DisplayObject}) 

UI_LABEL_TYPE = "Label"
UI_LABEL_DEFAULT_STATE = "normal"
UI_LABEL_DEFAULT_SKIN = {
	name="myTxt",type="Label",x=0,y=0,width=24,height=12,
	normal={txt="test",font="SimSun",size=12,bold=false,italic=false,color={0,0,0}}
}

UI_DEFAULT_FONT = 'DFYuanW7-GBK.ttf'
--UI_DEFAULT_FONT = 'res/fonts/DFYuanW7-GBK.ttf'

Alignment = { 
	Left = 0, -- 左对齐 
	Center = 1, -- 水平居中
	Right = 2, -- 右对齐 
	Top = 0, -- 垂直顶对齐
	Middle = 1, --垂直居中
	Bottom = 2, --垂直底对齐
}

isLabel = true 
fontScale = 2

function new(skin)
	local label = { 
		name = skin.name,
		uiType = UI_LABEL_TYPE,
		_state = UI_LABEL_DEFAULT_STATE,
		_skin = skin, 
		_ccnode = nil,
	}
	setmetatable(label, {__index = Label})
	init(label, skin)
	return label 
end

function init(self, skin)
	local txtSkin = self:getStateSkin(self._state) or self:getStateSkinByIndex(1)
	-- local label = cc.LabelTTF:create(txtSkin.txt, txtSkin.font, txtSkin.size*fontScale, cc.size(0,0), Alignment.Left, Alignment.Bottom)
	--local label = cc.LabelTTF:create(txtSkin.txt, 'SimHei', txtSkin.size*fontScale, cc.size(0,0), Alignment.Left, Alignment.Bottom)
	local label = cc.LabelTTF:create(txtSkin.text, UI_DEFAULT_FONT, txtSkin.size*fontScale, cc.size(0,0), Alignment.Left, Alignment.Bottom)
	label:setScale(1/fontScale)
	label:setPosition(cc.p((skin.x or 0), (skin.y or 0)))
	--label:setPosition(cc.p(skin.x, skin.y - txtSkin.size / 8))            
	label:setAnchorPoint(cc.p(0,0))
	local c = cc.c3b(txtSkin.color[1], txtSkin.color[2], txtSkin.color[3])
	label:setColor(c)
	self._ccnode = label 
	
	--偏白色的文字统一加点阴影
	if c.r > 200 and c.g > 200 and c.b > 200 then 
		local d = txtSkin.size / 8 
		self:enableShadow(d, -d)
		--self:enableStroke(200,0,0, d)
	end
end

function getContentSize(self)
	local size = self._ccnode:getContentSize()
	return {width=size.width / fontScale,height=size.height / fontScale}
end

function getSkin(self)
	return self._skin
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

function setState(self, state)
    local txtSkin = self:getStateSkin(state)
	if self._state ~= state and txtSkin then
		self._state = state 
		self._ccnode:setString(txtSkin.txt)
		self._ccnode:setFontName(txtSkin.font)
		self._ccnode:setFontSize(txtSkin.size)
	end
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


function shader(self, shaderName, ...)
	Shader.setShader(self._ccnode, shaderName, ...)
end

function getString(self)
	return self._ccnode:getString()
end

function setString(self, str)
	self._ccnode:setString(str)
end

--水平
function getHorizontalAlignment(self)
	return self._ccnode:getHorizontalAlignment()
end
function setHorizontalAlignment(self, alignment)
	self._ccnode:setHorizontalAlignment(alignment)
end

--垂直
function getVerticalAlignment(self)
	return self._ccnode:getVerticalAlignment()
end
function setVerticalAlignment(self, alignment)
	self._ccnode:setVerticalAlignment(alignment)
end

function getDimensions(self)
	return self._ccnode:getDimensions()
end

function setDimensions(self, w, h) -- CCSize dim
	self._ccnode:setDimensions(cc.size(w * fontScale,h))
end

function getFontSize(self)
	return self._ccnode:getFontSize() / fontScale
end
function setFontSize(self, fontSize)
	self._ccnode:setFontSize(fontSize * fontScale)
end

function getFontName(self)
	return self._ccnode:getFontName()
end
function setFontName(self, fontName)
	self._ccnode:setFontName(fontName)
end

--阴影
--dx,dy 偏移
--blur 模糊
--oparcity 阴影不透明度
function enableShadow(self, dx, dy, shadowOpacity, shadowBlur)
	self._ccnode:enableShadow(cc.size(dx,dy), shadowOpacity or 0.6, shadowBlur or 0, true)
end
function disableShadow(self)
	self._ccnode:disableShadow(true)
end

--描边 
--void enableStroke(const ccColor3B &strokeColor, float strokeSize, bool mustUpdateTexture = true);
function enableStroke(self, r, g, b, strokeSize)
	self._ccnode:enableStroke(cc.c3b(r,g,b),strokeSize, true)
end
function disableStroke(self)
	self._ccnode:disableStroke(true)
end

function setColor(self, r, g, b)
	self._ccnode:setColor(cc.c3b(r,g,b))
end

--填充色   
function setFontFillColor(self, r, g, b)
	self._ccnode:setFontFillColor(cc.c3b(r,g,b), true)
end

