module(...,package.seeall)
setmetatable(_M, {__index = EventDispatcher}) 

local Def = require("src/modules/hero/HeroDefine")
local BaseMath = require("src/modules/public/BaseMath")
local DyAttrCalc = require("src/modules/hero/DyAttrCalc")
local FBConfig = require("src/config/FBConfig").Config
local PartnerData = require("src/modules/partner/PartnerData")
local StrengthTransferConfig = require("src/config/StrengthTransferConfig").Config
local SkillDefine = require("src/modules/skill/SkillDefine")
local SkillGroup = require("src/modules/skill/SkillGroup")
local BagData = require("src/modules/bag/BagData")
local HeroQualityConfig = require("src/config/HeroQualityConfig").Config
local HeroBTConfig = require("src/config/HeroBreakthroughConfig").Config
local PublicLogic = require("src/modules/public/PublicLogic")
heroes = {}
expedition = {}
function getHero(name)
	return heroes[name]
end

function getHeroCountByQuality(quality)
	local count = 0
	for _,hero in pairs(heroes) do
		if hero.quality >= quality then
			count = count + 1
		end
	end
	return count
end

function getHeroCount()
	local count = 0
	for _,_ in pairs(heroes) do
		count = count + 1
	end
	return count
end

function getHeroCountMoreThanLv(lv)
	local count = 0
	for _,hero in pairs(heroes) do
		if hero.lv >= lv then
			count = count + 1
		end
	end
	return count
end

function resetAllHeroFightAttr()
	for _,hero in pairs(heroes) do
		hero.fightAttr.hp = nil
		hero.fightAttr.rage = nil
		hero.fightAttr.assist = nil
	end
end


--参数hero是后端传递过来的hero数据
function new(name,exp,lv,quality,ctime,btLv,status,dyAttr,exchange)
	local h = {}
	h.name = name
	h.exp = exp
	h.lv = lv
	h.quality = quality
	h.status = status or Def.STATUS_NORMAL
	h.ctime = ctime or 0
	h.career = Def.DefineConfig[name].career
	h.careerName = Def.CAREER_NAMES[h.career]
	h.cname = Def.DefineConfig[name].cname
	h.trend = Def.DefineConfig[name].trend
	h.trendtxt = Def.TREND_NAMES[h.trend]
	h.fragId = Def.DefineConfig[name].fragId
	h.btLv = btLv or 0
    h.dyAttr = processDyAttr(dyAttr or {})
    h.fightAttr = {hp=nil,rage=nil,assist=nil}
    h.gender = Def.DefineConfig[name].gender
    h.ai = Def.DefineConfig[name].ai
    h.breakRate = Def.DefineConfig[name].breakRate
    h.exchange = exchange
	setmetatable(h,{__index=_M})
	--技能列表
	h.skillGroupList = require("src/modules/skill/SkillLogic").init(h)
	h.strength = require("src/modules/strength/StrengthLogic").init(h)
	h.gift = {}
	h.train = require("src/modules/train/TrainLogic").init(h)
	PartnerData.addHero(name)
	return h
end

function refreshHero(self,name,exp,lv,quality,ctime,btLv,status,dyAttr,exchange)
	self.name = name
	self.exp = exp
	self.lv = lv
	self.quality = quality
	self.status = status
	self.ctime = ctime
	self.career = Def.DefineConfig[name].career
	self.careerName = Def.CAREER_NAMES[self.career]
	self.cname = Def.DefineConfig[name].cname
	self.trend = Def.DefineConfig[name].trend
	self.trendtxt = Def.TREND_NAMES[self.trend]
	self.fragId = Def.DefineConfig[name].fragId
	self.btLv = btLv
    self.dyAttr = processDyAttr(dyAttr)
    self.fightAttr = {hp=nil,rage=nil,assist=nil}
    self.gender = Def.DefineConfig[name].gender
    self.ai = Def.DefineConfig[name].ai
    self.exchange = exchange
end

function copy(self)
	local hero = new(self.name,self.exp,self.lv,self.quality,self.ctime,{},{})
	hero.dyAttr = Common.deepCopy(self.dyAttr)
	local cp = {}
	for _,group in ipairs(self.skillGroupList) do
		local newGroup = SkillGroup.new(hero,group.groupId)
		newGroup.equipType = group.equipType
		newGroup:setLv(group.lv)
		cp[#cp+1] = newGroup 
	end
	hero.skillGroupList = cp
	return hero 
end

function getSkillGroupList(self)
	return self.skillGroupList
end

function processDyAttr(dyAttr)
	for _,attr in ipairs(Def.DecimalAttrs) do
		if dyAttr[attr] then
			dyAttr[attr] = dyAttr[attr]/100
		end
	end
	return dyAttr
end

function freshAttr(self,exp,lv,quality,ctime,btLv,status,dyAttr,exchange)
	self.exp = exp
	self.lv = lv
	self.quality = quality
	self.ctime = ctime
	self.btLv = btLv
	self.status = status
	self.dyAttr =  processDyAttr(dyAttr)
	self.exchange = exchange
end

function addExp(self,delta)
end


--获得升级到下个等级需要多少经验
function getExpForNextLv(self)
	return self:getExpForLv(self.lv + 1)
end

--获得升级到某个等级需要多少经验
function getExpForLv(self,lv)
	return BaseMath.getHeroExp(lv)
end

function isInExpedition(self)
	for _,n in pairs(expedition) do
		if self.name == n then return true end
	end
	return false
end

function getFight(self)
	--属性相关
	local fight = 0
	fight = self.dyAttr.maxHp * (1 + 0.00012 * self.dyAttr.def + 0.00008 * self.dyAttr.finalDef)
		* (1 + self.dyAttr.block / 4000) * (1 + self.dyAttr.antiCrthit / 4000)
		* (0.6 * self.dyAttr.atk + 0.4 * self.dyAttr.finalAtk) * (1 + self.dyAttr.crthit / 4000)
		* (1 + self.dyAttr.antiBlock / 4000) * (self.dyAttr.atkSpeed / 100) / 10000 + 100

	--技能相关
	for _,group in pairs(self:getSkillGroupList()) do
		if group:isEquip() == true or group.type == SkillDefine.TYPE_FINAL or group.type == SkillDefine.TYPE_ASSIST then
			fight = fight + group:getFight()
		end
	end 

	fight = math.floor(fight)
	return fight
end

function swapExpedition(a,b)
	expedition[a],expedition[b] = expedition[b],expedition[a]
end


function getExpedition(self)
	for i,name in ipairs(expedition) do 
		if name == self.name and i < 4 then
			return Def.EXP_ON
		elseif name == self.name and i == 4 then
			return Def.EXP_ASSIST
		end
	end
	return Def.EXP_OFF
end

function getEquipCount(self)
	local count = 0
	local gridList = self.equip.grids
	for _,grid in pairs(gridList) do
		if grid:hasEquip() == true then
			count = count + 1
		end
	end
	return count
end

function sortRecruitedHero(a,b)
	local sortA=0
	local sortB=0
	if a.sort then
		sortA = a.sort
	end
	if b.sort then
		sortB = b.sort
	end

	-- 已招募英雄的排序规则等级、转职等级、星级
	if a.quality ~= b.quality then
		return a.quality > b.quality
	elseif a.lv ~= b.lv then
		return a.lv > b.lv
	elseif a.strength.transferLv ~= b.strength.transferLv then
		return a.strength.transferLv  > b.strength.transferLv
	elseif a.exp ~= b.exp then
		return a.exp > b.exp
	elseif sortA ~= sortB then
		return sortA < sortB
	elseif a.ctime ~= b.ctime then
		return a.ctime < b.ctime
	else
		return a.name < b.name
	end
end

function getSortedHeroes()
	local hlist = {}

	for _,h in pairs(heroes) do
		table.insert(hlist,h)
	end
	table.sort(hlist,sortRecruitedHero)
	return hlist
end

function getNeighbours(name)
	local hlist = getSortedHeroes()
	local no = 0
	for i=1,#hlist do
		if hlist[i].name == name then
			no = i
			break
		end
	end
	local left,right
	if no > 1 then
		left = hlist[no-1].name
	else
		left = hlist[#hlist].name
	end
	if no < #hlist then
		right = hlist[no+1].name
	else
		right = hlist[1].name
	end

	return left,right
end

function getCNameByName(name)
	if not Def.DefineConfig[name] then return  end
	return Def.DefineConfig[name].cname
end

function getRNameByName(name)
	local hero = heroes[name]
	if not hero then
		return Def.DefineConfig[name].cname
	end
	local strength = hero.strength
	local cfg = StrengthTransferConfig[strength.transferLv]
	return cfg and cfg.name ..".".. hero.cname or hero.cname
end

function getAttrCName(name)
	return Def.DyAttrCName[name]
end

function getHeroIcon(name,type)
	return 'res/hero/'..type..'icon/'..name..".png"
end

function getCost(self)
	return self.dyAttr.cost
end

function isBreakThroughEnabled(self)
	if self.btLv >= Def.MAX_BT then
		return false
	end
	local targetLv = self.btLv + 1
	local heroLvRequired,stoneCntRequired,moneyRequired,heroStarRequired = getBTLvInfo(targetLv)

	if self.lv < heroLvRequired then
		return false
	end
	if self.quality < heroStarRequired then
		return self
	end
	local stoneCnt = BagData.getItemNumByItemId(Def.BREAK_STONE_ID)
	if stoneCnt < stoneCntRequired then
		return false
	end
	if Master.getInstance().money < moneyRequired then
		return false
	end
	return true
end
function isStarUpEnabled(self,nomoney)
	if self.quality >= Def.MAX_QUALITY then
		return false
	end
	local frag = BaseMath.getHeroQualityFrag(self.name,self.quality+1)
	local fragId = Def.DefineConfig[self.name].fragId
	if BagData.getItemNumByItemId(fragId) < frag then 
		return false
	end
	if not nomoney then
		local money = Master:getInstance().money
		if money < HeroQualityConfig[self.quality+1].qualityMoney then
			return false
		end
	end
	return true
end

function getBTLvInfo(lv)
	if HeroBTConfig[lv] then
		return HeroBTConfig[lv].heroLv,HeroBTConfig[lv].stone,HeroBTConfig[lv].money,HeroBTConfig[lv].heroStar
	end
end

function getHeroBTList(name)
	local conf = Def.DefineConfig[name]
	if conf then
		return conf.breakThrough
	end
end

function getBTAttr(attr,lv)
	if lv == 0 then return 0 end
	if HeroBTConfig[lv] and HeroBTConfig[lv][attr] then
		local value = 0
		for i=1,lv do
			value = value + HeroBTConfig[i][attr]
		end
		return value
	end
end

function getBTAnimation(btLv)
	if btLv >= 8 then
		return "Animation3"
	elseif btLv >= 5 then
		return "Animation2"
	elseif btLv >= 2 then
		return "Animation1"
	end
end

function showHeroNameLabel(self,txtlabel,btLv)
	if txtlabel then
		local v = self.btLv
		if btLv then v = btLv end
		if v > 0 then
			txtlabel:setString(self.cname.."+"..v)
		else
			txtlabel:setString(self.cname)
		end
		local q = Def.HERO_QUALITY[self.quality]
		txtlabel:setColor(q.r,q.g,q.b)
		local d = 2
		txtlabel:enableShadow(d,-d)
		txtlabel:enableStroke(200,0,0,d)
	end
end

return Hero
