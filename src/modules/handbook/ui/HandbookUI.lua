module(..., package.seeall)
setmetatable(_M, {__index = Control})

local Handbook = require("src/modules/handbook/Handbook")
local Def = require("src/modules/handbook/HandbookDefine")
local HeroDefineConfig = require("src/config/HeroDefineConfig").Config
local HeroDefine = require("src/modules/hero/HeroDefine")
local FightDefine = require("src/modules/fight/Define")
local Hero = require("src/modules/hero/Hero")
local ItemConfig = require("src/config/ItemConfig").Config
local SkillDefine = require("src/modules/skill/SkillDefine")
local SkillLogic = require("src/modules/skill/SkillLogic")
local Chapter = require("src/modules/chapter/Chapter")
function new(name)
	local ctrl = Control.new(require("res/handbook/HandbookSkin"),{"res/handbook/Handbook.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(name)
	return ctrl	
end

function uiEffect(self)
	return UIManager.FIRST_TEMP_FULL
end

function addStage(self)
	self:setPositionY(Stage.uiBottom)
end

local function showHeroInfo(self,conf)
	local info = self.herohandbook.heroinfo
	local trendinfo = HeroDefine.CAREER_NAMES[conf.career]
	info.txtcareer:setString(trendinfo)
	info.herodesc:setString(conf.shortIntro)
	info.txtname:setString(conf.cname)
	info:removeChildByName('bighead')
	info.skeleton:setVisible(false)
	local hero = Hero.getHero(conf.name)
	if hero then
		info.bighero:setVisible(false)
		local icon = Sprite.new("bighead","res/hero/bicon/"..conf.name..'.png')
		if icon then
			info:addChild(icon)
			icon:setPosition(info.bighero:getPosition())
			icon:setScaleX(-0.4)
			icon:setScaleY(0.4)
			icon:setPositionX(icon:getPositionX()+200)
		end

		self:loadArmture(conf.name)
		local assistGroupId = SkillLogic.getSkillGroup(hero,SkillDefine.TYPE_ASSIST).groupId
		if assistGroupId then
			self.herohandbook.heroinfo.skillbg1:setSkillGroupIcon(assistGroupId,36)
		end
		local finalGroupId = SkillLogic.getSkillGroup(hero,SkillDefine.TYPE_FINAL).groupId
		if finalGroupId then
			self.herohandbook.heroinfo.skillbg2:setSkillGroupIcon(finalGroupId,36)
		end
	else
		info.bighero:setVisible(true)
		self:removeArmture()
	end
end	

function removeArmture(self)
	if self.curArm then
		self.herohandbook.heroinfo._ccnode:removeChild(self.curArm)
		self.curArm = nil
	end
end
function showHerohandbook(self)

	-- 构造英雄图鉴
	self.herohandbook:setVisible(true)
	self.itemhandbook:setVisible(false)
	local list = self.herohandbook.herohblist
	list:setItemNum(0)
	local no,item
	local row = 0

	local function onClickHero(self,event,target)
		if event.etype == Event.Touch_ended then
			if self.curItem then
				self.curItem:setVisible(false)
			end
			self.curItem = target.chosen
			self.curItem:setVisible(true)
			showHeroInfo(self,target.conf)
		end
	end
	local hlist = {}
	for i,h in ipairs(HeroDefineConfig) do 
		if h.tag == HeroDefine.HERO_TAG_HERO then
			table.insert(hlist,h)
		end
	end
	for i,h in ipairs(hlist) do

		if (i-1) % 9 == 0 then
			no = list:addItem()
			item = list.itemContainer[no]
			item.listBG2:setVisible(false)
			item.listBG3:setVisible(false)
			row = row + 1
		end
		local col = i-math.floor((i-1)/9)*9
		item['card'..col]:setVisible(true)
		local hero = Hero.getHero(h.name)
		if Hero.getHero(h.name) then
			CommonGrid.bind(item['card'..col].shadowcard)
			item['card'..col].shadowcard:setHeroIcon2(h.name,'f',hero.quality,1)
		end
		item['card'..col].chosen:setVisible(false)
		item['card'..col].conf = h
		item['card'..col]:addEventListener(Event.TouchEvent,onClickHero,self)
		if col > 3 then
			item.listBG2:setVisible(true)
		end
		if col > 6 then
			item.listBG3:setVisible(true)
		end
		if i == 1 then
			item['card1']:dispatchEvent(Event.TouchEvent,{etype=Event.Touch_ended})
		end
	end

	for i=1,9 do 
		if (row-1)*9 + i > #hlist then
			item['card'..i]:setVisible(false)
		end
	end
	list:setBgVisiable(false)
	self.txtprogress:setString(Hero.getHeroCount()..'/30')

end

function showItemInfo(self,conf)
	if conf then
		self.itemhandbook.iteminfo.txticon:setString(conf.name)
		self.itemhandbook.iteminfo.itemdesc:setString(conf.desc)
		self.itemhandbook.iteminfo.grid:setItemIcon(conf.id,"descIcon")
		local levellist = Chapter.getLevelListByReward(conf.id)
		if levellist[1] then
			local title = Chapter.getLevelTitle(levellist[1].levelId)
			self.itemhandbook.iteminfo.itemsource:setString(title)
		else
			self.itemhandbook.iteminfo.itemsource:setString("未知")
		end
	else
		self.itemhandbook.iteminfo.txticon:setString("未知")
		self.itemhandbook.iteminfo.itemdesc:setString("未知")
		self.itemhandbook.iteminfo.itemsource:setString("未知")
		self.itemhandbook.iteminfo.grid:setItemIcon()
	end
end


function showItemHandbook(self,tag)
	tag = tonumber(tag)
	self.herohandbook:setVisible(false)
	self.itemhandbook:setVisible(true)
	self.curItem = nil 
	local function onClickItem(self,event,target)
		if event.etype == Event.Touch_ended then
			if self.curItem then
				self.curItem:setVisible(false)
			end
			self.curItem = target.itemchosen
			self.curItem:setVisible(true)
			showItemInfo(self,target.conf)
		end
	end
	local list = self.itemhandbook.itemhblist
	local index = 0
	local no,item
	local row = 0
	local chosenflag
	local cnt = 0
	local libcnt = 0
	self.itemhandbook.itemhblist:setItemNum(0)
	self.itemhandbook.itemhblist:setBgVisiable(false)
	for itemId,conf in pairs(ItemConfig) do
		if conf.handbookTag == tag then
			index = index + 1
			if (index - 1)%9 == 0 then
				no = list:addItem()
				item = list.itemContainer[no]
				item.listBG2:setVisible(false)
				item.listBG3:setVisible(false)
				row = row + 1
			end
			local col = index-math.floor((index-1)/9)*9
			item['gezi'..col]:setVisible(true)

			if Handbook.isItemInLib(itemId) then
				CommonGrid.bind(item['gezi'..col])
				item['gezi'..col]:setItemIcon(itemId)
				item['gezi'..col].conf = conf
				libcnt = libcnt + 1
			end
			item['gezi'..col].itemchosen:setVisible(false)
			
			item['gezi'..col]:addEventListener(Event.TouchEvent,onClickItem,self)
			if chosenflag == nil then
				chosenflag = itemId
				item['gezi'..col]:dispatchEvent(Event.TouchEvent,{etype=Event.Touch_ended})
			end

			if col > 3 then
				item.listBG2:setVisible(true)
			end
			if col > 6 then
				item.listBG3:setVisible(true)
			end
			cnt = cnt + 1
		end
	end
	for i=1,9 do
		if (row-1)*9 + i > cnt then
			item['gezi'..i]:setVisible(false)
		end
	end
	self.txtprogress:setString(libcnt.."/"..cnt)

end

function loadArmture(self,name)
	local loader = AsyncLoader.new()
	loader:addEventListener(loader.Event.Load,function(self,event) 
		if event.etype == AsyncLoader.Event.Finish then
			if self.alive then
				--载入待机动画
				local info = self.herohandbook.heroinfo
				self:removeArmture()
				local resUrl = string.format("res/armature/%s/%s.ExportJson",string.lower(name),name)
				if resUrl then
					self:addArmatureFrame(resUrl)
				end
				-- 播放待机动画
				self.curArm = ccs.Armature:create(name)
				info._ccnode:addChild(self.curArm)
				self.curArm:setPosition(info.skeleton:getPosition())
				self.curArm:getAnimation():playWithNames({'待机'},0,true)
				self.curArm:setScale(0.8)

			else
				loader:removeAllArmatureFileInfo()
			end
		end
	end,self)
	loader:addArmatureFileInfo(string.format("res/armature/%s/%s.ExportJson",string.lower(name),name))
	loader:start()
end

function init(self,name)
	self.curItem = nil 
	self.curArm = nil 
	CommonGrid.bind(self.herohandbook.heroinfo.skillbg1)
	CommonGrid.bind(self.herohandbook.heroinfo.skillbg2)
	CommonGrid.bind(self.itemhandbook.iteminfo.grid)
	local function onClose(self,event,target) 
		UIManager.removeUI(self)
	end
	self.back:addEventListener(Event.Click,onClose,self)

	local function onReward(self,event,target)
		UIManager.addUI("src/modules/handbook/ui/HandbookRewardUI",name)
	end
	self.reward:addEventListener(Event.Click,onReward,self)
	if name == 'hero' then
		self:showHerohandbook()
	elseif name == 'item' then
		function onClickRGB(self,event,target)
			self:showItemHandbook(target.name)
		end
		for _,rb in ipairs(self.itemhandbook.itemrgb:getChildren()) do 
			rb:addEventListener(Event.Click,onClickRGB,self)
		end
		self.itemhandbook.itemrgb['1']:dispatchEvent(Event.Click,{etype=Event.Click})
		self.itemhandbook.itemrgb['1']:setSelected(true)
	end
end

