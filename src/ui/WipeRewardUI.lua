module(..., package.seeall)
setmetatable(_M, {__index = Control})


function new()
	local ctrl = Control.new(require("res/common/WipeRewardSkin"), {"res/common/WipeReward.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	return ctrl
end

function uiEffect()
	return UIManager.THIRD_TEMP
end

function init(self)
	self:addArmatureFrame("res/common/effect/complete/Complete.ExportJson")
	_M.touch = Common.outSideTouch
	Common.setLabelCenter(self.txtleveltitle)
	self.confirm:addEventListener(Event.Click,function() 
		self:dispatchEvent(Event.Confirm,{etype = Event.Confirm_close})
		UIManager.removeUI(self)
	end)
end


function refreshReward(self,title,wipeList)
	local master = Master.getInstance()
	self.txtleveltitle:setString(title)
	self.wipelist:setItemNum(0)
	self.wipelist:setBgVisiable(false)
	for i,v in ipairs(wipeList) do
		local reward = v.reward
		local lvTitile = v.title or "第"..i.."次" 
		local no = self.wipelist:addItem()
		local item = self.wipelist.itemContainer[no]
		item.txtno:setString(lvTitile)
		local r = {}
		for _,rr in ipairs(reward.reward) do 
			r[rr.rewardName] = rr.cnt
		end
		if r.money then
			item.txtmoney:setString("获得银币："..r.money)
			r.money = nil
		else
			item.txtmoney:setString("")
		end
		if reward.charLvPercent then
			item.expprog:setPercent(reward.charLvPercent)
		else
			item.expprog:setVisible(false)
			item.back:setVisible(false)
		end
		if reward.charLv then
			item.txtlv:setString('lv'..reward.charLv)
		else
			item.txtlv:setVisible(false)
		end
		if r.charExp then
			item.txtexp:setString("获得战队经验："..r.charExp)
			r.charExp = nil
		else
			item.txtexp:setString("")
		end
		r.heroExp = nil   -- 此处有点问题，UI上没有位置显示英雄经验
		local i = 0
		for n,rr in pairs(r) do 
			local itemId = tonumber(n)
			i = i + 1
			CommonGrid.bind(item['wipegrid'..i],true)
			item['wipegrid'..i]:setItemIcon(itemId,'mIcon')
			item['wipegrid'..i]:setItemNum(rr)
		end
		if i < 5 then
			for j=i+1,5 do
				CommonGrid.bind(item['wipegrid'..j])
				item['wipegrid'..j]:setItemIcon()
			end
		end
	end
	Common.setBtnAnimation(self._ccnode,"Complete",'wipe')
end





