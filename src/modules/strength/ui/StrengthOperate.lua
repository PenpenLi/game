module("StrengthOperate",package.seeall)
setmetatable(_M,{__index = Control})
local StrengthDefine = require("src/modules/strength/StrengthDefine")
local Hero = require("src/modules/hero/Hero")
local StrengthLogic = require("src/modules/strength/StrengthLogic")
local ItemConfig = require("src/config/ItemConfig").Config
local BagData = require("src/modules/bag/BagData")
local HeroDefine = require("src/modules/hero/HeroDefine")
local MaterialConfig = require("src/config/StrengthMaterialConfig").Config
local Chapter = require("src/modules/chapter/Chapter")
local ChapterDefine = require("src/modules/chapter/ChapterDefine")
local Def = require("src/modules/hero/HeroDefine")
local PublicLogic = require("src/modules/public/PublicLogic")
local ComposeChain = ComposeChain or {}
local AccessChain = AccessChain or {}
local BannerNum = 4
local GridNum = 2

function new(state,heroName,cellPos,gridPos)
	local ctrl = Control.new(require("res/strength/StrengthOperateSkin"),{"res/strength/StrengthOperate.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(state,heroName,cellPos,gridPos)
	return ctrl
end

function uiEffect()
	return UIManager.THIRD_TEMP
end

function init(self,state,heroName,cellPos,gridPos)
	self:addArmatureFrame("res/strength/effect/compose/StrengthCompose.ExportJson")
	self:addArmatureFrame("res/partner/effect/PartnerGrid.ExportJson")
	self:setAnchorPoint(0.5,0.5)
	--self.operate:setAnchorPoint(-0.5,0)
	--self.operatePosX = self.operate:getPositionX()
	--self.operate:setPositionX(self.operatePosX+50)
	local hero = Hero.heroes[heroName]
	local strength = hero.strength
	local cell = strength.cells[cellPos]
	local grid = cell.grids[gridPos]
	local cfg = StrengthLogic.getStrengthConfig(heroName,cellPos)
	local need 
	--if StrengthLogic.isFirstLv(hero.strength,cellPos) then
	if cell.lv <= strength.transferLv and not StrengthLogic.isMaxLv(strength,cellPos) then
		need = cfg.lvCfg[cell.lv+1].need
	else
		need = cfg.lvCfg[cell.lv].need
	end
	self.itemId = need[gridPos]
	self.hero = hero
	self.cell = cell
	self.grid = grid
	self:initOperateView(state)
	self:initAccessView()
	self:initComposeView()
	if #self.chain == 1 then
		self.compose:setVisible(false)
		self.access:setPositionX(270)
		ComposeChain = {[1] = self.itemId}
		self:refreshAccessView()
	end
	self:setEventHandler(heroName,cellPos,gridPos)
end

_M.touch = function(self,event)
	Common.outSideTouch(self,event)
end

function initOperateView(self,state)
	local operateView = self.operate
	self:setOperateView(state)
	CommonGrid.bind(operateView.headBG)
	operateView.headBG:setItemIcon(self.itemId,"descIcon")
	local item = ItemConfig[self.itemId]
	operateView.txtname:setString(item.name)
	local num = BagData.getItemNumByItemId(self.itemId)
	operateView.txtnum:setString(num)
	operateView.txtdesc:setString(string.format("需要英雄等级：%d",item.lv))
	operateView.txtdesc:setAnchorPoint(0.5,0)
	operateView.txtsm:setDimensions(self.operate.xbt6:getContentSize().width-20,0)
	operateView.txtsm:setString(item.extraDesc)
	local adjustY = operateView.txtsm:getContentSize().height-15
	operateView.txtsm:setPositionY(operateView.txtsm:getPositionY()-adjustY)
	local cfg = MaterialConfig[self.itemId]
	if cfg then
		for k,v in pairs(cfg.attr) do
			operateView.txtattr:setString(HeroDefine.DyAttrCName[k])
			--operateView.txtattr:setAnchorPoint(0.5,0)
			operateView.txtval:setString("+"..v)
			operateView.txtval:setPositionX(operateView.txtattr:getPositionX()+operateView.txtattr:getContentSize().width)
			break
		end
	end
end

function initAccessView(self)
	local accessView = self.access
	CommonGrid.bind(accessView.headBG)
	accessView.headBG:setItemIcon(self.itemId,"descIcon")
	local item = ItemConfig[self.itemId]
	accessView.txtname:setString(item.name)
	local num = BagData.getItemNumByItemId(self.itemId)
	accessView.txtnum:setString(num)
	accessView.chapterlist:setBgVisiable(false)

	--local function onBannerClick(self,event,target)
	--	if event.etype == Event.Touch_ended then
	--		if target.id < #AccessChain then
	--			for i = #AccessChain,target.id+1,-1 do
	--				AccessChain[i] = nil
	--			end
	--			ComposeChain = Common.deepCopy(AccessChain)
	--			self:refreshComposeView()
	--		end
	--	end
	--end
	--local accessView = self.access
	--accessView.chapterlist:setBgVisiable(false)
	--accessView:setVisible(false)
	--for i = 1,BannerNum do
	--	setPathGridState(self.access["banner"..i],"null")
	--	accessView["banner"..i].id = i
	--	CommonGrid.bind(accessView["banner"..i].bg)
	--	accessView["banner"..i]:addEventListener(Event.TouchEvent,onBannerClick,self)
	--end
end

function initComposeView(self)
	local function onGridClick(self,event,target)
		if event.etype == Event.Touch_ended then
			--if StrengthLogic.checkCanCompose(traget.id,i) then
			--if MaterialConfig[target.id] and next(MaterialConfig[target.id].need) then
			--	table.insert(ComposeChain,target.id)
			--	self:refreshComposeView()
			--else
			--	AccessChain = Common.deepCopy(ComposeChain)
			--	table.insert(AccessChain,target.id)
			--	self:refreshAccessView()
			--end
			local list = self.compose.banner
			local col = list:getItemCount()
			local canFind = false
			for i = 1,col do
				local ctrl = list:getItemByNum(i)
				if ctrl.id == target.id then
					ctrl:dispatchEvent(Event.TouchEvent,{etype = Event.Touch_ended})
					canFind = true
					break
				end
			end
			if not canFind then
				ComposeChain = {[1] = target.id}
				self:refreshComposeViewAtom()
				self:refreshAccessView()
			end
			local composeView = self.compose
			--if composeView.lastAni then
			--	composeView.lastAni:removeFromParent()
			--end
			--composeView.lastAni = Common.setBtnAnimation(target.jnBG._ccnode,"PartnerGrid","1")
			--composeView.lastAni:setScale(0.75)
		end
	end
	local function onBannerClick(self,event,target)
		if event.etype == Event.Touch_ended then
			ComposeChain = {[1] = target.id}
			self:refreshComposeView()
			self:refreshAccessView()
			local list = self.compose.banner
			local col = list:getItemCount()
			for i = 1,col do
				local ctrl = list:getItemByNum(i)
				ctrl.light:setVisible(false)
			end
			target.light:setVisible(true)
		end
	end

	local function onCompose(self,event,target)
		local itemId = ComposeChain[#ComposeChain]
		Network.sendMsg(PacketID.CG_MATERIAL_COMPOSE,itemId)
	end
	local composeView = self.compose
	--composeView:setVisible(false)
	--for i = 1,BannerNum do
	--	composeView["banner"..i].id = i
	--	CommonGrid.bind(composeView["banner"..i].bg)
	--	composeView["banner"..i]:addEventListener(Event.TouchEvent,onBannerClick,self)
	--end
	local item = ItemConfig[self.itemId]
	local group = getComposeChain({self.itemId})
	self.chain = group
	local col = #group
	local list = composeView.banner
	list:setDirection(List.UI_LIST_HORIZONTAL)
	list:setBgVisiable(false)
	list:removeAllItem()
	list:setItemNum(col)
	for i = 1,col do
		local ctrl = list:getItemByNum(i)
		CommonGrid.bind(ctrl.bg)
		ctrl.bg:setItemIcon(group[i])
		ctrl.light:setVisible(false)
		ctrl.id = group[i]
		ctrl.i = i
		ctrl:addEventListener(Event.TouchEvent,onBannerClick,self)
		if i == col then
			ctrl.arrow:setVisible(false)
		end
	end
	
	CommonGrid.bind(composeView.gridTop.jnBG)
	composeView.gridTop:addEventListener(Event.TouchEvent,onGridClick,self)
	for i = 1,2 do
		CommonGrid.bind(composeView["grid"..i].jnBG)
	end
	composeView["grid1"]:addEventListener(Event.TouchEvent,onGridClick,self)
	--for i = 1,3 do
	--	CommonGrid.bind(composeView["grid"..i].jnBG)
	--	composeView["grid"..i]:addEventListener(Event.TouchEvent,onGridClick,self)
	--end
	composeView.composeBtn:addEventListener(Event.Click,onCompose,self)
	composeView.composeAuto:addEventListener(Event.Click,onCompose,self)
	local function onAccess(self,event,target)
		local list = self.access.chapterlist
		local ctr = list:getItemByNum(1)
		if ctr then
			ctr:dispatchEvent(Event.TouchEvent,{etype = Event.Touch_ended})
		end
	end
	composeView.access:addEventListener(Event.Click,onAccess,self)
	if #self.chain > 1 then
		composeView.banner:getItemByNum(1):dispatchEvent(Event.TouchEvent,{etype = Event.Touch_ended})
	end
	composeView.back:setVisible(false)
end

function setComposeViewBtn(self,name)
	local composeView = self.compose
	composeView.confirm:setVisible(false)
	composeView.equip:setVisible(false)
	composeView.access:setVisible(false)
	composeView.compose:setVisible(false)
	composeView.composeBtn:setVisible(false)
	composeView.composeAuto:setVisible(false)
	if composeView[name] then
		composeView[name]:setVisible(true)
	end
end

function setPathGridState(grid,state)
	grid.light:setVisible(false)
	grid.bg:setVisible(false)
	grid.arrow:setVisible(false)
	if state == "last" then
		grid.light:setVisible(true)
		grid.bg:setVisible(true)
	elseif state == "mid" then
		grid.arrow:setVisible(true)
		grid.bg:setVisible(true)
	end
end

function setEventHandler(self,heroName,cellPos,gridPos)
	local function onEquip(self,event,target)
		Network.sendMsg(PacketID.CG_STRENGTH_EQUIP,heroName,cellPos,gridPos)
		--UIManager.removeUI(self)

		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_POWER, step = 5})
	end
	self.operate.equip:addEventListener(Event.Click,onEquip,self)
	self.compose.equip:addEventListener(Event.Click,onEquip,self)
	local function onConfirm(self,event,target)
		UIManager.removeUI(self)
	end
	self.operate.confirm:addEventListener(Event.Click,onConfirm,self)
	--local function onAccess(self,event,target)
	--	AccessChain = {self.itemId}
	--	self:refreshAccessView()
	--	self.operate:setAnchorPoint(0,0)
	--	self.operate:setPositionX(self.operatePosX)
	--	self.compose:setVisible(false)
	--end
	--self.operate.access:addEventListener(Event.Click,onAccess,self)
	--local function onAccessBack(self,event,target)
	--	if self.compose:isVisible() then
	--		--AccessChain[#AccessChain] = nil
	--		--ComposeChain[#ComposeChain] = nil
	--		self:refreshComposeView()
	--	else
	--		UIManager.removeUI(self)
	--	end
	--end
	--self.access.back:addEventListener(Event.Click,onAccessBack,self)
	--local function onComposePath(self,event,target)
	--	self.compose:setVisible(true)
	--	ComposeChain = {self.itemId}

	--	local flag,n = self:refreshComposeView()
	--	if flag then
	--		self.compose["grid"..n]:dispatchEvent(Event.TouchEvent,{etype=Event.Touch_ended})
	--	end

	--	self.operate:setAnchorPoint(0,0)
	--	self.operate:setPositionX(self.operatePosX)
	--	self:setOperateView(StrengthDefine.GRID_STATE.noActive)
	--end
	--self.operate.compose:addEventListener(Event.Click,onComposePath,self)
	--local function onComposeBack(self,event,target)
	--	UIManager.removeUI(self)
	--end
	--self.compose.close:addEventListener(Event.Click,onComposeBack,self)
			
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.operate.equip, addFinishFun = function()
		local hero = Hero.getHero(heroName)
		local strength = hero.strength
		if strength.cells[1].grids[1].id > 0 or BagData.getItemNumByItemId(1701001) == 0 then
			UIManager.removeUI(self)
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_POWER, step = 5})
		end
	end,step = 5, delayTime = 0.35, groupId = GuideDefine.GUIDE_POWER})
end

function refreshComposeViewAtom(self)
	local composeView = self.compose
	local itemIds = ComposeChain
	local lastId = itemIds[#itemIds]
	local item = ItemConfig[lastId]
	composeView.gridTop.txtdesc:setString(string.format("需要英雄等级：%d",item.lv))
	composeView.gridTop.txtattr:setString(item.desc)
	composeView.gridTop.txtval:setVisible(false)
	composeView.gridTop.txtname:setString(item.name)
end

function refreshComposeView(self)
	local composeView = self.compose
	--if #ComposeChain < 0 then
	--	return false
	--end
	local itemIds = ComposeChain
	local lastId = itemIds[#itemIds]
	local item = ItemConfig[lastId]

	composeView.gridTop.jnBG:setItemIcon(lastId)
	composeView.gridTop.id = lastId

	if composeView.lastAni then
		composeView.lastAni:removeFromParent()
	end
	composeView.lastAni = Common.setBtnAnimation(composeView.gridTop.jnBG._icon,"PartnerGrid","1")
	composeView.lastAni:setScale(0.75)

	local need = MaterialConfig[lastId].need
	local flag = false
	local n = 1
	local index = 1
	if need and next(need) then
		composeView.gridTop:setVisible(true)
		composeView.arrow2:setVisible(true)
		composeView.txthf:setVisible(true)
		composeView.grid1:setVisible(true)
		composeView.jbbicon:setVisible(true)
		composeView.grid2:setVisible(false)
		local cost = composeCost(human,lastId)
		local itemCfg = ItemConfig[lastId]
		composeView.gridTop.txtname:setString(itemCfg.name)
		composeView.gridTop.txtdesc:setString(string.format("需要英雄等级：%d",item.lv))
		composeView.gridTop.txtattr:setString(item.desc)
		composeView.gridTop.txtval:setVisible(false)
		composeView.cost:setString(cost)
		for k,v in pairs(need) do
			composeView["grid1"].id= k
			composeView["grid1"].jnBG:setItemIcon(k)
			composeView["grid1"].txtname:setString(ItemConfig[k].name)
			local num = BagData.getItemNumByItemId(k)
			composeView["grid1"].num:setString(num .. "/" .. v)
			if num < v then
				flag = true
				n = index
				composeView["grid1"].num:setColor(255,0,0)
			else
				composeView["grid1"].num:setColor(255,255,255)
			end
			break
		end
	else
		composeView.gridTop:setVisible(false)
		composeView.arrow2:setVisible(false)
		composeView.jbbicon:setVisible(false)
		composeView.cost:setString("")
		composeView.txthf:setVisible(false)
		composeView.grid1:setVisible(false)
		composeView.grid2:setVisible(true)
		composeView.grid2.jnBG:setItemIcon(lastId)
		local num = BagData.getItemNumByItemId(lastId)
		composeView.grid2.num:setString("")
		composeView.grid2.txtattr:setString(item.desc)
		composeView.grid2.txtname:setString(item.name)
		composeView.grid2.txtdesc:setString(string.format("需要英雄等级：%d",item.lv))
		composeView.grid2.txtval:setVisible(false)
		composeView.grid2.zjbg1:setVisible(false)
	end
	if self.chain[1] == lastId and BagData.getItemNumByItemId(lastId) > 0 then
		composeView.jbbicon:setVisible(false)
		composeView.cost:setString("")
		composeView.txthf:setVisible(false)
		setComposeViewBtn(self,"equip")
	else
		local list = self.compose.banner
		local col = list:getItemCount()
		local j
		for i = 1,col do
			local ctrl = list:getItemByNum(i)
			if ctrl.id == lastId then
				j = i 
				break
			end
		end
		local name
		if j >= col then
			name = "access"
		elseif j >= col - 1 then
			name = "composeBtn"
		else
			name = "composeAuto"
		end
		self:setComposeViewBtn(name)
	end
	return flag,n
end

function refreshAccessView(self)
	local accessView = self.access
	local itemIds = ComposeChain
	local lastId = itemIds[#itemIds]

	accessView.headBG:setItemIcon(lastId,"descIcon")
	local item = ItemConfig[lastId]
	accessView.txtname:setString(item.name)
	local num = BagData.getItemNumByItemId(lastId)
	accessView.txtnum:setString(num)


	local function goChapter(self,event,target)
		if event.etype == Event.Touch_ended then
			if target.url == nil and self.txtnotopened:isVisible() then
				Common.showMsg("本关卡尚未开放")
			else
				-- Chapter.sendLevelStart(target.levelId,target.difficulty)
				if target.url then
					if target.lv and Master.getInstance().lv < target.lv then
						Common.showMsg("战队等级达到"..target.lv.."级开放")
					else
						local ui = UIManager.addChildUI(target.url)
						ui:setPositionY(0)
					end
				else
					UIManager.setUIStatus({"diamond"})
					UIManager.addUI('src/modules/chapter/ui/LevelUI',target.chapterId,target.difficulty,target.levelId)
				end
			end
		end
	end
	local levelList = Chapter.getLevelListByReward(lastId)
	local itemList = {}
	local list = self.access.chapterlist
	list:setItemNum(0)
	if #levelList >0 then
		for i,level in ipairs(levelList) do
			local it = {}
			local chapterId = Chapter.getChapterId(level.levelId)
			local chapterTitle = Chapter.getChapterTitle(chapterId)
			local levelTtile = Chapter.getLevelTitle(level.levelId)
			local opened,passed,_ = Chapter.getLevelInfo(level.levelId,level.difficulty)
			it.title = chapterTitle
			it.opened = opened
			local difficultyName = ChapterDefine.DIFFICULTY_NAME[level.difficulty]
			it.content = "("..difficultyName..")"..levelTtile
			it.chapterId = chapterId
			it.levelId = level.levelId
			it.difficulty = level.difficulty
			table.insert(itemList,it)
		end
	end
	local shopList = Shop.getShopListById(lastId)
	if #shopList > 0 then
		for _,src in ipairs(shopList) do
			local source = Def.FRAGSOURCE[src]
			local lv = PublicLogic.getOpenLv(source.module)
			if source.checkFunc and not source.checkFunc(Master.getInstance()) then
			else
				table.insert(itemList,{src=src,title=source.name,content=source.desc,url=source.url,opened = true,lv=lv})
			end
		end
	end
	if not next(itemList) then
	else
		for i,it in ipairs(itemList) do
			local no = list:addItem()
			local item = list:getItemByNum(no)
			Common.setLabelCenter(item.txtchapter,'left')
			item.txtchapter:setString(it.title)
			if it.url == nil then
				if it.opened then
					item.txtnotopened:setVisible(false)
					item:shader()
				else
					item.txtnotopened:setVisible(true)
					item:shader(Shader.SHADER_TYPE_GRAY)
				end
			end
			if it.content then
				item.txtlevel:setString(it.content)
			else
				item.txtlevel:setString()
			end
			item.chapterId = it.chapterId
			item.levelId = it.levelId
			item.difficulty = it.difficulty
			item.url = it.url
			item.lv = it.lv
			item:addEventListener(Event.TouchEvent,goChapter,item)
			if it.url then
				local difficultyName = ChapterDefine.DIFFICULTY_NAME[it.difficulty]
				local diffIcon = Sprite.new('diffIcon',"res/common/icon/fragSource/"..it.src..".png")
				if diffIcon then
					item:addChild(diffIcon)
					local px,py = item.chengjiuBG:getPosition()
					local size = item.chengjiuBG:getContentSize()
					diffIcon:setPosition(px+size.width/2,py+size.height/2)
					diffIcon:setAnchorPoint(0.5,0.5)
					diffIcon:setScale(64/82)
				end
				item.txtnotopened:setString("前往")
			else
				local difficultyName = ChapterDefine.DIFFICULTY_NAME[it.difficulty]
				local diffIcon = Sprite.new('diffIcon','res/chapter/difficultyicon'..it.difficulty..".png")
				if diffIcon then
					item:addChild(diffIcon)
					local px,py = item.chengjiuBG:getPosition()
					local size = item.chengjiuBG:getContentSize()
					diffIcon:setPosition(px+size.width/2,py+size.height/2)
					diffIcon:setAnchorPoint(0.5,0.5)
					diffIcon:setScale(64/82)
				end
			end
		end
	end
end

function refreshOperateView(self)
	local num = BagData.getItemNumByItemId(self.itemId)
	self.operate.txtnum:setString(num)
	local state = StrengthLogic.checkGridState(self.hero,self.grid.id,self.itemId)
	self:setOperateView(state)
end

function setOperateView(self,state)
	local operateView = self.operate
	operateView.confirm:setVisible(false)
	--operateView.compose:setVisible(false)
	operateView.equip:setVisible(false)
	--operateView.access:setVisible(false)
	operateView:setVisible(false)
	self.access:setVisible(false)
	self.compose:setVisible(false)
	if state == StrengthDefine.GRID_STATE.active then
		operateView:setVisible(true)
		operateView.confirm:setVisible(true)
	elseif state == StrengthDefine.GRID_STATE.canActive then
		operateView:setVisible(true)
		operateView.equip:setVisible(true)
		operateView.equip:setState(Button.UI_BUTTON_NORMAL)
		operateView.equip.touchEnabled = true
	elseif state == StrengthDefine.GRID_STATE.noActive then
		operateView:setVisible(true)
		operateView.equip:setVisible(true)
		operateView.equip:setState(Button.UI_BUTTON_DISABLE)
		operateView.equip.touchEnabled = false
	elseif state == StrengthDefine.GRID_STATE.notActive then
		--local levelList = Chapter.getLevelListByReward(self.itemId)
		--if #levelList > 0 then
		--	operateView.access:setVisible(true)
		--else
		--	operateView.compose:setVisible(true)
		--end
		self.access:setVisible(true)
		self.compose:setVisible(true)
	elseif state == StrengthDefine.GRID_STATE.canCompose then
		--operateView.compose:setVisible(true)
		self.access:setVisible(true)
		self.compose:setVisible(true)
	end
	local cfg = ItemConfig[self.itemId]
	if self.hero.lv >= cfg.lv then
		self.compose.gridTop.txtdesc:setColor(64,118,0)
	else
		self.compose.gridTop.txtdesc:setColor(255,0,0)
	end
end

function playEffect(self)
	UIManager.playMusic("compose")
	if self.compose.grid1:isVisible() then
		Common.setBtnAnimation(self.compose.grid1.jnBG._ccnode,"StrengthCompose","middle")
	end
	--if self.compose.grid2:isVisible() then
	--	Common.setBtnAnimation(self.compose.grid1.jnBG._ccnode,"StrengthCompose","left")
	--end
	--if self.compose.grid3:isVisible() then
	--	Common.setBtnAnimation(self.compose.grid1.jnBG._ccnode,"StrengthCompose","right")
	--end
	--Common.setBtnAnimation(self.compose.grid1.jnBG._ccnode,"StrengthCompose","top")
end

function clear(self)
	Control.clear(self)

	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 5, groupId = GuideDefine.GUIDE_POWER})
end

function composeCost(human,id)
	if not MaterialConfig[id] then
		return 0 
	end
	local need = MaterialConfig[id].need
	local cost = MaterialConfig[id].cost
	for k,v in pairs(need) do
		local num = v - BagData.getItemNumByItemId(k)
		if num > 0 then
			cost = cost + num * composeCost(human,k)
		end
	end
	return cost
end

function getComposeChain(group)
	local id = group[#group]
	if not MaterialConfig[id] then
		return group
	end
	local need = MaterialConfig[id].need
	for k,v in pairs(need) do
		table.insert(group,k)
		group = getComposeChain(group)
		break
	end
	return group
end

function setComposeChain()
	local id = ComposeGroup[#ComposeGroup]
	if not MaterialConfig[id] then
		return ComposeGroup
	end
	local need = MaterialConfig[id].need
	for k,v in pairs(need) do
		table.insert(ComposeGroup,k)
		setComposeChain()
		break
	end
	return ComposeGroup
end

return StrengthOperate
