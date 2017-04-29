module(..., package.seeall)
local HeroDefine = require("src/modules/hero/HeroDefine")
local HeroQualityConfig = require("src/config/HeroQualityConfig").Config
local DyAttrName = HeroDefine.DyAttrName
local HeroConfig = HeroDefine.DefineConfig
local HeroAttrConfig = HeroDefine.AttrConfig
local BaseMath = require("src/modules/public/BaseMath")


inFactor = {
	atkA = {5.5,3,3.2},
	defA = {4.3,3.2,2.8},
	atkB = {3.4,5,2.6},
	defB = {2.8,4.5,2.4},
	atkC = {3.5,2.4,4.9},
	defC = {4.1,2.7,4.7},
	maxHp = {2.5,2.5,2.5},
	cost = {1.2,1.2,1.2},
}

qualityFactor = {
	[1] = 1,     -- 白
	[2] = 1.1,   -- 绿
	[3] = 1.2,   -- 蓝
	[4] = 1.3,   -- 黄
	[5] = 1.4,   -- 红
	[6] = 1.5,   -- 紫
	[7] = 1.7,   -- 橙
}

function getHeroDyAttr(hero,dyAttr,lv,quality)
	local name = hero.name
	
	-- 英雄偏向
	local trend = HeroDefine.DefineConfig[name].trend
	for _,attr in pairs(DyAttrName) do 
		if not dyAttr[attr] then dyAttr[attr] = 0 end
		local value = HeroDefine.DefineConfig[name][attr]

		local qua = HeroQualityConfig[quality][attr..'Rate'] or HeroQualityConfig[quality].defaultRate
		-- ldb.ldb_open()
		
		-- if attr == 'maxHp' then
		--  资质系数
		local intelligence
		if inFactor[attr] then
			intelligence = inFactor[attr][trend]
		else
			intelligence = 1
		end
		--  品质系数
		dyAttr[attr] = BaseMath['getHero_'..attr](value,lv,intelligence,qua)
	end
	return dyAttr
end
