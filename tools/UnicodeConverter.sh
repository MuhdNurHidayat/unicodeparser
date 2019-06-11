#!/bin/bash
_verinfo="UnicodeConverter.sh 1.0
Copyright (C) 2019 Hagb and contributors
released under The MIT License"
_T=120
_t=100
_d=12
_mode=1
_key=t
_h=1
_help=\
"Usage: $0 [OPTION]
UnicodeConverter.sh is a script to help to input text to Minetest unicodeparser CSM.

option:
 -T DELAY   set the DELAY(ms) (default is $_T) from inputting to beginning to outputi.
 -t DELAY   (only in MODE 1, 1.5 and 2) set the DELAY(ms) (default is $_t) between keystrokes.
 -d DELAY   (only in MODE 2) set the DELAY(ms) (default is $_d) between typing chars.
 -m MODE    set the MODE (default is $_mode) of this script, 1 or 1.5 or 2 or 3 or 4:
               1    use clipboard and two ctrl+v.
                    There may be a bug in paste, which is why this default MODE use two ctrl+v but not normally one.
                    MODE 1 has been tested in Minetest 0.4.17.1, in which the mode worked well but MODE 1.5 not.
                    Please try this MODE first and then if abnormal, try MODE 1.5
               1.5  use clipboard and ctrl+v (use normally one ctrl+v).
               2    type chars of the transformed text one-by-one automatically and dont't use ctrl+v.
               3    only copy the transformed text to clipboard.
               4    only print the transformed text.
 -H HOW     (only in MODE 1, 1.5 and/or 2) tell script how you use this script.
            HOW (default is $_h) is 1 (if you use script when in game interface, use 1) or 2 (if you use script when in chat interface, use 2).
 -s TEXT    TEXT will be transformed. When this option is used, the input box will not be used.
 -k KEY     (only in HOW 1 and at the same time MODE 1, 1.5 or 2) set key (default is $_key) for chatting set in Minetest.
            The key code should be in the xdotool form.
 -h         display this help and exit.
 -v         output version info and exit.

DEPENDS:
 bash
 busybox
 xclip (depended by MODE 1, 1.5 and/or 3)
 xdotool (MODE 1 to 2)

Exit status:
 0 if OK,
 1 if there was error

$_verinfo
"
_text=""
_s=0

## Get options
while getopts "T:t:d:m:H:s:k:hv" opt;
do
	case $opt in
		T) _T="$OPTARG" ;;
		t) _t="$OPTARG" ;;
		d) _d="$OPTARG" ;;
		m) _mode="$OPTARG" ;;
		H) _h="$OPTARG" ;;
		s) _text="$OPTARG";_s=1 ;;
		k) _key="$OPTARG" ;;
		h) echo "$_help" ;exit 0 ;;
		v) echo "$_verinfo" ;exit 0 ;;
		\?) echo "$_help" >&2 ;exit 1 ;;
	esac
done

## Check options
as_delay() {
	if [ -n "`echo -En "$1" | sed 's/[0-9]//g'`" -o -z "$1" ] ;then
		echo -E "$1" is not a vaild DELAY. >&2
		echo -E "$_help" >&2
		exit 1
	fi
}
as_delay $_T
as_delay $_t
as_delay $_d
if [ "$_mode" != "1" -a "$_mode" != "1.5" -a "$_mode" != "2" -a "$_mode" != "3" -a "$_mode" != "4" ] ;then
	echo -E "$_mode" is not a vaild MODE. >&2
	echo -E "$_help" >&2
	exit 1
fi
if [ "$_h" != "1" -a "$_h" != "2" ] ;then
	echo -E "$_h" is not a vaild HOW value. >&2
	echo -E "$_help" >&2
	exit 1
fi

## Do what should be done
if [ "$_h" == 2 ];then _key=""; fi
### If -s option isn't used, then use an input box to get text
if [ $_s = "0" ];then _text="`zenity --entry --text 'Input' --title 'Unicode Codepoint Converter'`"; fi
### If text is null, then stop
if [ -z "$_text" ];then exit 0; fi
### Transform from original text
_output=".uc `( ( echo -nE $_text) | iconv -t utf-16LE) | busybox hexdump -v -e '/2 "\u%04x"' `"
### Delay (about -T option)
busybox usleep ${_T}000
### Output text transformed
case $_mode in
	1)
		#### Backup clipboard
		_oldclip="`xclip -o -selection clipboard`"
		#### Push text transformed to clipboard
		echo -nE "$_output" | xclip -i -selection clipboard
		#### Send keystrokes
		xdotool key --clearmodifiers --delay $_t $_key ctrl+v ctrl+v Return 
		#### Restore clipboard
		echo -nE "$_oldclip" | xclip -i -selection clipboard
	;;
	1.5)
		_oldclip="`xclip -o -selection clipboard`"
		echo -nE "$_output" | xclip -i -selection clipboard
		xdotool key --clearmodifiers --delay $_t $_key ctrl+v Return
		echo -nE "$_oldclip" | xclip -i -selection clipboard
	;;
	2)
		xdotool key --clearmodifiers $_key
		busybox usleep ${_t}000
		xdotool type --clearmodifiers "$_output"
		busybox usleep ${_t}000
		xdotool key --clearmodifiers Return
	;;
	3)
		_oldclip="`xclip -o -selection clipboard`"
		echo -nE "$_output" | xclip -i -selection clipboard
	;;
	4)
		echo -E "$_output"
	;;
esac
