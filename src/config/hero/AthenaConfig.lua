module(...,package.seeall)
Config={
[1701] = {name=1701, lock=3, action="站立轻拳", loop=0, speedX=0, isJump=false, shader="", effect="", sound="athena/Qingquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=180, hitEvent={[3]={reac="hit_light_a",effect="轻受击",deffect="防御1",deback=20,back=15,delayA=0.08,delayB=0.08}}, noHitEvent={}, },
[1702] = {name=1702, lock=3, action="站立轻脚", loop=0, speedX=0, isJump=false, shader="", effect="", sound="athena/Qingquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=180, hitEvent={[2]={reac="hit_light_a",effect="轻受击",deffect="防御1",deback=20,back=15,delayA=0.08,delayB=0.08}}, noHitEvent={}, },
[1703] = {name=1703, lock=3, action="站立重拳", loop=0, speedX=0, isJump=false, shader="", effect="", sound="athena/Zhongquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=190, hitEvent={[1]={reac="hit_heavy_a",effect="重受击",deffect="防御1",deback=30,back=20,delayA=0.08,delayB=0.08}}, noHitEvent={}, },
[1704] = {name=1704, lock=3, action="站立重脚", loop=0, speedX=0, isJump=false, shader="", effect="", sound="athena/Zhongquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=240, hitEvent={[6]={reac="hit_heavy_a",effect="重受击",deffect="防御1",deback=30,back=20,delayA=0.12,delayB=0.12}}, noHitEvent={}, },
[1705] = {name=1705, lock=3, action="跳跃轻拳", loop=0, speedX=0, isJump=true, shader="", effect="", sound="athena/Qingquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=170, hitEvent={[8]={reac="hit_light_a",effect="轻受击",deffect="防御1",back=15,deback=20,delayA=0.08,delayB=0.08}}, noHitEvent={}, },
[1706] = {name=1706, lock=3, action="跳跃轻脚", loop=0, speedX=0, isJump=true, shader="", effect="", sound="athena/Qingquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=185, hitEvent={[7]={reac="hit_light_a",effect="轻受击",deffect="防御1",back=15,deback=20,delayA=0.04,delayB=0.04}}, noHitEvent={}, },
[1707] = {name=1707, lock=3, action="跳跃重拳", loop=0, speedX=0, isJump=true, shader="", effect="", sound="athena/Zhongquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=165, hitEvent={[6]={reac="hit_heavy_b",effect="重受击",deffect="防御1",deback=30,delayA=0.06,delayB=0.06}}, noHitEvent={}, },
[1708] = {name=1708, lock=3, action="跳跃重脚", loop=0, speedX=0, isJump=true, shader="", effect="", sound="athena/Zhongquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=195, hitEvent={[9]={reac="hit_heavy_b",effect="重受击",deffect="防御1",deback=20,delayA=0.12,delayB=0.12}}, noHitEvent={}, },
[1709] = {name=1709, lock=3, action="凤凰方箭", loop=0, speedX=0, isJump=false, shader="", effect="", sound="athena/Fenghuangfangjian.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=150, hitEvent={["23-28,34-39,50,51"]={reac="hit_heavy_b",effect="大招受击",deffect="防御2",back=5,deback=10,flash=1},[52]={reac="hit_fly_a",effect="大招受击",deffect="防御2",speed=-650,deback=30,delayA=0.12,delayB=0.12}}, noHitEvent={}, },
[1710] = {name=1710, lock=3, action="空中闪光水晶波", loop=0, speedX=0, isJump=true, shader="", effect="", sound="athena/Kongzhongshanguangshuijingbo.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=200, hitEvent={["25,33,43,56,67"]={reac="hit_fly_a",burn = "Thunder",effect="大招受击",deffect="防御2",deback=30,delayA=0.12,delayB=0.12}}, noHitEvent={}, },
[1711] = {name=1711, lock=3, action="闪光水晶波", loop=0, speedX=0, isJump=false, shader="", effect="", sound="athena/Shanguangshuijingbo.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=200, hitEvent={["26,35,44,56,67"]={reac="hit_fly_a",burn = "Thunder",effect="大招受击",deffect="防御2",deback=30,delayA=0.12,delayB=0.12}}, noHitEvent={}, },
[1712] = {name=1712, lock=3, action="凤凰剑", loop=0, speedX=0, isJump=false, shader="", effect="", sound="athena/Fenghuangjian.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=250, hitEvent={["9-13"]={reac="hit_heavy_a",effect="大招受击",deffect="防御2",deback=10},[19]={reac="hit_heavy_b",effect="大招受击",deffect="防御2",deback=30,delayB=0.12}}, noHitEvent={}, },
[1713] = {name=1713, lock=3, action="划空光剑", loop=0, speedX=0, isJump=false, shader="", effect="", sound="athena/Huakongguangjian.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=180, hitEvent={["9,11,13,15,17,19,21"]={reac="hit_heavy_b",forceReac=true,effect="重受击",deffect="防御2",deback=30,flash=1,shock=1},[23]={reac="hit_fly_a",effect="重受击",deffect="防御2",deback=30,delayA=0.04,delayB=0.04,shock=3}}, noHitEvent={}, },
[1714] = {name=1714, lock=3, action="精神力反射波", loop=0, speedX=720, isJump=false, shader="", effect="", sound="athena/Jingshenlifanshebo.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=355, hitEvent={["13,16,19"]={reac="hit_heavy_b",forceReac=true,effect="重受击",deffect="防御2",deback=30,flash=1,back=15},[22]={reac="hit_fly_a",effect="重受击",deffect="防御2",speed=-540,deback=30,delayA=0.04,delayB=0.04,shock=3}}, noHitEvent={}, },
[1715] = {name=1715, lock=3, action="心灵传送术-1", loop=0, speedX=0, isJump=false, shader="Blur", effect="", sound="athena/Xinlingchuansongshu.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=1000, hitEvent={}, noHitEvent={}, },
[1716] = {name=1716, lock=3, action="超级精神穿透", loop=0, speedX=0, isJump=false, shader="", effect="", sound="athena/Chaojijingshenchuantou.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=170, hitEvent={[3]={reac="be_caught",effect="抓起",delayA=0.04,delayB=0.04},[16]={reac="hit_fly_b",effect="重受击",deffect="防御2",speed=-360,delayB=0.36,shock=3}}, noHitEvent={}, },
[1717] = {name=1717, lock=3, action="精神力射（背摔）", loop=0, speedX=0, isJump=false, shader="", effect="", sound="athena/Houshuai.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=150, hitEvent={}, noHitEvent={}, },
[1718] = {name=1718, lock=3, action="位投（前摔）", loop=0, speedX=0, isJump=false, shader="", effect="", sound="athena/Qianshuai.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=150, hitEvent={}, noHitEvent={}, },
[1719] = {name=1719, lock=3, action="精神力球_动作", loop=0, speedX=0, isJump=false, shader="", effect="", sound="athena/Jingshenliqiu.mp3", beBeat={"forward_run","stand"}, rangeMin=300, rangeMax=1000, hitEvent={[0]={reac="hit_heavy_b",effect="重受击",deffect="防御2",deback=30,back=60,delayB=0.12}}, noHitEvent={}, },
[1720] = {name=1720, lock=3, action="连环脚", loop=0, speedX=360, isJump=false, shader="", effect="", sound="athena/Lianhuanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=210, hitEvent={[3]={reac="hit_heavy_b",effect="重受击",deffect="防御1",deback=20,back=5,delayA=0.08,delayB=0.08,shock=1},[7]={reac="hit_heavy_a",effect="重受击",deffect="防御1",deback=20,back=5,delayA=0.08,delayB=0.08,shock=1}}, noHitEvent={}, },
[1721] = {name=1721, lock=3, action="跳跃轻拳", loop=0, speedX=360, isJump=true, shader="", effect="", sound="athena/Qingquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=170, hitEvent={[8]={reac="hit_light_a",effect="轻受击",deffect="防御1",back=15,deback=20,delayA=0.08,delayB=0.08}}, noHitEvent={}, },
[1722] = {name=1722, lock=3, action="跳跃轻脚", loop=0, speedX=360, isJump=true, shader="", effect="", sound="athena/Qingquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=185, hitEvent={[7]={reac="hit_light_a",effect="轻受击",deffect="防御1",back=15,deback=20,delayA=0.04,delayB=0.04}}, noHitEvent={}, },
[1723] = {name=1723, lock=3, action="跳跃重拳", loop=0, speedX=360, isJump=true, shader="", effect="", sound="athena/Zhongquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=165, hitEvent={[6]={reac="hit_heavy_b",effect="重受击",deffect="防御1",deback=30,delayA=0.06,delayB=0.06}}, noHitEvent={}, },
[1724] = {name=1724, lock=3, action="跳跃重脚", loop=0, speedX=360, isJump=true, shader="", effect="", sound="athena/Zhongquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=195, hitEvent={[9]={reac="hit_heavy_b",effect="重受击",deffect="防御1",deback=20,delayA=0.12,delayB=0.12}}, noHitEvent={}, },
[1725] = {name=1725, lock=3, action="跳跃轻拳", loop=0, speedX=-360, isJump=true, shader="", effect="", sound="athena/Qingquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=170, hitEvent={[8]={reac="hit_light_a",effect="轻受击",deffect="防御1",back=15,deback=20,delayA=0.08,delayB=0.08}}, noHitEvent={}, },
[1726] = {name=1726, lock=3, action="跳跃轻脚", loop=0, speedX=-360, isJump=true, shader="", effect="", sound="athena/Qingquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=185, hitEvent={[7]={reac="hit_light_a",effect="轻受击",deffect="防御1",back=15,deback=20,delayA=0.04,delayB=0.04}}, noHitEvent={}, },
[1727] = {name=1727, lock=3, action="跳跃重拳", loop=0, speedX=-360, isJump=true, shader="", effect="", sound="athena/Zhongquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=165, hitEvent={[6]={reac="hit_heavy_b",effect="重受击",deffect="防御1",deback=30,delayA=0.06,delayB=0.06}}, noHitEvent={}, },
[1728] = {name=1728, lock=3, action="跳跃重脚", loop=0, speedX=-360, isJump=true, shader="", effect="", sound="athena/Zhongquanjiao.mp3", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=195, hitEvent={[9]={reac="hit_heavy_b",effect="重受击",deffect="防御1",deback=20,delayA=0.12,delayB=0.12}}, noHitEvent={}, },
["assist"] = {name="assist", lock=1, action="加血", loop=0, speedX=-360, isJump=true, shader="", effect="", sound="", beBeat={"forward_run","stand"}, rangeMin=0, rangeMax=195, hitEvent={[9]={reac="hit_heavy_b",effect="重受击",deffect="防御1",deback=20,delayA=0.12,delayB=0.12}}, noHitEvent={}, },
}
