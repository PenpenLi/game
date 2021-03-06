module(..., package.seeall)
local TexasDefine = require("src/modules/guild/texas/TexasDefine")
local TexasConfig = require("src/config/TexasConfig").Config

function num2DigitColor(num)
	local kindLen = TexasDefine.POKER_KIND_LEN
	local kind = TexasDefine.POKER_KIND
	local totalLen = TexasDefine.POKER_NUM
	local digit = kindLen
	local color = kind
	if num%totalLen > 0 then
		num = num%totalLen
		digit = kindLen 
		color = (num - num%kindLen)/kindLen
		if num%kindLen > 0 then
			digit = num%kindLen
			color = color + 1
		end
	end
	return digit,color
end

local function getNextDigit(digit)
	local ret = {}
	ret[digit+1] = true
	if digit == 1 then
		ret[10] = true
	end
	return ret
end

local function compareDigit(a,b)
	if a == b then
		return 0
	elseif b == 1 or a < b then
		return -1
	elseif a == 1 or a > b then
		return 1
	end
end

local function compareColor(a,b)
	if a == b then
		return 0
	elseif a < b then
		return 1
	elseif a > b then
		return -1
	end
end

function compareCards(cardsA,cardsB)
	local lvA,cmpA = getCardLv(cardsA)
	local lvB,cmpB = getCardLv(cardsB)
	if lvA == lvB then
		local ret = true
		for i = 1,#cmpA do
			if cmpA[i].d and compareDigit(cmpA[i].d,cmpB[i].d) < 0 then
				ret = false
			end
			if cmpA[i].c and compareColor(cmpA[i].c,cmpB[i].c) < 0 then
				ret = false
			end
		end
		return ret
	else
		return lvA < lvB
	end
end

function getCardLv(pCards)
	local cards = Common.deepCopy(pCards)
	table.sort(cards)
	local cardLv = #TexasConfig
	local compareGroup
	for i = 1,#TexasConfig do
		local ret,cmp = _M[TexasConfig[i].func](cards)
		if ret then
			cardLv = i
			compareGroup = cmp
			break
		end
	end
	return cardLv,compareGroup
end

function num2DigitColor(num)
	local kindLen = TexasDefine.POKER_KIND_LEN
	local kind = TexasDefine.POKER_KIND
	local totalLen = TexasDefine.POKER_NUM
	local digit = kindLen
	local color = kind
	if num%totalLen > 0 then
		num = num%totalLen
		digit = kindLen 
		color = (num - num%kindLen)/kindLen
		if num%kindLen > 0 then
			digit = num%kindLen
			color = color + 1
		end
	end
	return digit,color
end

--皇家同花顺
function superStraight(cards)
	if flushStraight(cards) then
		local digit,color = num2DigitColor(cards[1])
		if digit == 1 then
			return true,{{c=color}}
		end
	end
	return false
end
--同花顺
function flushStraight(cards)
	local ret1,cmp1 = onlyFlush(cards)
	local ret2,cmp2 = onlyStraight(cards)
	if ret1 and ret2 then
		for i = 1,#cmp2 do
			table.insert(cmp1,cmp2[i])
		end
		return true,cmp1
	end
	return false
end
--四条
function fourOfAKind(cards)
	local temp = {}
	for i = 1,#cards do
		local digit,color = num2DigitColor(cards[i])
		temp[digit] = temp[digit] or {}
		temp[digit].num = temp[digit].num or 0
		temp[digit].num = temp[digit].num + 1
		temp[digit].color = color
	end
	local singleColor = 0
	local singleDigit = 0
	local digit = 0
	local flag = false
	for k,v in pairs(temp) do
		if v.num >= 4 then
			digit = k
			flag = true
		else
			singleDigit = k
			singleColor = temp[k].color
		end
	end
	if flag then
		return true,{{d=digit},{d=singleDigit},{c=singleColor}}
	end
	return false
end
--葫芦
function fullHouse(cards)
	local temp = {}
	for i = 1,#cards do
		local digit,color = num2DigitColor(cards[i])
		temp[digit] = temp[digit] or 0
		temp[digit] = temp[digit] + 1
	end
	local three = false
	local pair = false
	local digit3 = 0
	local digit2 = 0
	for k,v in pairs(temp) do
		if v >= 3 then
			three = true
			digit3 = k
		elseif v >= 2 then
			pair = true
			digit2 = k
		end
	end
	if three and pair then
		return true,{{d=digit3},{d=digit2}}
	end
	return false
end
--同花
function onlyFlush(cards)
	local maxDigit,maxColor = num2DigitColor(cards[1])
	for i = 2,#cards do
		local digit,color = num2DigitColor(cards[i])
		if digit > maxDigit then
			maxDigit = digit
		end
		if maxColor ~= color then
			return false
		end 
	end
	return true,{{c=maxColor},{d=maxDigit}}
end
--顺子
function onlyStraight(cards)
	table.sort(cards,function(a,b)
		local digitA,_ = num2DigitColor(a)
		local digitB,_ = num2DigitColor(b)
		return digitA < digitB
	end)
	local temp,maxColor = num2DigitColor(cards[1])
	local maxDigit = temp
	for i = 2,#cards do
		local digit,color = num2DigitColor(cards[i])
		if not getNextDigit(temp)[digit] then
			return false
		end
		temp = digit
		if compareDigit(digit,maxDigit) > 0 then
			maxDigit = digit
			maxColor = color
		end
	end
	return true,{{d=maxDigit},{c=maxColor}}
end
--三条
function threeOfAKind(cards)
	local temp = {}
	local maxDigit = 0
	for i = 1,#cards do
		local digit,color = num2DigitColor(cards[i])
		temp[digit] = temp[digit] or {}
		temp[digit].num = temp[digit].num or 0
		temp[digit].num = temp[digit].num + 1
		temp[digit].color = color
	end
	local ret = {}
	local digit1 = 0	--三条数字
	local digit2 = 0	--散牌数字1 
	local digit3 = 0	--散牌数字2
	local color1 = 5
	local color2 = 5
	local color3 = 5
	local flag = false
	for k,v in pairs(temp) do
		if v.num >= 3 then
			digit1 = k
			color1 = v.color
			flag = true
		elseif digit2 == 0 then
			digit2 = k
			color2 = v.color
		else
			digit3 = k
			color3 = v.color
		end
	end
	if flag then
		local color = color2
		if compareDigit(digit2,digit3) < 0 then
			digit2,digit3 = digit3,digit2
			color = color3	
		end
		return true,{{d=digit1},{d=color1},{d=digit2},{d=digit3},{c=color}}
	end
	return false
end
--两对
function twoPairs(cards)
	local temp = {}
	for i = 1,#cards do
		local digit,color = num2DigitColor(cards[i])
		temp[digit] = temp[digit] or {}
		temp[digit].num = temp[digit].num or 0
		temp[digit].num = temp[digit].num + 1
		temp[digit].color = color
	end
	local pairNum = 0
	local ret = {}
	local singleColor = 0
	local singleDigit = 0
	for k,v in pairs(temp) do
		if v.num >= 2 then
			table.insert(ret,{d=k})
			pairNum = pairNum + 1
		else
			singleDigit = k
			singleColor = v.color
		end
	end
	if pairNum >= 2 then
		table.sort(ret,function(a,b) return a.d > b.d end)
		table.insert(ret,{d=singleDigit})
		table.insert(ret,{c=singleColor})
		return true,ret
	end
	return false
end
--一对
function onePair(cards)
	local temp = {}
	local maxDigit = 0
	local maxColor = 5
	for i = 1,#cards do
		local digit,color = num2DigitColor(cards[i])
		temp[digit] = temp[digit] or 0
		temp[digit] = temp[digit] + 1
		if compareDigit(digit,maxDigit) > 0 and
			compareColor(color,maxColor) > 0 then
			maxDigit = digit
			maxColor = color
		end
	end
	local pairNum = 0
	for k,v in pairs(temp) do
		if v >= 2 then
			pairNum = pairNum + 1
		end
	end
	if pairNum >= 1 then
		return true,{{d=maxDigit},{c=maxColor}}
	end
	return false
end
--单只
function badCards(cards)
	local maxDigit = 0
	local maxColor = 5
	for i = 1,#cards do
		local digit,color = num2DigitColor(cards[i])
		if compareDigit(digit,maxDigit) > 0 and
			compareColor(color,maxColor) > 0 then
			maxDigit = digit
			maxColor = color
		end
	end
	return true,{{d=maxDigit},{c=maxColor}}
end
