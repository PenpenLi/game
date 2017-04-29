module("PartnerFragUI",package.seeall)
setmetatable(PartnerFragUI, {__index = Control})
local BagData = require("src/modules/bag/BagData")
local Chapter = require("src/modules/chapter/Chapter")
local ChapterDefine = require("src/modules/chapter/ChapterDefine")
local ItemConfig = require("src/config/ItemConfig").Config
local PartnerChainConfig = require("src/config/PartnerChainConfig").Config
local Def = require("src/modules/hero/HeroDefine")
local PublicLogic = require("src/modules/public/PublicLogic")

function new(id,materialId)
	local ctrl = Control.new(require("res/hero/HeroFragSkin"),{"res/hero/HeroFrag.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(id,materialId)
	return ctrl
end

function uiEffect()
	return UIManager.THIRD_TEMP
end

function init(self,id,materialId)
	_M.touch = Common.outSideTouch
	CommonGrid.bind(self.frag.iconbg)
	self.frag.iconbg:setItemIcon(materialId)
	local itemCfg = ItemConfig[materialId]
	self.frag.txtheroname:setString(itemCfg.name)
	local fragmentNum = BagData.getItemNumByItemId(materialId)
	local chainCfg = PartnerChainConfig[id]
	local fnum = chainCfg.group[materialId]
	self.frag.progress.txtprogress:setString(fragmentNum.."/"..fnum)

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
					UIManager.addUI('src/modules/chapter/ui/LevelUI',target.chapterId,target.difficulty,target.levelId)
				end
			end
		end
	end
	local levelList = Chapter.getLevelListByReward(materialId)
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
	local shopList = Shop.getShopListById(materialId)
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
		self.frag.txtnochapter:setVisible(true)
		self.frag.txtnochapter:setString("此碎片太珍稀，找不到掉落")
	else
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
			item.levelId = it.chapterId
			item.difficulty = it.difficulty
			item.url = it.url
			item.lv = it.lv
			item:addEventListener(Event.TouchEvent,goChapter,item)
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
	end
end

return PartnerFragUI
