﻿我上次向大家介绍快速启动工具 [RunZ](https://github.com/goreliu/runz) 后，有不少朋友表示对它感兴趣，并且有部分用户提出了宝贵的意见和建议，我在此深表感谢。我对大家多次询问的一些问题依次回复并整理在此（[常见问题](https://github.com/goreliu/runz/wiki/常见问题)）。这几天时间我也在马不停蹄地实现新功能和修复已有缺陷。在这里我将主要的新增功能分享给大家。

## 界面调整

一个软件的界面还是很重要的，上次的 RunZ 截图毫无意外地被一些人嫌弃了。我努力在不影响性能不占用更多资源的前提尽量让 RunZ 的界面美观了一些。

![主界面](Images/main.png)

从截图可以看到，和上次相比好看了不少，不知道大家是否满意呢？主要有以下三个改动：

1. 最明显的，支持边框图片了，可以随意更换成自己喜欢的图片，横纵的边框宽度也一致了。
2. 主界面的「命令/文件」列与「注释」列分开显示，支持随意调整列宽度，支持无注释的情况自动展开「命令/文件」列。
3. 支持皮肤文件，里边可以详细定制字体、控件大小、边框宽度、边框图片、每列输出的宽度、背景颜色、是否显示标题栏、是否显示任务栏图标和是否显示当前命令等等。发布包自带了两个皮肤可供参考。可以方便地在不同皮肤之间切换，让你拥有一个与众不同的 RunZ。

说完了界面，就要重点介绍下新增功能了，毕竟这才是重点。

## 「发送到」菜单功能

有些时候，我们只需要添加一个文件进来，以便快速找到。如果将该文件所在的目录添加到配置文件，会将很多无关的文件一起搜罗进来。这时就可以使用「发送到」菜单了。在资源管理器或 TotalCommander 里选定文件（可一次选择多个文件），然后打开右键菜单，点「发送到」中的 RunZ，就会用编辑器（默认是记事本，可以在系统修改文件打开方式，换更专业的编辑器）打开一个配置文件。

我们可以看下该文件的内容。我选择的文件是 QRCode.ahk，可以看到这里已经将它的文件名和所在目录路径添加进去了，如果没有其他需求，就可以直接关闭该文件，用 Ctrl + q 或者右键菜单重启 RunZ，就可以直接搜到 QRCode.ahk 并执行了。如果需要对该文件添加注释，以便更容易找到，可以把 @ 的第二个参数 QRCode 修改成其他文本。如果还需要对该文件绑定快捷键，那么可以按照注释那样将快捷键（需要了解下 AHK 的按键书写方式，如 #a 是 Win + a，^b 是 Ctrl + b，!c 是 Alt + c）添加为第 4 个参数就可以了。如果选择了多个文件，则每个文件都会有对应内容。

```
; 此文件（AHK 代码）由发送到菜单或命令行工具写入，也可手动修改
; 一定不要添加重复标签，否则程序会启动异常，必须再手动修改或删除该文件来恢复

global Arg

UserFunctionsAuto:
    ; 第一个参数为标签名，请不要随意修改
    ; 第二个参数为搜索项（内容随意）
    ; 第三个参数为 true 时，当搜索无结果也会显示，默认为 false
    ; 第四个参数为绑定的全局热键，默认无
    ; 比如：
    ; @("UserTest1", "用户测试（ut1）", false, "#p")
    ; 请不要修改包含 -*-*-*-*-*- 的行（包括前边的空格），否则发送到菜单功能会异常

    ; 以下内容为自动添加，手动添加请在此行上方添加
    ; -*-*-*-*-*-
    @("QRCode", "QRCode")
return

; 以下内容为自动添加
; -*-*-*-*-*-
QRCode:
    ; 用法：  Run, "文件名" "参数..", 工作目录, Max|Min|Hide
    Run, "C:\Users\goreliu\Downloads\QRCode.ahk", "C:\Users\goreliu\Downloads"
return


; 以下内容为手动添加，可自由编辑

```

可能有些用户认为直接编辑配置文件这种交互方式不好，不如在图形界面方便，这一点我也仔细考虑过。当配置项数量较少时，在图形界面配置的确有较大的优势，直观方便，对用户更友好。但当配置项较多时，图形界面的缺点也慢慢体现出来，比如密密麻麻的标签页、编辑框、单选框、复选框让人无从下手，而且碍于显示效果，很多选项没办法详尽的解释，搜索到自己想找的配置项也比较困难。而直接编辑配置文件的优点体现了出来，我只需要关心自己感兴趣的配置项，其他的维持默认就好了，无需细看。配置文件中可以添加详尽的注释，甚至包含一份说明文档，也能显示的下。想搜索直接用编辑器的搜索功能即可。而且更易于备份和比较。

因为目前 RunZ 的配置项已经比较多了，要想在图形界面友好地展示出来是一件比较困难的事情，而直接编辑文件的方式还是游刃有余。而且正常使用的过程中并不需要频繁地修改配置文件。

至于「发送到」菜单编辑的这个文件，并不是通常意义的配置文件，而是 AHK 代码。这也是我尝试的一种新的交互方式，这样做的好处是更加灵活，更容易实现复杂的功能，而易用性并没有降低很多。

## 二重搜索功能

顾名思义，二重搜索是指对上次运行完的命令结果再进行一次搜索过滤，根据输入将结果实时展示出来。

典型的场景是这样的，我需要在当前系统运行的所有进程中，搜索特定的进程。我需要先在所有命令中搜到「列出进程列表」的 ProcessList 功能（可以简单输入 jc 或者 jclb）。此为第一重搜索。

结果出来后我发现内容很多，我想依次查看是否有 totalcmd.exe 和 tmux.exe 进程。当然可以输入 jc totalcmd 回车，然后清空再输入 jc tmux 回车，这样通过两次执行来实现。但更直观方便的用法是输入 jc 回车，自动进入二重搜索模式，此时无论输入什么，都会将匹配到的进程实时显示出来，效果如下：

![二重搜索](Images/process_list.gif)

注意此功能并不是为查找进程功能专门定制的，插件要想支持此功能，只需要加一行代码。

拿上边演示的查找进程功能来看，它的实现代码只有 6 行。我已经添加了注释，这里重点看最后一行，它的功能就是告诉 RunZ，我输出的内容可以被再搜索。只要插件包含这一行，就会自动启用二重搜索功能。

```
ProcessList:
    result := ""

    ; 这三行是获取进程列表的逻辑
    for process in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process")
        result .= "* | 进程 | " process.Name " | " process.CommandLine "`n"
    Sort, result

	; Arg 为输入参数，如输入 jc hot 回车，Arg 为 hot
	; AlignText 函数用来对结果分列格式化
    ; 符合 x | xxxx | 内容1 | 内容2 的每行都可以被格式化成统一宽度
	; FilterResult 函数则是用 tcmatch.dll 对文本进行搜索，保留匹配到的内容
	; DisplayResult 函数用来展示内容
    DisplayResult(FilterResult(AlignText(result), Arg))

    ; TurnOnResultFilter 函数告诉 RunZ，我输出的内容可以再被搜索。
    TurnOnResultFilter()
return
```

## 输入改变时实时执行

另一种场景和二重搜索有些类似，比如我需要计算一个表达式 123 * 456 + 789 的值，但我希望实时看到它每一步的计算结果，而无需按回车。

自带的计算器已经支持该功能，只需要输入 js 回车，接下来输入的表达式会被实时计算和展示出来。

![计算器自动执行](Images/calc_auto.gif)

插件要支持实时执行也是非常容易的，拿计算器插件来说，只需要两行代码，TurnOnRealtimeExec 函数便是告知 RunZ 每当输入内容变化时都需要再调用我一次。

```
Calc:
    DisplayResult(Eval(Arg))
    TurnOnRealtimeExec()
return
```

由此可见，写一个输出内容格式美观，并且支持二重搜索或实时执行的插件是非常容易的，你可以随意添加自己需要的功能。
这也是 RunZ 的主要特点——容易扩展的体现。

## 其他功能

新增了数个实用功能，如查看磁盘空间：

![查看磁盘空间](Images/disk.png)

此外，新增的功能还有支持开机自启动、支持按 Esc 清空输入内容等，新增的插件有查询汇率、URL 编码等，这里不一一列举，期待能给大家带来更多方便。
