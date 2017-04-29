module(..., package.seeall)

function heroDistance(heroA, heroB)
    --[[
	local x,y = heroA:getPosition()
	local size = heroA:getContentSize()
	local ao = {x = x + size.width / 2, y = y + size.height / 2}
	--print('================A,x,y:',x,y)

	x,y = heroB:getPosition()
	size = heroB:getContentSize()
	local bo = {x = x + size.width / 2, y = y + size.height / 2}
	--print('================B,x,y:',x,y)

	return math.sqrt((bo.x-ao.x)*(bo.x-ao.x) + (bo.y-ao.y)*(bo.y-ao.y))
	--]]
	local xa,ya = heroA:getPosition()
	local xb,yb = heroB:getPosition()
	--print('=====================xa,ya,xb,yb:',xa,ya,xb,yb)
	--return math.sqrt((xa - xb)*(xa - xb) + (ya - yb)*(ya - yb))
	return math.abs(xa - xb)
end

--[[
function collideDistance(heroA,heroB)
    local sizeA = heroA:getContentSize()
    local sizeB = heroB:getContentSize()
    --print('======================A,width,height:',sizeA.width,sizeA.height)
    --print('======================B,width,height:',sizeB.width,sizeB.height)
    return (sizeA.width + sizeB.width) / 2 - 5,(sizeA.height + sizeB.height) / 2 - 5
end

function isCollide(heroA,heroB)
	do
		return false
	end
    local dis = heroDistance(heroA,heroB)
    local w,h = collideDistance(heroA,heroB)
    --print('============================dis,w,h:',dis,w,h)
    return dis < w - 15 and dis < h - 15
end
--]]

--[[
假定矩形是用一对点表达的(minx,miny)(maxx,   maxy) 
那么两个矩形rect1{(minx1,miny1)(maxx1,   maxy1)},   rect2{(minx2,miny2)(maxx2,   maxy2)} 

相交的结果一定是个矩形，构成这个相交矩形rect{(minx,miny)(maxx,   maxy)}的点对坐标是： 
minx   =   max(minx1,   minx2) 
miny   =   max(miny1,   miny2) 
maxx   =   min(maxx1,   maxx2) 
maxy   =   min(maxy1,   maxy2) 

如果两个矩形不相交，那么计算得到的点对坐标必然满足 
minx   >   maxx 
或者 
miny   >   maxy 
--]]
function isIntersect(rectA,rectB)
	local minx = math.max(rectA.x,rectB.x)
	local miny = math.max(rectA.y,rectB.y)
	local maxx = math.min(rectA.x + rectA.width,rectB.x + rectB.width)
	local maxy = math.min(rectA.y + rectA.height,rectB.y + rectB.height)
	return minx <= maxx and miny <= maxy,minx,miny,maxx,maxy
end

function isPushCollide(heroA,heroB,dx)
	if heroA:getPenetrate() or heroB:getPenetrate() then
		return false
	end
	dx = dx or 0
	local rectA = heroA:getBodyBoxReal()
	rectA.x = rectA.x + dx
	rectA.width = rectA.width - 2 * dx
	rectA.y = rectA.y + 25
	rectA.height = rectA.height - 50

	local rectB = heroB:getBodyBoxReal()
	rectB.x = rectB.x + dx
	rectB.width = rectB.width - 2 * dx
	rectB.y = rectB.y + 25
	rectB.height = rectB.height - 50

	return isIntersect(rectA,rectB)

	--[[
	local minx = math.max(rectA.x,rectB.x)
	local miny = math.max(rectA.y,rectB.y)
	local maxx = math.min(rectA.x + rectA.width,rectB.x + rectB.width)
	local maxy = math.min(rectA.y + rectA.height,rectB.y + rectB.height)
	print('--------------rectA,x,y,width,height:',rectA.x,rectA.y,rectA.width,rectA.height)
	print('--------------rectB,x,y,width,height:',rectB.x,rectB.y,rectB.width,rectB.height)
	print('----------------------------isPushCollide,minx,miny,maxx,maxy:',minx,miny,maxx,maxy)
	return minx <= maxx and miny <= maxy
	--]]
end

function isAttackCollide(heroA,heroB)
	local rectA = heroA:getBodyBoxReal()
	rectA.x = rectA.x + 40
	rectA.width = rectA.width - 80
	rectA.y = rectA.y + 40
	rectA.height = rectA.height - 80

	local rectB = heroB:getBodyBoxReal()
	rectB.x = rectB.x + 40
	rectB.width = rectB.width - 80
	rectB.y = rectB.y + 40
	rectB.height = rectB.height - 80

	return isIntersect(rectA,rectB)
end







----------------------------init config-----------------------------------

function split(str)
	local res = {}
	local splitlist = {}
	string.gsub(str, '[^,]+', function(w) table.insert(splitlist, w) end )

	for k,v in pairs(splitlist) do
		local index = string.find(v,"-")
		if index then
			local a = tonumber(string.sub(v,1,index-1))
			local b = tonumber(string.sub(v,index+1))
			for n=a,b do
				table.insert(res,n)
			end
		else
			table.insert(res,tonumber(v))
		end
	end
	return res	
end

function createTable(t)
	local res = {}
	local cnt = 0
	for k,v in pairs(t) do
		if type(k) == "string" then
			--print('------------------------------K:',k)
			local ret = split(k)
			for _,frame in ipairs(ret) do
				--print('-------------------frame:',frame)
				--t[frame] = v
				res[frame] = v
				cnt = cnt + 1
			end
			--t[k] = nil
		else
			--print('===================k,type:',k,type(k))
			res[k] = v
			cnt = cnt + 1
		end
	end
	res.cnt = cnt
	return res
end

function initHeroConfig(config)
	for _,v in pairs(config) do
		--print('------------------------skill:',k)
		v.hitEvent = createTable(v.hitEvent)
		v.noHitEvent = createTable(v.noHitEvent)
	end
end


----------------------------------------creae effect -------------------------------------------
function createComboHit(num)
	num = tostring(num)
	local node = cc.Node:create()
	local w = 0
	local h = 0
	local sp = cc.Sprite:createWithSpriteFrameName("combo_hit_rush.png")
	sp:setAnchorPoint(cc.p(0,0.5))
	sp:setPosition(cc.p(w,0))
	node:addChild(sp)
	w = sp:getContentSize().width + w
	h = math.max(h,sp:getContentSize().height)

	for k = 1,#num do
		local n = num:sub(k,k)
		if n == "." then
			break
		end
		local sp = cc.Sprite:createWithSpriteFrameName("combo_hit_num".. n .. ".png")
		sp:setAnchorPoint(cc.p(0,0.5))
		sp:setPosition(cc.p(w,0))
		node:addChild(sp)
		w = sp:getContentSize().width + w
		h = math.max(h,sp:getContentSize().height)
	end

	local sp = cc.Sprite:createWithSpriteFrameName("combo_hit_hits.png")
	sp:setAnchorPoint(cc.p(0,0.5))
	sp:setPosition(cc.p(w,0))
	node:addChild(sp)
	w = sp:getContentSize().width + w
	h = math.max(h,sp:getContentSize().height)

	node:setContentSize(cc.size(w,h))
	node:setScale(0.8)


	return node
end

local comboAddCnt
function createComboAdd(num)
	local seq
	if comboAddCnt ~= num then
		comboAddCnt = num 
		local scaleBy = cc.ScaleBy:create(0.08,3)
		seq = cc.Sequence:create(
			scaleBy,
			scaleBy:reverse()
		)
	end
	num = tostring(num * 100)
	local node = cc.Node:create()
	local w = 0
	local h = 0
	local sp = cc.Sprite:createWithSpriteFrameName("combo_add.png")
	sp:setAnchorPoint(cc.p(0,0.5))
	sp:setPosition(cc.p(w,0))
	node:addChild(sp)
	w = sp:getContentSize().width + w 
	h = math.max(h,sp:getContentSize().height)

	for k = 1,#num do
		local n = num:sub(k,k)
		if n == "." then
			break
		end
		local sp = cc.Sprite:createWithSpriteFrameName("combo_add".. n .. ".png")
		sp:setAnchorPoint(cc.p(0.5,0.5))
		sp:setPosition(cc.p(w,0))
		node:addChild(sp)
		w = sp:getContentSize().width + w
		h = math.max(h,sp:getContentSize().height)
		if seq then
			sp:runAction(seq:clone())
		end
	end

	w = w - 10
	local sp = cc.Sprite:createWithSpriteFrameName("combo_add%.png")
	sp:setAnchorPoint(cc.p(0,0.5))
	sp:setPosition(cc.p(w,0))
	node:addChild(sp)
	w = sp:getContentSize().width + w
	h = math.max(h,sp:getContentSize().height)

	node:setContentSize(cc.size(w,h))
	return node
end

--no use never
function createDecHp(num)
	local fadeOut = cc.FadeOut:create(0.33)
	local node = cc.Node:create()
	node:setAnchorPoint(cc.p(0.5,0.5))
	local w = 0
	local h = 0
	local sp = cc.Sprite:createWithSpriteFrameName("x-.png")
	sp:setAnchorPoint(cc.p(0,0))
	sp:setPosition(cc.p(w,0))
	node:addChild(sp)
	sp:runAction(fadeOut)
	w = sp:getContentSize().width + w
	h = math.max(h,sp:getContentSize().height)

	local first = true
	for k = 9,1,-1 do
		local base = 10^k
		local n = math.floor(num % base / (base / 10))
		if n == 0 and first and k > 1 then
		else
			first = false
			local sp = cc.Sprite:createWithSpriteFrameName("x".. n .. ".png")
			sp:setAnchorPoint(cc.p(0,0))
			sp:setPosition(cc.p(w,0))
			node:addChild(sp)
			sp:runAction(fadeOut:clone())
			w = sp:getContentSize().width + w
			h = math.max(h,sp:getContentSize().height)
		end
	end

	node:setContentSize(cc.size(w,h))
	return node
end

function createFightEffect(name,num,txtName)
	num = tostring(num)
	--[[
		fe_bj	暴击
		fe_gd	格档
		fe_jx	加血
		fe_nq	怒气
		fe_zygj	增益攻击
		fe_zhgj	召唤攻击
		fe_kx	扣血
		fe_pz	破招
	--]]
	--local fadeOut = cc.FadeOut:create(0.2)
	--local delayTime = cc.DelayTime:create(0.2)
	--local seq = cc.Sequence:create(delayTime,fadeOut)
	local node = cc.Node:create()
	local w = 0
	local h = 0
	local sp = cc.Sprite:createWithSpriteFrameName((txtName or name) .. ".png")
	sp:setAnchorPoint(cc.p(0,0.5))
	sp:setPosition(cc.p(w,0))
	node:addChild(sp)
	--sp:runAction(seq)
	w = sp:getContentSize().width + w
	h = math.max(h,sp:getContentSize().height)

	for k = 1,#num do
		local n = num:sub(k,k)
		if n == "." then
			break
		end
		local sp = cc.Sprite:createWithSpriteFrameName(name .. n .. ".png")
		sp:setAnchorPoint(cc.p(0,0.5))
		sp:setPosition(cc.p(w,0))
		node:addChild(sp)
		--sp:runAction(seq:clone())
		w = sp:getContentSize().width + w
		h = math.max(h,sp:getContentSize().height)
	end

	node:setContentSize(cc.size(w,h))
	node:setAnchorPoint(cc.p(0.5,0.5))
	node:setCascadeOpacityEnabled(true)
	node:setCascadeColorEnabled(true)
	return node
end

function createAssistEffect(assistType)
	local assistEffectTable = {
		atk = "assist_decHp",
		hp = "assist_addHp",
		hpR = "assist_addHp",
		rageA = "assist_addPower",
		rageD = "assist_decPower",
		atkBuf = "assist_addAtk",
		timeA = "assist_addTime",
		timeD = "assist_addTime"
	}
	local sp = Sprite.createWithSpriteFrameName(assistEffectTable[assistType] or "assist_decHp","assistEffect")
	sp:setAnchorPoint(cc.p(0,0))

	local fadeIn= cc.FadeIn:create(0.33)
	local delayTime = cc.DelayTime:create(1)
	local fadeOut = cc.FadeOut:create(0.33)
	local callback = cc.CallFunc:create(function() 
		sp:removeFromParent()
	end)

	sp:runAction(cc.Sequence:create(
		fadeIn,
		delayTime,
		fadeOut,
		callback
	))
	return sp 
end

function createVipCopyEffect(addType,value)
	value = tostring(value)
	local node = cc.Node:create()
	local w = 0
	local h = 0
	local sp = cc.Sprite:createWithSpriteFrameName("vip_copy1.png")
	sp:setAnchorPoint(cc.p(0,0.5))
	sp:setPosition(cc.p(w,0))
	node:addChild(sp)
	w = sp:getContentSize().width + w
	h = math.max(h,sp:getContentSize().height)

	local sp = cc.Sprite:createWithSpriteFrameName("vip_copy2.png")
	sp:setAnchorPoint(cc.p(0,0.5))
	sp:setPosition(cc.p(w + 15,0))
	node:addChild(sp)
	w = sp:getContentSize().width + w + 15
	h = math.max(h,sp:getContentSize().height)

	for k = 1,#value do
		local n = value:sub(k,k)
		if n == "." then
			break
		end
		local sp = cc.Sprite:createWithSpriteFrameName("combo_add" .. n .. ".png")
		sp:setAnchorPoint(cc.p(0,0.5))
		sp:setPosition(cc.p(w,0))
		node:addChild(sp)
		w = sp:getContentSize().width + w
		h = math.max(h,sp:getContentSize().height)
	end

	node:setContentSize(cc.size(w,h))
	node:setAnchorPoint(cc.p(0,0.5))
	node:setCascadeOpacityEnabled(true)
	node:setCascadeColorEnabled(true)
	return node
end
