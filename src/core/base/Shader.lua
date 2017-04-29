module("Shader", package.seeall)

-- 有效shader名
SHADER_TYPE_GRAY = "Gray"  -- 变灰
SHADER_TYPE_FROZEN = "Frozen" --冻结
SHADER_TYPE_ICE = "Ice" --冰
SHADER_TYPE_POISON = "Poison" --中毒
SHADER_TYPE_STONE = "Stone" --石化
SHADER_TYPE_BANISH = "Banish" --消除
SHADER_TYPE_SHADOW = "Shadow" --黑色剪影
SHADER_TYPE_RELIEF = "Relief" --浮雕
SHADER_TYPE_BLUR = "Blur" -- 模糊
SHADER_TYPE_NEGATIVE = "Negative" -- 反色 
SHADER_TYPE_OUTLINE = "Outline" -- 描边 
SHADER_TYPE_BLACKWHITE = "BlackWhite" -- 黑白剪影 
SHADER_TYPE_BLINK= "Blink" -- 闪烁 

function setShader(spr, shaderName, ...)
	local key = shaderName or "ShaderPositionTextureColor_noMVP"
	local program = cc.GLProgramCache:getInstance():getGLProgram(key)
	if not program then
		program = cc.GLProgram:create("src/core/shader/" .. key .. ".vsh","src/core/shader/" .. key .. ".fsh")
		program:link()
		program:updateUniforms()
		cc.GLProgramCache:getInstance():addGLProgram(program, key)
		if cc.GLProgramCache:getInstance().cacheCustomShader then
			cc.GLProgramCache:getInstance():cacheCustomShader(key,"src/core/shader/" .. key .. ".vsh","src/core/shader/" .. key .. ".fsh")
		end
	end
	spr:setGLProgram(program)

	local fn = _M[key]
	if fn then
		fn(spr, program, ...)
	end
end

function setArmatureShader(armature, shaderName, ...)
	local childrenCount = armature:getChildrenCount()
	local children = armature:getChildren()
	for i=1,childrenCount do
		local bone = children[i]
		local tp = bone:getDisplayRenderNodeType()
		--DisplayType
		--CS_DISPLAY_SPRITE, 0    //! display is a single Sprite
		--CS_DISPLAY_ARMATURE, 1  //! display is a Armature
		--CS_DISPLAY_PARTICLE, 2  //! display is a CCParticle.
		if tp == 0 or tp == 1 or tp == 2 then
			setShader(bone, shaderName, ...)
		end
	end
end

function setCascadeShader(spr, shaderName, ...)
	setShader(spr, shaderName, ...)
	local childrenCount = spr:getChildrenCount()
	local children = spr:getChildren()
	for i=1,childrenCount do
		local child = children[i]
		setCascadeShader(child, shaderName, ...)
	end
end

------------------- 以下为带参数shader  -------------------

function Relief(spr, program, width, height) 
	if not width or not height then
		local size = spr:getContentSize()
		width = size.width
		height = size.height
	end
	local state = spr:getGLProgramState() 
	state:setUniformFloat("width", width)
	state:setUniformFloat("height", height)
end

function Blur(spr, program, x, y)
	local blurSize = {x = x, y = y}
	local state = spr:getGLProgramState() 
	state:setUniformVec2("blurSize", blurSize)
end

--变线色， 阀值， 线宽  ==》参考值 threshold = 1.75, radius = 0.01, r=1.0, g=0.2, b=0.3
function Outline(spr, program, threshold, radius, r, g, b)
	local outlineColor = {x = r, y = g, z = b}
	local state = spr:getGLProgramState() 
	state:setUniformFloat("u_threshold", threshold)
	state:setUniformFloat("u_radius", radius)
	state:setUniformVec3("u_outlineColor", outlineColor)
end

function BlackWhite(spr, program, threshold)
	local state = spr:getGLProgramState() 
	state:setUniformFloat("u_threshold", threshold)
end

