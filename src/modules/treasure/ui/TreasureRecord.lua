module(..., package.seeall)
setmetatable(_M, {__index = Control})

local Treasure = require("src/modules/treasure/Treasure")
local TDefine = require("src/modules/treasure/TreasureDefine")
local ItemConfig = require("src/config/ItemConfig").Config
local TreasureConfig = require("src/config/TreasureConfig").Config
local MonsterConfig = require("src/config/MonsterConfig").Config
local ShopDefine = require("src/modules/shop/ShopDefine")
local Shop = require("src/modules/shop/Shop")
function new(recordList)
	local ctrl = Control.new(require("res/treasure/TreasureRecordSkin"),{"res/treasure/TreasureRecord.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(recordList)
	return ctrl
end
function addStage(self)
	-- self:setPositionY(Stage.uiBottom)
end
function uiEffect(self)
	return UIManager.THIRD_TEMP
end



function init(self,recordList)
	local function onCheckMine(self,event,target)
		Treasure.sendTreasureMineInfo(target.mineId)
	end
	local function onCheckReward(self,event,target)
		local reward = {}
		for _,item in ipairs(target.reward) do 
			table.insert(reward,{id=item.itemId,num=item.cnt})
		end
		if #reward > 0 then
			reward[1].title="收益奖励"
			RewardTips.show(reward)
		else
			Common.showMsg("尚无收益")
		end
	end
	self.reclist:setBgVisiable(false)
	local master = Master.getInstance()
	if #recordList > 0 then
		self.norecord:setVisible(false)
		for _,rec in ipairs(recordList) do
			local no = self.reclist:addItem()
			local item = self.reclist:getItemByNum(no)
			local mineId = rec.mineId
			local recType = rec.recType
			Common.setLabelCenter(item.left.lv,"left")
			item.left.lv:setString("Lv"..rec.lv1)
			item.left.charName:setString(rec.name1)
			Common.setLabelCenter(item.right.lv,"right")
			item.right.lv:setString("Lv"..rec.lv2)
			item.right.charName:setString(rec.name2)

			if rec.body1 == 0 then rec.body1 = TDefine.DEF_BODY_ID end
			if rec.body2 == 0 then rec.body2 = TDefine.DEF_BODY_ID end
			CommonGrid.bind(item.left.zjbg)
			item.left.zjbg:setBodyIcon(rec.body1,0.5)
			CommonGrid.bind(item.right.zjbg)
			item.right.zjbg:setBodyIcon(rec.body2,0.5)
			for i=1,4 do 
				CommonGrid.bind(item.left['hero'..i])
				if rec.hero1[i] and rec.hero1[i].name ~= "" then 
					item.left['hero'..i]:setHeroIcon(rec.hero1[i].name,nil,57/92,rec.hero1[i].quality)
				end
				CommonGrid.bind(item.right['hero'..i])
				if rec.recType == TDefine.REC_OCCUPY_SUCCESS then
					local cfg = TreasureConfig[mineId]
					if cfg then
						local mid = cfg.monster[i]
						local mc = MonsterConfig[mid]
						item.right['hero'..i]:setHeroIcon(mc.name,nil,57/92,mc.quality)
					end
				else
					if rec.hero2[i] and rec.hero2[i].name ~= "" then 
						item.right['hero'..i]:setHeroIcon(rec.hero2[i].name,nil,57/92,rec.hero2[i].quality)
					end
				end
			end
			if rec.recType == TDefine.REC_OCCUPY_SUCCESS or rec.recType == TDefine.REC_FINISH then
				local cfg = TreasureConfig[mineId]
				if cfg then
					item.right.charName:setString(cfg.monsterName)
					item.right.lv:setString("Lv"..cfg.monsterLv)
				end
			end

			Common.setLabelCenter(item.txttitle)
			item.txttitle:setString(TDefine.REC_TYPE_NAME[rec.recType].name)
			if rec.recType == TDefine.REC_DEFENCE_FAIL then
				item.left.lose:setVisible(true)
				item.left.win:setVisible(false)
				item.right.lose:setVisible(false)
				item.right.win:setVisible(true)
				item.redbg:setVisible(true)
				item.yellowbg:setVisible(false)
			else
				item.left.lose:setVisible(false)
				item.left.win:setVisible(true)
				item.right.lose:setVisible(true)
				item.right.win:setVisible(false)
				item.redbg:setVisible(false)
				item.yellowbg:setVisible(true)
			end

			if rec.recType == TDefine.REC_DEFENCE_FAIL or rec.recType == TDefine.REC_FINISH then
				item.checkreward:setVisible(true)
				item.checkmine:setVisible(false)
				item.checkreward.reward = rec.reward
			else
				if Treasure.mine[mineId] then
					item.checkmine:setVisible(true)
					item.checkreward:setVisible(false)
					item.checkmine.mineId = mineId
				else
					item.checkmine:setVisible(false)
					item.checkreward:setVisible(false)
				end
			end
			if rec.recType == TDefine.REC_FINISH then
				item.right:setVisible(false)
				item.vs:setVisible(false)
				item.left.win:setVisible(false)
				item.left.lose:setVisible(false)
			else
				item.right:setVisible(true)
				item.vs:setVisible(true)
			end

			item.checkmine:addEventListener(Event.Click,onCheckMine,self)
			item.checkreward:addEventListener(Event.Click,onCheckReward,self)
			Common.setLabelCenter(item.txttime)
			local time = Master.getServerTime() - rec.dt
			local day = math.floor(time / (24*3600))
			time = time - 24*3600*day
			local hour = math.floor(time / 3600)
			time = time - 3600*hour
			local min = math.floor(time / 60)
			local timestr = ""
			if day > 0 then
				timestr = day.."天"
			end
			if hour > 0 then
				timestr = timestr ..hour.."时"
			end
			if min > 0 then
				timestr = timestr ..min.."分"
			end
			if timestr ~= "" then
				item.txttime:setString(timestr.."前")
			else
				item.txttime:setString("刚刚")
			end
		end
	else
		self.norecord:setVisible(true)
	end


end



_M.touch = function(self,event)
	Common.outSideTouch(self,event)
end