module(...,package.seeall)
Config={
[1401] = {name=1401, lock=3, action="龙击拳", loop=0, speedX=0, isJump=false, shader="", effect="", sound="robert/Longjiquan.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=285, hitEvent={["8-26"]={reac="hit_fly_a",effect="轻受击",deffect="防御2",deback=60,delayA=0.08,delayB=0.32,shock=1}}, noHitEvent={}, },
[1402] = {name=1402, lock=3, action="背摔", loop=0, speedX=0, isJump=false, shader="", effect="", sound="robert/Houshuai.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=120, hitEvent={}, noHitEvent={}, },
[1403] = {name=1403, lock=3, action="站立轻拳", loop=0, speedX=0, isJump=false, shader="", effect="", sound="robert/Qingquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=160, hitEvent={[2]={reac="hit_light_a",effect="轻受击",deffect="防御1",deback=20,back=15}}, noHitEvent={}, },
[1404] = {name=1404, lock=3, action="站立轻脚", loop=0, speedX=0, isJump=false, shader="", effect="", sound="robert/Qingquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=140, hitEvent={[2]={reac="hit_light_b",effect="轻受击",deffect="防御1",deback=20,back=15}}, noHitEvent={}, },
[1405] = {name=1405, lock=3, action="站立重拳", loop=0, speedX=0, isJump=false, shader="", effect="", sound="robert/Zhongquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=210, hitEvent={[3]={reac="hit_heavy_a",effect="重受击",deffect="防御1",deback=30,delayA=0.04,shock=1}}, noHitEvent={}, },
[1406] = {name=1406, lock=3, action="站立重脚", loop=0, speedX=0, isJump=false, shader="", effect="", sound="robert/Zhongquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=220, hitEvent={[5]={reac="hit_heavy_a",effect="重受击",deffect="防御1",deback=30,back=20,delayA=0.04,shock=1}}, noHitEvent={}, },
[1407] = {name=1407, lock=3, action="跳跃轻拳", loop=0, speedX=0, isJump=true, shader="", effect="", sound="robert/Qingquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=160, hitEvent={["4-6"]={reac="hit_light_a",effect="轻受击",deffect="防御1",deback=20,back=15,delayA=0.02,delayB=0.02}}, noHitEvent={}, },
[1408] = {name=1408, lock=3, action="跳跃轻脚", loop=0, speedX=0, isJump=true, shader="", effect="", sound="robert/Qingquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=160, hitEvent={["5-7"]={reac="hit_light_a",effect="轻受击",deffect="防御1",deback=20,back=15,delayA=0.02,delayB=0.02}}, noHitEvent={}, },
[1409] = {name=1409, lock=3, action="跳跃重拳", loop=0, speedX=0, isJump=true, shader="", effect="", sound="robert/Zhongquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=180, hitEvent={["5-7"]={reac="hit_heavy_a",effect="重受击",deffect="防御1",deback=30,back=20,delayA=0.04,delayB=0.04}}, noHitEvent={}, },
[1410] = {name=1410, lock=3, action="跳跃重脚", loop=0, speedX=0, isJump=true, shader="", effect="", sound="robert/Zhongquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=160, hitEvent={["5-8"]={reac="hit_heavy_a",effect="重受击",deffect="防御1",deback=30,back=20,delayA=0.04,delayB=0.04}}, noHitEvent={}, },
[1411] = {name=1411, lock=3, action="霸王翔吼拳", loop=0, speedX=0, isJump=false, shader="Negative", effect="", sound="robert/Bawangxianghouquan.mp3", beBeat={"forward_run","stand"}, rangeMin=300, rangeMax=1000, hitEvent={[0]={reac="hit_fly_a",effect="大招受击",deffect="防御2",deback=60,delayB=0.08,shock=3}}, noHitEvent={}, },
[1412] = {name=1412, lock=3, action="龙虎乱舞", loop=0, speedX=270, isJump=false, shader="Negative", effect="RobertPower", sound="robert/Longhuluanwu.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=1000, hitEvent={["23,33,40,50,63,69,80,84,88"]={reac="hit_heavy_a",effect="大招受击",flash=1,deffect="防御2"},["26,36,45,56,78,82,86"]={reac="hit_heavy_b",effect="大招受击",flash=1,deffect="防御2"},[91]={reac="hit_fly_b",effect="大招受击",flash=1,deffect="防御2",delayA=0.56,delayB=0.56,shock=3}}, noHitEvent={}, },
[1413] = {name=1413, lock=3, action="龙牙", loop=0, speedX=0, isJump=false, shader="", effect="", sound="robert/Longya.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=310, hitEvent={[2]={reac="hit_fly_a",effect="重受击",deffect="防御2",deback=70,speed=-250,delayA=0.12,delayB=0.20},[8]={reac="hit_fly_a",effect="重受击",deffect="防御2",deback=70,speed=-120,delayA=0.32,delayB=0.36,shock=3,flash=1}}, noHitEvent={}, },
[1414] = {name=1414, lock=3, action="前摔", loop=0, speedX=0, isJump=false, shader="", effect="", sound="robert/Qianshuai.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=120, hitEvent={[1]={reac="be_caught",effect="抓起",delayA=0.04,delayB=0.04},[4]={reac="hit_fly_a",effect="重受击",speed=-540,delayA=0.16,delayB=0.12,shock=3}}, noHitEvent={}, },
[1415] = {name=1415, lock=3, action="飞燕神龙脚", loop=0, speedX=0, isJump=false, shader="", effect="", sound="robert/Feiyanlongshenjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=320, hitEvent={["7-13"]={reac="hit_heavy_a",effect="重受击",deffect="防御2",deback=40,back=60,delayA=0.06,delayB=0.08,shock=1}}, noHitEvent={}, },
[1416] = {name=1416, lock=3, action="飞燕疾风腿", loop=0, speedX=0, isJump=false, shader="", effect="", sound="robert/Feiyanxuanfengjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=280, hitEvent={[4]={reac="hit_heavy_a",effect="重受击",deffect="防御2",back=60,deback=60,delayA=0.08,delayB=0.16,shock=3,flash=1},[9]={reac="hit_fly_a",effect="重受击",deffect="防御2",deback=40,speed=-540,delayA=0.28,delayB=0.28,shock=6,flash=1}}, noHitEvent={}, },
[1417] = {name=1417, lock=3, action="飞燕旋风腿", loop=0, speedX=0, isJump=false, shader="", effect="", sound="robert/Feiyanxuanfengjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=300, hitEvent={["4,8,12,16"]={reac="hit_heavy_b",effect="重受击",deffect="防御2",deback=40,back=80,delayA=0.04,delayB=0.04,shock=1,flash=1}}, noHitEvent={}, },
[1418] = {name=1418, lock=3, action="无影疾风重段腿", loop=0, speedX=0, isJump=false, shader="", effect="", sound="", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=545, hitEvent={["7,15,23"]={reac="hit_heavy_b",effect="大招受击",deffect="防御2",deback=40,back=45,flash=1,shock=3},["11,19,27"]={reac="hit_heavy_a",effect="大招受击",deffect="防御2",deback=40,back=45,flash=1,shock=3},[31]={reac="hit_fly_a",effect="大招受击",deffect="防御2",speed=-540,deback=40,delayA=0.12,delayB=0.12,shock=4,flash=1}}, noHitEvent={}, },
[1419] = {name=1419, lock=3, action="跳跃轻拳", loop=0, speedX=360, isJump=true, shader="", effect="", sound="robert/Qingquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=180, hitEvent={["4-6"]={reac="hit_light_a",effect="轻受击",deffect="防御1",deback=20,back=15,delayA=0.02,delayB=0.02}}, noHitEvent={}, },
[1420] = {name=1420, lock=3, action="跳跃轻脚", loop=0, speedX=360, isJump=true, shader="", effect="", sound="robert/Qingquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=180, hitEvent={["5-7"]={reac="hit_light_a",effect="轻受击",deffect="防御1",deback=20,back=15,delayA=0.02,delayB=0.02}}, noHitEvent={}, },
[1421] = {name=1421, lock=3, action="跳跃重拳", loop=0, speedX=360, isJump=true, shader="", effect="", sound="robert/Zhongquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=160, hitEvent={["5-7"]={reac="hit_heavy_a",effect="重受击",deffect="防御1",deback=30,back=20,delayA=0.04,delayB=0.04}}, noHitEvent={}, },
[1422] = {name=1422, lock=3, action="跳跃重脚", loop=0, speedX=360, isJump=true, shader="", effect="", sound="robert/Zhongquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=160, hitEvent={["5-8"]={reac="hit_heavy_a",effect="重受击",deffect="防御1",deback=30,back=20,delayA=0.04,delayB=0.04}}, noHitEvent={}, },
[1423] = {name=1423, lock=3, action="跳跃轻拳", loop=0, speedX=-360, isJump=true, shader="", effect="", sound="robert/Qingquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=160, hitEvent={["4-6"]={reac="hit_light_a",effect="轻受击",deffect="防御1",deback=20,back=15,delayA=0.02,delayB=0.02}}, noHitEvent={}, },
[1424] = {name=1424, lock=3, action="跳跃轻脚", loop=0, speedX=-360, isJump=true, shader="", effect="", sound="robert/Qingquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=160, hitEvent={["5-7"]={reac="hit_light_a",effect="轻受击",deffect="防御1",deback=20,back=15,delayA=0.02,delayB=0.02}}, noHitEvent={}, },
[1425] = {name=1425, lock=3, action="跳跃重拳", loop=0, speedX=-360, isJump=true, shader="", effect="", sound="robert/Zhongquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=180, hitEvent={["5-7"]={reac="hit_heavy_a",effect="重受击",deffect="防御1",deback=30,back=20,delayA=0.04,delayB=0.04}}, noHitEvent={}, },
[1426] = {name=1426, lock=3, action="跳跃重脚", loop=0, speedX=-360, isJump=true, shader="", effect="", sound="robert/Zhongquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=160, hitEvent={["5-8"]={reac="hit_heavy_a",effect="重受击",deffect="防御1",deback=30,back=20,delayA=0.04,delayB=0.04}}, noHitEvent={}, },
[1427] = {name=1427, lock=3, action="极限流连舞脚", loop=0, speedX=0, isJump=false, shader="", effect="", sound="robert/Jixianliulianwujiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=200, hitEvent={[4]={reac="hit_heavy_a",effect="重受击",deffect="防御1",back=30,deback=30},[10]={reac="hit_heavy_b",effect="重受击",deffect="防御1",back=30,deback=30,shock=1},[17]={reac="hit_heavy_a",effect="重受击",deffect="防御1",back=35,deback=30,shock=1},[27]={reac="hit_fly_a",effect="重受击",deffect="防御1",speed=-540,deback=30,delayA=0.02,delayB=0.18,shock=3,flash=1}}, noHitEvent={}, },
["assist"] = {name="assist", lock=1, action="减怒气", loop=0, speedX=0, isJump=false, shader="", effect="", sound="", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=999, hitEvent={}, noHitEvent={}, },
}
