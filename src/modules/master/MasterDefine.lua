module(...,package.seeall)

--重登超时时间
TIMER_RE_LOGIN_TIMEOUT = 28 * 60
--定时加体力
TIMER_ADD_PHYSICS = 6 * 60

RENAME_RMB = 100

MAX_LV = 100
MAX_NAME = 7	--名字长度


OK = 0


-- 登录错误码
ASK_LOGIN_FAIL              = 1     --登录验证不通过
ASK_LOGIN_TIMEOUT           = 2     --登录超时
ASK_LOGIN_ERR_MSG = {
	[ASK_LOGIN_FAIL]              = "登录验证不通过",
	[ASK_LOGIN_TIMEOUT]           = "登录超时",
}

-- result code for rename 
RET_NAME_EXIST = 1	--已存在
RET_NAME_INVALID = 2	--名字不合法
RET_NAME_NORMB = 3	--没rmb
RET_NAME_TXT = {
	[RET_NAME_EXIST] = "名称已存在",
	[RET_NAME_INVALID] = "名字不合法",
	[RET_NAME_NORMB] = "钻石不足",
}

-- 断开连接错误码
DISCONNECT_REASON_ANOTHER_CHAR_LOGIN    = 1        -- 角色在其它地方上线
DISCONNECT_REASON_CHANGE_TO_CROSS_SCENE = 2     -- 角色从游戏服切换到跨服副本服 游戏服断开连接
DISCONNECT_REASON_CROSS_SCENE_GAMING    = 3        -- 角色正在跨服副本中 无法登录 请先断开原连接
DISCONNECT_REASON_ADMIN_KICK            = 4                -- 管理后台踢人
DISCONNECT_REASON_SERVER_FULL           = 5               -- 服务器人满
DISCONNECT_REASON_FORBID_ACCOUNT        = 6            -- 帐号被禁止登陆
DISCONNECT_REASON_FORBID_NAME           = 7               -- 角色被禁止登陆
DISCONNECT_REASON_FORBID_IP             =  8            -- IP被禁止登陆
DISCONNECT_REASON_CROSS_ACCOUNT_ERR     = 50        -- 错误帐号（登录中间服）
DISCONNECT_REASON_SERVER_CLOSE          = 9              -- 服务器关闭
DISCONNECT_REASON_AUTH_FAIL             = 10              -- 验证失败
DISCONNECT_REASON_3RD_AUTH_FAIL         = 11          -- 第三方验证失败

DISCONNECT_REASON_TXT = {
	[DISCONNECT_REASON_ANOTHER_CHAR_LOGIN] = "角色在别处登陆",
	[DISCONNECT_REASON_ADMIN_KICK] = "被管理员T下线",
	[DISCONNECT_REASON_SERVER_FULL] = "",
	[DISCONNECT_REASON_FORBID_ACCOUNT] = "账号被禁止登陆",
	[DISCONNECT_REASON_FORBID_NAME] = "角色被禁止登陆",
	[DISCONNECT_REASON_FORBID_IP] = "IP被禁止登陆",
	[DISCONNECT_REASON_SERVER_CLOSE] = "服务器关服维护",
	[DISCONNECT_REASON_AUTH_FAIL]    = "验证失败",
	[DISCONNECT_REASON_3RD_AUTH_FAIL] = "验证失败",          -- 第三方验证失败
}





