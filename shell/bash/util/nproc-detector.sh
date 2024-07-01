#!/bin/sh
# shellcheck shell=sh # Written to be posix compatible

# Detect the total number of cpu cores/threads. Returns 1 when fails.
detect_nproc() {

	case "$(nproc)" in
	[1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9]) procNum="$(nproc)" EXPORT procNum EXIT ;;
	*)
		case "$LANG" in
		en-* | *) die 5 "Command 'nproc' does not return an expected value on this system, setting the processor count on '1' which will negatively affect performance on systems with more then one thread" ;;
		esac

		export procNum="1"
		;;
	esac

}
