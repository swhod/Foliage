
----

## 按键传入后的分支（惯用左手）

*独自悬空*
if 主角不在地上 && ( 主角.抓握的植物节点 == null )
{
	动作-下落();
	return ;
}

*攀爬，或者与植物一起悬空*
if 主角不在地上 && ( 主角.抓握的植物节点 != null )
{
	if 植物在土里
	{
		if 按键类型 == AD { 动作-松开植物并横向位移(); }
		if 按键类型 == WS { 动作-攀爬(); }
		if 按键类型 == E { 动作-松开植物(); }
		if 按键类型 == 上下左右 { 非法操作(); }
	}
	else
	{
		动作-带着植物下落();
	}
	return ;
}

*独自走路*
if 主角在地上 && ( 主角.抓握的植物节点 == null )
{
	if 按键类型 == AD { 动作-横向位移(); }
	if 按键类型 == WS { 动作-攀爬(); }
	if 按键类型 == E { 动作-抓住植物(); }
	if 按键类型 == 上下左右 { 非法操作(); }
	return ;
}

*把植物当扶手，或者带着植物走*
if 主角在地上 && ( 主角.抓握的植物节点 != null )
{
	if 植物在土里
	{
		if 按键类型 == AD { 动作-松开植物并横向位移(); }
		if 按键类型 == WS { 动作-攀爬(); }
		if 按键类型 == E { 动作-松开植物(); }
		if 按键类型 == 上下左右 { 动作-让植物位移(); }
	}
	else
		if 按键类型 == AD { 动作-带着植物横向位移(); }
		if 按键类型 == WS { 非法操作(); }
		if 按键类型 == E { 动作-松开植物(); }
		if 按键类型 == 上下左右 { 动作-让植物位移(); }
	return ;
}

## 动作函数

*动作函数都是尝试动作（返回值是 bool 型的），比如下落是“尝试下落”的意思，运行时总是需要先判断能否下落*

bool 动作-松开植物并横向位移()
{
	bool b = 动作-松开植物(); 
	if b 
	{ 
		b = 动作-横向位移(); 
		if !b { 动作-抓住植物(); }
	}
	return b;
}

bool 动作-横向位移()
{
	direction d = 横向位移方向();
	if d == 留在原地 { return false; }
	更新位置-横向位移(d);
	动作-下落();
	return true;
}

direction 横向位移方向()
{
	if 移动方向上主角的头会被挡住 { return 留在原地; }
	if 移动方向上主角的脚会被挡住 { return 横向登上障碍; }
	else { return 横向位移; }
}

bool 动作-下落()
{
	int dropgridcount = 0;
	while 主角不在地上 do
	{
		更新位置-纵向位移(主角);
		dropgridcount = dropgridcount + 1;
	}
	if dropgridcount == 0 { return false; }
	if dropgridcount > 3 { 主角死亡; }
	return true;
}

bool 动作-攀爬()
{
	if 主角.抓握的植物节点 == null
	{
		if 主角不在地上 { return false; }
		if 向上攀爬
		{
			bool b = 动作-抓住植物();
			if !b { return false; }
		}
	}
	if 攀爬方向上主角会被挡住
	{ 
		if 向下攀爬 { 动作-松开植物(); }
		return false; 
	}
	更新位置-纵向位移(主角);
	动作-松开植物();
	bool b = 动作-抓住植物();
	if !b { 动作-下落(); }
	return true;
}

bool 动作-抓住植物()
{
	if 主角.抓握的植物节点 != null { return false; }
	if 主角头部没有植物 && 主角脚部没有植物 { return false; }
	if 主角脚部有植物 { 主角.抓握的植物节点 = 主角脚部的植物; }
	if 主角头部有植物 { 主角.抓握的植物节点 = 主角头部的植物; }
	return true;
}

bool 动作-松开植物()
{
	if 主角.抓握的植物节点 == null { return false; }
	if 主角抓握的植物不插在土里 { return false; }
	主角.抓握的植物节点 = null;
	动作-下落();
	return true;
}

bool 动作-带着植物横向位移()
{
	direction d = 横向位移方向();
	if d == 留在原地 { return false; }
	bool b = 植物移动(主角抓握的植物, d);
	if b { 动作-横向位移(); }
	return b;
}

bool 动作-带着植物下落()
{
	int dropgridcount = 0;
	bool b = 植物下插(主角抓握的植物);
	while 主角不在地上 && b do
	{
		更新位置-纵向位移(主角);
		dropgridcount = dropgridcount + 1;
		b = 植物移动(主角抓握的植物); 
	}
	if dropgridcount == 0 { return false; }
	if dropgridcount > 3 { 主角死亡; }
	return true;
}

bool 动作-让植物位移()
{
	if 主角不在地上 { return false; }
	if 主角.抓握的植物 == null { return false; }
	bool b = 植物移动(主角抓握的植物, 方向); 
	return b;
}