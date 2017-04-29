module(...,package.seeall)
local Hero = require("src/modules/hero/Hero")

function setData(name,base,current)
	local hero = Hero.heroes[name]
	hero.train.base = base
	for k,v in pairs(current) do
		if v.val > 90000 then
			v.val = v.val - 100000
		end
	end
	hero.train.current = current 
end

function getBase(name)
	local hero = Hero.heroes[name]
	if hero then
		return hero.train.base
	end
end

function getCurrent(name)
	local hero = Hero.heroes[name]
	if hero then
		return hero.train.current
	end
end

function query(name)
	local hero = Hero.heroes[name]
	if hero then
		--Network.sendMsg(PacketID.CG_TRAIN_QUERY,name)
	end
end
