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

Call Java form Lua, and call Lua from Java.

-   Call Java Class Static Method from Lua
-   Pass Lua function to Java
-   Call Lua function from Java

<br />

**References:**

-   [LuaJavaBridge - Call Java from Lua (Chinese only)](http://dualface.github.com/blog/2013/01/01/call-java-from-lua/)

]]
module("LuaJ",package.seeall)

local call
if LuaJavaBridge then
	call = LuaJavaBridge.callStaticMethod
end

local function checkArguments(args, sig , returnType)
    if type(args) ~= "table" then args = {} end
    if sig then return args, sig end
	returnType = returnType or "V"
    sig = {"("}
    for i, v in ipairs(args) do
        local t = type(v)
        if t == "number" then
            sig[#sig + 1] = "F"
        elseif t == "boolean" then
            sig[#sig + 1] = "Z"
        elseif t == "function" then
            sig[#sig + 1] = "I"
        else
            sig[#sig + 1] = "Ljava/lang/String;"
        end
    end
    sig[#sig + 1] = ")"
    sig[#sig + 1] = returnType
    return args, table.concat(sig)
end

--[[--

Call Java Class Static Method

### Example:

	local callback = function(p)
		print("callback>>>>>>",p)
	end
    local className = "org/cocos2dx/kabubox/KbJni"
    local args = {
		"string_param",
		callback,
	}
    local sig  = "(Ljava/lang/String;I)V"
    local ok = LuaJ.callStaticMethod(className, "test", args, sig)
    if ok then
		print("jni succeed")
        -- call success
    else
		print("jni failure")
        -- call failure
    end

### Parameters:

-   string **className** Java class name
-   string **methodName** Method name
-   [_optional table **args**_] Arguments pass to Java
-   [_optional string **sig**_] Java Method Signature


> Java Method Signature reference: [JNI Types and Data Structures](http://docs.oracle.com/javase/7/docs/technotes/guides/jni/spec/types.html#wp16432)

### Returns:

-   boolean call success or failure
-   mixed Java method returned value

### 坑
    local args = {
		123,
		callback,
	}
	对应的原型：lua的number是float
	public static foo(final float a,final int b){}
]]
local errorMsg = {
	[-1] = "不支持的参数类型或返回值类型",
	[-2] = "无效的签名",
	[-3] = "没有找到指定的方法",
	[-4] = "Java 方法执行时抛出了异常",
	[-5] = "Java 虚拟机出错",
	[-6] = "Java 虚拟机出错",
}
function callStaticMethod(className, methodName, args, returnType , sig)
    local args, sig = checkArguments(args, sig, returnType)
    print("luaj.callStaticMethod==>", className, "=" ,methodName, "=", sig)
    local ret,res = call(className, methodName, args, sig)
	res = res or 0
	local msg = errorMsg[res] or ""
	--assert(ret,"luaj errorcode===>" .. res .. "==>msg:" .. msg)
	print(ret,"===>luaj errorcode===>" .. res .. "==>msg:" .. msg)
	return res
end

