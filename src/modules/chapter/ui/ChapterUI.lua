module(..., package.seeall)
setmetatable(_M, {__index = Control})

local Chapter = require("src/modules/chapter/Chapter")
local FBConfig = require("src/config/FBConfig").Config
local LevelConfig = require("src/config/LevelConfig").Config
local ChapterConfig = require("src/config/ChapterConfig").Config
local BaseMath = require("src/modules/public/BaseMath")
local LevelUI = require("src/modules/chapter/ui/LevelUI")
local ExpConfig = require("src/config/ExpConfig").Config

lastChapterId = nil

function new(chapterId)
	local ctrl = Control.new(require("res/chapter/ChapterSkin"),{"res/chapter/Chapter.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(chapterId)
	return ctrl	
end

function uiEffect(self)
	return UIManager.FIRST_TEMP_LABEL
end

function addStage(self)
	self:setPositionY(Stage.uiBottom)
end


-- 地震特效 sec:每次震荡时间 cnt:震荡次数 dis:震幅  dir:震动方向 ddis:震幅变化
function shock(self, sec, cnt, dis, dir, ddis)
	if not self.fx_shock then
		self.fx_shock = true 
		sec = sec or 0.6
		cnt = cnt or 5 
		dis = dis or 15 
		dir = dir or 90 
		ddis = ddis or 0 
		local ary = {}
		for i=1, cnt do
			--local d = dis * (cnt - i + 1) / cnt
			local d = dis + i * ddis 
			local dy = math.sin(dir/180*math.pi) * d
			local dx = math.cos(dir/180*math.pi) * d
			local move = cc.MoveBy:create(sec/2, cc.p(-dx, -dy))
			--local sine = cc.EaseSineOut:create(move)
			--table.insert(ary, sine)
			table.insert(ary, move)

			move = cc.MoveBy:create(sec/2, cc.p(dx, dy))
			--sine = cc.EaseSineIn:create(move)
			--table.insert(ary, sine)
			table.insert(ary, move)
		end
		table.insert(ary, cc.CallFunc:create(function()
			self.fx_shock = nil
		end))
		local seq = cc.Sequence:create(ary)
		self:runAction(seq)
	end
end

function setRadioBtn(self,num)
	local template = {name="region1",type="RadioButton",x=0,y=0,width=31,height=30,children=
		{
			{name="myImage",type="Image",x=0,y=0,width=31,height=30,
				{name = "on",status = "down",img="Chapter.on_dn",x=0,y=0,width=23,height=23},
				{name = "off",status = "normal",img="Chapter.off_nl",x=0,y=0,width=31,height=30},
			}
		},
	}
	for i = 2,num do
		local skin = Common.deepCopy(template)
		local ctrl = RadioButton.new(skin)
		ctrl.name = "region"..i
		ctrl:setPositionX((i-1)*30)
		ctrl:setEnabled(false)
		self.pageballs:addChild(ctrl)
	end
	local size = self.pageballs:getContentSize()
	self.pageballs:setContentSize(cc.size(size.width+num*30,size.height))
	self.pageballs:setPositionX(self.chapterpage:getPositionX()+self.chapterpage:getContentSize().width/2)
	self.pageballs:setAnchorPoint(0.5,0)
end

function init(self,chapterId)
	local function onClose(self,event,target) 
		UIManager.removeUI(self)
	end 	
	self.back:addEventListener(Event.Click,onClose,self)
	local FC = Chapter.FBContainer
	local maxChapterId = 0
	--确定到底有多少page 首先要确定最高解锁章节
	for cid,_ in pairs(ChapterConfig) do 
		if cid > maxChapterId then
			maxChapterId = cid
		end
	end
	-- maxChapterId = maxChapterId + 1
	local pageNum = math.ceil(maxChapterId/5)
	self.pageNum = pageNum
	local topPageId = 1

	self.chapterpage:setUnitNum(pageNum)
	self:addArmatureFrame("res/chapter/effect/chapter/chapter.ExportJson")
	-- self:addArmatureFrame("res/chapter/effect/topchapter.ExportJson")

	self:setRadioBtn(pageNum)
	function onFlip(self,event,target)
		self.pageballs:onChildTouch(self.pageballs['region'..event.currentUnit])
	end
	self.chapterpage:addEventListener(Event.FlipUnitEvent,onFlip,self)
	self.pageballs:onChildTouch(self.pageballs['region1'])

	self.pages:setVisible(false)

	for i=1,pageNum do
		local page = self.chapterpage.unitContainer[i]:getChild('page')
		page.pageId = i
		page.pagebg:setVisible(false)
		for k=1,5 do
			local cid = (i-1)*5 + k
			page:removeChildByName('chapter'..k)
			-- page['chapter'..k] = nil
			-- print('i='..i.." k="..k)
			local skin = Common.deepCopy(self.pages['page'..i]['chapter'..cid]._skin)
			print('cid='..cid.." i="..i)
			local c = Control.new(skin)
			page:addChild(c)
		end

		page.touch = 
		function(self,event)
			if event.etype == Event.Touch_ended then
				local worldPoint = event.p
				for p=1,5 do 
					local cid = (self.pageId-1)*5 + p
					local child = self['chapter'..cid]
					if child.valid then
						local touchLocation = self._ccnode:convertToNodeSpace(worldPoint) 
						if child.touchEnabled and child:isVisible() then
							local bound = child._ccnode:getBoundingBox()
							if cc.rectContainsPoint(bound, touchLocation) then
								local chapterId = child.chapterId 
								local cartoon = child['cartoon'..cid]._ccnode
								local loc = cartoon:convertToNodeSpace(worldPoint)
								local ret,r,g,b,a = cartoon:getPixelRGBA(loc.x,loc.y)
								print('ret='..tostring(ret)..' r='..r..' g='..g..' b='..b..' a='..a)
								if ret and a > 0 then
									local master = Master:getInstance()

									local charLevel = ChapterConfig[chapterId][1].charLevel
									
									if master.lv >= charLevel then
										UIManager.addUI("src/modules/chapter/ui/LevelUI",chapterId)
									else
										Common.showMsg("战队等级达到"..charLevel.."级开放本章节")
									end
									return true
								end
							end
						end

					end
				end
			end
			return false
		end

		local tipAni = ccs.Armature:create('chapter')

		local loc = page._ccnode:convertToNodeSpace(cc.p(self:getContentSize().width/2,self:getContentSize().height/2)) 
		page._ccnode:addChild(tipAni)
		tipAni:setPosition(loc)
		tipAni:setVisible(false)
		local topchapter = Chapter.getTopOpenedChapter()
		for j=1,5 do
			local chapterId = (i-1)*5 + j
			page['chapter'..chapterId].chapterId = chapterId
			print(chapterId)
			-- if Chapter.getTopOpenedDifficulty(chapterId) > 0 or Chapter.debugFlag then
			if Chapter.isChapterOpened(chapterId) or Chapter.debugFlag then
				local c = Chapter.openedChapter
				if Chapter.openedChapter[chapterId] == nil then
					-- 开启此章节
					--sec:每次震荡时间 cnt:震荡次数 dis:震幅  dir:震动方向 ddis:震幅变化
					shock(page['chapter'..chapterId],0.1, 5, 5,50)
					shock(page['chapter'..chapterId],0.1, 5, 5,100)
					shock(page['chapter'..chapterId],0.1, 5, 5,50)
					shock(page['chapter'..chapterId],0.1, 5, 5,100)
					Chapter.openedChapter[chapterId] = true

					-- tipAni:getAnimation():play("当前状态"..i.."_"..j,-1,-1)
					-- tipAni:setVisible(true)
					
					-- local scaleTo = cc.ScaleTo:create(0.3,1.01,1.01)
					-- local sineOut = cc.EaseSineOut:create(scaleTo)
					-- local scaleTo2 = cc.ScaleTo:create(0.3,0.99,0.99)
					-- local sineOut2 = cc.EaseSineOut:create(scaleTo2)
					-- local seq = cc.Sequence:create({sineOut,sineOut2})
					-- local repeate = cc.RepeatForever:create(seq)
					-- page['chapter'..chapterId]:runAction(repeate)
				end

				page['chapter'..chapterId].valid = true
				-- local animation =ccs.Armature:create('chapter')
				-- page._ccnode:addChild(animation)
				-- local loc = page._ccnode:convertToNodeSpace(cc.p(self._skin.width/2,self._skin.height/2))
				-- animation:setPosition(loc)
				-- animation:setScale(1/Stage.uiScale)
				-- animation:getAnimation():play(tostring(j),-1,-1)
				topPageId = i
			else
				page['chapter'..chapterId]:shader(Shader.SHADER_TYPE_GRAY)
				page['chapter'..chapterId].valid = false
			end

			if chapterId == 1 then
				local firstLevelId = Chapter.getFirstLevel(1)
				local opened,passed = Chapter.getLevelInfo(firstLevelId,1)
				if not passed then
					self:addArmatureFrame("res/armature/effect/Finger.ExportJson")
					self.fingerEffect = ccs.Armature:create("Finger")
					self.fingerEffect:getAnimation():play("特效",-1,1)
					local size = page.chapter1:getContentSize()
					page.chapter1._ccnode:addChild(self.fingerEffect)
					self.fingerEffect:setPosition(size.width/2,size.height/2)
				end
			end
					


			if chapterId == topchapter then

				page['chapter'..chapterId]:shader(Shader.SHADER_TYPE_BLINK)
				-- tipAni:getAnimation():play("当前状态"..i.."_"..j,-1,-1)
				-- tipAni:setVisible(true)
			elseif chapterId < topchapter then
				page['chapter'..chapterId]:shader()
			else
				page['chapter'..chapterId]:shader(Shader.SHADER_TYPE_GRAY)
			end

			Dot.check(page['chapter'..chapterId]['p'..chapterId],"chapterUIBox",chapterId)
			Dot.setDotAlignment(page['chapter'..chapterId]['p'..chapterId],'lBottom',{x=-5,y=-5})
			

		end



		if i == 1 then	
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=page.chapter1, step = 3, touchComponent = page, groupId = GuideDefine.GUIDE_CHAPTER_FIRST})
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=page.chapter1, step = 2, touchComponent = page, groupId = GuideDefine.GUIDE_CHAPTER_FIGHT_SEC})
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=page.chapter1, step = 2, touchComponent = page, groupId = GuideDefine.GUIDE_CHAPTER_FIGHT_THIRD})
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=page.chapter1, step = 7, touchComponent = page, groupId = GuideDefine.GUIDE_HERO_ACTIVE})
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=page.chapter1, step = 6, touchComponent = page, groupId = GuideDefine.GUIDE_SIGN_IN})
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=page.chapter1, step = 3, touchComponent = page, groupId = GuideDefine.GUIDE_CHAPTER_DIFF})
		end
	end
	local lc = lastChapterId
	if lc then
		local p= math.floor((lc-1)/5) + 1
		self.chapterpage:selectUnit(p,0)
	else
		local topchapter = Chapter.getTopOpenedChapter()
		local p= math.floor((topchapter-1)/5) + 1
		self.chapterpage:selectUnit(p,0)
		self:refreshArrow(p)
	end
	self.chapterpage:getChild("chapterbg"):setVisible(false)



	-- local master = Master:getInstance()
	-- local physicsLimit = ExpConfig[master.lv].physics
	-- local percent = math.min(100,master.physics*100/physicsLimit)
	-- self.physics.physicsprog:setPercent(percent)
	-- Common.setLabelCenter(self.physics.txtPhysics)
	-- self.physics.thenxtPhysics:setString(master.physics)
	
	local function onNext(self,event,target)
		local cur = self.chapterpage.currentUnit
		if target.name == 'left' then
			if cur > 1 then
				self.chapterpage:selectUnit(cur - 1)
			end
			if cur == 2 then
				self.left:setVisible(false)
			end
			if cur == pageNum then
				self.right:setVisible(true)
			end
		elseif target.name == 'right' then
			if cur < pageNum then
				self.chapterpage:selectUnit(cur + 1)
			end
			if cur == pageNum - 1 then
				self.right:setVisible(false)
			end
			if cur == 1 then
				self.left:setVisible(true)
			end
		end
		-- self:refreshArrow()
	end
	
	self.left:addEventListener(Event.Click,onNext,self)
	self.right:addEventListener(Event.Click,onNext,self)



end

function refreshArrow(self,cur)
	if cur >= self.pageNum then
		self.right:setVisible(false)
	else
		self.right:setVisible(true)
	end
	if cur == 1 then
		self.left:setVisible(false)
	else
		self.left:setVisible(true)
	end
end

function clear(self)
	Control.clear(self)
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 3, groupId = GuideDefine.GUIDE_CHAPTER_FIRST})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 2, groupId = GuideDefine.GUIDE_CHAPTER_FIGHT_SEC})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 2, groupId = GuideDefine.GUIDE_CHAPTER_FIGHT_THIRD})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 3, groupId = GuideDefine.GUIDE_HERO_ACTIVE})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 6, groupId = GuideDefine.GUIDE_SIGN_IN})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 3, groupId = GuideDefine.GUIDE_CHAPTER_DIFF})
end
