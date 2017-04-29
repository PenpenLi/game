module("HeroFragUI", package.seeall)
setmetatable(HeroFragUI, {__index = Control})





local Def = require("src/modules/hero/HeroDefine")
local HeroQualityConfig = require("src/config/HeroQualityConfig").Config
local Hero = require("src/modules/hero/Hero")
local BagData = require("src/modules/bag/BagData")
local Chapter = require("src/modules/chapter/Chapter")
local ChapterDefine = require("src/modules/chapter/ChapterDefine")
local BaseMath = require("src/modules/public/BaseMath")
local PublicLogic = require("src/modules/public/PublicLogic")






function new(name)
	local ctrl = Control.new(require("res/hero/HeroFragSkin"),{"res/hero/HeroFrag.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(name)
	return ctrl
end

function uiEffect()
	return UIManager.THIRD_TEMP
end


function showCard(self,name)
	local conf = Def.DefineConfig[name]
	local illu = self.illustration
	Common.setLabelCenter(illu.txtname)
	illu.txtname:setString(conf.cname)
	if illu:getChild('heroicon') == nil then
		local spr = Sprite.new('heroicon','res/hero/cicon/'..name..".jpg")
		if spr then
			illu:addChild(spr)
			local size = illu:getContentSize()
			spr:setPosition(size.width/2,size.height/2)
			spr:setAnchorPoint(0.5,0.5)
			spr._ccnode:setLocalZOrder(-1)
			spr:setScale(0.99)
			spr.hname = name
		end
	end
	for i=1,5 do
		if i == conf.career then
			illu.careericon['careericon'..i]:setVisible(true)
		else
			illu.careericon['careericon'..i]:setVisible(false)
		end
	end
	for i=1,5 do
		illu.staricon['star'..i]:setVisible(false)
	end
	-- illu.

end

function init(self,name)
	_M.touch = Common.outSideTouch
	local conf = Def.DefineConfig[name]
	-- self:showCard(name)
	
	local hero = Hero.getHero(name)
	CommonGrid.bind(self.frag.iconbg)
	self.frag.iconbg:setHeroIcon(name,'s',72/92)

	local fragId = conf.fragId
	local fragmentNum = BagData.getItemNumByItemId(fragId)
	if Hero.getHero(name) then
		self.frag.txtheroname:setString(conf.cname.."(已获得)")
		self.frag.progress.txtprogress:setString(fragmentNum)
	else
		local fnum = BaseMath.getHeroRecruitFrag(name)
		self.frag.progress.txtprogress:setString(fragmentNum.."/"..fnum)
		self.frag.txtheroname:setString(conf.cname)
	end
	local levelList = Chapter.getLevelListByReward(fragId)
	local function goChapter(self,event,target)
		if event.etype == Event.Touch_ended then
			if target.url == nil and target.txtnotopened:isVisible() then
				Common.showMsg("本关卡尚未开放")
			else
				-- Chapter.sendLevelStart(target.levelId,target.difficulty)
				if target.url then
					if target.lv and Master.getInstance().lv < target.lv then
						Common.showMsg("战队等级达到"..target.lv.."级开放")
					else
						--local ui = UIManager.addChildUI(target.url)
						if target.childUI then
							UIManager.removeUI(self)
							UIManager.addChildUI(target.url,name)
						else
							UIManager.replaceUI(target.url)
						end
						--ui:setPositionY(0)
					end
				else
					UIManager.addUI('src/modules/chapter/ui/LevelUI',target.chapterId,target.difficulty,target.levelId)
				end
			end
		end
	end

	local itemList = {}
	self.frag.guankalist:setItemNum(0)
	self.frag.guankalist:setVisible(true)
	self.frag.txtnochapter:setVisible(false)
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
	for _,src in ipairs(conf.fragSource) do
		local source = Def.FRAGSOURCE[src]
		if source then
			local lv = PublicLogic.getOpenLv(source.module)
			if source.checkFunc and not source.checkFunc(Master.getInstance(),hero) then
			else
				table.insert(itemList,{src=src,title=source.name,content=source.desc,url=source.url,opened = true,lv=lv,childUI = source.childUI})
			end
		end
	end

	if #itemList > 0 then
		for i,it in ipairs(itemList) do
			local no = self.frag.guankalist:addItem()
			local item = self.frag.guankalist:getItemByNum(no)
			item.buy:setVisible(false)
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
			item.childUI = it.childUI
			item:addEventListener(Event.TouchEvent,goChapter,self)
			if it.url then
				local difficultyName = ChapterDefine.DIFFICULTY_NAME[it.difficulty]
				local diffIcon = Sprite.new('diffIcon',"res/common/icon/fragSource/"..it.src..".png")
				if diffIcon then
					item:addChild(diffIcon)
					local px,py = item.headBG:getPosition()
					local size = item.headBG:getContentSize()
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
					local px,py = item.headBG:getPosition()
					local size = item.headBG:getContentSize()
					diffIcon:setPosition(px+size.width/2,py+size.height/2)
					diffIcon:setAnchorPoint(0.5,0.5)
					diffIcon:setScale(64/82)
				end
			end
		end
		self.frag.txtnochapter:setVisible(false)
	else
		self.frag.txtnochapter:setVisible(true)
	end

end


return HeroFragUI
