module("RichText", package.seeall)
setmetatable(RichText, {__index = Control}) 

UI_RICH_TEXT_TYPE = "RichText"
UI_RICH_TEXT_DEFAULT_SKIN = {
	name="myRich",type="RichText",x=0,y=0,width=200,height=200,
	normal={txt="test",font="SimSun",size=12,bold=false,italic=false,color={0,0,0}}
}

local htmlTags = {
	p = 'text',
	font = 'text',
	img = 'image',
	a = 'link',
	line = "line",
	br = "line",
}
local uiFunc = {}
local getAttr = function(elem)
	local text = elem[2]
	local attr = elem[3]
	local color = cc.c3b(0,0,0)
	if attr.color then
		print("..........+",attr.color)
		color = loadstring("return cc.c3b(" .. attr.color .. ')')()
	end
	local fontSize = attr.size or 20
	local opacity = 255
	local fontName = attr.face or Label.UI_DEFAULT_FONT 
	--local fontName = attr.face or "SimSun"
	return text,fontSize,color,opacity,fontName
end
uiFunc.text = function(self,elem)
	local text,fontSize,color,opacity,fontName = getAttr(elem)
	local node = ccui.RichElementText:create(elem.idx,color,opacity,text,fontName,fontSize)
	self._ccnode:pushBackElement(node)
	--table.insert(self._elementNodeList, node)
end

uiFunc.image = function(self,elem)
	local imgSrc = elem[2].src
	local color = cc.c3b(255,255,255)
	local opacity = 255
	local node = ccui.RichElementImage:create(elem.idx,color,opacity,imgSrc)
	self._ccnode:pushBackElement(node)
	--table.insert(self._elementNodeList, node)
end

uiFunc.link = function(self,elem)
	local text,fontSize,color,opacity,fontName = getAttr(elem)
	local node = ccui.RichElementText:create(elem.idx,color,opacity,text,fontName,fontSize)
	--[[
	label = Label.new(Label.UI_LABEL_DEFAULT_SKIN)
	label:setString(text)
	label:setFontSize(fontSize)
	label:setFontName(fontName)
	label:setColor(color[1],color[2],color[3])
	local node = ccui.RichElementCustomNode:create(elem.idx,color,opacity,label._ccnode)
	--]]
	self._ccnode:pushBackElement(node)
	--table.insert(self._elementNodeList, node)
end

uiFunc.line = function(self,elem)
	local node = cc.Node:create()
	node:setContentSize(self:getContentSize())
	local enode = ccui.RichElementCustomNode:create(elem.idx,cc.c3b(0,0,0),255,node)
	self._ccnode:pushBackElement(enode)
	--table.insert(self._elementNodeList, node)
end


function new(skin)
	local node = {
		name = skin.name,
		uiType = UI_RICH_TEXT_TYPE,
		elements = {},
		_ccnode = nil,
		color = {},
		--_elementNodeList = {},
	}
	setmetatable(node, {__index = RichText})
	node:init(skin)
	return node
end

function init(self,skin)
	local node = ccui.RichText:create()
	node:setPosition(cc.p(skin.x, skin.y))            
	node:setAnchorPoint(cc.p(0.5,0.5))
	--node:setSize(cc.size(skin.width,skin.height))
	node:setContentSize(cc.size(skin.width,skin.height))
	node:ignoreContentAdaptWithSize(false)
	self._ccnode = node

	self.elements = Common.newQueue()
end

function addStage(self)
end

--不能对同一个RichText重复设置setString,可改底层清理所有richElements或者重建RichText
function setString(self,value)
	local tb = Html.parsestr(value)
	--Common.printR(tb)
	--self:removeAllElement()
	self:depthSearch(tb)
	self:pushElements()
end

function depthSearch(self,tb,parent)
	if parent then
		--继承父节点属性
		if not tb._attr then
			tb._attr = parent._attr
		else
			parent._attr.color = parent._attr.color or self.color
			tb._attr.size = tb._attr.size or parent._attr.size
			tb._attr.color = tb._attr.color or parent._attr.color
		end
	end
	for k,v in pairs(tb) do
		if type(v) == 'table' then
			if v._tag and (v._tag:lower() == 'img' or v._tag:lower() == 'br') then
				self.elements:push({v._tag,v._attr})
			elseif v._attr then
				self:depthSearch(v,tb)
			end
		else
			if type(k) == 'number' then
				self.elements:push({tb._tag,v,tb._attr})
			end
		end
		if tb._tag == "#document" and (v._tag and v._tag == "p") then
			self.elements:push({"line"})
		end
	end
end

function pushElements(self)
	local index = 1
	while not self.elements:empty() do
		local elem = self.elements:front()
		elem.idx = index
		index = index + 1
		self:parseElement(elem)
		self.elements:pop()
	end
end


function parseElement(self,elem)
	--Common.printR(elem)
	local uiType = htmlTags[elem[1]]
	if uiType and uiFunc[uiType] then
		uiFunc[uiType](self,elem)
	end
end

function setAnchorPoint(self, x, y)
	assert(false,"锚点cc.p(0.5,0.5) richtext坑爹，不支持改锚点，否则元素的坐标会偏移")
	self._ccnode:setAnchorPoint(cc.p(x, y))
end

function setVerticalSpace(self, val)
	self._ccnode:setVerticalSpace(val)
end

function setColor(self,r,g,b)
	self.color = r .. "," .. g .. ","  .. b
end

--function removeAllElement(self)
--	self.elements = Common.newQueue()
--	for _,elementNode in pairs(self._elementNodeList) do
--		self._ccnode:removeElement(elementNode)
--		break
--	end
--	self._elementNodeList = {}
--
--	self._ccnode:formatText()
--end


