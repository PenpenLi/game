module(...,package.seeall)
Config={
[5401] = {name=5401, lock=3, action="站立轻拳", loop=0, target={}, speedX=0, isJump=false, shader="", effect="", sound="", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=140, hitEvent={[3]={reac="hit_light_a",effect="轻受击",deffect="防御1",deback=20,back=15,delayA=0.04,delayB=0.04,shcok=1}}, noHitEvent={}, },
[5402] = {name=5402, lock=3, action="站立轻脚", loop=0, target={}, speedX=0, isJump=false, shader="", effect="", sound="", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=140, hitEvent={[1]={reac="hit_light_a",effect="轻受击",deffect="防御1",deback=20,back=15,delayA=0.04,delayB=0.04,shcok=1}}, noHitEvent={}, },
[5403] = {name=5403, lock=3, action="近身重拳", loop=0, target={}, speedX=0, isJump=false, shader="", effect="", sound="", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=310, hitEvent={[4]={reac="hit_heavy_b",effect="重受击",deffect="防御1",deback=30,back=20,delayA=0.04,delayB=0.04,shcok=1,sound="chang/Tieqiu.mp3"}}, noHitEvent={}, },
[5404] = {name=5404, lock=3, action="站立重脚", loop=0, target={}, speedX=0, isJump=false, shader="", effect="", sound="", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=290, hitEvent={[3]={reac="hit_heavy_b",effect="重受击",deffect="防御1",deback=30,back=20,delayA=0.04,delayB=0.04}}, noHitEvent={}, },
[5405] = {name=5405, lock=3, action="跳跃轻拳", loop=0, target={}, speedX=0, isJump=true, shader="", effect="", sound="", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=225, hitEvent={[5]={reac="hit_light_a",effect="轻受击",deffect="防御1",deback=20,back=30,delayA=0.04,delayB=0.04,shock=1}}, noHitEvent={}, },
[5406] = {name=5406, lock=3, action="跳跃轻脚", loop=0, target={}, speedX=0, isJump=true, shader="", effect="", sound="", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=185, hitEvent={[5]={reac="hit_light_a",effect="轻受击",deffect="防御1",deback=20,back=15,delayA=0.04,delayB=0.04}}, noHitEvent={}, },
[5407] = {name=5407, lock=3, action="跳跃重拳", loop=0, target={}, speedX=0, isJump=true, shader="", effect="", sound="", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=200, hitEvent={[6]={reac="hit_heavy_a",effect="重受击",deffect="防御1",deback=30,back=45,delayA=0.04,delayB=0.04,sound="chang/Tieqiu.mp3"}}, noHitEvent={}, },
[5408] = {name=5408, lock=3, action="跳跃重脚", loop=0, target={}, speedX=0, isJump=true, shader="", effect="", sound="", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=250, hitEvent={[5]={reac="hit_heavy_a",effect="重受击",deffect="防御1",deback=30,back=20,delayA=0.04,delayB=0.04}}, noHitEvent={}, },
[5409] = {name=5409, lock=3, action="铁球大压杀", loop=0, target={}, speedX=0, isJump=true, shader="", effect="", sound="", beBeat={"forward_run","stand"}, rangeMin=150, rangeMax=500, hitEvent={["11-24"]={reac="hit_fly_a",effect="重受击",deffect="防御1",deback=30,delayA=0.12,delayB=0.12,shock=3,flash=1,fall=1}}, noHitEvent={[25]={shock=3,flash=1},[26]={shock=3},[28]={shock=3}}, },
[5410] = {name=5410, lock=3, action="铁球粉碎击", loop=0, target={}, speedX=0, isJump=false, shader="", effect="", sound="", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=440, hitEvent={[8]={reac="hit_fly_a",effect="重受击",deffect="防御1",deback=30,delayA=0.04,delayB=0.04,shock=3,flash=1,sound="chang/Tieqiu.mp3"}}, noHitEvent={[9]={shock=3}}, },
[5411] = {name=5411, lock=3, action="遁逃", loop=0, target={}, speedX=0, isJump=false, shader="", effect="", sound="", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=500, hitEvent={["3-10"]={reac="hit_fly_a",effect="重受击",deffect="防御1",deback=30,delayA=0.04,delayB=0.04,shock=3,speed=-560,sound="chang/Tieqiu.mp3"}}, noHitEvent={}, },
[5412] = {name=5412, lock=3, action="铁球大回转", loop=0, target={}, speedX=0, isJump=false, shader="", effect="", sound="", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=250, hitEvent={[5]={reac="hit_fly_a",effect="重受击",deffect="防御1",deback=30,delayA=0.08,shock=3,speed=-130,flash=1,sound="chang/Tieqiu.mp3"},["14,21"]={reac="hit_fly_a",effect="重受击",deffect="防御1",deback=30,delayA=0.08,shock=3,speed=-130,sound="chang/Tieqiu.mp3"},[30]={reac="hit_fly_a",effect="重受击",deffect="防御1",deback=30,delayA=0.08,shock=3,speed=-130,flash=1,sound="chang/Tieqiu.mp3"}}, noHitEvent={}, },
[5413] = {name=5413, lock=3, action="超重击", loop=0, target={}, speedX=0, isJump=false, shader="", effect="", sound="", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=200, hitEvent={[7]={reac="hit_fly_a",effect="重受击",deffect="防御1",deback=30,delayA=0.04,delayB=0.12,shock=3,speed=-120}}, noHitEvent={}, },
[5414] = {name=5414, lock=3, action="大破坏投", loop=0, target={"chang_大破坏投_配小黑人","somesault_up_a"}, speedX=0, isJump=false, shader="", effect="", sound="", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=999, hitEvent={[1]={effect="重受击"},["5,13,21,29"]={effect="重受击",shock=3,flash=1,sound="daimon/Zadi.mp3"}}, noHitEvent={[30]={shock=3},[40]={shock=3}}, },
[5415] = {name=5415, lock=3, action="铁球大扑杀", loop=0, target={}, speedX=0, isJump=false, shader="", effect="", sound="", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=340, hitEvent={["7,14"]={reac="hit_heavy_b",effect="重受击",deffect="防御1",deback=30,back=10,delayA=0.04,delayB=0.04,shcok=1,sound="chang/Tieqiu.mp3"},[15]={reac="hit_heavy_a",effect="重受击",deffect="防御1",deback=30,back=10,delayA=0.12,delayB=0.08,shcok=3,sound="chang/Tieqiu.mp3"}}, noHitEvent={}, },
[5416] = {name=5416, lock=3, action="前摔", loop=0, target={}, speedX=0, isJump=false, shader="", effect="", sound="", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=130, hitEvent={[2]={reac="be_caught",effect="抓起",flash=1},[16]={reac="hit_fly_a",effect="重受击",delayA=0.08,delayB=0.02,speed=-560,shock=3}}, noHitEvent={}, },
[5417] = {name=5417, lock=3, action="背摔", loop=0, target={"chang_背摔_配小黑人","somesault_up_a"}, speedX=0, isJump=false, shader="", effect="", sound="", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=999, hitEvent={[3]={effect="重受击",shock=1},[12]={effect="重受击",shock=3,flash=1}}, noHitEvent={}, },
[5418] = {name=5418, lock=1, action="铁球大暴走_释放", loop=0, target={}, speedX=0, isJump=false, shader="Negative", effect="", sound="", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=999, hitEvent={}, noHitEvent={}, },
[5419] = {name=5419, lock=3, action="铁球大暴走_攻击", loop=0, target={}, speedX=0, isJump=false, shader="Negative", effect="", sound="", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=999, hitEvent={["4,16,32,44"]={reac="hit_heavy_b",effect="重受击",deffect="防御1",deback=30,flash=1,shock=1},["9,22,38,53"]={reac="hit_heavy_a",effect="重受击",deffect="防御1",deback=30,shock=1},[63]={reac="hit_fly_a",effect="重受击",deffect="防御1",deback=30,flash=1,shock=3}}, noHitEvent={}, },
[5420] = {name=5420, lock=3, action="跳跃轻拳", loop=0, target={}, speedX=360, isJump=true, shader="", effect="", sound="", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=225, hitEvent={[5]={reac="hit_light_a",effect="轻受击",deffect="防御1",deback=20,back=30,delayA=0.04,delayB=0.04,shock=1}}, noHitEvent={}, },
[5421] = {name=5421, lock=3, action="跳跃轻脚", loop=0, target={}, speedX=360, isJump=true, shader="", effect="", sound="", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=185, hitEvent={[5]={reac="hit_light_a",effect="轻受击",deffect="防御1",deback=20,back=15,delayA=0.04,delayB=0.04}}, noHitEvent={}, },
[5422] = {name=5422, lock=3, action="跳跃重拳", loop=0, target={}, speedX=360, isJump=true, shader="", effect="", sound="", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=200, hitEvent={[6]={reac="hit_heavy_a",effect="重受击",deffect="防御1",deback=30,back=45,delayA=0.04,delayB=0.04,sound="chang/Tieqiu.mp3"}}, noHitEvent={}, },
[5423] = {name=5423, lock=3, action="跳跃重脚", loop=0, target={}, speedX=360, isJump=true, shader="", effect="", sound="", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=250, hitEvent={[5]={reac="hit_heavy_a",effect="重受击",deffect="防御1",deback=30,back=20,delayA=0.04,delayB=0.04}}, noHitEvent={}, },
[5424] = {name=5424, lock=3, action="跳跃轻拳", loop=0, target={}, speedX=-360, isJump=true, shader="", effect="", sound="", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=225, hitEvent={[5]={reac="hit_light_a",effect="轻受击",deffect="防御1",deback=20,back=30,delayA=0.04,delayB=0.04,shock=1}}, noHitEvent={}, },
[5425] = {name=5425, lock=3, action="跳跃轻脚", loop=0, target={}, speedX=-360, isJump=true, shader="", effect="", sound="", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=185, hitEvent={[5]={reac="hit_light_a",effect="轻受击",deffect="防御1",deback=20,back=15,delayA=0.04,delayB=0.04}}, noHitEvent={}, },
[5426] = {name=5426, lock=3, action="跳跃重拳", loop=0, target={}, speedX=-360, isJump=true, shader="", effect="", sound="", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=200, hitEvent={[6]={reac="hit_heavy_a",effect="重受击",deffect="防御1",deback=30,back=45,delayA=0.04,delayB=0.04,sound="chang/Tieqiu.mp3"}}, noHitEvent={}, },
[5427] = {name=5427, lock=3, action="跳跃重脚", loop=0, target={}, speedX=-360, isJump=true, shader="", effect="", sound="", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=250, hitEvent={[5]={reac="hit_heavy_a",effect="重受击",deffect="防御1",deback=30,back=20,delayA=0.04,delayB=0.04}}, noHitEvent={}, },
["rush"] = {name="rush", lock=3, action="跑", loop=1, target={}, speedX=900, isJump=false, shader="Negative", effect="", sound="", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=999, hitEvent={}, noHitEvent={}, },
["assist"] = {name="assist", lock=1, action="召唤攻击", loop=0, target={}, speedX=0, isJump=false, shader="", effect="", sound="", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=999, hitEvent={["1-5"]={effect="重受击"}}, noHitEvent={[8]={shock=3},[9]={shock=3},[11]={shock=3},[28]={shock=3}}, },
}
