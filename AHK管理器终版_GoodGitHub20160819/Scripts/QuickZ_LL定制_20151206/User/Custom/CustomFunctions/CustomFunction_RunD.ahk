CustomFunction_RunD(ExePath,WinTitle,x=0,y=0,WaitDuration=0)
{ ;��ʽΪRunD(Ӧ�ó���,Ӧ�ó���ı���,x,y,�ȴ�ʱ��)
	Global gMenuZ
	Run "%ExePath%"
	Sleep,% (WaitDuration="") ? 1000 : WaitDuration
	WinWaitActive, %WinTitle% ,,5
	WinActivate, %WinTitle%
	x:=x ? x : 100
	y:=y ? y : 100
	PostMessage, 0x233, CustomFunction_HDrop(gMenuZ.Data.files,x,y), 0,, %WinTitle%
}