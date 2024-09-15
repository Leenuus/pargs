all: install

install:
	install ./pargs ~/.local/bin/pargs
	ln -s ~/.local/bin/pargs ~/.local/bin/xargs

uninstall:
	rm ~/.local/bin/pargs ~/.local/bin/xargs
