module(..., package.seeall)
local AudioEngine = AudioEngine

function preLoadEffect()
	AudioEngine.preloadMusic('res/sound/fight/common/BackgroundMusic3.mp3')
	--
	AudioEngine.preloadEffect('res/sound/fight/common/HitHeavy.mp3')
	AudioEngine.preloadEffect('res/sound/fight/common/HitLight.mp3')
end

function playEffect(filename,isLoop)
	if filename == "" then
		return
	end
	AudioEngine.playEffect('res/sound/fight/' .. filename, isLoop)
end

function playMusic(filename,isLoop)
	if filename == "" then
		return
	end
	AudioEngine.playMusic('res/sound/fight/' .. filename,isLoop)
end

function stopMusic(isReleaseData)
	--AudioEngine.destroyInstance()
    AudioEngine.stopMusic(true)
end
