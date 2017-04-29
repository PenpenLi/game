module(..., package.seeall)
setmetatable(_M, {__index = Scene}) 

function new()
	local scene = Scene.new("test") 
	setmetatable(scene, {__index = _M})
	scene:init3()
	return scene
end

function init(self)
	
end

function init2(self)
--[[	local labelSkin = {
		name="memory2",type="Label",x=Stage.width/2,y=100,width=200,height=80,
		normal={txt = '拳皇Q传',font="Helvetica",size=40,bold=false,italic=false,color={255,255,255}}
	}
	local memoryLabel = Label.new(labelSkin)
	memoryLabel:shader(Shader.SHADER_TYPE_OUTLINE, 1.75, 0.01, 255, 0, 0)
	self:addChild(memoryLabel)
	self.memoryLabel = memoryLabel 
]]

	--local ui = Sprite.new("test", "res/HandControl.png")
	local ui = Sprite.new("test", "res/tou_676.png")
	ui:setPosition(100,100)
	ui:shader(Shader.SHADER_TYPE_BLINK, 0.005, 0.02, 255, 0, 0)
	self:addChild(ui)
	self.ui = ui

end

function init3(self)

	local layer = LayerColor.new2("fuckfuckfuck",cc.c4b(0,0,0,255),Stage.winSize.width,Stage.winSize.height)
	layer:setPosition(0,0)
	--layer:setAnchorPoint(cc.p(0.5,0.5))
	self:addChild(layer)

	self:addChild(Sprite.new("map", "res/map/bg004.jpg"))
	
    --ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("res/armature/clark/ClarkTarget.ExportJson")
    --ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("res/armature/athena/Athena.ExportJson")
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("res/Fuck.ExportJson")
	local effect =ccs.Armature:create("Fuck")
	effect:getAnimation():setFrameEventCallFunc(function(bone,evt,originFrameIndex,currentFrameIndex) end)


	--Stage.currentScene:setShader(self.curState.shader,0.0038*2,0.0005*2)
	
	
	--Shader.setArmatureShader(effect, Shader.SHADER_TYPE_BLUR, 0.007, 0.001)
	--Shader.setArmatureShader(effect, Shader.SHADER_TYPE_GRAY, 0.007, 0.001)
	--Shader.setArmatureShader(effect, Shader.SHADER_TYPE_BLINK, 0.4)
	--Shader.setArmatureShader(effect, Shader.SHADER_TYPE_RELIEF,20,20)
	--Shader.setArmatureShader(effect, Shader.SHADER_TYPE_OUTLINE, 2.75, 0.001, 0.9,0.9,0.9)
	
	--local effect =ccs.Armature:create("Fuck")
	--local effect =ccs.Armature:create("Robert")
	effect:setAnchorPoint(0.5,0.5)
	effect:setPosition(300,200)
	local node = cc.Sprite:create("res/hero/bicon/Andy.png")
	node:setPosition(cc.p(0,0))
	node:setAnchorPoint(cc.p(0.5,0.5))
    effect:getBone("Layer1"):addDisplay(node, 0)
	--effect:setScaleX(-1)
	--clark_终结阿根廷攻击_配小黑人
	--effect:getAnimation():play('空中闪光水晶波',-1,-1)
	effect:getAnimation():play('fuck',-1,1)
	--effect:getAnimation():play('fuck',-1,-1)
    --effect:getAnimation():gotoAndPause(28)
	self._ccnode:addChild(effect)
	self.effect = effect

	--[[
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("res/armature/clark/Clark.ExportJson")
	local effect2 =ccs.Armature:create("Clark")
	effect2:setAnchorPoint(0.5,0.5)
	effect2:setPosition(300,200)
	effect2:getAnimation():play('弗兰肯必杀投',-1,0)
    --effect2:getAnimation():gotoAndPause(28)
	self._ccnode:addChild(effect2)
	self.effect2 = effect2
	--]]

	--local box = self.effect:getBone("攻击点"):getBoundingBox()
	local box = self.effect:getBoundingBox()
	--local box = self.effect:getBone("攻击点"):getDisplayManager():getBoundingBox()
	--self._ccnode:addChild(Common.getDrawBoxNode(box))

    self:openTimer()
    self:addEventListener(Event.Frame,onFrameEvent,self)

	self:addEventListener(Event.TouchEvent,onClick,self)

end

function addStage(self)
--	self:fxGhost3()
end

function onFrameEvent(self,event)
	--[[
    --self.sp:update(event.delay)
    self.fuckNode:update(event.delay)
    self.sp:update(event.delay)
    self.ac:update(event.delay)
    self.ac:step(event.delay)
	--]]
	--[[
	if not self.tipsPanel then
		self.tipsPanel = require("src/ui/TipsUI").showTips("多玩游戏真好玩！")
	end
	]]
end

function onClick(self,event, target)
	self.effect:setPosition(event.x,event.y)


	--[[
	local box = self.effect:getBoundingBox()
	self._ccnode:addChild(Common.getDrawBoxNode(box))
	local x,y = self.effect:getPosition()
	local size = self.effect:getContentSize()
	box = cc.rect(x,y,size.width,size.height)
	self._ccnode:addChild(Common.getDrawBoxNode(box, cc.c4b(0,255,0,200)))


	self:fxGhost2()
	--]]
end

function fxGhost(self, isOpen, sec, cnt)
    local x,y = self.effect:getPosition()
	if self.e then
		self._ccnode:removeChild(self.e)
	end
	local ef = self.effect
	local e = ccs.Armature:create(ef:getName())
	--e:getAnimation():play(ef:getAnimation():getCurrentMovementID(),-1,0)
	e:getAnimation():play("击倒A",-1,0)
    e:getAnimation():gotoAndPause(1)
	e:setPosition(x+200,200)
	e:setOpacity(200)
	self.e = e
	self._ccnode:addChild(e)
end

-- 特效：残影 
function fxGhost3(self, isOpen, sec, cnt)
    local box = self.effect:getBoundingBox()
    local x,y = self.effect:getPosition()
	local rt = cc.RenderTexture:create(box.width, box.height)
	rt:setPosition(cc.p(box.x, box.y))
	rt:setAnchorPoint(cc.p(0,0))

	rt:beginWithClear(0,0,0,0)
		self.effect:visit()
	rt["end"](rt) 
	self._ccnode:addChild(rt)
end


-- 特效：残影 
function fxGhost2(self, isOpen, sec, cnt)
    local box = self.effect:getBoundingBox()
    local x,y = self.effect:getPosition()

	print("======> ",box.x,box.y,box.width,box.height,x,y)

	local rt = cc.RenderTexture:create(Stage.winSize.width, Stage.winSize.height)
	--local rt = cc.RenderTexture:create(box.width, box.height)
	--rt:setPosition(cc.p(box.x, box.y))
	--rt:setAnchorPoint(cc.p(0.5,0))

    self.effect:setPosition(cc.p(x-box.x,y-box.y))
	rt:beginWithClear(0,0,0,0)
		self.effect:visit()
	rt["end"](rt) 
    self.effect:setPosition(cc.p(x,y))

	local tex = rt:getSprite():getTexture()
	--tex:setAliasTexParameters()
	local spr = self:getChild("ghost")
	if spr then
		self:removeChild(spr)
	end
	spr = Sprite.new("ghost")
	print("+++++++++spr:setTexture(tex)")
	spr:setTexture(tex)

	--[[

	self:addTimer(function()
	
		local tex = rt:getSprite():getTexture()
		--tex:setAliasTexParameters()
		local spr = self:getChild("ghost")
		if spr then
			self:removeChild(spr)
		end
		spr = Sprite.new("ghost")
		print("+++++++++spr:setTexture(tex)")
		spr:setTexture(tex)
		spr:setPosition(x,y)
		spr:setPosition(0,0)
		spr:setAnchorPoint(0, 0)
		--spr:setScaleY(-1);
		spr:setScale(2)
		--spr:setOpacity(200)
		self:addChild(spr)

		local x,y = spr:getPosition()
		local size = spr:getContentSize()
		print("+++++++++self:addChild(spr)",x,y,size.width,size.height)
		box = cc.rect(x,y,size.width,size.height)
		self._ccnode:addChild(Common.getDrawBoxNode(box, cc.c4b(0,0,200,200)))


		local labelSkin = {
			name="memory",type="Label",x=0,y=0,width=10,height=10,
			normal={txt = 'x',font="Helvetica",size=20,bold=false,italic=false,color={255,255,255}}
		}
		local lb = Label.new(labelSkin)
		spr:addChild(lb)

		local dt = cc.DelayTime:create(0.5)
		local cb = cc.CallFunc:create(function() 
			self._ccnode:removeChild(spr)
		end)
		local seq = cc.Sequence:create({dt,cb})
		--spr:runAction(seq)

		rt:release()
	
	end,1,1)
	]]

end
