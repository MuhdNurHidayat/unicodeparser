#!/bin/bash
_input=` zenity --entry --text '保持 Minetest 处于输入界面并在此输入内容：' --title 'Minetest 输入辅助工具' ` #用户输入
if [ -n "$_input" ]; then
	_input=".uc `( ( echo -nE $_input) | iconv -t utf-16LE) | busybox hexdump -v -e '/2 "\u%04x"' `" #转换成16进制
	sleep 0.25
	#echo $_input2
	xdotool key --clearmodifiers t type --clearmodifiers "$_input" #输出到Minetest 
	xdotool key --clearmodifiers Return #发送
fi
