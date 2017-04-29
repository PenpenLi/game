module(..., package.seeall)
setmetatable(_M, {__index = Control})

local Chapter = require("src/modules/chapter/Chapter")
local ChapterConfig = require("src/config/ChapterConfig").Config
local ChapterUI = require("src/modules/chapter/ui/ChapterUI")
local LevelConfig = require("src/config/LevelConfig").Config
local ExpConfig = require("src/config/ExpConfig").Config
local ChapterDefine = require("src/modules/chapter/ChapterDefine")
local ItemConfig = require("src/config/ItemConfig").Config
local MonsterConfig = require("src/config/MonsterConfig").Config
local Monster = require("src/modules/hero/Monster")
local Hero = require("src/modules/hero/Hero")
local FightControl = require("src/modules/fight/FightControl")
local BaseMath = require("src/modules/public/BaseMath")
local BagData = require("src/modules/bag/BagData")
local ItemCmd = require("src/modules/bag/ItemCmd")
local MasterDefine = require("src/modules/master/MasterDefine")
local ShopUI = require("src/modules/shop/ui/ShopUI")
local VipLogic = require("src/modules/vip/VipLogic")
local ShopDefine = require("src/modules/shop/ShopDefine")
local Shop = require("src/modules/shop/Shop")
local FixRewardConfig = require("src/config/FixRewardConfig").Config
local CC = Chapter.ChapterContainer
local LC = Chapter.LevelContainer
local FC = Chapter.FBContainer

local VipDefine = require("src/modules/vip/VipDefine")
local VipLogic = require("src/modules/vip/VipLogic")

local PublicLogic = require("src/modules/public/PublicLogic")

Instance = nil 

showChapterOpen = {}
showChapter = false


function new(chapterId,difficulty,levelId,isShowTip)
	local ctrl = Control.new(require("res/chapter/LevelSkin"),{"res/chapter/Level.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(chapterId,difficulty,levelId,isShowTip)
	Instance = ctrl
	return ctrl	
end


function addStage(self)
	self:setPositionY(Stage.uiBottom)

	GuideManager.dispatchEvent(GuideDefine.GUIDE_TRIGGER_TALK, {step = 23, groupId = GuideDefine.GUIDE_CHAPTER_FIRST})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_TRIGGER_TALK, {step = 1, groupId = GuideDefine.GUIDE_SKILL_TALK})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_TRIGGER_TALK, {step = 1, groupId = GuideDefine.GUIDE_CHAPTER_DIFF})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_TRIGGER_TALK, {step = 1, noDelayFun = function()
		--UIManager.reset()
	end, groupId = GuideDefine.GUIDE_TASK_TALK})
end

function uiEffect(self)
	return UIManager.FIRST_TEMP_LABEL
end

function showWipeSettlement(self,levelId,difficulty,rewardList)
	self:refreshWipeSettlement(levelId,difficulty,rewardList)
	-- self.wipeEffect:playWithNames({'wipe'},0,true)
end
function refreshWipeSettlement(self,levelId,difficulty,rewardList)
	if LevelConfig[levelId] == nil then
		return
	end
	if difficulty < 1 or difficulty > 3 then
		return
	end 
	local chapterId = Chapter.getChapterId(levelId)
	local chapterTitle = Chapter.getChapterTitle(chapterId)
	local levelTitle = LevelConfig[levelId][difficulty].levelTitle
	local difficultyName = ChapterDefine.DIFFICULTY_NAME[difficulty]
	local title = chapterTitle.." ("..difficultyName..") "..levelTitle
	local wipeList = {}
	for k,v in pairs(rewardList) do
		wipeList[#wipeList+1] = {
			reward = v
		}
	end
	local ui = UIManager.addChildUI("src/ui/WipeRewardUI")
	ui:refreshReward(title,wipeList)
end

-- function showWipePanel(self,levelId,difficulty)
-- 	ActionUI.show(self.wipepanel,"scale")
-- 	self:refreshWipePanel(levelId,difficulty)
-- end

-- function refreshWipePanel(self,levelId,difficulty)
-- 	self.wipepanel:setVisible(true)
-- 	local conf = LevelConfig[levelId][difficulty]
-- 	if conf.imgUrl ~= '' then
-- 		self.wipepanel.levelimg:removeChildByName("levelimg")
-- 		local spr = Sprite.new('levelimg','res/chapter/levels/'..conf.imgUrl)
-- 		if spr then
-- 			self.wipepanel.levelimg:addChild(spr)
-- 			self.wipepanel.levelimg.mzbg:setTop()
-- 			spr:setPosition(spr:getPosition())
-- 		end
-- 	end
-- 	Common.setLabelCenter(self.wipepanel.levelimg.txttitle)
-- 	self.wipepanel.levelimg.txttitle:setString(Chapter.getLevelTitle(levelId))
-- 	self.wipepanel.levelimg.txttitle:setTop()
-- 	self.wipepanel.txtdifficulty:setString(Chapter.getDifficultyName(difficulty))
	
-- 	local _,_,timesForDay,buyTimes = Chapter.getLevelInfo(levelId,difficulty)
	
-- 	local timesLeft = math.max(conf.limitPerDay - timesForDay,0)
-- 	if conf.limitPerDay == 0 then
-- 		-- 不受限关卡
-- 		self.wipepanel.timelimit:setVisible(false)
-- 		self.wipepanel.start.txttitle:setString('历练')
-- 		self.wipepanel.start2.txttitle:setString('历练x'..conf.wipeBatchTimes)
-- 		self.wipepanel.start:setEnabled(true)
-- 		self.wipepanel.start2:setEnabled(true)
-- 	else
-- 		-- 受限关卡
-- 		-- 有剩余次数的情况下，不能购买通关次数
-- 		self.wipepanel.timelimit:setVisible(true)
-- 		if timesLeft > 0 then
-- 			self.wipepanel.timelimit.buy:setVisible(false)
-- 			self.wipepanel.start.txttitle:setString('历练')
-- 			self.wipepanel.start2.txttitle:setString('历练x'..conf.wipeBatchTimes)
-- 			self.wipepanel.start:setEnabled(true)
-- 			self.wipepanel.start2:setEnabled(true)
-- 		else
-- 			self.wipepanel.timelimit.buy:setVisible(true)
-- 			self.wipepanel.start.txttitle:setString('无法历练')
-- 			self.wipepanel.start2.txttitle:setString('无法历练')
-- 			self.wipepanel.start:setEnabled(true)
-- 			self.wipepanel.start2:setEnabled(true)
-- 		end
-- 		self.wipepanel.timelimit.txttimes:setString(timesLeft)
-- 	end


	
-- 	self.wipepanel.txtcostphysics:setString(conf.energy)
	
-- 	self.wipeTimesLeft = timesLeft


-- 	-- 扫荡券数量
-- 	local ticket = BagData.getItemNumByItemId(ChapterDefine.WIPE_TICKET_ITEMID)
-- 	self.wipepanel.txtwipeticket:setString(ticket)

-- 	for i=1,3 do
-- 		if conf.showReward[i] then
-- 			self.wipepanel.reward.reward2['grid'..i]:setItemIcon(conf.showReward[i])
-- 		else
-- 			self.wipepanel.reward.reward2['grid'..i]:setItemIcon()
-- 		end
-- 	end
-- 	if conf.fixReward.money then
-- 		self.wipepanel.reward.reward1.money.txtmoney:setString(tostring(conf.fixReward.money))
-- 	else
-- 		self.wipepanel.reward.reward1.money.txtmoney:setString('')
-- 	end
-- 	if conf.fixReward.charExp then
-- 		self.wipepanel.reward.reward1.exp.txtexp:setString(tostring(conf.fixReward.charExp))
-- 	else
-- 		self.wipepanel.reward.reward1.exp.txtexp:setString('')
-- 	end


-- end

function showEnergyTip(self)
	ShopUI.virBuy(ShopDefine.K_SHOP_VIRTUAL_PHY_ID)
end
-- function clearCD(self)
-- 	for no,item in pairs(self.levellist.itemContainer) do
-- 		if item.level.passed then
-- 			local levelId = item.level.level.levelId
-- 			local difficulty = item.level.level.difficulty
-- 			local limit = LevelConfig[levelId][difficulty].limitPerDay
-- 			local opened,passed,times = Chapter.getLevelInfo(levelId,difficulty)
-- 			item.level.fight.txtfight:setString("扫荡"..times.."/"..limit.."")
-- 		end
-- 	end
-- 	local tipUI = TipsUI.showTipsOnlyConfirm("清除扫荡CD成功")
-- end

function showLevelInfo(self,levelId,difficulty,levelCnt)
	self.levelId = levelId
	self.difficulty = difficulty
	local conf = LevelConfig[levelId][difficulty]
	local showReward = {}
	for itemId,_ in pairs(conf.randReward) do
		if type(itemId) == "number" then
			table.insert(showReward,itemId)
		end
	end
	for itemId,_ in pairs(conf.cycleReward) do
		if type(itemId) == "number" then
			table.insert(showReward,itemId)
		end
	end


	local rewardNo = 0
	for i,itemId in ipairs(showReward) do
		rewardNo = rewardNo + 1
		if rewardNo > 5 then break end
		self.reward.reward2['grid'..rewardNo]:setItemIcon(itemId,"mIcon")
	end
	-- for itemId,_ in pairs(conf.cycleReward) do
	-- 	rewardNo = rewardNo + 1
	-- 	if rewardNo > 5 then break end
	-- 	self.reward.reward2['grid'..rewardNo]:setItemIcon(itemId,"mIcon")
	-- end
	for i=rewardNo+1,5 do
		self.reward.reward2['grid'..i]:setItemIcon()
	end
	-- for i=1,5 do
	-- 	if showReward[i] then
	-- 		self.reward.reward2['grid'..i]:setItemIcon(showReward[i],"mIcon")
	-- 	else
	-- 		self.reward.reward2['grid'..i]:setItemIcon()
	-- 	end
	-- end
	local lv = Master.getInstance().lv
	if FixRewardConfig[lv] then
		if FixRewardConfig[lv]['chapterReward'..difficulty].money then
			self.reward.reward1.money.txtmoney:setString(FixRewardConfig[lv]['chapterReward'..difficulty].money)
		else
			self.reward.reward1.money.txtmoney:setString('')
		end
		if FixRewardConfig[lv]['chapterReward'..difficulty].charExp then
			self.reward.reward1.exp.txtexp:setString(FixRewardConfig[lv]['chapterReward'..difficulty].charExp)
		else
			self.reward.reward1.exp.txtexp:setString('')
		end
	end
	Common.setLabelCenter(self.power.txtpower,"left")
	self.power.txtpower:setString(conf.recommendedPower)
	self.levelId = levelId
	self.difficulty = difficulty
	self.levelphysics.txtphysics:setString(conf.energy)

	local opened,passed,timesForDay,_,star = Chapter.getLevelInfo(levelId,difficulty)
	-- if passed then
		self.wipe:setVisible(true)
		-- 扫荡券数量
		local ticket = BagData.getItemNumByItemId(ChapterDefine.WIPE_TICKET_ITEMID)
		self.wipe.tickets.txtticket:setString(ticket)
		self.wipe.tickets:setVisible(true)

		local timesLeft = math.max(conf.limitPerDay - timesForDay,0)
		if conf.limitPerDay == 0 then
			-- 不受限关卡
			self.wipe.times:setVisible(false)
			self.wipe.wipe.txttitle:setString('扫荡')
			self.wipe.wipe2.txttitle:setString('扫荡'..conf.wipeBatchTimes..'次')
			self.wipe.wipe:setVisible(true)
			self.wipe.wipe2:setVisible(true)
			self.wipe.buytimes:setVisible(false)
			self.wipe.wipe2.wipeTimes = conf.wipeBatchTimes
		else
			-- 受限关卡
			-- 有剩余次数的情况下，不能购买通关次数
			self.wipe.times:setVisible(true)
			self.wipe.times.txttimes:setString(timesLeft)
			if timesLeft > 0 then
				local wipeTimes = timesLeft > conf.wipeBatchTimes and conf.wipeBatchTimes or timesLeft
				print("wipeTimes="..wipeTimes)
				self.wipe.wipe2.wipeTimes = wipeTimes
				self.wipe.wipe.txttitle:setString('扫荡')
				self.wipe.wipe2.txttitle:setString('扫荡'..wipeTimes.."次")
				self.wipe.wipe:setVisible(true)
				self.wipe.wipe2:setVisible(true)
				self.wipe.buytimes:setVisible(false)
			else
				self.wipe.wipe:setVisible(false)
				self.wipe.wipe2:setVisible(false)
				self.wipe.buytimes:setVisible(true)
			end
		end
		-- self.txtintro1:setVisible(true)
		-- self.txtintro2:setVisible(false)
		-- self.txtintro1:setString('   '..conf.intro)
	-- else
	-- 	self.wipe:setVisible(false)
	-- 	self.txtintro1:setVisible(false)
	-- 	self.txtintro2:setVisible(true)
	-- 	self.txtintro2:setString('   '..conf.intro)
	-- end
	self.txtintro:setString(conf.intro)

	local master = Master:getInstance()
	if master.lv < PublicLogic.getOpenLv("wipe") or star < 3 then
		-- 不开放历练
		self.wipe.wipe:setState(Button.UI_BUTTON_DISABLE)
		self.wipe.wipe2:setState(Button.UI_BUTTON_DISABLE)
	else
		self.wipe.wipe:setState(Button.UI_BUTTON_NORMAL)
		self.wipe.wipe2:setState(Button.UI_BUTTON_NORMAL)
	end

	-- local width = self.intro._skin.width - 10
	-- local skin = 
 --    {name="introSV",type="Label",x=10,y=0,width=width,height=0,
 --        {name="txtexp",status="",txt="经验：4578/9876",font="SimHei",size=20,bold=false,italic=false,color={255,255,255}},
 --    }
	-- self.txtintro = Label.new(skin)
	-- self.txtintro:setDimensions(skin.width,0)
	-- self.txtintro:setString(conf.intro)
	-- -- txt:setString('   '..(ChapterConfig[chapterId][difficulty].intro or ChapterConfig[chapterId][1].intro))
	-- self.intro:clearMoveNode()
	-- self.intro:setMoveNode(self.txtintro)
	
	if self.chapterId == 1 then
		if (self.levelId >= 101 and self.levelId <= 110 ) and self.difficulty == 1 then
			local o,p,_ = Chapter.getLevelInfo(self.levelId,1)
			if not p and o then
				self.fingerEffect:setVisible(true)
				self.fingerEffect:getAnimation():play("特效",-1,1)
			else
				self.fingerEffect:getAnimation():stop()
				self.fingerEffect:setVisible(false)
			end
		else
			self.fingerEffect:getAnimation():stop()
			self.fingerEffect:setVisible(false)
		end
	end

end



function showLevels(self,chapterId,difficulty,levelId)
	self.levellist:setDirection(FocusList.UI_FOCUSLIST_HORIZONTAL)
	self.levellist:getChild('levellistbg'):setVisible(false)
	self.levellist:setItemNum(0)
	self.difficulty = difficulty
	self.chapterId = chapterId
	-- local curStar,maxStar = Chapter.getStar(chapterId,difficulty)
	-- self.box.txtstar:setString(curStar.."/"..maxStar)

	Common.setLabelCenter(self.title.txttitle)
	self.title.txttitle:setString(ChapterConfig[chapterId][difficulty].chapterTitle)

	local levels = Chapter.getLevels(chapterId,difficulty)
	local function onTouchLevel(self,event,target)
		if event.etype == Event.Touch_ended then
			local item = target
			if target.chosen:isVisible() then
				-- self:showLevelInfo(target.levelId,difficulty,#levels)
				-- self:toChallenge()
			end
		end
	end
	-- Common.setLabelCenter(self.txtno)
	-- self.txtno:setString("1/"..#levels)
	local topOpenedItemId = 1
	local selectedItemId = 0
	for id,level in pairs(levels) do
		local no = self.levellist:addItem()
		local item = self.levellist.itemContainer[no]


		-- item.chosenEffect = ccs.Armature:create('level')
		-- item._ccnode:addChild(item.chosenEffect,10)
		-- local size = item:getContentSize()
		-- item.chosenEffect:setPosition(size.width/2,size.height/2)
		-- item.chosenEffect:getAnimation():setSpeedScale(0.8)
		item.chosen:setVisible(false)
		item.levelId = level.levelId
		item.difficulty = difficulty
		local conf = LevelConfig[level.levelId][difficulty]
		Common.setLabelCenter(item.txttitle,'left')
		item.txttitle:setString('第'..no..'关 '..Chapter.getLevelTitle(level.levelId))
		-- 关卡图片
		local opened,passed,_,_,star = Chapter.getLevelInfo(level.levelId,difficulty)

		if conf.imgUrl ~= '' then
			local spr = Sprite.new("spr","res/chapter/levels/"..conf.imgUrl)
			if spr then
				item:addChild(spr)
				item.mzbg:setTop()
				spr:setPosition(item.levelicon:getPosition())
				item.txttitle:setTop()
				if not opened then
					spr:shader(Shader.SHADER_TYPE_GRAY)
				end
			end
		end
		if levelId and level.levelId == levelId then
			selectedItemId = id
		end
		if opened then
			item.lock:setVisible(false)
			topOpenedItemId = id
		else
			item.lock:setVisible(true)
			item.lock:setTop()
		end
		print(level.levelId.." "..star)
		for i=1,3 do
			item['starbg'..i]:setTop()
			if star >= i then
				item['star'..i]:setVisible(true)
				item['star'..i]:setTop()
			else
				item['star'..i]:setVisible(false)
			end
		end
		
		item.difficulty = difficulty
		item:addEventListener(Event.TouchEvent,onTouchLevel,self)

	end
	local topLevelId = Chapter.getTopOpenedLevel(chapterId,difficulty)
	if selectedItemId > 0 then
		self.levellist:setSelectedItem(selectedItemId)
		-- self:showLevelInfo(levelId,difficulty)
	else
		self.levellist:setSelectedItem(topOpenedItemId,true)
		-- self:showLevelInfo(topLevelId,difficulty)
	end
	
	-- local lastBox = 0
	-- for i=1,3 do
	-- 	if Chapter.getBox(chapterId,difficulty,i) then
	-- 		lastBox = i
	-- 	end
	-- end
	-- if lastBox == 0 then lastBox = 1 end
	-- for i=1,3 do
	-- 	if i == lastBox then
	-- 		self['box'..i]:setVisible(true)
	-- 	else
	-- 		self['box'..i]:setVisible(false)
	-- 	end
	-- end
	self:showBoxBlink()
	-- local width = self.intro._skin.width - 10
	-- local skin = 
 --    {name="introSV",type="Label",x=10,y=0,width=width,height=0,
 --        {name="txtexp",status="",txt="经验：4578/9876",font="SimHei",size=20,bold=false,italic=false,color={255,255,255}},
 --    }
	-- local txt = Label.new(skin)
	-- txt:setDimensions(skin.width,0)
	-- txt:setString('   '..(ChapterConfig[chapterId][difficulty].intro or ChapterConfig[chapterId][1].intro))
	-- self.intro:clearMoveNode()
	-- self.intro:setMoveNode(txt)


	-- self:refreshPhysics()

end

function showBoxBlink(self)
	if Chapter.isBoxAvailable(self.chapterId,self.difficulty) then
		self.boxEffect:getAnimation():playWithNames({'Animation1'},0,true)
		self.boxEffect:setVisible(true)
		self.boxStarEffect:getAnimation():playWithNames({'Animation1'},0,true)
		self.boxStarEffect:setVisible(true)
	else
		self.boxEffect:setVisible(false)
		self.boxEffect:getAnimation():stop()
		self.boxStarEffect:setVisible(false)
		self.boxStarEffect:getAnimation():stop()
	end
end

function showRewardTip(self,chapterId,difficulty)
	UIManager.addChildUI('src/modules/chapter/ui/LevelRewardUI',chapterId,difficulty)
	-- ActionUI.show(self.rewardtip,"scale")
	-- for i=1,3 do
	-- 	local starConf = ChapterConfig[self.chapterId][self.difficulty]['boxStar'..i]
	-- 	local rewardConf = ChapterConfig[self.chapterId][self.difficulty]['boxReward'..i]
	-- 	local maxStar,curStar = Chapter.getStar(self.chapterId,self.difficulty)
	-- 	if starConf and starConf>0 then
	-- 		local no = 1
	-- 		if curStar >= starConf then 
	-- 			self.rewardtip['reward'..i].receive:setState(Button.UI_BUTTON_NORMAL)
	-- 			self.rewardtip['reward'..i].receive:setEnabled(true)
	-- 		else
	-- 			self.rewardtip['reward'..i].receive:setState(Button.UI_BUTTON_DISABLE)
	-- 			self.rewardtip['reward'..i].receive:setEnabled(false)
	-- 		end
	-- 		for itemId,r in pairs(rewardConf) do
	-- 			if type(itemId) == 'number' then 
	-- 				self.rewardtip['reward'..i]['rewardgrid'..no]:setItemIcon(itemId)
	-- 				self.rewardtip['reward'..i]['rewardgrid'..no]:setItemNum(r)
	-- 				no = no + 1
	-- 			end
	-- 		end
	-- 	else
	-- 		self.rewardtip['reward'..i]:setVisible(false)
	-- 	end
	-- end
end

-- function refreshPhysics(self)
-- 	local master = Master.getInstance()
-- 	self.levelphysics.txtphysics:setString(master.physics)
-- 	-- self.physics.totalphysics:setString(ExpConfig[master.lv].physics)
-- end
function toChallenge(self)
	local levelId = self.levelId
	local difficulty = self.difficulty
	local opened,passed,times = Chapter.getLevelInfo(levelId,difficulty)
	if not Chapter.debugFlag and not opened then
		local tips = TipsUI.showTipsOnlyConfirm("本章节尚未开放")
		return
	end
	local conf = LevelConfig[levelId][difficulty]
	if conf.energy > Master.getInstance().physics then
		ShopUI.virBuy(ShopDefine.K_SHOP_VIRTUAL_PHY_ID)
	else
		UIManager.addUI("src/modules/chapter/ui/ChapterFightUI",levelId,difficulty)
	end
	-- sendFBStart(self.levelId,self.difficulty)
end

-- function sendFBStart(levelId,difficulty)
-- 	local ui = WaittingUI.create(PacketID.GC_CHAPTER_FB_START)
-- 	ui:addEventListener(WaittingUI.Event.Timeout,function()
-- 		local tipsUI = TipsUI.showTopTips("网络不太好哦,请重试")
-- 		tipsUI:addEventListener(Event.Confirm,function(self,event) 
-- 			if event.etype == Event.Confirm_yes then
-- 				sendFBStart(levelId,difficulty)
-- 			elseif event.etype == Event.Confirm_no then
-- 				ui:removeFromParent()
-- 			end
-- 		end)
-- 	end,self)
-- 	Network.sendMsg(PacketID.CG_CHAPTER_FB_START,levelId,difficulty)
-- end

function sendFBWipe(levelId,difficulty,wipeTimes)
	local ui = WaittingUI.create(PacketID.GC_CHAPTER_FB_WIPE)
	ui:addEventListener(WaittingUI.Event.Timeout,function()
		local tipsUI = TipsUI.showTopTips("网络不太好哦,请重试")
		tipsUI:addEventListener(Event.Confirm,function(self,event) 
			if event.etype == Event.Confirm_yes then
				sendFBWipe(levelId,difficulty,wipeTimes)
			elseif event.etype == Event.Confirm_no then
				ui:removeFromParent()
			end
		end)
	end,self)
	Network.sendMsg(PacketID.CG_CHAPTER_FB_WIPE,levelId,difficulty,wipeTimes)
end


function refreshDot(self)
	for i=1,3 do
		Dot.check(self.difficultyrbg[tostring(i)],"chapterUIBox",self.chapterId,i)
		Dot.setDotAlignment(self.difficultyrbg[tostring(i)],'rTop',{x=10,y=10})
	end
end

function init(self,chapterId,difficulty,levelId,isShowTip)
	ChapterUI.lastChapterId = chapterId
	self.chapterId = chapterId
	-- self.energytip:setVisible(false)
	self.left:setVisible(false)
	self.right:setVisible(false)

	-- self.intro:getChild("svbg"):setVisible(false)
	-- Common.setLabelCenter(self.txtintro1,'left')
	self.txtintro:setDimensions(self.txtintro._skin.width,0)
	self.txtintro:setHorizontalAlignment(Label.Alignment.Left)
	self.txtintro:setPositionY(self.txtintro:getPositionY() + self.txtintro._skin.height)
	self.txtintro:setAnchorPoint(0,1)
	-- Common.setLabelCenter(self.txtintro2,'left')
	Common.setLabelCenter(self.wipe.wipe2.txttitle)
	Common.setLabelCenter(self.wipe.wipe.txttitle)
	CommonGrid.bind(self.levelphysics.tiliicon2)
	self.levelphysics.tiliicon2:setCoinIcon("phy")

	-- self.startip:setVisible(false)
	self:hideStarTip()
	-- self:addArmatureFrame("res/chapter/effect/level.ExportJson")
	self:addArmatureFrame("res/chapter/effect/boxblink.ExportJson")
	self:addArmatureFrame("res/chapter/effect/boxStar.ExportJson")

	-- self.wipeEffect = ccs.Armature:create("Complete")
	-- self.wipesettlement._ccnode:addChild(self.wipeEffect)
	-- self.wipeEffect:setAnchorPoint(0.5,0.5)
	-- self.wipeEffect:setPosition(self.wipesettlement:getContentSize().width/2,self.wipesettlement:getContentSize().height)

	self.boxEffect = ccs.Armature:create('boxblink')
	self.box._ccnode:addChild(self.boxEffect,-1)
	local size = self.box:getContentSize()
	self.boxEffect:setPosition(size.width/2,size.height/2)
	self.boxEffect:setScale(0.7)

	self.boxStarEffect = ccs.Armature:create('boxStar')
	self.box._ccnode:addChild(self.boxStarEffect)
	local size = self.box:getContentSize()
	self.boxStarEffect:setPosition(size.width/2,size.height/2)
	-- self.boxEffect:setScale(0.7)



	self:addArmatureFrame("res/armature/effect/Finger.ExportJson")
	self.fingerEffect = ccs.Armature:create("Finger")
	local size = self.challenge:getContentSize()
	self.challenge._ccnode:addChild(self.fingerEffect)
	self.fingerEffect:setPosition(size.width/2,size.height/2)

	local function onsxtj(self,event,target)
		if event.etype == Event.Touch_began or 	event.etype == Event.Touch_moved then
			self.startip:setVisible(true)
			-- local conf = LevelConfig[self.levelId][self.difficulty]
			-- if conf.starCondition[3] == 0 then
			-- 	self.startip.txtdesc:setString("己方无英雄死亡")
			-- elseif conf.starCondition[3] == 1 then
			-- 	self.startip.txtdesc:setString("己方无英雄阵亡或只阵亡一人")
			-- else
			-- 	self.startip.txtdesc:setString("己方阵亡人数少于或等于两人")
			-- end
		else
			self.startip:setVisible(false)
		end
		-- self:showStarTip()
	end
	-- Common.setLabelCenter(self.startip.txtdesc)
	self.wipe.sxtj:addEventListener(Event.TouchEvent,onsxtj,self)

	-- local function onBoxReceive(self,event,target)
	-- 	Network.sendMsg(PacketID.CG_CHAPTER_BOX_REWARD,self.chapterId,self.difficulty,target.boxId)

	-- end
	-- for i=1,3 do
	-- 	self.rewardtip['reward'..i].receive:addEventListener(Event.Click,onBoxReceive,self)
	-- 	for j=1,3 do
	-- 		CommonGrid.bind(self.rewardtip['reward'..i]['rewardgrid'..j],true)
	-- 	end
	-- 	self.rewardtip['reward'..i].receive.boxId = i
	-- end
	local function onOpenBox(self,event,target)
		-- 本章节获得所有的星星，则可以开启宝箱
		-- local curStar,maxStar = Chapter.getStar(self.chapterId,self.difficulty)
		-- if curStar >= maxStar then
		-- 	Network.sendMsg(PacketID.CG_CHAPTER_BOX_REWARD,self.chapterId,self.difficulty)
		-- else
		-- 	local tips = TipsUI.showTipsOnlyConfirm("赢得本章节本难度所有星星可以获得宝箱奖励")
		-- end
		self:showRewardTip(self.chapterId,self.difficulty)
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_CHAPTER_BOX, step = 1})
	end

	self.box:addEventListener(Event.Click,onOpenBox,self)
	self.box:setTop()
	-- for i=1,3 do
	-- 	self['box'..i].boxId = i
	-- 	self['box'..i]:addEventListener(Event.Click,onOpenBox,self)
	-- 	self['box'..i]:setTop()
	-- end



	local function onSelected(id,item,cnt)
		-- self.txtno:setString(id..'/'..cnt)
		self:showLevelInfo(item.levelId,item.difficulty,cnt)
		if self.selectedItem and self.selectedItem.chosen and self.selectedItem.chosen._ccnode then
			-- self.selectedItem.chosen:setVisible(false)
			-- if self.selectedItem.chosenEffect then
			-- 	self.selectedItem.chosenEffect:getAnimation():stop()
			-- 	self.selectedItem.chosenEffect:setVisible(false)
			-- end
		end
		self.selectedItem = item
		-- self.selectedItem.chosen:setVisible(true)
		-- if self.selectedItem.chosenEffect then
		-- 	self.selectedItem.chosenEffect:getAnimation():playWithNames({'Animation1'},0,true)
		-- 	self.selectedItem.chosenEffect:setVisible(true)
		-- end
		self.selectedItem.chosen:setTop()
	end
	self.levellist:setSelectedCB(onSelected)
	for i=1,5 do 
		CommonGrid.bind(self.reward.reward2['grid'..i],true)
	end
	-- Common.setLabelCenter(self.box.txtstar)
	--隐藏章节没有定义的难度
	local maxDifficulty = Chapter.getTopOpenedDifficulty(chapterId)

	for i=1,3 do
		if ChapterConfig[chapterId][i] == nil then
			self.difficultyrbg[tostring(i)]:setState(Button.UI_BUTTON_NORMAL)
			self.difficultyrbg[tostring(i)]:setVisible(false)
		else
			if i > maxDifficulty then
				self.difficultyrbg[tostring(i)]:setState(Button.UI_BUTTON_DISABLE)
				self.difficultyrbg[tostring(i)]:setEnabled(true)
				self.difficultyrbg[tostring(i)].closed = true
			else
				self.difficultyrbg[tostring(i)]:setState(Button.UI_BUTTON_NORMAL)
				self.difficultyrbg[tostring(i)]:setEnabled(true)
				self.difficultyrbg[tostring(i)].closed = false
			end
			self.difficultyrbg[tostring(i)]:setVisible(true)
		end
	end
	self:refreshDot()


	function onClickRGB(self,event,target)
		if target.name ~= '1' and target.closed == true then
			local conf = ChapterConfig[self.chapterId][tonumber(target.name)]
			if conf.charLevel > Master.getInstance().lv then
				Common.showMsg("战队等级达到"..conf.charLevel.."级才能开启本难度")
			else
				-- 判断前置章节是否完成
				local d = tonumber(target.name)
				local last = Chapter.getLastLevel(self.chapterId)
				local opened,passed = Chapter.getLevelInfo(last,d-1)
				if target.name == '2' and passed then
					Common.showMsg("通关前一个章节所有噩梦难度的关卡才能开启本章节噩梦难度")
				elseif target.name == '2' and not passed then
					Common.showMsg("通关所有普通难度的关卡才能开启噩梦难度")
				elseif target.name == '3' and passed then
					Common.showMsg("通关前一个章节所有地狱难度的关卡才能开启本章节地狱难度")
				elseif target.name == '3' and not passed then
					Common.showMsg("通关所有噩梦难度的关卡才能开启地狱难度")
				end
			end
		else
			if self.difficulty ~= tonumber(target.name) then
				self:showLevels(chapterId,tonumber(target.name),levelId)
			end
		end
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_CHAPTER_DIFF, step = 4})
	end
	for _,rb in ipairs(self.difficultyrbg:getChildren()) do 
		rb:addEventListener(Event.Click,onClickRGB,self)
	end

	
	-- local maxDifficulty = Chapter.getTopOpenedDifficulty(chapterId)
	if maxDifficulty == 0 then 
		maxDifficulty = 1 
	end
	if difficulty and difficulty >=1 and difficulty <= 3 then
		maxDifficulty = difficulty
	else
		local lastLevelId = Chapter.getLastLevel(chapterId)
		local o,p = Chapter.getLevelInfo(lastLevelId,maxDifficulty)
		if p then
			local lastFL = Chapter.getLastFightLevel(chapterId)
			if lastFL then
				maxDifficulty = lastFL.difficulty
				levelId = lastFL.levelId
			end
		end
	end

	self.difficultyrbg[tostring(maxDifficulty)]:dispatchEvent(Event.Click,{etype=Event.Click})
	self.difficultyrbg[tostring(maxDifficulty)]:setSelected(true)


	-- local function onChangeDifficulty(self,event,target)
	-- 	local d = event.target
	-- 	if d.closed then
	-- 		if d.name == '2' then
	-- 			Common.showMsg("通关所有普通难度的关卡才能开启噩梦难度")
	-- 		elseif d.name == '3' then
	-- 			Common.showMsg("通关所有噩梦难度的关卡才能开启地狱难度")
	-- 		end
	-- 	end
	-- end
	-- self.difficultyrbg:addEventListener(Event.Change, onChangeDifficulty, self)



	-- local function onInvisible(self,event,target)
	-- 	target._parent:setVisible(false)
	-- end

	-- self.energytip.close:addEventListener(Event.Click,onInvisible,self)

	-- local function onHideRewardTip(self,event,target)
	-- 	ActionUI.hide(self.rewardtip,'scaleHide')
	-- end
	-- self.rewardtip.confirm:addEventListener(Event.Click,onHideRewardTip,self)

	-- 取消排行榜
	-- local function onRank(self,event,target)
	-- 	Network.sendMsg(PacketID.CG_CHAPTER_RANK)
	-- end
	-- self.rank:addEventListener(Event.Click,onRank,self)



	local function onClose(self,event,target)
		UIManager.removeUI(self)
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_CHAPTER_DIFF, step = 2})
	end
	self.back:addEventListener(Event.Click,onClose,self)
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.back, noDelayFun=function()
		if self:getChild('ChapterTipTip') then
			self:removeChildByName('ChapterTipTip')
		end
	end,clickFun=function()
		UIManager.addUI('src/modules/chapter/ui/ChapterUI')
	end,step = 2,  groupId = GuideDefine.GUIDE_CHAPTER_DIFF})

	

	-- for i=1,3 do 
	-- 	CommonGrid.bind(self.rewardtip['rewardgrid'..i],true)
	-- end


	local function onGetBoxReward(self,event,target)
	end



	local function onChallenge(self,event,target)
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_CHAPTER_FIRST, step = 4})
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_CHAPTER_FIGHT_SEC, step = 3})
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_CHAPTER_FIGHT_THIRD, step = 3})
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_HERO_ACTIVE, step = 8})
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_SIGN_IN, step = 7})
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_CHAPTER_SECOND, step = 7})

		self:toChallenge()
		-- local levelId = self.levelId
		-- local difficulty = self.difficulty
		-- local opened,passed,times = Chapter.getLevelInfo(levelId,difficulty)
		-- if not opened then
		-- 	local tips = TipsUI.showTipsOnlyConfirm("本章节尚未开放")
		-- 	return
		-- end
		-- Network.sendMsg(PacketID.CG_CHAPTER_FB_START,self.levelId,self.difficulty)
					
	end
	self.challenge:addEventListener(Event.Click,onChallenge,self)


	-- local function onWipe(self,event,target)
	-- 	local master = Master:getInstance()
	-- 	if master.lv < ChapterDefine.LILIAN_LEVEL then
	-- 		local tips = TipsUI.showTipsOnlyConfirm("战队等级达到"..ChapterDefine.LILIAN_LEVEL.."开放历练功能")
	-- 		return
	-- 	end
	-- 	local levelId = self.levelId
	-- 	local difficulty = self.difficulty
	-- 	local opened,passed,times = Chapter.getLevelInfo(levelId,difficulty)
	-- 	if not passed then
	-- 		local tips = TipsUI.showTipsOnlyConfirm("请先挑战本关卡，再进行历练")
	-- 		return
	-- 	end
	-- 	self:showWipePanel(self.levelId,self.difficulty)
	-- end
	-- self.wipe:addEventListener(Event.Click,onWipe,self)

	local function onStartWipe(self,event,target)
		local opened,passed,timesForDay,_,star = Chapter.getLevelInfo(self.levelId,self.difficulty)
		local wipeOpenLv = PublicLogic.getOpenLv("wipe")
		if event.etype == Event.Touch_began then
			local master = Master:getInstance()
			if master.lv < wipeOpenLv then
				-- 不开放历练
				-- local tips = TipsUI.showTipsOnlyConfirm()
				Common.showMsg("战队等级达到"..wipeOpenLv..'级才开放扫荡功能')
				self.wipe.wipe:setState(Button.UI_BUTTON_DISABLE)
				self.wipe.wipe2:setState(Button.UI_BUTTON_DISABLE)
				return false
			end
			
			if star < 3 then
				-- local tips = TipsUI.showTipsOnlyConfirm()
				Common.showMsg("3星通关才开放扫荡功能")
				self.wipe.wipe:setState(Button.UI_BUTTON_DISABLE)
				self.wipe.wipe2:setState(Button.UI_BUTTON_DISABLE)
				return false
			end
		elseif event.etype == Event.Touch_out then
			local master = Master:getInstance()
			if master.lv < wipeOpenLv then
				-- 不开放历练
				-- local tips = TipsUI.showTipsOnlyConfirm("战队等级达到"..ChapterDefine.LILIAN_LEVEL..'级才开放历练功能')
				self.wipe.wipe:setState(Button.UI_BUTTON_DISABLE)
				self.wipe.wipe2:setState(Button.UI_BUTTON_DISABLE)
				return false
			end
			
			if star < 3 then
				-- local tips = TipsUI.showTipsOnlyConfirm("3星通关才开放历练功能")
				self.wipe.wipe:setState(Button.UI_BUTTON_DISABLE)
				self.wipe.wipe2:setState(Button.UI_BUTTON_DISABLE)
				return false
			end
		elseif event.etype == Event.Touch_moved then
			local master = Master:getInstance()
			if master.lv < wipeOpenLv then
				-- 不开放历练
				-- local tips = TipsUI.showTipsOnlyConfirm("战队等级达到"..ChapterDefine.LILIAN_LEVEL..'级才开放历练功能')
				self.wipe.wipe:setState(Button.UI_BUTTON_DISABLE)
				self.wipe.wipe2:setState(Button.UI_BUTTON_DISABLE)
				return false
			end
			
			if star < 3 then
				-- local tips = TipsUI.showTipsOnlyConfirm("3星通关才开放历练功能")
				self.wipe.wipe:setState(Button.UI_BUTTON_DISABLE)
				self.wipe.wipe2:setState(Button.UI_BUTTON_DISABLE)
				return false
			end
		elseif event.etype == Event.Touch_ended then
			local master = Master:getInstance()
			if master.lv < wipeOpenLv then
				-- 不开放历练
				-- local tips = TipsUI.showTipsOnlyConfirm()
				-- Common.showMsg("战队等级达到"..wipeOpenLv..'级才开放扫荡功能')
				self.wipe.wipe:setState(Button.UI_BUTTON_DISABLE)
				self.wipe.wipe2:setState(Button.UI_BUTTON_DISABLE)
				return false
			end
			
			if star < 3 then
				-- local tips = TipsUI.showTipsOnlyConfirm()
				-- Common.showMsg("3星通关才开放扫荡功能")
				self.wipe.wipe:setState(Button.UI_BUTTON_DISABLE)
				self.wipe.wipe2:setState(Button.UI_BUTTON_DISABLE)
				return false
			end
			local master = Master:getInstance()
			local levelId = self.levelId
			local difficulty = self.difficulty
			local conf = LevelConfig[self.levelId][self.difficulty]
			
			local timesLeft = math.max(conf.limitPerDay - timesForDay,0)
			if not opened then
				-- local tips = TipsUI.showTipsOnlyConfirm()
				Common.showMsg("本章节尚未开放")
				return
			end
			local wipeTimes = 1
			
			if target.name == 'wipe2' then
				wipeTimes = target.wipeTimes
			end
			
			

			-- -- 判断剩余次数
			-- if conf.limitPerDay > 0 and  timesLeft < wipeTimes then
			-- 	local tips = TipsUI.showTipsOnlyConfirm("剩余历练次数不足"..wipeTimes.."次，无法批量历练")
			-- 	return
			-- end

			-- 判断体力
			local costp = conf.energy*wipeTimes
			if costp > master.physics then
				ShopUI.virBuy(ShopDefine.K_SHOP_VIRTUAL_PHY_ID)
				return
			end
			-- 判断扫荡券
			local ticket = BagData.getItemNumByItemId(ChapterDefine.WIPE_TICKET_ITEMID)
			if ticket < wipeTimes then
				local tipUI = TipsUI.showTips("扫荡券不足，是否使用"..wipeTimes.."颗钻石进行"..wipeTimes.."次扫荡？")
				tipUI:addEventListener(Event.Confirm,function(self,event)
					if event.etype == Event.Confirm_yes then
						-- Network.sendMsg(PacketID.CG_CHAPTER_FB_WIPE,levelId,difficulty,wipeTimes)
						sendFBWipe(levelId,difficulty,wipeTimes)
					end
				end,self)
			else
				--开始扫荡
				sendFBWipe(levelId,difficulty,wipeTimes)
			end
		end

	end

	self.wipe.wipe:addEventListener(Event.TouchEvent,onStartWipe,self)
	self.wipe.wipe2:addEventListener(Event.TouchEvent,onStartWipe,self)
	self.wipe.wipe.touchParent = false
	self.wipe.wipe2.touchParent = false
	Common.setLabelCenter(self.wipe.wipe.txttitle)
	Common.setLabelCenter(self.wipe.wipe.txttitle)





	local function onBuyTimes(self,event,target)
		if LevelConfig[self.levelId] and LevelConfig[self.levelId][self.difficulty] then
			local conf = LevelConfig[self.levelId][self.difficulty]
			local _,_,timesForDay,buyTimes = Chapter.getLevelInfo(self.levelId,self.difficulty)
			local leftTimes = VipLogic.getVipAddCount(VipDefine.VIP_CHAPTER_RESET)-buyTimes
			if leftTimes > 0 then
				local price = Shop.getPriceByTimes(ChapterDefine.BUTTIMES_SHOPID,buyTimes+1)
				local master = Master:getInstance()
				if master.rmb < price then
					Common.showRechargeTips("不足"..price.."颗钻石，无法购买扫荡次数，是否充值？")
				else
					local tips = TipsUI.showTips('花费'..price..'颗钻石购买'..conf.limitPerDay..'次通关次数 (今日还可以购买'..leftTimes..'次)')
					tips:addEventListener(Event.Confirm,function(self,event)
						if event.etype == Event.Confirm_yes then
							Network.sendMsg(PacketID.CG_CHAPTER_BUYTIMES,self.levelId,self.difficulty,buyTimes + 1)
						end
					end,self)					
				end

			else
				Common.showRechargeTips('今日购买次数已用完咯，升级VIP等级来增加购买次数？')
			end

		end
	end
	self.wipe.buytimes:addEventListener(Event.Click,onBuyTimes,self)		
	
	-- self.txtintro1:setAnchorPoint(0,1)
	-- self.txtintro1:setPositionY(self.txtintro1._skin.y+self.txtintro1._skin.height)

	-- self.txtintro2:setAnchorPoint(0,1)
	-- self.txtintro2:setPositionY(self.txtintro2._skin.y+self.txtintro2._skin.height)

	-- local function onAddPhy(self,event,target)
	-- 	ShopUI.phyBuy()
	-- end
	-- self.physics.add:addEventListener(Event.Click,onAddPhy,self)


	

	-- local function onCDTime(self,event)
	-- 	for no,item in pairs(self.levellist.itemContainer) do
	-- 		if item.level.passed then
	-- 			local t = os.time() - Chapter.cdTime
	-- 			if t < ChapterDefine.WIPE_CD then
	-- 				local dc = Common.getShortDCTime(ChapterDefine.WIPE_CD-t)
	-- 				item.level.fight.txtfight:setString("冷却"..dc)
	-- 				item.level.fight.txtcd:setVisible(false)
	-- 			end
	-- 		end
	-- 	end
	-- end

	GuideManager.dispatchEvent(GuideDefine.GUIDE_TRIGGER_TALK, {step = 1, groupId = GuideDefine.GUIDE_HERO_TALK})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_TRIGGER_TALK, {step = 1, groupId = GuideDefine.GUIDE_PARTNER_TALK})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component = self.box, step = 1, groupId = GuideDefine.GUIDE_CHAPTER_BOX, noDelayFun = function() 
			if self:getChild('ChapterTipTip') then
				self:removeChildByName('ChapterTipTip')
			end
			showChapter = true
			GuideManager.setGuide(true)
		end	
	})
	if ChapterConfig[self.chapterId+1] then 
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.difficultyrbg['2'], step = 4, groupId = GuideDefine.GUIDE_CHAPTER_DIFF})
		-- 判断是否有开启下一个章节的提示
		local firstLevelId = Chapter.getFirstLevel(self.chapterId+1 )
		local opened,passed,_ = Chapter.getLevelInfo(firstLevelId,1)
		if (isShowTip or showChapter) and Chapter.isLastLevel(self.levelId) and self.difficulty==1 and (not showChapterOpen[self.chapterId+1] or showChapter) and  opened and (not passed or showChapter) then
			if showChapter == false then
				showChapterOpen[self.chapterId+1] = true
			end
			-- 开启新章节
			if GuideManager.isShowGuide() == false then
				self:showTip()	
				showChapter = false
			else
				GuideManager.setGuide(false)
				showChapter = true
			end
		end
	end





	-- self.cdTimer = self:addTimer(onCDTime, 1, -1, self)
	-- self:openTimer()

	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.challenge, step = 4, groupId = GuideDefine.GUIDE_CHAPTER_FIRST})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.challenge, step = 3, groupId = GuideDefine.GUIDE_CHAPTER_FIGHT_SEC})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.challenge, step = 3, groupId = GuideDefine.GUIDE_CHAPTER_FIGHT_THIRD})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.challenge, step = 8, groupId = GuideDefine.GUIDE_HERO_ACTIVE})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.challenge, step = 7, groupId = GuideDefine.GUIDE_SIGN_IN})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.challenge, step = 7, groupId = GuideDefine.GUIDE_CHAPTER_SECOND})

end

function showTip(self)
	local nextChapterId = self.chapterId + 1
	if ChapterConfig[nextChapterId] then
		local master = Master:getInstance()
		local charLevel = ChapterConfig[nextChapterId][1].charLevel
		if master.lv >= charLevel then
			if Chapter.isChapterOpened(nextChapterId) then
				local tipUI = TipsUI.showTips("已开启下一章节，是否立刻进入下一章节？")
				tipUI:addEventListener(Event.Confirm,function(self,event)
					if event.etype == Event.Confirm_yes then
						UIManager.replaceUI("src/modules/chapter/ui/ChapterUI")
					end
				end,self)
				tipUI.name = "ChapterTipTip"
				tipUI:changeParent(self)
			end
		end
	end
end

function hideStarTip(self)
	self.startip:setVisible(false)
	self:removeChildByName('starmask')
end

function showStarTip(self)
	local mask = LayerColor.new('starmask',0,0,0,100,Stage.frameSize.width,Stage.frameSize.height)
	self:addChild(mask)
	self.startip:setTop()
	self.startip:setVisible(true)
	local conf = LevelConfig[self.levelId][self.difficulty]
	if conf.starCondition[3] == 0 then
		self.startip.txtdesc:setString("己方无英雄死亡")
	elseif conf.starCondition[3] == 1 then
		self.startip.txtdesc:setString("己方无英雄阵亡或只阵亡一个英雄")
	else
		self.startip.txtdesc:setString("己方阵亡英雄人数少于或等于两人")
	end
	mask:addEventListener(Event.TouchEvent,function(self,event) 
		if event.etype == Event.Touch_began then
			self:hideStarTip() 
		end
		end,
		self )
end

function clear(self)
	Instance = nil
	Control.clear(self)
	if self.cdTimer then
		self:delTimer(self.cdTimer)
		self.cdTimer = nil
	end

	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step=4, groupId = GuideDefine.GUIDE_CHAPTER_FIRST})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step=3, groupId = GuideDefine.GUIDE_CHAPTER_FIGHT_SEC})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step=3, groupId = GuideDefine.GUIDE_CHAPTER_FIGHT_THIRD})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step=8, groupId = GuideDefine.GUIDE_HERO_ACTIVE})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step=7, groupId = GuideDefine.GUIDE_SIGN_IN})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step=7, groupId = GuideDefine.GUIDE_CHAPTER_SECOND})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step=1, groupId = GuideDefine.GUIDE_CHAPTER_BOX})
end




