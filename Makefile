D=~/dev/dotfiles

install_bash:
	ln -sf $D/bashrc.local ~/.bashrc.local

install_vim:
	ln -sf $D/vimrc ~/.vimrc
	rm ~/.vim
	ln -sf $D/vim ~/.vim

install_misc:
	ln -sf $D/gitconfig ~/.gitconfig
	ln -sf $D/screenrc ~/.screenrc
	ln -sf $D/tmux.conf ~/.tmux.conf

install_bin:
	cp -av bin ~/bin
	curl http://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
	chmod +x ~/bin/repo

install_fonts:
	cp -av fonts ~/.fonts
	fc-cache -f

install_udev:
	sudo cp -av rules.d /lib/udev/rules.d/

install_xorg:
	sudo cp -av xorg.conf.d /usr/share/X11/xorg.conf.d/

install_sysctl:
	sudo cp -av sysctl.d /etc/sysctl.d/

install_powerline:
	sudo apt install python3-powerline powerline
	systemctl --user enable powerline-daemon
	systemctl --user start powerline-daemon

install: install_bash install_vim install_misc install_bin install_fonts install_udev install_xorg install_sysctl install_powerline
