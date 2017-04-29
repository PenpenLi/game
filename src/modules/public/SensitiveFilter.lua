module(..., package.seeall)

local SensitiveWord = require("src/modules/public/SensitiveWord")
local Common = require("src/core/utils/Common")

local _sensitiveTree = {}

function init()
	local start = os.clock()
	buildSensitiveTree()
	print("buildSensitiveTree use time ======================== " .. (os.clock() - start))
end

function buildSensitiveTree()
	local tab = SensitiveWord.Config
	local wordLen = #tab
	for wordIndex=1,wordLen do
		local word = tab[wordIndex]
		local charTab = Common.utf2tb(word)
		local charLen = #charTab
		local tempTab = _sensitiveTree
		for charIndex=1,charLen do
			local char = charTab[charIndex]
			if tempTab[char] == nil then
				tempTab[char] = {isSensitive = false}
			end
			if charIndex == charLen then
				tempTab[char].isSensitive = true
				tempTab[char].sensitiveWord = word
			end
			tempTab = tempTab[char]
		end
	end
end

function hasSensitiveWord(str)
	local charTab = Common.utf2tb(str)
	local isSensitive = false
	local t = _sensitiveTree
	for charIndex,char in ipairs(charTab) do
		if t[char] == nil then
			t = _sensitiveTree
		end
		if t[char] ~= nil then
			isSensitive = t[char].isSensitive
			if isSensitive == true then
				break
			end
			t = t[char]
		end
	end
	return isSensitive
end

function filterSensitiveWord(str)
	local charTab = Common.utf2tb(str)
	local retStr = str
	local t = _sensitiveTree
	for charIndex,char in ipairs(charTab) do
		if t[char] == nil then
			t = _sensitiveTree
		end
		if t[char] ~= nil then
			if t[char].isSensitive == true then
				retStr = string.gsub(retStr, t[char].sensitiveWord, "**")
			end
			t = t[char]
		end
	end 
	return retStr
end

init()
