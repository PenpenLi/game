-- 小黑人, 通用 特写状态
module(..., package.seeall)
local Hero = require("src/modules/fight/Hero")
local Helper = require("src/modules/fight/KofHelper")
setmetatable(_M, {__index = Hero}) 
local Define = require("src/modules/fight/Define")

local boneRes = {
	["头"] = {
		"clark_小黑人_头.png",
		"clark_小黑人_头C.png",
		"clark_小黑人_头A.png",
		"clark_小黑人_头B.png",
	},

	["左手上"] = {
		"clark_小黑人_左手上.png",
	},

	["左手下"] = {
		"clark_小黑人_左手下.png",
	},

	["身体"] = {
		"clark_小黑人_身体.png",
	},

	["右手上"] = {
		"clark_小黑人_右手上.png",
	},

	["右手下"] = {
		"clark_小黑人_右手下.png",
	},

	["左腿上"] = {
		"clark_小黑人_左腿上.png",
	},

	["左腿下"] = {
		"clark_小黑人_左腿下.png",
	},

	["右脚上"] = {
		"clark_小黑人_右脚上.png",
	},

	["右脚下"] = {
		"clark_小黑人_右脚下.png",
	},
}

local specialRes = {
	["Mary"] = {
		["左腿上"] = {
			"clark_小黑人_左腿上.png",
			"clark_小黑人_右脚上.png",
		},

		["左腿下"] = {
			"clark_小黑人_左腿下.png",
			"clark_小黑人_右脚下.png",
		},

		["右脚上"] = {
			"clark_小黑人_右脚上.png",
			"clark_小黑人_左腿上.png",
		},

		["右脚下"] = {
			"clark_小黑人_右脚下.png",
			"clark_小黑人_左腿下.png",
		},
	}
}

local skinRes = {
	--[[
	["_heroA_"] = "res/armature//HeroATargetSkin.plist",
	["_heroB_"] = "res/armature//HeroBTargetSkin.plist",
	-]]
	["Andy_heroA_"] = "res/armature/andy/AndyHeroATargetSkin.plist",
	["Andy_heroB_"] = "res/armature/andy/AndyHeroBTargetSkin.plist",

	["Athena_heroA_"] = "res/armature/athena/AthenaHeroATargetSkin.plist",
	["Athena_heroB_"] = "res/armature/athena/AthenaHeroBTargetSkin.plist",

	["Benimaru_heroA_"] = "res/armature/benimaru/BenimaruHeroATargetSkin.plist",
	["Benimaru_heroB_"] = "res/armature/benimaru/BenimaruHeroBTargetSkin.plist",

	["Billy_heroA_"] = "res/armature/billy/BillyHeroATargetSkin.plist",
	["Billy_heroB_"] = "res/armature/billy/BillyHeroBTargetSkin.plist",

	["Chang_heroA_"] = "res/armature/chang/ChangHeroATargetSkin.plist",
	["Chang_heroB_"] = "res/armature/chang/ChangHeroBTargetSkin.plist",

	["Chin_heroA_"] = "res/armature/chin/ChinHeroATargetSkin.plist",
	["Chin_heroB_"] = "res/armature/chin/ChinHeroBTargetSkin.plist",

	["Chizuru_heroA_"] = "res/armature/chizuru/ChizuruHeroATargetSkin.plist",
	["Chizuru_heroB_"] = "res/armature/chizuru/ChizuruHeroBTargetSkin.plist",

	["Choi_heroA_"] = "res/armature/choi/ChoiHeroATargetSkin.plist",
	["Choi_heroB_"] = "res/armature/choi/ChoiHeroBTargetSkin.plist",

	["Chris_heroA_"] = "res/armature/chris/ChrisHeroATargetSkin.plist",
	["Chris_heroB_"] = "res/armature/chris/ChrisHeroBTargetSkin.plist",

	["Chris2_heroA_"] = "res/armature/chris2/Chris2HeroATargetSkin.plist",
	["Chris2_heroB_"] = "res/armature/chris2/Chris2HeroBTargetSkin.plist",

	["Clark_heroA_"] = "res/armature/clark/ClarkHeroATargetSkin.plist",
	["Clark_heroB_"] = "res/armature/clark/ClarkHeroBTargetSkin.plist",

	["Daimon_heroA_"] = "res/armature/daimon/DaimonHeroATargetSkin.plist",
	["Daimon_heroB_"] = "res/armature/daimon/DaimonHeroBTargetSkin.plist",

	["Iori_heroA_"] = "res/armature/iori/IoriHeroATargetSkin.plist",
	["Iori_heroB_"] = "res/armature/iori/IoriHeroBTargetSkin.plist",

	["Iori2_heroA_"] = "res/armature/iori2/Iori2HeroATargetSkin.plist",
	["Iori2_heroB_"] = "res/armature/iori2/Iori2HeroBTargetSkin.plist",

	["JieTouHunHun_heroB_"] = "res/armature/jietouhunhun/JieTouHunHunHeroBTargetSkin.plist",

	["Joe_heroA_"] = "res/armature/joe/JoeHeroATargetSkin.plist",
	["Joe_heroB_"] = "res/armature/joe/JoeHeroBTargetSkin.plist",

	["Kensou_heroA_"] = "res/armature/kensou/KensouHeroATargetSkin.plist",
	["Kensou_heroB_"] = "res/armature/kensou/KensouHeroBTargetSkin.plist",

	["Kim_heroA_"] = "res/armature/kim/KimHeroATargetSkin.plist",
	["Kim_heroB_"] = "res/armature/kim/KimHeroBTargetSkin.plist",

	["King_heroA_"] = "res/armature/king/KingHeroATargetSkin.plist",
	["King_heroB_"] = "res/armature/king/KingHeroBTargetSkin.plist",

	["Kyo_heroA_"] = "res/armature/kyo/KyoHeroATargetSkin.plist",
	["Kyo_heroB_"] = "res/armature/kyo/KyoHeroBTargetSkin.plist",
	
	["Leona_heroA_"] = "res/armature/leona/LeonaHeroATargetSkin.plist",
	["Leona_heroB_"] = "res/armature/leona/LeonaHeroBTargetSkin.plist",

	["Leona2_heroA_"] = "res/armature/leona2/Leona2HeroATargetSkin.plist",
	["Leona2_heroB_"] = "res/armature/leona2/Leona2HeroBTargetSkin.plist",

	["LianDaoPan_heroB_"] = "res/armature/liandaopan/LianDaoPanHeroBTargetSkin.plist",

	["Mai_heroA_"] = "res/armature/mai/MaiHeroATargetSkin.plist",
	["Mai_heroB_"] = "res/armature/mai/MaiHeroBTargetSkin.plist",

	["Mary_heroA_"] = "res/armature/mary/MaryHeroATargetSkin.plist",
	["Mary_heroB_"] = "res/armature/mary/MaryHeroBTargetSkin.plist",

	["NanManQuanWang_heroB_"] = "res/armature/nanmanquanwang/NanManQuanWangHeroBTargetSkin.plist",
	
	["Orochi_heroA_"] = "res/armature/orochi/OrochiHeroATargetSkin.plist",
	["Orochi_heroB_"] = "res/armature/orochi/OrochiHeroBTargetSkin.plist",

	["Ralf_heroA_"] = "res/armature/ralf/RalfHeroATargetSkin.plist",
	["Ralf_heroB_"] = "res/armature/ralf/RalfHeroBTargetSkin.plist",

	["Robert_heroA_"] = "res/armature/robert/RobertHeroATargetSkin.plist",
	["Robert_heroB_"] = "res/armature/robert/RobertHeroBTargetSkin.plist",

	["Ryo_heroA_"] = "res/armature/ryo/RyoHeroATargetSkin.plist",
	["Ryo_heroB_"] = "res/armature/ryo/RyoHeroBTargetSkin.plist",

	["Shermie_heroA_"] = "res/armature/shermie/ShermieHeroATargetSkin.plist",
	["Shermie_heroB_"] = "res/armature/shermie/ShermieHeroBTargetSkin.plist",

	["Shermie2_heroA_"] = "res/armature/shermie2/Shermie2HeroATargetSkin.plist",
	["Shermie2_heroB_"] = "res/armature/shermie2/Shermie2HeroBTargetSkin.plist",

	["Shingo_heroA_"] = "res/armature/shingo/ShingoHeroATargetSkin.plist",
	["Shingo_heroB_"] = "res/armature/shingo/ShingoHeroBTargetSkin.plist",

	["Terry_heroA_"] = "res/armature/terry/TerryHeroATargetSkin.plist",
	["Terry_heroB_"] = "res/armature/terry/TerryHeroBTargetSkin.plist",

	["TianTongKai_heroB_"] = "res/armature/tiantongkai/TianTongKaiHeroBTargetSkin.plist",

	["TiaoZi_heroB_"] = "res/armature/tiaozi/TiaoZiHeroBTargetSkin.plist",

	["Yamazaki_heroA_"] = "res/armature/yamazaki/YamazakiHeroATargetSkin.plist",
	["Yamazaki_heroB_"] = "res/armature/yamazaki/YamazakiHeroBTargetSkin.plist",

	["Yashiro_heroA_"] = "res/armature/yashiro/YashiroHeroATargetSkin.plist",
	["Yashiro_heroB_"] = "res/armature/yashiro/YashiroHeroBTargetSkin.plist",

	["Yashiro2_heroA_"] = "res/armature/yashiro2/Yashiro2HeroATargetSkin.plist",
	["Yashiro2_heroB_"] = "res/armature/yashiro2/Yashiro2HeroBTargetSkin.plist",

	["YinYueShaoNv_heroB_"] = "res/armature/yinyueshaonv/YinYueShaoNvHeroBTargetSkin.plist",

	["Yuri_heroA_"] = "res/armature/yuri/YuriHeroATargetSkin.plist",
	["Yuri_heroB_"] = "res/armature/yuri/YuriHeroBTargetSkin.plist",
}

function create(hero,name,enemyName,enemySkin)
	local heroName = hero.heroName
	local str = enemyName .. "_" .. enemySkin .. "_"
	local targetAnimation = ccs.Armature:create(name)
	if skinRes[str] then
		hero:addSpriteFrames(skinRes[str])
		---[[
		for name,res in pairs(boneRes) do
			local bone = targetAnimation:getBone(name)
			if specialRes[heroName] and specialRes[heroName][name] then
				res = specialRes[heroName][name]
			end
			for k,v in pairs(res) do
				local skin = ccs.Skin:createWithSpriteFrameName(str .. v)
				bone:addDisplay(skin,k - 1)
			end
		end
		--]]
	end
	return targetAnimation
end
