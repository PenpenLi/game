module("Common", package.seeall) 

-- local UtilInstance = UtilInstance or nil
local UtilInstance =  nil
local CrontabConfig = require("src/config/CrontabConfig").Config
--local CharNameConfig = require("script/config/CharNameConfig")
--C++注册过来的Util
function cUtil()
	if not UtilInstance then
		UtilInstance = LuaUtil:new()
	end
	return UtilInstance
end

function getRotateFlower()
	local f = cc.Sprite:create("res/common/flower.png")
	local actionBy = cc.RotateBy:create(2, 360)
	f:runAction(cc.RepeatForever:create(actionBy))
	return f
end

function printR(sth)
	if Device.platform ~= "windows" then
		return
	end

	if type(sth) ~= "table" then
		print(sth)
		return
	end

	local space, deep = string.rep(' ', 4), 0
	local function _dump(t)
		local temp = {}
		for k,v in pairs(t) do
			local key = tostring(k)

			if type(v) == "table" then
				deep = deep + 2
				print(string.format("%s[%s] => Table\n%s(",
				string.rep(space, deep - 1),
				key,
				string.rep(space, deep)
				)
				) --print.
				_dump(v)

				print(string.format("%s)",string.rep(space, deep)))
				deep = deep - 2
			else
				print(string.format("%s[%s] => %s",
				string.rep(space, deep + 1),
				key,
				tostring(v)
				)
				) --print.
			end
		end
	end

	print(string.format("Table\n("))
	_dump(sth)
	print(string.format(")"))
end

tbCharArrayToString = {}
function getStringFromTable(tbLen, tb)
    for i = 0, tbLen-1 do
        tbCharArrayToString[i] = string.char(tb[i] % 256)
    end
    return table.concat(tbCharArrayToString, "", 0, tbLen - 1)
end

function urlEncode(str)
  if (str) then
    str = string.gsub (str, "\n", "\r\n")
    str = string.gsub (str, "([^%w %-%_%.%~])",
        function (c) return string.format ("%%%02X", string.byte(c)) end)
    str = string.gsub (str, " ", "+")
  end
  return str
end

function urlDecode(str)
  str = string.gsub (str, "+", " ")
  str = string.gsub (str, "%%(%x%x)",
      function(h) return string.char(tonumber(h,16)) end)
  str = string.gsub (str, "\r\n", "\n")
  return str
end

function distance(x1, y1, x2, y2)
	return math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))
end

msgIndex = 0
function showMsg(...)
	local msg = string.format(...)
	msgIndex = msgIndex + 1
	local name = "CommonShowMsg_" .. msgIndex 
	local skin = {
		name=name,type="Label",x=0,y=0,width=24,height=12,
		normal={txt=msg,font="SimSun",size=28,bold=true,italic=false,color={255,255,255}}
	}
	local tip = Label.new(skin)
	local bg = cc.Scale9Sprite:create("res/common/icon/tipsbg.png")
	bg:setAnchorPoint(0.5,0.5)
	bg:setPosition((Stage.width - skin.width) / 2,(Stage.height - skin.height) / 1.5)
	local width = math.max(tip:getContentSize().width,92)
	local height = math.max(tip:getContentSize().height,92)
	bg:setContentSize(cc.size(width+92,height))
	bg:addChild(tip._ccnode)
	tip:setAnchorPoint(0.5,0.5)
	tip:setPositionX(bg:getContentSize().width/2)
	tip:setPositionY(bg:getContentSize().height/2)
    Stage.currentScene._ccnode:addChild(bg)

	local sineOut = cc.FadeOut:create(1.2)
	local call = cc.CallFunc:create(function()
		bg:removeFromParent()
	end)
	bg:runAction(cc.Sequence:create({cc.DelayTime:create(1), sineOut, call}))
end

attrIndex = 0
function addAttrTips(attrName,attrVal,ctrl,pos)
	local name = "attrTips_"..attrIndex
	local msg = attrName.."+"..attrVal
	attrIndex = attrIndex + 1
	local skin = {
		name=name,type="Label",x=0,y=0,width=24,height=12,
		normal={txt=msg,font="SimSun",size=28,bold=true,italic=false,color={255,255,255}}
	}
	local tips = Label.new(skin)
	tips:setAnchorPoint(0.5,0.5)
	if ctrl then
		tips:setPositionX(pos.x)
		tips:setPositionY(pos.y)
		ctrl:addChild(tips)
	else
		tips:setPosition((Stage.width - skin.width) / 2,(Stage.height - skin.height) / 1.5)
    	Stage.currentScene:addChild(tips)
	end
	tips:setColor(176,231,27)
	local original = tips:getScale()
	local scaleTo = cc.ScaleTo:create(0.2,original*1.1,original*1.1)
	local sineOut = cc.EaseSineOut:create(scaleTo)
	local scaleTo2 = cc.ScaleTo:create(0.05,original,original)
	local sineOut2 = cc.EaseSineOut:create(scaleTo2)
	local seq = cc.Sequence:create({sineOut,sineOut2})

	local moveBy = cc.MoveBy:create(0.5,cc.p(0,100))
	local sineOut3 = cc.EaseSineOut:create(moveBy)
	local fadeOut = cc.FadeOut:create(1.2)
	local spawn = cc.Spawn:create(sineOut3,fadeOut)
	local call = cc.CallFunc:create(function()
		tips:removeFromParent()
	end)
	--tips:runAction(cc.Sequence:create({seq,cc.DelayTime:create(0.5),spawn,call}))
	tips:runAction(cc.Sequence:create({seq,spawn,call}))
end

function showMsgWithParam(msg, ...)
	msg = replaceRegTag(msg, ...)
	showMsg(msg)
end

--用于返回码 如：%s神兵碎片不足，使用方式为 replaceRegTag("%s是%dB", "骆总", 2)
function replaceRegTag(content, ...)
    for key,val in ipairs({...}) do
        local t = type(val)
        if t == "number" then
            content = string.gsub(content, "%%d", tostring(val), 1)

        elseif t == "string" then
            content = string.gsub(content, "%%s", tostring(val), 1)
        end
    end

    return content
end

--返回指定长度的数字字符串，数字位数不足前补0，数字应该是正数
local prefix_str = {[0]="","0","00","000","0000","00000","000000","0000000"}
function numberToString(number, strLen)
	local len = strLen or 2
	assert(strLen and strLen >= 2 and strLen <= 8, "numberToString: invalid strlen!" .. strLen)
	if number == 0 then
		return prefix_str[strLen]
	end
	local p1,p2 = 0,10
	for i = 1, 8 do
		if i > strLen then
			break
		end
		--[[ [0~10) 一位，[10~100) 二位，[100~1000) 三位, .... ]]
		if number >=  p1 and number < p2 then
			return prefix_str[strLen-i] .. tostring(number)
		end
		p1 = p2
		p2 = p2 * 10
	end
	return tostring(number)
end

--随机角色名
function randomRoleName()
	local NameAdj = require("src/config/NameAdjConfig").Config
	local NameFull = require("src/config/NameFullConfig").Config
	local n1 = NameAdj[math.random(1,#NameAdj)].name
	local n2 = NameFull[math.random(1,#NameFull)].name
	return n1 .. n2
end

function RandomRoleName(sex)
	local firstName = CharNameConfig.SurnameConfig

	local mname = CharNameConfig.MaleNameConfig

	local wname = CharNameConfig.FemaleNameConfig

	local n1,n2,n3
	n1 = firstName[math.random(1,#firstName)]
	if sex == CommonDefine.HUMAN_SEX_MALE then
		n2 = mname[math.random(1,#mname)]
		n3 = mname[math.random(1,#mname)]
	else
		n2 = wname[math.random(1,#wname)]
		n3 = wname[math.random(1,#wname)]
	end
	return n1 .. n2 .. n3
end

function createAnimation(name, speed, frameBegin, frameEnd)
	local FRAME_TIME = 0.04167 * speed 
	local cache = cc.SpriteFrameCache:getInstance()
	local ary = {}
	for i = frameBegin, frameEnd do
		local url = name .. numberToString(i, 4)
		local frame = cache:spriteFrameByName(url)
		table.insert(ary, frame)
	end
	return cc.Animation:createWithSpriteFrames(ary, FRAME_TIME)
end

function isToday(dt)
    if not dt then return false end
	local s1 = os.date("%Y%m%d",os.time())
	local s2 = os.date("%Y%m%d",dt)
	return s1 == s2
end
--返回当天N点的时间戳
function GetTodayTime(N)
    local t = os.date("*t", os.time());
    local todayTime = {year = t.year, month = t.month , day = t.day , hour=N or 0,min=0,sec=0}
    return os.time(todayTime) 
end

-- hh:mm:ss
function getDCTime(t)
	local h = math.floor(t / 3600)
	local m = math.floor(t / 60) - h * 60
	local s = t % 60
	return string.format("%02d:%02d:%02d", h, m, s)
end


function getTimeByStr(str)
    -- str : hour:min:sec  09:01:00
    -- ret : value of os.time(XXX)
    local hour 
    local min
    local sec
    if string.sub(str, 2, 2) == ":" then
        hour = string.sub(str, 1, 1)
        min = string.sub(str, 3, 4)
        sec = string.sub(str, 6, 7)
    else
        hour = string.sub(str, 1, 2)
        min = string.sub(str, 4, 5)
        sec = string.sub(str, 7, 8)
    end
    local timeTable = os.date('*t', os.time())
    timeTable.hour = math.floor(hour)
    timeTable.min = math.floor(min)
    timeTable.sec = math.floor(sec)
    return os.time(timeTable)
end

function getShortDCTime(t)
	local m = math.floor(t / 60)
	local s = t % 60
	return string.format("%02d:%02d", m, s)
end

function Div(a, b)
	return (a - a % b) / b
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

function showMemUsage(parent)
	if true or Device.platform ~= "android" then
		local memoryLabel = parent:getChild("memory")
		if not memoryLabel then
			local labelSkin = {
				name="memory",type="Label",x=Stage.width,y=10,width=100,height=30,
				normal={txt = '',font="Helvetica",size=20,bold=false,italic=false,color={255,255,255}}
			}
			memoryLabel = Label.new(labelSkin)
			memoryLabel:setAnchorPoint(1,0)
			parent:addChild(memoryLabel,255)
		end
		memoryLabel:setString(string.format('mem:%.3f\n\rlua:%.3f', Device.getUsedMemory()  ,collectgarbage("count") / 1000))
	end
end

function printTexInfo()
	print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
end


local nodeQueue = {}
function newQueue()
	local o = {
		elements = {},
		frontIdx = 1,
		point = 0,
	}
	setmetatable(o,{__index=nodeQueue})
	return o
end

function nodeQueue:push(node)
	self.point = self.point + 1
	self.elements[self.point] = node
end

function nodeQueue:pop()
	self.point = self.point - 1
	self.frontIdx = self.frontIdx + 1
end

function nodeQueue:front()
	return self.elements[self.frontIdx]
end

function nodeQueue:empty()
	return self.point == 0
end


--获取数字指定数位的值，place：个位1，十位2，百位3...
function numberSplit(number, place)

end

function newEnum(tb, nStartFrom)    --创建一个枚举类型
	nStartFrom = nStartFrom or 1
	local o = {m_begin = nStartFrom, m_end = nStartFrom + #tb -1 }
	for i = 1, #tb do
		o[tb[i]] = i - 1 + nStartFrom
	end
	o.__index = function(t, k) assert(nil, k .. " not exist") end
	setmetatable(o, o)
	return o
end

MIX = {[0]=0,[1]=4,[2]=1,[3]=6,[4]=2,[5]=7,[6]=3,[7]=8,[8]=9,[9]=5}
DEMIX = {[0]=0,[1]=2,[2]=4,[3]=6,[4]=1,[5]=9,[6]=3,[7]=5,[8]=7,[9]=8}
function mixVal(value)
	value = math.ceil(value)
	local ret = 0
	local left = value % 10
	local value,_ = math.modf(value/10)
	local cnt = 0
	while value >= 0 do
		left = MIX[left]
		if cnt > 0 then
			ret = ret + left * math.pow(10, cnt)
		else
			ret = ret + left
		end
		cnt = cnt + 1
		if value == 0 then
			break
		end
		left = value % 10
		value,_ = math.modf(value/10)
	end
	return ret
end

function demixVal(value)
	local ret = 0
	local left = value % 10
	local value,_ = math.modf(value/10)
	local cnt = 0
	while value >= 0 do
		left = DEMIX[left]
		if cnt > 0 then
			ret = ret + left * math.pow(10, cnt)
		else
			ret = ret + left
		end
		cnt = cnt + 1
		if value == 0 then
			break
		end
		left = value % 10
		value,_ = math.modf(value/10)
	end
	return ret
end

function checkRolename(newName)
    local nameLen = #newName
    if nameLen < 2 or nameLen > 24 then
    	return false
    end
    
    local i, j = string.find(newName, "%[")
    if i ~= nil then
    	return false
    end
    
    i, j = string.find(newName, "]")
    if i ~= nil then
    	return false
    end
    
    for tmpStr in string.gmatch(newName, "([%z\1-\127\194-\244][\128-\191]*)") do
        if string.len(tmpStr) == 1 then
            local byteVal = string.byte(tmpStr)
            if  byteVal < 33 or byteVal == 127 then
                return false
            end
        end
    end
    return true
end

function GetTbNum(tb)
    local count = 0
    if tb then
        for _ in pairs(tb) do
            count = count + 1
        end
    end
    return count
end

function setLabelCenter(label,align)
	--label:setDimensions(label._skin.width,0)
	label:setDimensions(label:getContentSize().width,0)
	local lableAlign = Label.Alignment.Center
	if align == 'left' then
		lableAlign = Label.Alignment.Left
	elseif align == 'right' then
		lableAlign = Label.Alignment.Right
	end
	label:setHorizontalAlignment(lableAlign)
end

function setBodyGrid(bodyId,target) 
	CommonGrid.bind(target)
	target:setBodyIcon(bodyId)
end

function getMonsterName(monsterId)
	local MonsterConfig = require("src/config/MonsterConfig").Config
	return MonsterConfig[monsterId].monsterName
end

function getMonsterBodyName(monsterId)
	local MonsterConfig = require("src/config/MonsterConfig").Config
	return MonsterConfig[monsterId].name
end

function createEditBox(editLabel,callback)
	editLabel:setVisible(false)
	local sprite9 = cc.Scale9Sprite:create("res/common/non.png")
	local size = editLabel:getContentSize()
	size = {width=size.width,height=size.height * 1.8}
	local editBox = cc.EditBox:create(size,sprite9)
	editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DEFAULT)
	editBox:setAnchorPoint(0,0.5)
	editBox:setPosition(editLabel:getPosition())
	local size = editLabel:getContentSize()
	editBox:setPositionY(editLabel:getPositionY() + size.height/2)

	local function onStartEditor(eventType)
		if eventType == "began" then
			editBox:setText("")
		end
		if callback then callback(eventType) end
	end
	editBox:registerScriptEditBoxHandler(onStartEditor)
	editBox:setMaxLength(50)
	return editBox
end

--返回一个线框node。 box:指定的矩形 c4b:指定的颜色
function getDrawBoxNode(box, c4b)
	local allPos = {}
	table.insert(allPos, cc.p(0,0))
	table.insert(allPos, cc.p(box.width,0))
	table.insert(allPos, cc.p(box.width,box.height))
	table.insert(allPos, cc.p(0,box.height))
	local c4b = c4b or cc.c4b(255,0,0,200)
    local glNode  = gl.glNodeCreate()
    glNode:setContentSize(cc.size(box.width, box.height))
    glNode:setPosition(box.x,box.y)
    glNode:setAnchorPoint(cc.p(0, 0))
    function boxDraw(transform, transformUpdated)
        kmGLPushMatrix()
        kmGLLoadMatrix(transform)
    	cc.DrawPrimitives.drawColor4B(c4b.r,c4b.g,c4b.b,c4b.a)
    	cc.DrawPrimitives.drawPoly(allPos, 4, true)
        kmGLPopMatrix()
    end
    glNode:registerScriptDrawHandler(boxDraw)
	return glNode
end

--数字递加动作
function addNumAction(txt, maxNum, prefix,suffix)
	local prefix = prefix or ""
	local suffix = suffix or ""
	txt:stopAllActions()
	local timeGap = 0.05
	local curNum = 0
	local incNum = 1
	local sequence = cc.Sequence:create(cc.DelayTime:create(timeGap), cc.CallFunc:create(function()
			curNum = curNum + incNum
			incNum = incNum + 1
			if curNum > maxNum then
				txt:setString(prefix .. maxNum .. suffix)
				txt:stopAllActions()
			else
				txt:setString(prefix .. curNum .. suffix)
			end
		end
	))
	local repeate = cc.RepeatForever:create(sequence)
	txt:runAction(repeate)
end

--0xxxxxxx
--110xxxxx 10xxxxxx
--1110xxxx 10xxxxxx 10xxxxxx
--11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
--111110xx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx
--1111110x 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx
--定义查找表，长度256，表中的数值表示以此为起始字节的utf8字符长度
UTFLEN =
{
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
	2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
	3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
	4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 6, 6, 1, 1
}

function utf2tb(str)
	local i = 1
    local index = 1
    local tb = {}
    local len = string.len(str)
    while (true) do
        if i > len then
            break
        end
        local c = string.sub(str,i,i)
        local j = i + UTFLEN[string.byte(c)]    
        local word = string.sub(str,i,j-1)
        tb[index] = word
        index = index + 1
        i = j
    end
    return tb 
end

function addBg(ui,image)
	local bg = Sprite.new('bg_' .. image,image)
	bg.touchEnabled = false
	ui:addChild(bg,-1)
	return bg
end

function split(str, sign)
	local retTab = {}
	local temp = str
	local f = string.find(temp, sign)
	while f ~= nil do
		local sub = string.sub(temp, 1, f - 1)
		temp = string.sub(temp, f + 1)
		table.insert(retTab, sub)
		f = string.find(temp, sign)
	end
	if temp ~= "" then
		table.insert(retTab, temp)
	end
	return retTab
end

function setBtnAnimation(node,armatureName,animationName,adjustPos)
	local pos = adjustPos or {}
	local posX = pos.x or 0
	local posY = pos.y or 0
	local btnAnimation = ccs.Armature:create(armatureName)
	local rSize = node:getContentSize()
	btnAnimation:getAnimation():play(animationName,-1,-1)
	btnAnimation:setAnchorPoint(0.5,0.5)
	btnAnimation:setPosition(rSize.width/2+posX,rSize.height/2+posY)
	node:addChild(btnAnimation)
	return btnAnimation
end

function showRechargeTips(msg, isShowTip)
	if isShowTip == nil then
		isShowTip = true
	end
	if isShowTip == true then
		local msg = msg or "钻石不足，是否充值?"
		local tips = TipsUI.showTips(msg)
		tips:addEventListener(Event.Confirm,function(self,event) 
			if event.etype == Event.Confirm_yes then
				--showMsg('充值暂未开放')
				local ui = UIManager.addUI("src/modules/vip/ui/VipUI")
				ui:showRecharge()
			end
		end)
		return tips
	else
		--showMsg('充值暂未开放')
		local ui = UIManager.addUI("src/modules/vip/ui/VipUI")
		ui:showRecharge()
	end
end

local _beganBtn = nil
function outSideTouch(self,event)
	local child = self:getTouchedChild(event.p)
	if child then
		_beganBtn = nil
		Control.touch(self,event)
	else
		if event.etype == Event.Touch_began then
			_beganBtn = self
		elseif event.etype == Event.Touch_ended then
			if _beganBtn == self then
				_beganBtn = nil
				UIManager.removeUI(self)
				return true
			end
		end
	end
	return false
end

function getTouchUseCount(event, itemNum)
	local cnt = 1
	if event then
		local t = math.abs(event.maxTimes)
		if t < 5 then
			cnt = 1
		elseif t < 10 then
			cnt = math.min(2,itemNum)
		elseif t < 15 then
			cnt = math.min(3,itemNum)
		elseif t < 20 then
			cnt = math.min(4,itemNum)
		else
			cnt = math.min(5,itemNum)
		end
	end
	return cnt
end

function Split(str, delim, maxNb)
    -- Eliminate bad cases...
    if string.find(str, delim) == nil then
        return { str }
    end
    if maxNb == nil or maxNb < 1 then
        maxNb = 0    -- No limit
    end
    local result = {}
    local pat = "(.-)" .. delim .. "()"
    local nb = 0
    local lastPos
    for part, pos in string.gmatch(str, pat) do
        nb = nb + 1
        result[nb] = part
        lastPos = pos
        if nb == maxNb then break end
    end
    -- Handle the last field
    if nb ~= maxNb then
        result[nb + 1] = string.sub(str, lastPos)
    end
    return result
end

function createRichText(label,fontSize,color)
	local rich = RichText2.new()
	rich:setFontSize(fontSize)
	rich:setShadow(false)
	rich:setFontColor(unpack(color))
	--rich:setVerticalSpace(10)
	local size = label:getContentSize()
	local posX,posY = label:getPosition()
	rich:setTextWidth(size.width)
	rich:setPosition(posX,posY+size.height)
	label._parent:addChild(rich)
	label:removeFromParent()
	return rich
end


function getTimeByString(str)
	-- str 格式 YYYYMMDDhhmmss
	local year = tonumber(string.sub(str,1,4))
	local month = tonumber(string.sub(str,5,6))
	local day = tonumber(string.sub(str,7,8))
	local hour = tonumber(string.sub(str,9,10)) or 0
	local min = tonumber(string.sub(str,11,12)) or 0
	local sec = tonumber(string.sub(str,13,14)) or 0
	local timeTable = {year = year, month = month , day = day, hour=hour,min=min,sec=sec}
	return os.time(timeTable),timeTable
end

function getToday0Clock(t)
	local ONE_DAY = 24 * 3600
	local ENGHT_HOUR = 8 * 3600
	return t - (t + ENGHT_HOUR)%ONE_DAY
end

function getServerDay()
	local day = 0
	if Master.getInstance().createServer > 0 then
		local ONE_DAY = 24 * 3600
		local ENGHT_OCLOCK = 8 * 3600
		local time = getToday0Clock(Master.getInstance().createServer)
		local curTime = getToday0Clock(os.time())
		day = (curTime - time) / ONE_DAY + 1
		--day = math.ceil((os.time() - Master.getInstance().createServer) / (24 * 3600))
	end
	return day 
end

function getDHMSByTime(t)
	local d = math.floor(t / (24 * 3600))
	local d1 = math.floor(t % (24 * 3600))
	local h = math.floor(d1/ 3600)
	local h1 = math.floor(d1 % 3600)
	local m = math.floor(h1/60)
	local s = t % 60
	return d,h,m,s
end

function getCronEventHMStr(evId)
	local act = CrontabConfig[evId]
    local hourList = CronStr2List(act.hour,23)
    local minList  = CronStr2List(act.min,59)
	local ret = ""
	if hourList[1] and minList[1] then
		ret = string.format("%02d:%02d",hourList[1],minList[1])
	end
	return ret
end

function getCronEventPassTime(evId)
	local act = CrontabConfig[evId]
	local serverTime = Master.getServerTime()
	local date = os.date('*t',serverTime)
	local dayDiff
	for i = #act.week,1,-1 do
		if date.wday >= act.week[i] + 1 then
			dayDiff = date.wday - (act.week[i] + 1)
			break
		end
	end
	if not dayDiff then
		dayDiff = 7 - ((act.week[#act.week] + 1) - date.wday)
	end
	local cronTimeList = ParseCron(act.min,act.hour)
	if dayDiff > 0 then
		return serverTime + dayDiff*24*3600 - cronTimeList[#cronTimeList]
	else
		for i = #cronTimeList,1,-1 do
			if serverTime > cronTimeList[i] then
				return serverTime - cronTimeList[i]
			end
		end
		return serverTime + (dayDiff + 1)*24*3600 - cronTimeList[#cronTimeList]
	end
end

function getCronEventLeftTime(evId)
	local act = CrontabConfig[evId]
	local serverTime = Master.getServerTime()
	local date = os.date('*t',serverTime)
	local dayDiff
	for i = 1,#act.week do
		if date.wday <= act.week[i] + 1 then
			dayDiff = act.week[i] + 1 - date.wday
			break
		end
	end
	if not dayDiff then
		dayDiff = 7 - (date.wday - (act.week[1] + 1))
	end
	local cronTimeList = ParseCron(act.min,act.hour)
	if dayDiff > 0 then
		return cronTimeList[1] + dayDiff*24*3600 - serverTime
	else
		for i = 1,#cronTimeList do
			if serverTime < cronTimeList[i] then
				return cronTimeList[i] - serverTime
			end
		end
		return cronTimeList[1] + (dayDiff + 1)*24*3600 - serverTime
	end
end

function ParseCron(min,hour)
    local timeTable = os.date('*t', os.time())
    local cronTime = {}
    local hourList = CronStr2List(hour,23)
    local minList  = CronStr2List(min,59)
    for i=1,#hourList do
        for j=1,#minList do
            timeTable.hour = hourList[i]
            timeTable.min  = minList[j] 
            timeTable.sec  = 0
            cronTime[#cronTime+1] = os.time(timeTable)
        end
    end
    return cronTime
end

function CronStr2List(str,maxNum)
    local list = {}
    if type(str) == 'table' then  --枚举型,{2,4,6}
        for i=1,#str do
            list[#list+1] = str[i]
        end
    elseif str == '*' then           --泛型,*
        for i=0,maxNum do
            list[#list+1] = i
        end
    else                              --步进型,*/5 | 10-50/5
        local start = 0
        local stop  = maxNum
        local step = 1
        if string.sub(str,1,1) == "*" then  --形如*/5
            step = string.sub(str,3)
        else
            local sep2Index = string.find(str,"/")
            local sepIndex = string.find(str,"-")
            start = string.sub(str,1,sepIndex-1)
            stop  = string.sub(str,sepIndex+1,sep2Index-1)
            step  = string.sub(str,sep2Index+1)
        end
        for i=start,stop,step do
            list[#list+1] = i
        end
    end
    return list
end

return Common
