module(..., package.seeall)
local ThermaeDefine = require("src/config/ThermaeDefineConfig").Defined
local Hero = require("src/modules/hero/Hero")
local HeroDefine = require("src/modules/hero/HeroDefine")

function getBathingHero()
	local heros = Hero.getSortedHeroes()
	for k,v in pairs(heros) do
		if v.status == HeroDefine.STATUS_THERMAE then
			return v
		end
	end
end


