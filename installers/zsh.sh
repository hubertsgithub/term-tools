#!/bin/bash

# tmp file for this script
ZSHRC_TMP=~/term-tools/zshrc.tmp

if command -v zsh >/dev/null 2>&1; then
	echo "zsh: exists"
elif command -v apt-get >/dev/null 2>&1; then
	# ubuntu
	sudo apt-get install -y zsh
elif command -v /opt/local/bin/port >/dev/null 2>&1; then
	# macport
	sudo port install zsh
else
	echo "ERROR: git is not installed"
	exit 1
fi

if [ ! -d ~/.oh-my-zsh ]; then
	wget --no-check-certificate http://install.ohmyz.sh -O - | sh
fi

if [ -s /etc/zsh/zshrc ]; then
	# This fixes the  up arrow key for ZSH default config.  The default is to
	# have the cursor go to th END of the line, but Ubuntu has overwritten this
	# ZSH default to go to the beginning of the line.  I think that's stupid,
	# so I'm reverting back to the default behavior
	sed -e 's/vi-up-line-or-history/up-line-or-history/g' -e 's/vi-down-line-or-history/down-line-or-history/' /etc/zsh/zshrc > $ZSHRC_TMP
	sudo mv $ZSHRC_TMP /etc/zsh/zshrc
fi

# install oh-my-zsh config if it exists
if [ -d ~/.oh-my-zsh ]; then
	cd ~/.oh-my-zsh

	ln $@ -s ~/term-tools/oh-my-zsh-custom/zsh-syntax-highlighting plugins/zsh-syntax-highlighting
	ln $@ -s ~/term-tools/config/sbell.zsh-theme themes/sbell.zsh-theme
	ln $@ -s ~/term-tools/config/sbell-screen.zsh-theme themes/sbell-screen.zsh-theme

	cd -

	# set theme and add syntax plugin
	sed -e 's/^ZSH_THEME=.*$/if [[ $TERM == "screen-256color" ]]; then ZSH_THEME="sbell-screen" else ZSH_THEME="sbell" fi/' \
		-e 's/^plugins=(\(.*\))/plugins=(\1 zsh-syntax-highlighting)/' \
		-e 's/zsh-syntax-highlighting zsh-syntax-highlighting/zsh-syntax-highlighting/' \
		~/.zshrc > $ZSHRC_TMP

	mv -f $ZSHRC_TMP ~/.zshrc
else
	echo "ERROR: ~/.oh-my-zsh does not exist"
	exit 1
fi

for f in ~/.zshrc ~/.bashrc; do
	if [[ -s $f ]]; then
		if [[ $(grep -c 'source ~/term-tools/config/shrc.sh' $f) == "0" ]]; then
			echo '[[ -s ~/term-tools/config/shrc.sh ]] && source ~/term-tools/config/shrc.sh' >> $f
		fi
		if [[ $(grep -c 'source ~/term-tools/config/shrc-tmux.sh' $f) == "0" ]]; then
			echo '' >> $f
			echo '# This line starts all new shells inside tmux (if tmux is installed and set up).' >> $f
			echo '# It must be the last command in this file.' >> $f
			echo '[[ -s ~/term-tools/config/shrc-tmux.sh ]] && source ~/term-tools/config/shrc-tmux.sh' >> $f
		fi
	fi
done

# change default shell
# If we don't have apt-get we are on mac...
if [[ "$(uname)" == "Linux" ]]; then
	sudo chsh $USER -s /bin/zsh
elif [[ "$(uname)" == "Darwin" ]]; then
	sudo chsh -s /bin/zsh $USER
else
	echo "ERROR: Unexpected OS!"
	exit 1
fi
