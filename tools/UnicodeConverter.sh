#!/bin/bash
_T=120
_t=100
_d=12
_mode=1
_key=t
_verinfo="UnicodeConverter.sh"
_help=\
"Usage: $0 [OPTION]
UnicodeConverter.sh is a script to help to input text to Minetest unicodeparser CSM.

option:
 -T DELAY   set the delay(ms) (default is $_T) from inputting to beginning to output
 -t DELAY   (only in mode 1 or 2) set the delay(ms) (default is $_t) between keystrokes
 -d DELAY   (only in mode 2) set the delay(ms) (default is $_d) between typing chars
 -m MODE    set the mode (default is $_mode) of this script, 1 or 2 or 3 or 4:
               1    use clipboard and ctrl+v  
                    (There is a bug in Minetest's paste, which is why the mode use two ctrl+v
		    but not normally one, so this way may be not available in your environment.
		    I tested it only in my computer, but in my computer mode 1 is the best mode)
               2    type chars of the transformed text one-by-one automatically
               3    only copy the transformed text to clipboard
               4    only print the transformed text
 -s TEXT    TEXT will be transformed. If use this option, the input box will not be used
 -k KEY     set key (default is $_key) for chatting set in Minetest, as the xdotool form.
 -h         display this help and exit
 -v         output version info and exit

Exit status:
 0 if OK,
 1 if there was error

$_verinfo
"
_text=""
_s=0
while getopts "T:t:d:m:s:k:h" opt;
do
	case $opt in
		T) _T="$OPTARG" ;;
		t) _t="$OPTARG" ;;
		d) _d="$OPTARG" ;;
		m) _mode="$OPTARG" ;;
		s) _text="$OPTARG";_s=1 ;;
		k) _key="$OPTARG" ;;
		h) echo "$_help" ;exit 0 ;;
		v) echo "$_verinfo" ;exit 0 ;;
		\?) echo "$_help" >&2 ;exit 1 ;;
	esac
done
as_delay() {
	if [ -n "`echo -En "$1" | sed 's/[0-9]//g'`" -o -z "$1" ] ;then
		echo "$1" is not a vaild delay. >&2
		exit 1
	fi
}
as_delay $_T
as_delay $_t
as_delay $_d
if [ "$_mode" != "1" -a "$_mode" != "2" -a "$_mode" != "3" -a "$_mode" != "4" ] ;then
	echo "$_mode" is not a vaild mode.
	exit 1
fi
if [ $_s = "0" ];then
	_text="`zenity --entry --text 'Input' --title 'Unicode Codepoint Converter'`"
fi
if [ -z "$_text" ];then
	exit 0
fi
_output=".uc `( ( echo -nE $_text) | iconv -t utf-16LE) | busybox hexdump -v -e '/2 "\u%04x"' `"
busybox usleep ${_T}000
case $_mode in
	1)
		_oldclip="`xclip -o -selection clipboard`"
		echo -nE "$_output" | xclip -i -selection clipboard
		xdotool key --clearmodifiers --delay $_t $_key ctrl+v ctrl+v Return 
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
