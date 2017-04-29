--[[

Copyright (c) 2011-2012 qeeplay.com

http://dualface.github.com/quick-cocos2d-x/

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

]]

--[[--

Query information about the system (get device information, current language, etc) and execute system functions (show alert view, show input box, etc).

<br />

Following properties predefined:

-   **device.platform** the platform name (the OS name), i.e. one of the following: ios, android, blackberry, mac, windows, linux.

-   **device.environment** returns the environment that the app is running in. i.e. one of the following: simulator, device.

-   **device.model** returns the device model (as specified by the manufacturer) :

    - On iOS: return iPhone, iPad
    - On Android: return Android device model name
    - On Mac, windows, linux: return "unknown"

-   **device.language** returns the default language on the device :

    Value       | Language
    ----------- | -------------
    cn          | Chinese
    fr          | French
    it          | Italian
    gr          | German
    sp          | Spanish
    ru          | Russian
    jp          | Japanese
    en          | English

-   **device.writablePath** returns the writable path.

]]
Device = {}
local echoInfo = print

Device.platform    = "unknown"
Device.environment = "simulator"
Device.model       = "unknown"

local sharedApplication = cc.Application:getInstance()
local target = sharedApplication:getTargetPlatform()
if target == cc.PLATFORM_OS_WINDOWS then
    Device.platform = "windows"
elseif target == cc.PLATFORM_OS_LINUX then
    Device.platform = "linux"
elseif target == cc.PLATFORM_OS_MAC then
    Device.platform = "mac"
elseif target == cc.PLATFORM_OS_ANDROID then
    Device.platform = "android"
elseif target == cc.PLATFORM_OS_IPHONE or target == cc.PLATFORM_OS_IPAD then
    Device.platform = "ios"
    if target == cc.PLATFORM_OS_IPHONE then
        Device.model = "iphone"
    else
        Device.model = "ipad"
    end
elseif target == cc.PLATFORM_OS_BLACKBERRY then
    Device.platform = "blackberry"
end

if sharedApplication.getTargetEnvironment and sharedApplication:getTargetEnvironment() == kTargetDevice then
    Device.environment = "Device"
end

local language_ = sharedApplication:getCurrentLanguage()
if language_ == kLanguageChinese then
    language_ = "cn"
elseif language_ == kLanguageFrench then
    language_ = "fr"
elseif language_ == kLanguageItalian then
    language_ = "it"
elseif language_ == kLanguageGerman then
    language_ = "gr"
elseif language_ == kLanguageSpanish then
    language_ = "sp"
elseif language_ == kLanguageRussian then
    language_ = "ru"
else
    language_ = "en"
end

Device.language = language_
Device.writablePath = cc.FileUtils:getInstance():getWritablePath()

echoInfo("# Device.platform              = " .. Device.platform)
echoInfo("# Device.environment           = " .. Device.environment)
echoInfo("# Device.model                 = " .. Device.model)
echoInfo("# Device.language              = " .. Device.language)
echoInfo("# Device.writablePath          = " .. Device.writablePath)
echoInfo("#")

--[[--

Displays a platform-specific activity indicator.

### Note:

Supported platform: ios, android.

]]
function Device.showActivityIndicator()
    CCNative:showActivityIndicator()
end

--[[--

Hides activity indicator.

### Note:

Supported platform: ios, android.

]]
function Device.hideActivityIndicator()
    CCNative:hideActivityIndicator()
end

--[[--

Displays a popup alert box with one or more buttons. Program activity, including animation, will continue in the background, but all other user interactivity will be blocked until the user selects a button or cancels the dialog.

### Paramters:

-   string **title** The title string displayed in the alert

-   string **message** Message string displayed in the alert text.

-   table **buttonLabels** Table of strings, each of which will create a button with the corresponding label.

-   function **listener** The listener to be notified when a user presses any button in the alert box.

### Note:

Supported platform: ios, android, mac.

]]
function Device.showAlert(title, message, buttonLabels, listener)
    buttonLabels = totable(buttonLabels)
    local defaultLabel = ""
    if #buttonLabels > 0 then
        defaultLabel = buttonLabels[1]
        table.remove(buttonLabels, 1)
    end

    CCNative:createAlert(title, message, defaultLabel)
    for i, label in ipairs(buttonLabels) do
        CCNative:addAlertButton(label)
    end

    if type(listener) ~= "function" then
        listener = function() end
    end

    CCNative:showAlertLua(listener)
end

--[[--

Dismisses an alert box programmatically.

For example, you may wish to have a popup alert that automatically disappears after ten seconds even if the user doesn’t click it. In that case, you could call this function at the end of a ten-second timer.

### Note:

Supported platform: ios, android, mac.

]]
function Device.cancelAlert()
    CCNative:cancelAlert()
end

--[[--

Returns OpenUDID for Device.

> OpenUDID is a drop-in replacement for the deprecated uniqueIdentifier property of the UIDevice class on iOS (a.k.a. UDID) and otherwise is an industry-friendly equivalent for iOS and Android.

### Returns:

-   string OpenUDID

### Note:

Supported platform: ios, android, mac.

]]
function Device.getOpenUDID()
    return CCNative:getOpenUDID()
end

--[[--

Open a web page in the browser; create an email; or call a phone number.

Note: Executing this function will make the app background and switch to the built-in browser, email or phone app.

### Parameters:

-   string **url** url can be one of the following:

    -   Web link: "http://dualface.github.com/quick-cocos2d-x/"

    -   Email address: "mailto:nobody@mycompany.com".

        The email address url can also contain subject and body parameters, both of which must be url encoded.<br />
        Example: "mailto:nobody@mycompany.com?subject=Hi%20there&body=I%20just%20wanted%20to%20say%2C%20Hi!"<br />
        Try this URL encoder to encode your text.

    -   Phone number: "tel:123-456-7890"

### Note:

Supported platform: ios, android.

]]
function Device.openURL(url)
    CCNative:openURL(url)
end

--[[--

Displays a popup input dialog with ok and cancel button.

### Parameters:

-   string **title** The title string displayed in the input dialog
-   string **message** Message string displayed in the input dialog
-   string **defaultValue** Displayed in the text box.

### Returns:

-   string User entered text. If uesr cancel input dialog, return nil.

### Note:

Supported platform: mac, windows.

]]
function Device.showInputBox(title, message, defaultValue)
    title = title or "INPUT TEXT"
    message = message or "INPUT TEXT, CLICK OK BUTTON"
    defaultValue = defaultValue or ""
    return CCNative:getInputText(title, message, defaultValue)
end

Device.Orientaion = 1
Device.OrientationLandscape = 0  --横向
Device.OrientationPortrait  = 1  --纵向
--[[
--设置屏幕方向
--@param orientation   0:横向  1:纵向
--]]
function Device.setOrientation(orientation)
	assert(orientation == 1 or orientation == 0 ,"orientation must be 1 or 0")
	if Device.getOrientation == orientation then
		return
	end
    
	if Device.platform == "android" then
		local className = "org/cocos2dx/kabubox/KbJni"
		local args = {orientation}
		local sig  = "(I)V"
		LuaJ.callStaticMethod(className, "setOrientation", args, sig)
	elseif Device.platform == "ios" then
		local args = {factor=orientation}
		LuaOC.callStaticMethod("RootViewController","setOrientation",args)
	end
    local size = view:getFrameSize()
    local longer,shorter
    if size.width > size.height then --横屏
        longer = size.width
        shorter = size.height
    else
        longer = size.height
        shorter = size.width
    end
    if orientation == 1 then
        view:setFrameSize(shorter,longer)
        winSize = CCSizeMake(768,1024) --设计宽高
    elseif orientation == 0 then
        view:setFrameSize(longer,shorter)
        winSize = CCSizeMake(1024,768) --设计宽高
    end
    view:setDesignResolutionSize(winSize.width, winSize.height, ResolutionPolicy.kResolutionExactFit)    
	Device.Orientaion = orientation
end

function Device.getOrientation()
	return Device.Orientaion
end

--播放视频
Device.timerId = 0
function Device.playVideo(name,callback)
	--[[
	if Device.platform == "android" then
		local className = "org/cocos2dx/kabubox/KbJni"
		local args = {name,callback}
		LuaJ.callStaticMethod(className, "playVideo", args )
	elseif Device.platform == "ios" then
		local args = {videoName=name,callback=callback}
		LuaOC.callStaticMethod("RootViewController","playVideo",args)
	else
		--win下模拟播
		Device.timerId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function(dt) 
			callback()
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(Device.timerId)
		end,0.2,false)
	end
	--]]
	--模拟播
	Device.timerId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function(dt) 
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(Device.timerId)
		callback()
	end,0.2,false)
end

Device.macAddress = ""
local jniClasssName = "com/mxgame/app/MXJni"

function Device.getUDId()
	if Device.platform == "windows" then
		return math.random(100,999)
	elseif Device.platform == "android" then
		local setMacAddr = function(addr) 
			Device.macAddress = tostring(addr)
		end
		local args = {setMacAddr}
		LuaJ.callStaticMethod(jniClasssName, "getLocalMacAddress" ,args)
		return Device.macAddress
	else
		if  type(_getUDId) == 'function' then
			return _getUDId()
        else
            return "0"
		end
	end
end

Device.bundleVersion = nil
function Device.getBundleVersion()
	if not Device.bundleVersion then
		if Device.platform == "android" then
			local setVersion = function(ver)
				Device.bundleVersion = ver 
			end
			local args = {setVersion}
			LuaJ.callStaticMethod(jniClasssName, "getVersionName" ,args)
		elseif Device.platform == "windows" then
			Device.bundleVersion = "1.0"
        elseif Device.platform == "ios" then
            Device.bundleVersion = MX.Native.getBundleVersion()
		else
			Device.bundleVersion = cc.UserDefault:getInstance():getStringForKey("CFBundleVersion")
		end
	end
	return Device.bundleVersion
end

function Device.getCoreVersion()
	local verTb = Common.split(Device.getBundleVersion(),"%.")
	return verTb[1] .. "." .. verTb[2]
end

function Device.getFullVersion()
    local resVer = AsyncDownloadManager.getOldVersion()
	local bundleVersion = Device.getBundleVersion()
	local verTb = Common.split(bundleVersion,"%.")
	if resVer == 0 then
		resVer = verTb[3] or 0
	end
	return string.format("%s.%d.%d",Device.getCoreVersion(),resVer,Config.Platform)
end

function Device.getUsedMemory()
	local mem = MX.Native.getUsedMemory()
	if Device.platform == "android" then
		mem = mem / 1000
	elseif Device.platform == "windows" then
		mem = mem / 1000000
    else
        mem = mem / 1000000
	end
	return mem
end

function Device.setupNotify(nickName)
	nickName = nickName or ""
	nickName = nickName .. ","
	local notify = string.format("%s今天你打泡泡了嘛？每天登录都有好礼相送哦～",nickName) 
	_addLocalNotification(notify,"19:00:00")
end

function Device.getUDId()
	if Device.platform == "windows" then
		return math.random(100,999)
	elseif Device.platform == "android" then
		local setMacAddr = function(addr) 
			Device.macAddress = tostring(addr)
		end
		local args = {setMacAddr}
		LuaJ.callStaticMethod(jniClasssName, "getLocalMacAddress" ,args)
		return Device.macAddress
	else
		if  type(_getUDId) == 'function' then
			return _getUDId()
        else
            return "0"
		end
	end
end

function Device.restart()
	if Device.platform == "windows" then
	elseif Device.platform == "android" then
		--local res = LuaJ.callStaticMethod(jniClasssName, "restart" )
		--if res ~= 0 then
		--	_restart()
		--end
	else
	end
end

function Device.getIMEI()
	local IMEI = ""
	if Device.platform == "windows" then
		IMEI = "win_" .. os.time()
	elseif Device.platform == "ios" then
    	IMEI = MX.Native.getIMEI()
	end
	return tostring(IMEI)
end




