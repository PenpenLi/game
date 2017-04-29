module("Event", package.seeall)

MultiTouchEvent = "multiTouch"
TouchEvent = "touch"
FlipUnitEvent = "flipUnit"
Touch_began = "began"
Touch_moved = "moved"
Touch_ended = "ended"
Touch_cancelled = "cancelled"
Touch_over = "over"
Touch_out = "out"

Click = "click"
Selected = "selected"
Change = "change"
Refresh = "refresh" -- 刷新
Frame = "frame" -- 帧事件

Finish = "finish" -- 结束 
InitEnd= "initEnd"

PlayFrame = "playFrame"
PlayEnd = "playEnd"

MoveEnded = "moveEnded"
Hero_enterScene = "heroEnterScene"

BattleEnd = "battleEnd"

BattleStart = "battleStart"

Confirm = "confirm"
Confirm_yes = "yes"
Confirm_no = "no"
Confirm_known= "known"
Confirm_close = "close"

BagRefresh = "bagRefresh"
ShopCntRefresh = "shopCntRefresh"
ShopBuyVirtual = "shopBuyVirtual"
MasterRefresh = "masterRefresh"

FightEnd = "fightEnd"	--战斗结束
FightHarm = "fightHarm" --战斗伤害
FightDie = "fightDie"	--战斗死亡
FightReport = "fightReport" --战报结束
FightStart = "fightStart" --战斗开始，ready go 之后
FightPower = "fightPower" --释放大招
FightHit = "fightHit" --每次攻击完成
FightCombo = "fightCombo" --每次接招完成
FightRound = "fightRound"	--每一轮战斗开始

LoginSuccess = "LogicSuccess"

ChapterEnd = "chapterEnd"

HeroRecruitRemove = "HeroRecruitRemove"

GameStartEnd = "GameStartEnd"

EnterScene = "EnterScene"

GuideRemove = "GuideRemove"

LvUpUIEnd = "LvUpUIEnd"

TeamLvUp = "TeamLvUp"
