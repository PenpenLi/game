module(..., package.seeall)
setmetatable(_M, {__index = Control})

function onGet(self,id)
end

function getDataList(self)
	return {}
end

function refreshItem(self, data)
	local num = self.targetList:addItem()
	local item = self.targetList:getItemByNum(num)
	self:setItemIcon(item,data.iconId)
	self:setItemContent(item,data.title,data.content)
	self:setItemReward(item,data.reward,data.itemNum)
	self:setItemProgress(item,data.id,data.hasFinish , data.progressStr,data.canGo)

	if data.hasFinish and data.id == 1015 then
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=item, step = 2, delayTime = 0, groupId = GuideDefine.GUIDE_TASK, noDelayFun = function()
				self.targetList:showTopItem(item.num)
			end
		})
	end
end

function refreshTimeItem(self, data)
	local item = self.achieveList:getItemByNum(self.achieveList:addItem())
	item.data = data
	self:setItemIcon(item,data.iconId)
	self:setItemContent(item,data.title,data.content)
	self:setItemReward(item,data.reward,data.itemNum)
	self:setTimeItemProgress(item,data.id,data.hasFinish , data.progressStr,data.canGo,data.hasCanDo,data.hasCanJoin,data.hasExpired,data.time)
	self:setTimeIcon(item,data.hasOdds,data.hasFinish,data.hasCanJoin,data.taskSecond,data.hasExpired)

end

function setTimeIcon(self,item,hasOdds,hasFinish,hasCanJoin,taskSecond, hasExpired)
	if hasOdds then 
		item.tianjiangicon:setVisible(true)
		item.timelimitTxt:setVisible(false)
	else
		item.tianjiangicon:setVisible(false)
		item.timelimitTxt:setString(string.format("任务限时:%d分%d秒",math.floor(taskSecond/60),taskSecond%60))
		item.timelimitTxt:setVisible(true)
	end 

	if hasExpired or hasFinish then 
		item.timelimitTxt:setVisible(false)
	end
end

function setItemIcon(self,item,iconId)
	CommonGrid.bind(item.gridCon)
	item.gridCon:setIcon('item/120/' .. iconId) 
	item.gridCon._icon:setScale(0.8)
	item.gridCon:setIconCenter()
end


function setItemContent(self,item,title,content)
	item.contentTxt:setString(title)
	item.titleTxt:setString(content)
end

function setItemReward(self,item,reward,itemNum)
	if reward then
		local list = {}
		for k,v  in pairs(reward) do
			if type(k) == 'number' then
				list[#list+1] = {itemId=k,num=v[1]}
			elseif k == "money" then
				list[#list+1] = {mType="money",num=v[1]}
			elseif k == "rmb" then
				list[#list+1] = {mType="rmb",num=v[1]}
			end
		end
		for i=1,3 do
			local grid = item["g" .. i]
			local reward = list[i]
			if reward then
				if reward.itemId then
					CommonGrid.bind(grid.icon)
					grid.icon:setItemIcon(reward.itemId,"",23)
					--grid.icon:setScale(0.4)
					--local size = grid.icon:getPosition()
					--grid.icon:setPosition()
					--grid.icon._icon:setScale(0.5)
				else
					CommonGrid.setCoinIcon(grid.icon,reward.mType)
					grid.icon:setScale(0.9)
				end
				if itemNum then
					reward.num = itemNum
				end
				grid.num:setString(string.format("X%d",reward.num))
			else
				grid:setVisible(false)
			end
		end
	end
end

function setTimeItemProgress(self,item, id , hasFinish ,progressStr,canGo,hasCanDo,hasCanJoin,hasExpired,time)
	item.go.touchParent = false
	item.go:setVisible(false)
	item.get:setVisible(false)
	item.got:setVisible(false)
	item.doingTxt:setVisible(false)
	item.ysxicon:setVisible(false)
	item.timelimitTxt:setVisible(false)
	item.countTxt:setDimensions(item.countTxt:getContentSize().width, 0)
	item.countTxt:setHorizontalAlignment(Label.Alignment.Right)
	item.timelimitTxt:setColor(200,0,0)
	item.taskId = id
	--Common.setLabelCenter(item.countTxt)
	if progressStr == "" then
		item.countTxt:setString("")
	else
		item.countTxt:setString(progressStr)  
	end

	if hasExpired then
		item.ysxicon:setVisible(true)
	elseif hasFinish then
		item.get:setVisible(true)
		item.countTxt:setVisible(false)
		item:addEventListener(Event.TouchEvent, function(self, evt) 
			if evt.etype == Event.Touch_ended then
				self:onGet(id, evt) 
			end
		end, self)
	elseif hasCanDo then
		item.timelimitTxt:setVisible(true)
		item.go:setVisible(true)
		item.go:addEventListener(Event.TouchEvent, function(self, evt) 
			if evt.etype == Event.Touch_ended then
				self:onGo(id, evt) 
			end
		end, self)
	else 
		item.got:setVisible(true)
			item.got:addEventListener(Event.TouchEvent, function(self, evt) 
				if evt.etype == Event.Touch_ended then
					self:onJoin(id, evt) 
				end
			end, self)
	end
	if time then 
		item.time = time
		item.timelimitTxt:setString(string.format("任务限时:%d分%d秒",math.floor(item.time/60),item.time%60))
	end 
end

function setItemProgress(self,item, id , hasFinish ,progressStr,canGo)
	item.go.touchParent = false
	item.go:setVisible(false)
	item.countTxt:setDimensions(item.countTxt:getContentSize().width, 0)
	item.countTxt:setHorizontalAlignment(Label.Alignment.Right)
	--Common.setLabelCenter(item.countTxt)
	if hasFinish then
		item.get:setVisible(true)
		item.countTxt:setVisible(false)
		item:addEventListener(Event.TouchEvent, function(self, evt) 
			if evt.etype == Event.Touch_ended then
				self:onGet(id, evt) 
			end
		end, self)
	else
		item.get:setVisible(false)
		if canGo then
			item.go:setVisible(true)
			item.go:addEventListener(Event.TouchEvent, function(self, evt) 
				if evt.etype == Event.Touch_ended then
					self:onGo(id, evt) 
				end
			end, self)
		end
		if progressStr == "" then
			item.countTxt:setString("")
		else
			item.countTxt:setString(progressStr)  
		end
	end
end

function refresh(self)
	self.targetList:removeAllItem()
	self.dataList = self:getDataList()
	self.dataLen = #self.dataList
	self.curIndex = 1
	if self.dataLen > 0 then 
		self.nullText:setVisible(false)
	else 
		self.nullText:setVisible(true)
	end 
end


function refreshTime(self)
	self.achieveList:removeAllItem()
	self.dataList = self:getDataList()
	self.dataLen = #self.dataList
	self.curIndex = 1
end




