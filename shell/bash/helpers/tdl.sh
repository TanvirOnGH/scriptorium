#!/bin/sh

# <https://github.com/iyear/tdl>

# Recommended
export TDL_NS=tg

# -d /dir/path
# -u <single-link>
# --desc

if [ "$1" = "ls" ]; then
	tdl chat ls
else
	BASE_COMMAND="tdl chat export -c $1"

	# index: start,end
	if [ -n "$2" ] && [ -n "$3" ]; then
		COMMAND="$BASE_COMMAND -T id -i $2,$3"
	else
		COMMAND="$BASE_COMMAND"
	fi

	$COMMAND
fi

tdl dl -f tdl-export.json --takeout --continue --skip-same --reconnect-timeout 0 -t 8 -l 4
