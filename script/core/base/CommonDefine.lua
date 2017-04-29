module("CommonDefine",package.seeall)

--本文件只放全局通用的常量定义
--那些功能模块的错误码，返回码等写到各自的模块定义文件中去

OK = 0

MAX_ONLINE_CNT = 40000

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
-- 100 开始是c++层的错误码
DISCONNECT_REASON_CLIENT = 100                  -- client主动断开
DISCONNECT_REASON_TIMEOUT = 101                 -- 长时间没有发包断开
DISCONNECT_REASON_PACKET_ERR = 102              -- 发送非法包断开

PAY_SUCCESS = 1		--充值成功
PAY_NO_CHAR = 2		--角色不存在
PAY_FAIL	= 3		--充值失败
PAY_NO_ITEM = 4     --没有定义这个商品

-- money type
MONEY_NIL               = 0     -- 预留空
MONEY_COPPER_COIN       = 1     -- 铜币

--产出和消耗类型命名规则：X XXX XX 
--第一位为类型，1:获得，2:失去。中间2位为模块ID，后面两位为流水号
--模块定义：
-- gm 01
ITEM_TYPE = 
{
    ADD = 10000, -- 获得类型开始
	--gm
	ADD_GM = 10101,	--gm指令获得

	DEC = 20000, -- 失去类型开始
	DEC_TODO	= 20201,	 --

}

RMB_TYPE = 
{
    ADD = 10000, -- 获得类型开始
	--gm 01
	ADD_GM = 10101,	--gm指令获得
	--admin
	ADD_ADMIN = 12701, 	--后台发钻石

	DEC = 20000, -- 失去类型开始
	DEC_TODO = 20301, 	--

}
--金币消费类型
MONEY_TYPE = 
{
    ADD = 10000, -- 获得类型开始
	--gm
	ADD_GM = 10101,	--gm指令获得

	DEC = 20000, -- 失去类型开始
	--gm
	DEC_GM = 20101,		--GM指令失去
}


return CommonDefine


