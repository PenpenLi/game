module("RichText2", package.seeall)
setmetatable(_M, {__index = Control})

--[[
--
	local rt = RT.new()
	rt:setVerticalSpace(10)
	rt:setTextWidth(50)
	rt:setString("abc<font size='15' color='255,255,255'>中文怎么样</font><img scale='0.2' src='res/common/icon/tipsbg.png'></img>去你的<font color='255,0,0'>红色</font>ayy<br></br>yyyy")
	rt:setPosition(Stage.width/Stage.uiScale/2, Stage.height/Stage.uiScale/2)
	self:addChild(rt)
--
----]]

UI_LABEL_DEFAULT_SKIN = {
	name="myTxt",type="Label",x=0,y=0,width=24,height=12,
	normal={txt="test",font="SimSun",size=20,bold=false,italic=false,color={255,255,255}}
}

labelSigleton = nil
charSizeTab = nil
labelIndex = 0

function initLabelSigleton()
	charSizeTab = {}

	labelSigleton = Label.new(UI_LABEL_DEFAULT_SKIN)
	labelSigleton:setVisible(false)
	Stage.currentScene:addChild(labelSigleton)
end

function new()
	local instance = {}
	setmetatable(instance, {__index = _M})
	instance:init()
	return instance
end

function init(self)
	self.name = 'RichTxt_' .. labelIndex
	labelIndex = labelIndex + 1
	self.curWidth = 0
	self.curHeight = 0
	self.maxCharHeight = 0 
	self.verticalSpace = 0
	self.fontSize = 20
	self.fontColor = {255, 255, 255}
	self.isShadow = true
	self._ccnode = cc.Sprite:create()
	self.container = Sprite.new('labelContainer')
	self:addChild(self.container)
end

function setVerticalSpace(self, val)
	self.verticalSpace = val
end

function setTextWidth(self, val)
	self.textWidth = val
end

function setShadow(self, val)
	self.isShadow = val
end

function setFontSize(self, val)
	self.fontSize = val
end

function setFontColor(self, r, g, b)
	self.fontColor = {r, g, b}
end

function setString(self, txt)
	self.curWidth = 0
	self.curHeight = 0
	self.maxCharHeight = 0
	self.container:removeAllChildren()
	self:addLineSpr()
	--self:removeAllChildren()

	local bIndex,endIndex,beginContent,tag,fontContent,_,endContent = string.find(txt, "(.-)(<.->)([^>]*)(</.->)([^<]*)")
	while bIndex do
		--print('font = ' .. font .. ' fontContent = ' .. fontContent)
		if beginContent then
			--print('beginContent = ' .. beginContent)
			self:addLabel(beginContent)
		end
		if tag then
			--print('tag =====================' .. tag)
		end
		local attrTab = {}
		for k, v in string.gfind(tag, "(%w+)='(.-)'") do
			attrTab[k] = v
			--print('k =========' .. k .. ' v ================' .. v)
		end
		if string.find(tag, 'img') then
			self:addImg(attrTab)
		elseif string.find(tag, 'font') then
			self:addLabel(fontContent, attrTab)
		elseif string.find(tag, 'br') then
			self:addLine()
		else
			alert('标签错误 ' .. tag)
		end
		if endContent then
			self:addLabel(endContent)
			--print('endContent = ' .. endContent)
		end
		txt = string.sub(txt, endIndex + 1)
		bIndex,endIndex,beginContent,tag,fontContent,_,endContent = string.find(txt, "(.-)(<.->)([^>]*)(</.->)([^<]*)")
	end
	if string.len(txt) > 0 then
		self:addLabel(txt)
	end
end

function addLineSpr(self)
	self.curLineSpr = Sprite.new('Line_spr_' .. labelIndex)
	labelIndex = labelIndex + 1
	self.curLineSpr:setPositionY(-self.curHeight - self.maxCharHeight)
	self.container:addChild(self.curLineSpr)
end

function addLine(self)
	self.curWidth = 0	
	self.curHeight = self.curHeight + self.maxCharHeight + self.verticalSpace
	self.maxCharHeight = 0
	self:addLineSpr()
end

function addImg(self, attrTab)
	local sprName = 'RichText_Img_' .. labelIndex
	local spr = Sprite.new(sprName, attrTab.src)
	local size = spr:getContentSize()
	labelIndex = labelIndex + 1
	if attrTab.scale then
		spr:setScale(attrTab.scale)
		size = cc.size(size.width * attrTab.scale, size.height * attrTab.scale)
	end

	if self.textWidth == nil then
		spr:setPosition(self.curWidth, -self.curHeight)
		self.curWidth = self.curWidth + size.width
	else
		if size.height > self.maxCharHeight then
			self.maxCharHeight = size.height
		end
		if self.curWidth + size.width <= self.textWidth then
			self.curLineSpr:setPositionY(-self.curHeight - self.maxCharHeight)
			spr:setPositionX(self.curWidth)
			self.curWidth = self.curWidth + size.width
		else
			self.curHeight = self.curHeight + self.maxCharHeight + self.verticalSpace	
			self.maxCharHeight = 0
			self.curWidth = size.width + 2
			self:addLineSpr()
		end
	end
	self.curLineSpr:addChild(spr)
end

function addLabel(self, content, font)
	if string.len(content) > 0 then
		if self.textWidth == nil then
			self:addSubLabel(content, font)
			self.curWidth = self.curWidth + self:getStringWidth(content, font)
		else
			local charTab = Common.utf2tb(content)
			local len = #charTab
			local str = ''
			local widthSum = 0
			for i=1,len do
				local charSize = self:getCharSize(charTab[i], font)
				--print('char ========================' .. charTab[i])
				if self.curWidth + widthSum + charSize.width > self.textWidth then
					--print('self.curWidth1 = ' .. self.curWidth .. ' charWidth = ' .. charSize.width .. ' textWidth = ' .. self.textWidth .. ' str = ' .. str)
					self:addSubLabel(str, font)
					self.curHeight = self.curHeight + self.maxCharHeight + self.verticalSpace

					str = ''
					widthSum = 0
					self.curWidth = 0
					self.maxCharHeight = 0
					self:addLineSpr()
					self.curLineSpr:setPositionY(-self.curHeight)
				end
				if self.curWidth + widthSum + charSize.width <= self.textWidth then
					if charSize.height > self.maxCharHeight then
						self.maxCharHeight = charSize.height
					end
					self.curLineSpr:setPositionY(-self.curHeight - self.maxCharHeight)
					widthSum = widthSum + charSize.width
					str = str .. charTab[i]
					--print('self.curWidth2 = ' .. self.curWidth .. ' charWidth = ' .. charSize.width .. ' textWidth = ' .. self.textWidth .. ' str = ' .. str)
					if i == len then
						self:addSubLabel(str, font)
						self.curWidth = self.curWidth + widthSum
						--print('str = ' .. str .. ' width = ' .. self.curWidth)
					end
				end
			end
		end
	end
end

function addSubLabel(self, content, font)
	local label = Label.new(UI_LABEL_DEFAULT_SKIN)
	label.name = 'LabelTxt_' .. labelIndex
	labelIndex = labelIndex + 1
	if self.isShadow == false then
		label:disableShadow()
	end
	label:setString(content)
	label:setPositionX(self.curWidth)
	label:setColor(self.fontColor[1], self.fontColor[2], self.fontColor[3])
	self.curLineSpr:addChild(label)

	if font then
		if font.size then
			label:setFontSize(font.size)
		else
			label:setFontSize(self.fontSize)
		end
		if font.color then
			local colorTab = Common.split(font.color, ',')
			label:setColor(colorTab[1], colorTab[2], colorTab[3])
		end
	else
		label:setFontSize(self.fontSize)
	end
end

function getStringWidth(self, str, font)
	--local charTab = Common.utf2tb(str)
	--local len = #charTab
	--local widthSum = 0
	--for i=1,len do
	--	widthSum = widthSum + self:getCharSize(charTab[i], font).width
	--end
	--return widthSum
	if labelSigleton == nil or labelSigleton.alive == false then
		initLabelSigleton()
	end
	labelSigleton:setString(str)
	if font and font.size then
		labelSigleton:setFontSize(font.size)
	else
		labelSigleton:setFontSize(self.fontSize)
	end
	return labelSigleton:getContentSize().width
end

function getCharSize(self, char, font)
	if labelSigleton == nil or labelSigleton.alive == false then
		initLabelSigleton()
	end
	local size = self.fontSize
	if font and font.size then
		size = font.size
	end
	if charSizeTab[size] == nil then
		charSizeTab[size] = {}
	end
	if charSizeTab[size][char] == nil then
		labelSigleton:setString(char)
		labelSigleton:setFontSize(size)
		charSizeTab[size][char] = labelSigleton:getContentSize()
	end
	return charSizeTab[size][char]
end

function reverse(self)
	local size = self:getContentSize()
	self.container:setPositionY(size.height)
end

function getContentSize(self)
	if self.textWidth then
		return cc.size(self.textWidth, self.curHeight + self.maxCharHeight)
	end
	return cc.size(self.curWidth, self.maxCharHeight)
end
