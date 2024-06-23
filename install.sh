#!/bin/sh
set -e

FLAVOR="_sqlite"

usage() {
	this=$1
	cat <<EOF
$this: download Ory software using bash

Usage: $this [-b] bindir [-d] <project> [<tag>]

  <project> (required)
    Can be one of:
      - keto - downloads Ory Keto
      - kratos - downloads Ory Kratos
      - hydra - downloads Ory Hydra
      - oathkeeper - downloads Ory Oathkeeper
      - ory - downloads the Ory CLI

  -b sets bindir or installation directory, Defaults to ./bin
  -s downloads the static binary build without SQLite support
  -d turns on debug logging

   [<tag>] (optional)
     The release you wish to download. If left empty the latest version will be installed.

        $ bash <(curl -s https://raw.githubusercontent.com/ory/meta/master/install.sh) kratos v0.8.0-alpha.2

EOF
	exit 2
}

parse_args() {
	#BINDIR is ./bin unless set be ENV
	# over-ridden by flag below

	BINDIR=${BINDIR:-./bin}
	while getopts "b:dhs?x" arg; do
		case "$arg" in
		b) BINDIR="$OPTARG" ;;
		s) FLAVOR="" ;;
		d) log_set_priority 10 ;;
		h | \?) usage "$0" ;;
		x) set -x ;;
		esac
	done
	shift $((OPTIND - 1))

	[ -z "$1" ] && (echo "Please specify the project you want to download. Possible values are: keto, kratos, hydra, oathkeeper, ory." && exit 1)
	TAG=$2

	case "$1" in

	ory)
		REPO="cli"
		BINARY=cowk8s
		PROJECT_NAME=cowk8s
		;;

	*)
		echo "The project you specified is unknown. Please choose one of \"ory\""
		exit 1
		;;
	esac
}
# this function wraps all the destructive operations
# if a curl|bash cuts off the end of the script due to
# network, either nothing will happen or will syntax error
# out preventing half-done work
execute() {
	tmpdir=$(mktemp -d)

	rm -rf "${tmpdir}"
}