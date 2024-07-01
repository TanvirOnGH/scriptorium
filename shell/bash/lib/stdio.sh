#!/bin/sh
# shellcheck disable=SC2154
# shellcheck shell=sh # Written to be posix compatible

# Simplified Assertion
die() {
	println "Error $1: $2!" 1>&2
	exit "$1"
}

unimplemented() {
	die 1 "Unimplemented"
}

print() {
	printf "%s" "$@"
}

println() {
	printf "%s\\n" "$@"
}

write_to_file() {
	println "$1" >>"$2"
}

copy() {
	if [ "$debug" = "true" ]; then
		cp -rv "$1" "$2"
	else
		cp -r "$1" "$2"
	fi
}

time_and_date() {
	date "+%d-%m-%Y %I:%M:%S %p"
}
