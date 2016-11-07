#!/bin/bash
set -e

# find term-tools directory
if [ "$BASH_VERSION" ]; then
	export TERM_TOOLS_DIR="$(builtin cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd)"
elif [ "$ZSH_VERSION" ]; then
	export TERM_TOOLS_DIR="$(builtin cd "$( dirname "${(%):-%N}" )/.." && pwd)"
fi
builtin cd "$TERM_TOOLS_DIR"

## tmux

if command -v tmux >/dev/null 2>&1 && [[ "$(tmux -V)" == "tmux 2.0" ]]; then
	echo "tmux 2.0: exists"
elif command -v apt-get >/dev/null 2>&1; then
	# ubuntu
	sudo apt-get install -y python-software-properties software-properties-common
	sudo add-apt-repository -y ppa:pi-rho/dev
	sudo apt-get update
	#sudo apt-get install -y tmux=1.9a-1~ppa1~t
	sudo apt-get remove -y tmux
	sudo apt-get install -y tmux xclip
elif command -v brew >/dev/null 2>&1; then
	# homebrew
	brew install tmux
elif command -v /opt/local/bin/port >/dev/null 2>&1; then
	# macport
	sudo port install tmux
else
	echo "ERROR: tmux 2.0 is not installed"
	exit 1
fi

tmux -V
ln $@ -sn "$TERM_TOOLS_DIR/config/tmux.conf" ~/.tmux.conf

### teamocil
#
#if command -v teamocil >/dev/null 2>&1; then
#	echo "teamocil: exists"
#elif command -v gem >/dev/null 2>&1; then
#	sudo gem install teamocil
#elif command -v apt-get >/dev/null 2>&1; then
#
#	sudo apt-get install -y base-files
#	source /etc/os-release
#	if [[ ${VERSION%%.*} -ge 14 ]]; then
#		# Ubuntu 14.04
#		sudo apt-get install -y ruby
#	else
#		# Ubuntu 12.04
#		sudo apt-get install -y ruby1.9.3 rubygems
#	fi
#
#	sudo gem install teamocil
#else
#	echo "ERROR: rubygems is not installed"
#	exit 1
#fi
