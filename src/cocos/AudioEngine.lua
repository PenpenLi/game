--Encapsulate SimpleAudioEngine to AudioEngine,Play music and sound effects. 
local M = {}

local isMusicON = true
local isEffectON = true

function M.setMusicOn(isOn)
	isMusicON = isOn
	if not isOn then
		M.pauseMusic()
	else
		M.resumeMusic()
	end
end

function M.setEffectOn(isOn)
	isEffectON = isOn
end

function M.stopAllEffects()
    --cc.SimpleAudioEngine:getInstance():stopAllEffects()
	_playSound(0,"stop",0)
end

function M.getMusicVolume()
	return 0
    --return cc.SimpleAudioEngine:getInstance():getMusicVolume()
end

function M.isMusicPlaying()
	return isMusicON
    --return cc.SimpleAudioEngine:getInstance():isMusicPlaying()
end

function M.getEffectsVolume()
	return 0
    --return cc.SimpleAudioEngine:getInstance():getEffectsVolume()
end

function M.setMusicVolume(volume)
    --cc.SimpleAudioEngine:getInstance():setMusicVolume(volume)
end

function M.stopEffect(handle)
	_playSound(0,"stopEffect",handle)
    --cc.SimpleAudioEngine:getInstance():stopEffect(handle)
end

function M.stopMusic(isReleaseData)
    local releaseDataValue = false
    if nil ~= isReleaseData then
        releaseDataValue = isReleaseData
    end
	print('======================stopMusic===========================')
	--cc.SimpleAudioEngine:getInstance():stopMusic(releaseDataValue)
	_playSound(1,"stop",isReleaseData and 1 or 0)
end

function M.playMusic(filename, isLoop)
    local loopValue = false
    if nil ~= isLoop then
        loopValue = isLoop
    end
	print('======================playMusic===========================')
	--cc.SimpleAudioEngine:getInstance():playMusic(filename, loopValue)
	_playSound(1,filename,isLoop and 1 or 0)
	M.setMusicOn(isMusicON)
end

function M.pauseAllEffects()
    --cc.SimpleAudioEngine:getInstance():pauseAllEffects()
	_playSound(0,"pause",0)
end

function M.preloadMusic(filename)
    --cc.SimpleAudioEngine:getInstance():preloadMusic(filename)
end

function M.resumeMusic()
    --cc.SimpleAudioEngine:getInstance():resumeMusic()
	if isMusicON then
		_playSound(1,"resume",0)
	end
end

function M.playEffect(filename, isLoop)
	if isEffectON then
		local loopValue = false
		if nil ~= isLoop then
			loopValue = isLoop
		end
		--local ret =  cc.SimpleAudioEngine:getInstance():playEffect(filename, loopValue)
		--return ret
		print('======================playEffect===========================')
		_playSound(0,filename,isLoop and 1 or 0)
	end
end

function M.rewindMusic()
    --cc.SimpleAudioEngine:getInstance():rewindMusic()
end

function M.willPlayMusic()
    --return cc.SimpleAudioEngine:getInstance():willPlayMusic()
end

function M.unloadEffect(filename)
    --cc.SimpleAudioEngine:getInstance():unloadEffect(filename)
end

function M.preloadEffect(filename)
    --cc.SimpleAudioEngine:getInstance():preloadEffect(filename)
end

function M.setEffectsVolume(volume)
    --cc.SimpleAudioEngine:getInstance():setEffectsVolume(volume)
end

function M.pauseEffect(handle)
    --cc.SimpleAudioEngine:getInstance():pauseEffect(handle)
end

function M.resumeAllEffects(handle)
    --cc.SimpleAudioEngine:getInstance():resumeAllEffects()
	_playSound(0,"resume",0)
end

function M.pauseMusic()
    --cc.SimpleAudioEngine:getInstance():pauseMusic()
	if not isMusicON then
		_playSound(1,"pause",0)
	end
end

function M.resumeEffect(handle)
	_playSound(0,"resumeEffect",handle)
    --cc.SimpleAudioEngine:getInstance():resumeEffect(handle)
end

function M.getInstance()
	return nil
    --return cc.SimpleAudioEngine:getInstance()
end

function M.destroyInstance()
	_playSound(1,"destroy",0)
    --return cc.SimpleAudioEngine:destroyInstance()
end

local modename = "AudioEngine"
local proxy = {}
local mt    = {
    __index = M,
    __newindex =  function (t ,k ,v)
        print("attemp to update a read-only table")
    end
} 
setmetatable(proxy,mt)
_G[modename] = proxy
package.loaded[modename] = proxy


