/*
Plugin=打开程序编辑文件所在位置
Name1=打开程序编辑文件所在位置
Command1=CustomFunction_getDocumentPath
Author=yyy
Version=0.1
*/

/*

支持程序：
1、com 方式：Word、Excel、PowerPoint、SciTE
2、窗口标题方式：EverEdit、EmEditor、Sublime text、notepad2、notepad++ 等智能获取，灵感来自 Array
3、启动参数方式：帮助文档、压缩包、图片查看等

com 来自 sunwind，winmgmt 来自 Array

版本更新：
1.0 初版。
1.1 修正路径有2个空格及以上的问题。
1.2 改用新的提取路径方法。最终路径如果不存在为程序 exe 路径。
1.3 修正路径中有2个 .XX（如 TreeSize.chs\TreeSize.exe）造成的匹配错误的问题
*/

; 返回程序编辑文件的路径
CustomFunction_getDocumentPath()
{   
    Global gMenuZ
    iHwnd := gMenuZ.Data.Hwnd
    ; WinGet, iHwnd, ID, A
    ; MouseGetPos,,,iHwnd
    
    WinGet, pPath, Processpath, ahk_id %iHwnd%
    SplitPath,pPath,pName,pDir,,pNameNoExt

    ;; 按住 ctrl 返回程序路径
    ;KeyState := GetKeyState("ctrl")
    ;if keyState = D
    ;{
    ;    return pPath
    ;}
    
    if IsLabel("CustomFunction_Case_" pNameNoExt)
        Goto CustomFunction_Case_%pNameNoExt%
    else
        Goto CustomFunction_Case_Default

    CustomFunction_Case_WINWORD:  ;Word
        app:= ComObjActive("Word.Application")
        doc:= app.ActiveDocument
        return % doc.FullName
    
    CustomFunction_Case_EXCEL:  ;Excel
        app := ComObjActive("Excel.Application")
        cBook := app.ActiveWorkbook
        return % cBook.FullName

    CustomFunction_Case_POWERPNT:  ;PowerPoint
        app := ComObjActive("Powerpnt.Application")
        activePresentation := Application.ActivePresentation
        return % activePresentation.FullName

    CustomFunction_Case_SciTE:  ; 打开SciTE当前文件所在目录  
        Return % CustomFunction_GDP_GetCurrentFilePath(CustomFunction_GDP_GetSciTEInstance())

    CustomFunction_Case_Default:
        ; 从标题中获取可能的路径
        WinGetTitle, winTitle, ahk_id %iHwnd%
        dPath := CustomFunction_getDocumentPathFromStr(winTitle)
        
        if (!dPath) {
            ; 从启动命令行获取可能的路径
            WinGet, NumPID, PID, ahk_id %iHwnd%
            CommandLine := CustomFunction_winmgmt("CommandLine", "Where ProcessId = " NumPID "")
            ;dPath := Regexreplace(CommandLine, ToMatch(pPath))
            StringReplace, dPath, CommandLine, %pPath%,, All
            dPath := CustomFunction_getDocumentPathFromStr(dPath)
        }

        if (!dPath)
            dPath := pPath
        return dPath
}

CustomFunction_GDP_GetCurrentFilePath(scite)  
{  
    if !scite  
    {  
        MsgBox, 16, Error, Can't find SciTE!  
        ExitApp  
    }  
    return scite.CurrentFile  
}

CustomFunction_GDP_GetSciTEInstance()  
{  
    olderr := ComObjError()
    ComObjError(false)
    scite := ComObjActive("SciTE4AHK.Application")
    ComObjError(olderr)
    return IsObject(scite) ? scite : ""  
}  

CustomFunction_winmgmt(v,w:="",d:="Win32_Process",m:="winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2"){
	s:=[]
	for i in ComObjGet(m).ExecQuery("Select " (v?v:"*") " from " d  (w ? " " w :""))
		s.Insert(i[v])
	return s.MaxIndex()?(s.MaxIndex()=1?s.1:s):""
}

;; 外部测试用
;GDP_test()
;GDP_test()
;{
;    sPaths = 
;    (
;    c:\Program Files\Windows Mail aaaa
;    "" "c:\Program Files\Windows Mail\wab.exe"
;    c:\Program Files\Windows Mail\wab.exe - EverEdit
;    )
    
;    for i, v in StrSplit(sPaths, "`n")
;    {
;        MsgBox % CustomFunction_getDocumentPathFromStr(v)
;    }
;}

CustomFunction_getDocumentPathFromStr(strPath)
{
    ; 提取可能的文件路径
    RegExMatch(strPath, "(\w:\\.*\.[\w-]+)", s)
    if CustomFunction_GDP_fileExist(s)
        return s
	
	; 按空格分割
	arr := StrSplit(strPath, A_Space)
	
	; 识别路径的开始和后面部分
	dPath =
	afterArr := []
	for i, v in arr
	{
		v := CustomFunction_GDP_trimPath(v)
		if CustomFunction_GDP_likePath(v)
		{
			dPath := CustomFunction_GDP_trimPath(v)
			if CustomFunction_GDP_fileExist(dPath)
				return dPath
		} else if (dPath) {
			afterArr.insert(v)
		}
	}
	
	; 连接后面部分，查看是否存在
	for i, v in afterArr
	{
		dPath := dPath " " v
		dPath := CustomFunction_GDP_trimPath(dPath)
		if CustomFunction_GDP_fileExist(dPath)
			return dPath
	}
}

CustomFunction_GDP_trimPath(s)  ; 去除前后干扰符
{
    return Trim(s, " `t`n""")
}

CustomFunction_GDP_fileExist(s)  ; 需要绝对路径
{
    return s && instr(s, "\") && FileExist(s)
}

CustomFunction_GDP_likePath(s)
{
    return RegExMatch(s, "\w:\\.*")
}
